SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXBitDictamen] 
as
BEGIN
	exec [10.0.2.14].Finmas.dbo.pCaXBitDictamen 
END
GO