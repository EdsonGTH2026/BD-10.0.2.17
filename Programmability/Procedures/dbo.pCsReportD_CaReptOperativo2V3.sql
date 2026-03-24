SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[pCsReportD_CaReptOperativo2V3]
    @fecha smalldatetime -- Parámetro para la fecha de corte
AS
BEGIN
    SET NOCOUNT ON;

 --declare @fecha smalldatetime  ---LA FECHA DE CORTE  
 --select @fecha=fechaconsolidacion from vcsfechaconsolidacion


----declare @fecini smalldatetime
----set @fecini =cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime) 
declare @fecante smalldatetime
----set @fecante= DATEADD(MONTH, -1, @fecha)      -----Mismo dia del mes anterior
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1     ---- Ultimo día del mes anterior
----select @fecante

/* TABLA1. ESTADO DE RESULTADOS OPERATIVOS*/
select fecha,periodo,EPRC, --EPRC_0_119, EPRC_120
       EPRC_New,EPRC_0, EPRC_1_7, EPRC_8_15, EPRC_16_21, EPRC_22_30, EPRC_31_60, EPRC_61_90, EPRC_91_120, EPRC_121_150, EPRC_151_180
from FNMGConsolidado.dbo.tCaReporteDiarioEPRC with(nolock)  where (fecha=@fecha or fecha=@fecante) and Tipo='Total'
--union
--select @fecha as fecha,'PLAN' as periodo,EPRC, EPRC_0_119, EPRC_120
--from FNMGConsolidado.dbo.tCaProyeccionxPeriodoV2 with(nolock)
--where periodo=dbo.fdufechaaperiodo(@fecha)

--select * from FNMGConsolidado.dbo.tCaReporteDiarioEPRC with(nolock) 

--tCaReporteDiarioEPRC FNMGConsolidado.dbo.tCaReporteDiarioEPRC with(nolock)
						
END
GO