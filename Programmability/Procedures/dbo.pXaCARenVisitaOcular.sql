SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pXaCARenVisitaOcular] @codsolicitud varchar(15),@codoficina varchar(4),@obs varchar(300),@actividad tinyint,@reside tinyint, @compdomicilio tinyint, @docidentidad tinyint, @codParentescoCompDom varchar(3)
as
	exec [10.0.2.14].finmas.dbo.pXaCARenVisitaOcular @codsolicitud, @codoficina, @obs, @actividad, @reside, @compdomicilio, @docidentidad, @codParentescoCompDom   --produccion
	--exec [10.0.2.14].finmas_20190315ini.dbo.pXaCARenVisitaOcular @codsolicitud, @codoficina, @obs, @actividad, @reside, @compdomicilio, @docidentidad, @codParentescoCompDom   --pruebas


GO