SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vINTFCabeceraCP] -- Original (12)
AS
	SELECT e.KOB + e.NroInstitucion + dbo.fduRellena('0', e.OficinaPrincipal, 4, 'D') AS ClaveUsuario, 
	e.NombreActividad AS NombreUsuario, dbo.fduFechaATexto(p.FechaReporte, 'DDMMAAAA') AS FechaReporte, 
	p.Corte, p.Periodo, e.Abreviatura, UPPER(e.Direccion) AS Direccion
	FROM finamigoconsolidado.dbo.tClEmpresas e with(nolock) CROSS JOIN tINTFPeriodoCP p
	WHERE (e.CodEmpresa = 1) AND (e.Activo = 1) AND (p.Activo = 1)

GO