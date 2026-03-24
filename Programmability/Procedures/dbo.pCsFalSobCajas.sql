SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsFalSobCajas] @fecini smalldatetime,@fecfin smalldatetime
as
	exec [10.0.2.14].finmas.dbo.pCsFalSobCajas @fecini,@fecfin
GO