SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaCAUbigeoEstado]
as
	select codarbolconta,descubigeo
	from tclubigeo with(nolock)
	where codubigeotipo='ESTA'
GO