SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  StoredProcedure [dbo].[sp_FindByRFC]    Script Date: 15/02/2024 04:17:58 p. m. ******/

-- =============================================
-- Author:		<zApAtA>
-- Create date: <15/02/2024>
-- Description:	<GET CFDI BY RFC>
-- =============================================
CREATE PROCEDURE [dbo].[pCsCFDI_FindByRFC] @RFC VARCHAR(50), @ID INT OUTPUT
AS

BEGIN 
    SET @ID = NULL;  

    DECLARE @Periodo INT;
    DECLARE @AnioActual INT;
    SET @AnioActual = YEAR(GETDATE()) - 1;

    SELECT TOP 1 @ID = [ID], @Periodo = [Periodo]
    FROM fnmgConsolidado.[dbo].[tCsCFDI_timbre_constancia_fiscal]
    WHERE [RFC] = @RFC
    ORDER BY [ID] DESC;

    
    IF @ID IS NOT NULL AND @Periodo != @AnioActual 
        SET @ID = NULL; 
END;
GO