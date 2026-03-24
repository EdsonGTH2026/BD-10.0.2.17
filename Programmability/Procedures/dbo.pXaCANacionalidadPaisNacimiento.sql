SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pXaCANacionalidadPaisNacimiento] @Tipo BIT
AS
	EXEC [10.0.2.14].[Finmas].[dbo].[pXaCANacionalidadPaisNacimiento] @Tipo
GO