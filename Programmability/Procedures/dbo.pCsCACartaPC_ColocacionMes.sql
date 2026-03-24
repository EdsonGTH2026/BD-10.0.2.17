SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACartaPC_ColocacionMes] @fecha smalldatetime,@codpromotor varchar(15),@codoficina varchar(4)
as
set nocount on

--COMENTAR
/*
Declare @fecha smalldatetime
declare @codpromotor varchar(15)
declare @codoficina varchar(4)

set @fecha='20180515'
set @codpromotor='CGM891025M5RR3'
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

print '###################################################################################################'
print '######################################### Colocacion Mes ##########################################'
print '###################################################################################################'

--################################################

declare @nivel int
select @nivel = Nivel from tCsRptEMIPC_Promotor where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina

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
where p.primerasesor=@codpromotor--'CGM891025M5RR3'
and p.desembolso>=@fecini--'20180501' 
and p.desembolso<=@fecha--'20180515'
and p.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
group by p.codprestamo,p.codusuario,p.monto

--select d.codprestamo,p.primerasesor
update #CADe
set codasesor = p.primerasesor
from #CADe d inner join tcspadroncarteradet p with(nolock) on p.codusuario=d.codusuario and p.desembolso=d.fecult
where p.primerasesor<>@codpromotor--'CGM891025M5RR3'

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

declare @MetaNuevoCre varchar(50)
declare @MetaPorBono money
set @MetaNuevoCre = case when @nivel=1 then '8 créditos'
						when @nivel=2 then '4 créditos'
						when @nivel=3 then 'Sin meta'
						when @nivel=4 then 'Sin meta'
						else 'REVISAR' end
set @MetaPorBono = case when @nivel=1 then 
								case when @nronuevo<5 then 0
									 when @nronuevo>=5 and @nronuevo<8 then 50
									 else 100 end
						when @nivel=2 then
								case when @nronuevo<2 then 0
									 when @nronuevo>=2 and @nronuevo<4 then 50
									 else 100 end
						when @nivel=3 then 0
						when @nivel=4 then 0
						else -1 end

/*
--COMETAR
select 'Colocacion',
count(codprestamo) Tnro
,sum(monto) Tmonto
,count(case when fecult is not null then codprestamo else null end) Rnro
,sum(case when fecult is not null then monto else 0 end) Rmonto
,count(case when fecult is null then codprestamo else null end) Nnro
,sum(case when fecult is null then monto else 0 end) Nmonto
,count(case when codasesor is not null then codprestamo else null end) Hnro
,sum(case when codasesor is not null then monto else 0 end) Hmonto
,@MetaNuevoCre 'meta',@MetaPorBono 'pormeta'
from #CADe
*/

--OSC
delete from tCsRptEMIPC_ColocacionMes where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_ColocacionMes (Fecha, CodPromotor, CodOficina, Tipo, Tnro, Tmonto, Rnro, Rmonto, Nnro, Nmonto, Hnro, Hmonto, meta, pormeta )
select 
	@fecha, @codpromotor, @codoficina,
	'Colocacion',
	count(codprestamo) Tnro
	,sum(monto) Tmonto
	,count(case when fecult is not null then codprestamo else null end) Rnro
	,sum(case when fecult is not null then monto else 0 end) Rmonto
	,count(case when fecult is null then codprestamo else null end) Nnro
	,sum(case when fecult is null then monto else 0 end) Nmonto
	,count(case when codasesor is not null then codprestamo else null end) Hnro
	,sum(case when codasesor is not null then monto else 0 end) Hmonto
	,@MetaNuevoCre 'meta',@MetaPorBono 'pormeta'
from #CADe

---->AGREGAR A LA TABLA QUE MOSTRARA EL REPORTE
drop table #CADe

--Regresa los datos
--select * from tCsRptEMIPC_ColocacionMes where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina


GO