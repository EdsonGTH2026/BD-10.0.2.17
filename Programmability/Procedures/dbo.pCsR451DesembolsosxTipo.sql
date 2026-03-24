SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsR451DesembolsosxTipo]  @fecini smalldatetime,@fecfin smalldatetime      
as    
set nocount on    
  
--declare @fecfin smalldatetime  
--declare @fecini smalldatetime  
  
--set @fecini='20241101'  
--set @fecfin='20241130'  
  
  
EXEC [10.0.2.14].[finmas].dbo.pCsR451ColocacionxTipo @fecini,@fecfin 
GO

GRANT EXECUTE ON [dbo].[pCsR451DesembolsosxTipo] TO [rie_jalvarezc]
GO