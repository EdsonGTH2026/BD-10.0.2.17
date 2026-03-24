SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vINTFCabeceraVr14CP] -- Original (12)
AS
SELECT e.KOB + e.NroInstitucion + dbo.fduRellena('0', e.OficinaPrincipal, 4, 'D') AS ClaveUsuario, 
e.NombreActividad AS NombreUsuario, dbo.fduFechaATexto(v.FechaReporte, 'DDMMAAAA') AS FechaReporte, 
v.Corte, v.Periodo, e.Abreviatura, UPPER(e.Direccion) AS Direccion
FROM finamigoconsolidado.dbo.tClEmpresas e CROSS JOIN tINTFPeriodoCP v
WHERE (e.CodEmpresa = 1) AND (e.Activo = 1) AND (v.Activo = 1)
GO