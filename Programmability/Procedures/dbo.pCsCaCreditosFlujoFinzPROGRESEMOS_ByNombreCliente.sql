SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCaCreditosFlujoFinzPROGRESEMOS_ByNombreCliente] (@FondeadorEstado varchar(1), @NombreCliente varchar(50))
as
BEGIN
	exec [10.0.2.14].finmas.dbo.pCaCreditosFlujoFinzPROGRESEMOS_ByNombreCliente @FondeadorEstado, @NombreCliente
END
GO