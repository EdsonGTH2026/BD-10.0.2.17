SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCaValidarDatosAdicionalesSolicitud_QA] @codcliente varchar(20), @codproducto varchar(3)
as
BEGIN
	exec [10.0.2.14].finmas_20190522ini.dbo.pXaCaValidarDatosAdicionalesSolicitud @codcliente,@codproducto  --pruebas
END
GO