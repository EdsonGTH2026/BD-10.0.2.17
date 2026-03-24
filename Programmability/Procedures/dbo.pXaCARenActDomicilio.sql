SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE procedure [dbo].[pXaCARenActDomicilio] @codusuario varchar(25), @Parametros varchar(2000)
as
	exec [10.0.2.14].finmas.dbo.pXaCARenActDomicilio @codusuario, @Parametros -->produccion
	--exec [10.0.2.14].finmas_20190315ini.dbo.pXaCARenActDomicilio @codusuario, @Parametros -->pruebas

GO