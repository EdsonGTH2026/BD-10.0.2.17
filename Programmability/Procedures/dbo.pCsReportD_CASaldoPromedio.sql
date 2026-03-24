SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsReportD_CASaldoPromedio] @fecha smalldatetime    
as    
BEGIN

set nocount on  
--declare @fecha smalldatetime
--set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)

select fecha,rango,categoria,saldoCtera,ptmosCtera,promSaldo_Ctera
,saldo170,nroPtmos170,promSaldo_170,saldo370,nroPtmos370,promSaldo_370--,imor31,imor31_170,imor31_370
from FNMGConsolidado.dbo.tCaPromedioSaldo
where fecha=@fecha


END
GO