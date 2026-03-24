SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsReportD_CaReptOperativo] @fecha smalldatetime    
as    
BEGIN

set nocount on  
--declare @fecha smalldatetime
--set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)

--declare @fecante smalldatetime
--set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1 

/* TABLA1. ESTADO DE RESULTADOS OPERATIVOS*/

select  fecha fecha,periodo,InteDevengado,GastoxInteres ,EPRC
	,MargenAjustado,Co_CobradaPagada,seguros,pagoTardio,OtrosIngresos	
	,co_ctasDigital,co_bancarias,GastoEstimado,NominaCentral,NominaRed,Gastos,Otros,ResultadoOp
from FNMGConsolidado.dbo.tCaReporteDiario
where fecha=@fecha --or fecha=@fecante
union
select  @fecha as fechacorte,'PLAN' as periodo,InteDevengado,GastoxInte,EPRC
	,MargenAjustado,Co_CobradaPagada,seguros,pagoTardio,OtrosIngresos	
	,co_ctasDigital,co_bancarias,GastoEstimado,NominaCentral,NominaRed,Gastos,Otros,ResultadoOp
from FNMGConsolidado.dbo.tCaProyeccionxPeriodo with(nolock)
where periodo=dbo.fdufechaaperiodo(@fecha) 

END
GO