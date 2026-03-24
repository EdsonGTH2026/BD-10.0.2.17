SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pSgGridReportes] @Nombre as varchar(50), @Archivo varchar(50), @Codigo varchar(10) AS
SET @Codigo =  '%' + @Codigo + '%'
SET @Nombre =  '%' + @Nombre + '%'
SET @Archivo =  @Archivo + '%'

SELECT     CodReporte AS 'Item', Nombre,RIGHT(RutaUbicacion, 
(CASE CHARINDEX('\', REVERSE(RutaUbicacion), 1)  WHEN 0 THEN 1 ELSE 
CHARINDEX('\', REVERSE(RutaUbicacion), 1)  END)  - 1)  AS Archivo, Activo AS '  '
FROM         tSgReportes
WHERE     (Nombre LIKE @Nombre) AND (RIGHT(RutaUbicacion, 
(CASE CHARINDEX('\', REVERSE(RutaUbicacion), 1)  WHEN 0 THEN 1 ELSE 
CHARINDEX('\', REVERSE(RutaUbicacion), 1)  END)  - 1)  LIKE @Archivo) AND (CodReporte LIKE @Codigo)
GO