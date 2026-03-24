SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pXaCADestinoPadre]
as
	exec [10.0.2.14].finmas.dbo.pXaCADestinoPadre  --produccion
	--exec [10.0.2.14].finmas_20190315ini.dbo.pXaCADestinoPadre  --pruebas
GO