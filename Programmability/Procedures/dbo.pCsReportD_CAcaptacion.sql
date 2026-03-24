SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsReportD_CAcaptacion] @fecha smalldatetime    
as    
BEGIN

set nocount on  
--declare @fecha smalldatetime
--set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)

select fecha,saldoDPF_Fin,saldoDPF_Ini,saldoVista_Fin,saldoVista_Ini,saldoGarantia_Fin,saldoGarantia_Ini,Captacion_Fin
,Captacion_Ini,PlazoFijo_tasaAnual,Cartera_tasaAnual

from FNMGConsolidado.dbo.tCaReporteDiario
where fecha=@fecha


END
GO