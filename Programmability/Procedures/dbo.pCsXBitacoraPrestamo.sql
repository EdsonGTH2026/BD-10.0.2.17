SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXBitacoraPrestamo](@codprestamo varchar(20) )
as
BEGIN

	exec [10.0.2.14].Finmas.dbo.pCaXBitacoraPrestamo @codprestamo

END
GO