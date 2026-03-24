SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 CREATE procedure [riglesiasa2].[pCaReportetCsAhorros]
 as 
 select * from tCsAhorros with(nolock)
GO