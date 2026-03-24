SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCaValidarDatosAdicionalesSolicitud] @codcliente varchar(20), @codproducto varchar(3)
as
BEGIN
	exec [10.0.2.14].finmas.dbo.pXaCaValidarDatosAdicionalesSolicitud @codcliente,@codproducto   --produccion
END
GO