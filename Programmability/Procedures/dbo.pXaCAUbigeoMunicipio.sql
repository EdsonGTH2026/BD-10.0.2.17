SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaCAUbigeoMunicipio] @codarbol varchar(13)
as
	select codarbolconta,descubigeo
	from tclubigeo with(nolock)
	where codubigeotipo='MUNI' and codarbolconta like @codarbol+'%'--'R000001000002%'
GO