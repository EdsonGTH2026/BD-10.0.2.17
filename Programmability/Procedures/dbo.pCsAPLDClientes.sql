SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAPLDClientes]
as
	select * from tCsAPLDClientes with(nolock)
GO