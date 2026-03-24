SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaCAActividad]
as
	exec [10.0.2.14].finmas.dbo.pXaCAActividad --> Producción
	--exec [10.0.2.14].finmas_20190315ini.dbo.pXaCAActividad --> Pruebas
GO