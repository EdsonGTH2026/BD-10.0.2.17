SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaCADestinoHijo]
as
	exec [10.0.2.14].finmas.dbo.pXaCADestinoHijo  --produccion
	---exec [10.0.2.14].finmas_20190315ini.dbo.pXaCADestinoHijo  --pruebas
GO