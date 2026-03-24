SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAPLDClivsCtas]
as
	select * from tCsAPLDClivsCtas with(nolock)
GO