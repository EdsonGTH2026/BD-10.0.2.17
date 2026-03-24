SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCACartaLN_ColocacionMes] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on
/*
--COMENTAR
Declare @fecha smalldatetime
declare @codoficina varchar(4)

set @fecha='20180515'
set @codoficina='37'
*/

Declare @fecini smalldatetime
Declare @fecini2 smalldatetime
Declare @fecano smalldatetime

declare @ncreBM decimal(8,2)
declare @ncreAM decimal(8,2)

set @fecha = convert(varchar,@fecha,112)
set @fecini = dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'
set @fecano = dbo.fdufechaatexto(dateadd(year,-1,@fecha),'AAAAMM')+'01'

set @fecini2 = dateadd(day,-1,@fecini)

--########################################################### COLOCACION MES
PRINT '######################################################################'
PRINT '##################### COLOCACION MES #################################'
--Colocación del mes:
--declare @nivel int
--set @nivel=4 --comentar
create table #CADe(
	codprestamo varchar(25),
	codusuario varchar(15),
	monto money,
	fecult smalldatetime,
	codasesor varchar(15),
saldo money
)
insert into #CADe (codprestamo,codusuario,monto,fecult)
select p.codprestamo,p.codusuario,p.monto,max(a.desembolso) fecha
from tcspadroncarteradet p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and p.desembolso>a.desembolso
where 
--p.primerasesor=@codpromotor--'CGM891025M5RR3'
p.codoficina = @codoficina 
and p.desembolso>=@fecini--'20180501' 
and p.desembolso<=@fecha--'20180515'
and p.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
group by p.codprestamo,p.codusuario,p.monto

--select d.codprestamo,p.primerasesor
update #CADe
set codasesor = p.primerasesor
from #CADe d inner join tcspadroncarteradet p with(nolock) on p.codusuario=d.codusuario and p.desembolso=d.fecult
where 
--p.primerasesor<>@codpromotor--'CGM891025M5RR3'
p.codoficina = @codoficina 

--Actualiza saldo
update #CADe set
saldo = isnull((select saldocapital+((interesvigente+interesvencido)*1.16) 
                from tcscarteradet where Fecha = @fecha and codprestamo = #CADe.codprestamo), #CADe.monto)

declare @RenoNro int
declare @RenoSal money
declare @RenoSal2 money
declare @CliPropios int
select @RenoNro=count(case when codasesor is not null then codprestamo else null end) --Hnro
,@RenoSal=sum(case when codasesor is not null then monto else 0 end) --Hmonto
,@CliPropios= count(codprestamo)-count(case when codasesor is not null then codprestamo else null end)
,@RenoSal2=sum(case when codasesor is not null then saldo else 0 end) --Hmonto
from #CADe

--select @RenoNro '@RenoNro',@RenoSal '@RenoSal',@CliPropios '@CliPropios'
Declare @nronuevo int
select @nronuevo=count(case when fecult is null then codprestamo else null end) --Nnro
--,isnull(sum(case when fecult is null then monto else 0 end),0) Nmonto 
from #CADe where fecult is null

--limipa la tabla final
delete from tCsRptEMI_LS_ColocacionMes where Fecha = convert(varchar,@fecha,112) and CodOficina = @codoficina
--Inserta en la tabla final
insert into tCsRptEMI_LS_ColocacionMes (Fecha, CodOficina, Tnro, Tmonto, Rnro, Rmonto, Nnro, Nmonto, Hnro, Hmonto )

select --'ColocacionMes',
convert(varchar,@fecha,112), @codoficina,
count(codprestamo) Tnro
,sum(monto) Tmonto
,count(case when fecult is not null then codprestamo else null end) Rnro
,sum(case when fecult is not null then monto else 0 end) Rmonto
,count(case when fecult is null then codprestamo else null end) Nnro
,sum(case when fecult is null then monto else 0 end) Nmonto
,count(case when codasesor is not null then codprestamo else null end) Hnro
,sum(case when codasesor is not null then monto else 0 end) Hmonto
from #CADe

---->AGREGAR A LA TABLA QUE MOSTRARA EL REPORTE
drop table #CADe
--Regresa los datos
--select * from tCsRptEMI_LS_ColocacionMes where Fecha = convert(varchar,@fecha,112) and CodOficina = @codoficina


GO