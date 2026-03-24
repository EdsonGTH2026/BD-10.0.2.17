SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vBOFCabeceraVr14] -- Original (12)
AS
SELECT 'BOF' as 'INICIOSEG',
e.KOB + e.NroInstitucion + dbo.fduRellena('0', e.OficinaPrincipal, 4, 'D') AS ClaveUsuario
, dbo.fduFechaATexto(v.FechaReporte, 'DDMMAAAA') AS FechaReporte, 
'**|' AS 'FINSEG'
FROM finamigoconsolidado.dbo.tClEmpresas e CROSS JOIN tBOFPeriodo v
WHERE (e.CodEmpresa = 1) AND (e.Activo = 1) AND (v.Activo = 1)
GO