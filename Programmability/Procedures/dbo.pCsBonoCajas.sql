SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE procedure [dbo].[pCsBonoCajas] 
@periodo as varchar(6)
as

exec [10.0.2.14].Finmas.dbo.pCsBonoCajas @periodo

GO