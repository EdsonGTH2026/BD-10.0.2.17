SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXRegistrarBitacoraCobranza](@Codprestamo varchar(20), @CodRelacion varchar(2), @Nombrecompleto varchar(100), @Observacion varchar(1000), @Dictamen varchar(2), @Tipo varchar(2), @Domicilio varchar(200), @Telefono varchar(10), @Usuario varchar(20) )
as
BEGIN
	exec [10.0.2.14].Finmas.dbo.pCaXRegistrarBitacoraCobranza @Codprestamo, @CodRelacion, @Nombrecompleto, @Observacion, @Dictamen, @Tipo, @Domicilio, @Telefono, @Usuario
END

GO