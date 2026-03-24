SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXComboEstados](@usuario varchar(20), @estado varchar(2))
as
BEGIN
	--exec [10.0.2.14].finmas.dbo.pCaXComboEstados @usuario, @estado --PRODUCCION
	--exec [10.0.2.14].alta14.dbo.pCaXComboEstados @usuario, @estado --PRUEBAS
	
	exec [10.0.2.14].finmas.dbo.pcaxcomboestados2 @usuario, @estado
END
GO