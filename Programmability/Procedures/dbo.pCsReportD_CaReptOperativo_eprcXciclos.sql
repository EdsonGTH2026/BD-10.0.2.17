SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[pCsReportD_CaReptOperativo_eprcXciclos]
    @fecha smalldatetime -- Parámetro para la fecha de corte
AS
BEGIN
    SET NOCOUNT ON;

 --declare @fecha smalldatetime  ---LA FECHA DE CORTE  
 --select @fecha=fechaconsolidacion from vcsfechaconsolidacion

 ---exec pcsFNMGReporteDiario_eprcXciclos '20250524'

--declare @fecini smalldatetime
--set @fecini =cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime) 
declare @fecante smalldatetime
----set @fecante= DATEADD(MONTH, -1, @fecha)   --- mismo dia del mes anterior
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1      ----- ultimo día del mes anterior
--select @fecante




/* TABLA1. ESTADO DE RESULTADOS OPERATIVOS*/
select fecha,periodo,EPRC --,EPRC_0_119, EPRC_120
       ,EPRC_C1, [EPRC_C2+]
--into #eprc_fecha
from FNMGConsolidado.dbo.tCaReporteDiarioEPRC_ciclos with(nolock)  where fecha=@fecha or fecha=@fecante


--select fecha,periodo,EPRC --,EPRC_0_119, EPRC_120
--       ,EPRC_C1, [EPRC_C2+]
--from FNMGConsolidado.dbo.tCaReporteDiarioEPRC_ciclos with(nolock)  

--where  fecha=@fecante


--drop table #eprc_fecha

--union
--select @fecha as fecha,'PLAN' as periodo,EPRC, EPRC_0_119, EPRC_120
--from FNMGConsolidado.dbo.tCaProyeccionxPeriodoV2 with(nolock)
--where periodo=dbo.fdufechaaperiodo(@fecha)

--select * from FNMGConsolidado.dbo.tCaReporteDiarioEPRC with(nolock) 

--tCaReporteDiarioEPRC FNMGConsolidado.dbo.tCaReporteDiarioEPRC with(nolock)
						
END
GO