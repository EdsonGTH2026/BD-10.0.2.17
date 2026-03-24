SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  View dbo.vBNCPMCabecera    Script Date: 08/03/2023 09:14:53 pm ******/


CREATE VIEW [dbo].[vBNCPMCabecera]
AS
SELECT 'OF15650001' AS ClaveUsuario, 
e.NombreActividad AS NombreUsuario, dbo.fduFechaATexto(a.FechaReporte, 'DDMMAAAA') AS FechaReporte, 
a.Corte, a.Periodo, e.Abreviatura, UPPER(e.Direccion) AS Direccion
FROM finamigoconsolidado.dbo.tClEmpresas e CROSS JOIN tBNCPMPeriodo a
WHERE (e.CodEmpresa = 1) AND (e.Activo = 1) AND (a.Activo = 1)

--select * FROM finamigoconsolidado.dbo.tClEmpresas


GO