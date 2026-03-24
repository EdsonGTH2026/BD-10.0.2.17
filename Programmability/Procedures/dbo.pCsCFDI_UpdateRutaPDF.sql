SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  StoredProcedure [dbo].[sp_UpdateRutaPDF]    Script Date: 15/02/2024 04:29:30 p. m. ******/

-- =============================================
-- Author:		<zApAtA>
-- Create date: <15/02/2024>
-- Description:	<ADD PATH OF PDF>
-- =============================================
CREATE PROCEDURE [dbo].[pCsCFDI_UpdateRutaPDF]
    @ID INT,
    @NuevaRutaPDF NVARCHAR(4000),
    @Resultado INT OUTPUT
AS
BEGIN
    SET @Resultado = 0; 

    UPDATE [fnmgConsolidado].[dbo].[tCsCFDI_timbre_constancia_fiscal]
    SET
        [Ruta_PDF] = @NuevaRutaPDF
    WHERE
        [ID] = @ID;

    IF @@ROWCOUNT > 0
        SET @Resultado = 1; 
END;
GO