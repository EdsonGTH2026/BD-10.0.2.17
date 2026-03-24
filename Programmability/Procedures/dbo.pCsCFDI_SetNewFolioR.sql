SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[sp_SetNewFolioR]    Script Date: 15/02/2024 04:27:03 p. m. ******/

-- =============================================
-- Author:		<zApAtA>
-- Create date: <15/02/2024>
-- Description:	<create new folio>
-- =============================================
CREATE PROCEDURE [dbo].[pCsCFDI_SetNewFolioR]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SiguienteFolio INT;

    IF NOT EXISTS (SELECT 1 FROM [fnmgConsolidado].[dbo].[tCsCFDI_timbre_constancia_fiscal])
    BEGIN
        SET @SiguienteFolio = 1; 
    END
    ELSE
    BEGIN
        SET @SiguienteFolio = ISNULL(
            (
                SELECT TOP 1 
                    CAST(SUBSTRING(Folio, LEN('R') + 1, LEN(Folio)) AS INT) + 1
                FROM 
                    [fnmgConsolidado].[dbo].[tCsCFDI_timbre_constancia_fiscal] WITH (NOLOCK)
                WHERE 
                    [Periodo] = (SELECT YEAR(DATEADD(YEAR, -1, GETDATE())))
                ORDER BY 
                    [Contancia_fecha_creacion] DESC,
                    ID DESC 
            ),
            0
        );
    END

    SELECT 'R' + CAST(@SiguienteFolio AS VARCHAR(10)) AS SiguienteFolio;
END
GO