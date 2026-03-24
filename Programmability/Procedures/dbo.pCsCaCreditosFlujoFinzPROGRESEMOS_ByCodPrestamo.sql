SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCaCreditosFlujoFinzPROGRESEMOS_ByCodPrestamo] (@FondeadorEstado varchar(1), @CodPrestamo varchar(20))
as
BEGIN
	exec [10.0.2.14].finmas.dbo.pCaCreditosFlujoFinzPROGRESEMOS_ByCodPrestamo @FondeadorEstado, @CodPrestamo
END
GO