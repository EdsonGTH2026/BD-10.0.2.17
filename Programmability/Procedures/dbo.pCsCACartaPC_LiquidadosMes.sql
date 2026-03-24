SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACartaPC_LiquidadosMes] @fecha smalldatetime,@codpromotor varchar(15),@codoficina varchar(4)
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
print '################################### Liquidado en Mes ##############################################'
print '###################################################################################################'
--###################################################

/* Liquidado en el mes */
create table #cnu(codprestamo varchar(25),codusuario varchar(15))
insert into #cnu
Select p.codprestamo,p.codusuario
from tcspadroncarteradet p with(nolock)
where p.desembolso>=@fecini--'20180501' 
and p.desembolso<=@fecha--'20180515'
and p.primerasesor=@codpromotor--'CGM891025M5RR3'
and p.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

/*
--COMENTAR
Select count(p.codprestamo) nroliqui,count(n.codprestamo) nroreno, round((count(n.codprestamo)/cast(count(p.codprestamo) as decimal(8,2)))*100,2) PorReno
from tcspadroncarteradet p with(nolock)
left outer join #cnu n with(nolock) on n.codusuario=p.codusuario
where p.cancelacion>=@fecini--'20180501'
and p.cancelacion<=@fecha--'20180515'
and p.primerasesor=@codpromotor--'CGM891025M5RR3'
*/

--OSC
delete from tCsRptEMIPC_LiquidadosMes where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_LiquidadosMes (Fecha, CodPromotor, CodOficina, Tipo, nroliqui, nroreno, PorReno )   
Select 
@fecha, @codpromotor, @codoficina, 'LIQUIDADOS MES',
count(p.codprestamo) as nroliqui,count(n.codprestamo) as nroreno, round((count(n.codprestamo)/cast(count(p.codprestamo) as decimal(8,2)))*100,2) as PorReno
from tcspadroncarteradet p with(nolock)
left outer join #cnu n with(nolock) on n.codusuario=p.codusuario
where p.cancelacion>=@fecini
and p.cancelacion<=@fecha
and p.primerasesor=@codpromotor
and p.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

drop table #cnu
--regresa los resultados
--select * from tCsRptEMIPC_LiquidadosMes where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina



GO