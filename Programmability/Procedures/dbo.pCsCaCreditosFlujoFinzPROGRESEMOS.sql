SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCaCreditosFlujoFinzPROGRESEMOS] (@FondeadorEstado varchar(1), @FecIni smalldatetime, @FecFin smalldatetime, @Oficinas varchar(100))
as
BEGIN
	exec [10.0.2.14].finmas.dbo.pCaCreditosFlujoFinzPROGRESEMOS @FondeadorEstado, @FecIni, @FecFin, @Oficinas
	--exec [10.0.2.14].finmas_20190522ini.dbo.pCacreditosFlujoFinzFacorp @FondeadorEstado, @FecIni, @FecFin, @Oficinas
END

GO