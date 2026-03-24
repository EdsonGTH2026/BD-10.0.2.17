SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsConsultaEval] @fecini smalldatetime ,@fecfin smalldatetime   
as    
set nocount on 

--declare @fecini smalldatetime; 
--set @fecini='20230801'--- fecha inicial

--declare @fecfin smalldatetime; 
--set @fecfin='20230810'--- fecha inicial

exec [10.0.2.14].[finmas].[dbo].[pCsCAEvalvs2] @fecini,@fecfin
GO

GRANT EXECUTE ON [dbo].[pCsConsultaEval] TO [rie_jaguilar]
GO

GRANT EXECUTE ON [dbo].[pCsConsultaEval] TO [rie_ldomingueze]
GO

GRANT EXECUTE ON [dbo].[pCsConsultaEval] TO [rie_jalvarezc]
GO