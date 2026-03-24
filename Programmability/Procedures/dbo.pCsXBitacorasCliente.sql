SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXBitacorasCliente](@usuario as varchar(15))
as
BEGIN
	--exec [10.0.2.14].finmas.dbo.pCaXBitacorasCliente @usuario  --PRODUCCION
	exec [10.0.2.14].alta14.dbo.pCaXBitacorasCliente @usuario  --PRUEBAS
END
GO