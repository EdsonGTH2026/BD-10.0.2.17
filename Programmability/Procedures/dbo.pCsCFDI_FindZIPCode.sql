SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[sp_FindZIPCode]    Script Date: 15/02/2024 04:20:23 p. m. ******/

-- =============================================
-- Author:		<zApAtA>
-- Create date: <15/02/2024>
-- Description:	<VALIDATE IF THE ZIP CODE EXIST>
-- =============================================

CREATE PROCEDURE [dbo].[pCsCFDI_FindZIPCode]
    @FindZIPCode NVARCHAR(10),
    @Found BIT OUTPUT
AS
BEGIN

    SET @Found = 0
    IF EXISTS (SELECT 1 FROM [fnmgConsolidado].[dbo].[tCsCFDI_CodigoPostal] WHERE [c_CodigoPostal] = @FindZIPCode)
    BEGIN
        SET @Found = 1
    END
END
GO