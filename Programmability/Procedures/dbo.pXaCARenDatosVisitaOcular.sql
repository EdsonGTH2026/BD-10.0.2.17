SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pXaCARenDatosVisitaOcular] @codsolicitud varchar(25), @codoficina varchar(4)
as
	exec [10.0.2.14].finmas.dbo.pXaCARenDatosVisitaOcular @codsolicitud ,@codoficina  -->Produccion
	--exec [10.0.2.14].finmas_20190315ini.dbo.pXaCARenDatosVisitaOcular @codsolicitud ,@codoficina  -->Pruebas


GO