SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[InsertLogErrorCFDI]    Script Date: 15/02/2024 04:14:20 p. m. ******/

-- =============================================
-- Author:		<zApAtA>
-- Create date: <15/02/2024>
-- Description:	<INSERT LOG CFDI>
-- =============================================
CREATE PROCEDURE [dbo].[pCsCFDI_InsertLogErrorCFDI]
    @RFC nvarchar(13),
    @Nombre nvarchar(70),
    @CodUsuario nvarchar(50),
    @Constancia_creada bit,
    @Fecha_creacion datetime,
    @Error nvarchar(4000)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO fnmgConsolidado.[dbo].[tCsCFDI_log_error_cfdi] (RFC, Nombre, CodUsuario, Constancia_creada, Fecha_creacion, Error)
    VALUES (@RFC, @Nombre, @CodUsuario, @Constancia_creada, @Fecha_creacion, @Error);
END
GO