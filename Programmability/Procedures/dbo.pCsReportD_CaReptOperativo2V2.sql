SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[pCsReportD_CaReptOperativo2V2]
    @fecha smalldatetime -- Parámetro para la fecha de corte
AS
BEGIN
    SET NOCOUNT ON;

 --declare @fecha smalldatetime  ---LA FECHA DE CORTE  
 --select @fecha=fechaconsolidacion from vcsfechaconsolidacion


declare @fecini smalldatetime
set @fecini =cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime) 
declare @fecante smalldatetime
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1 

/* TABLA1. ESTADO DE RESULTADOS OPERATIVOS*/
select fecha,periodo,EPRC, EPRC_0_119, EPRC_120
from FNMGConsolidado.dbo.tCaReporteDiarioEPRC  where fecha=@fecha or fecha=@fecante
--union
--select @fecha as fecha,'PLAN' as periodo,EPRC, EPRC_0_119, EPRC_120
--from FNMGConsolidado.dbo.tCaProyeccionxPeriodoV2 with(nolock)
--where periodo=dbo.fdufechaaperiodo(@fecha)




						
END
GO