SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* TABLA1. ESTADO DE RESULTADOS OPERATIVOS*/

Create Procedure [dbo].[pCsCaReporteDiarioT1]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'
declare @fecante smalldatetime
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1

 select fecha,periodo,InteDevengado,GastoxInteres,EPRC
,MargenAjustado,Co_CobradaPagada,seguros,pagoTardio,OtrosIngresos
,co_ctasDigital,co_bancarias,GastoEstimado,NominaCentral,NominaRed,Gastos,Otros,ResultadoOp
into #base1
from FNMGConsolidado.dbo.tCaReporteDiario
where fecha=@fecha or fecha=@fecante
union
select @fecha as fecha,'PLAN' as periodo,InteDevengado,GastoxInte,EPRC
,MargenAjustado,Co_CobradaPagada,seguros,pagoTardio,OtrosIngresos
,co_ctasDigital,co_bancarias,GastoEstimado,NominaCentral,NominaRed,Gastos,Otros,ResultadoOp
from FNMGConsolidado.dbo.tCaProyeccionxPeriodo with(nolock)
where periodo=dbo.fdufechaaperiodo(@fecha)


select fecha,periodo,'1. INTERES DEVENGADO' CATEGORIA,intedevengado valor from #base1 union
select fecha,periodo,'2. GASTO POR INTERES' CATEGORIA,GastoxInteres valor from #base1 union
select fecha,periodo,'3. EPRC' CATEGORIA,EPRC valor from #base1 union
select fecha,periodo,'4. MARGEN AJUSTADO' CATEGORIA,MargenAjustado valor from #base1 union
select fecha,periodo,'5. COMISION COBRADAS Y PAGADAS' CATEGORIA,Co_CobradaPagada valor from #base1 union
select fecha,periodo,'5.1 SEGUROS' CATEGORIA,seguros valor from #base1 union
select fecha,periodo,'5.2 PAGO TARDIO' CATEGORIA,pagoTardio valor from #base1 union
select fecha,periodo,'5.3 OTROS INGRESOS(EGRESOS) DE LA OPERACIÓN' CATEGORIA,OtrosIngresos valor from #base1 union
select fecha,periodo,'5.4 COMISIONES CTAS DIGITAL' CATEGORIA,co_ctasDigital valor from #base1 union 
select fecha,periodo,'5.5 COMISIONES BANCARIAS' CATEGORIA,co_bancarias valor from #base1 union
select fecha,periodo,'6. GASTO(ESTIMADO)' CATEGORIA,GastoEstimado valor from #base1 union
select fecha,periodo,'6.1 NÓMINA CENTRAL' CATEGORIA,NominaCentral valor from #base1 union
select fecha,periodo,'6.2 NÓMINA RED' CATEGORIA,NominaRed valor from #base1 union
select fecha,periodo,'6.3 GASTOS' CATEGORIA,Gastos valor from #base1 union
select fecha,periodo,'6.4 OTROS(INGRESOS/EGRESOS) DE LA OPERACIÓN' CATEGORIA,Otros valor from #base1 union
select fecha,periodo,'7. RESULTADO OPERATIVO' CATEGORIA,ResultadoOp valor from #base1


drop table #base1
GO