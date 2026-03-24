SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[spInsertarTimbreConstanciaFiscal]    Script Date: 15/02/2024 04:31:03 p. m. ******/

-- =============================================
-- Author:		<zApAtA>
-- Create date: <15/02/2024>
-- Description:	<INSERT NEW CFDI COMPLETE>
-- =============================================
CREATE PROCEDURE [dbo].[pCsCFDI_InsertCFDI]
    @RFC NVARCHAR(13),
    @Nombre NVARCHAR(70),
    @CodUsuario NVARCHAR(50),
    @Xml  NVARCHAR(4000),
    @Folio NVARCHAR(10),
    @UUID NVARCHAR(50),
    @Ruta_PDF NVARCHAR(255),
    @Constancia_creada BIT,
    @Periodo INT,
    @Constancia_fecha_creacion DATETIME,
    @Error NVARCHAR(4000),
    @Cancelado BIT,
	@IDCreado INT OUTPUT  
AS
BEGIN
    INSERT INTO [fnmgConsolidado].[dbo].[tCsCFDI_timbre_constancia_fiscal]
    (
        RFC,
        Nombre,
        CodUsuario,
        Xml,
        Folio,
        UUID,
        Ruta_PDF,
        Constancia_creada,
        Periodo,
        Contancia_fecha_creacion,
        Error,
        Cancelado
    )
    VALUES
    (
        @RFC,
        @Nombre,
        @CodUsuario,
        @Xml,
        @Folio,
        @UUID,
        @Ruta_PDF,
        @Constancia_creada,
        @Periodo,
        @Constancia_fecha_creacion,
        @Error,
        @Cancelado
    );
	SET @IDCreado = SCOPE_IDENTITY();
END
GO