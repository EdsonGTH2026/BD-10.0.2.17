SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsReportD_CaImorxRango] @fecha smalldatetime    
as    
BEGIN

set nocount on  
--declare @fecha smalldatetime
--set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)

select fecha,rango,imor31,imor31_170,imor31_370
  from FNMGConsolidado.dbo.tCaPromedioSaldo
  where fecha=@fecha

END
GO