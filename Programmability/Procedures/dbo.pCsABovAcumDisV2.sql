SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----version 2 de tCsABovAcumDistribucion donde admite sucursales sin pagos.

CREATE procedure [dbo].[pCsABovAcumDisV2] @fecha smalldatetime  
as  
set nocount on  

--select * from tCsABovAcumDistribucion where fechapro='20231218'

--declare @fecha smalldatetime  
--set @fecha='20231218' 

exec [10.0.2.14].[Finmas].[dbo].[pCsABovAcumDistribucionPRE] @fecha
GO

GRANT EXECUTE ON [dbo].[pCsABovAcumDisV2] TO [mchavezs2]
GO

GRANT EXECUTE ON [dbo].[pCsABovAcumDisV2] TO [ope_lcoronas]
GO