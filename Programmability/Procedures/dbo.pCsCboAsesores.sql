SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCboAsesores] @CodOficina varchar(2)  AS
SELECT     CodAsesor, NomAsesor
FROM         tCsAsesores
WHERE     (CodOficina = @CodOficina) AND (Activo = '1')
GO