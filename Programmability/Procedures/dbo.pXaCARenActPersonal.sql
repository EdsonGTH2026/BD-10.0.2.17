SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE procedure [dbo].[pXaCARenActPersonal] @codusuario varchar(25), @Parametros varchar(2000)
as
	exec [10.0.2.14].finmas.dbo.pXaCARenActPersonal @codusuario,@Parametros -->Produccion
	--exec [10.0.2.14].finmas_20190315ini.dbo.pXaCARenActPersonal @codusuario,@Parametros -->Pruebas

GO