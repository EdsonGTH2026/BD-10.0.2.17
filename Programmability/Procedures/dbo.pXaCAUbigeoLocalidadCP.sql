SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCAUbigeoLocalidadCP] @codpostal varchar(5)
as
	select codubigeo,descubigeo
	from tclubigeo with(nolock)
	--where codubigeotipo='COLO' and codarbolconta like 'R000001000002000002%' and descubigeo like '%DEL%'
	--where codubigeotipo='COLO' and codarbolconta like @codarbol+'%' and descubigeo like '%'+@filtro+'%'
	where codubigeotipo='COLO' and campo1 like @codpostal--'01090'
GO