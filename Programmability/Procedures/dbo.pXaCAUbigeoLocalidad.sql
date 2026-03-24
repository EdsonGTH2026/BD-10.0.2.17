SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCAUbigeoLocalidad] @codarbol varchar(19),@filtro varchar(100)
as
	select codubigeo,descubigeo
	from tclubigeo with(nolock)
	--where codubigeotipo='COLO' and codarbolconta like 'R000001000002000002%' and descubigeo like '%DEL%'
	where codubigeotipo='COLO' and codarbolconta like @codarbol+'%' and descubigeo like '%'+@filtro+'%'
GO