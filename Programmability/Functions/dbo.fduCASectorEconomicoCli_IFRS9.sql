SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---- FUNCION PARA ASGINAR EL SECTOR ECONOMICO DEL CLIENTE
---- 2025.08.15
---- ZCCU

CREATE FUNCTION [dbo].[fduCASectorEconomicoCli_IFRS9] (@CodUsuario VARCHAR(35))     
RETURNS varchar(40)      
AS

BEGIN
---------------------------- PRUEBAS 
/*
DECLARE @CodUsuario VARCHAR(30)
SET @CodUsuario= 'LSE06098312'
*/
------------------------------------

--DECLARAR VARIABLES
DECLARE @LabCodActividad VARCHAR(30)
DECLARE @CodAlterno VARCHAR(30)
DECLARE @Indicador VARCHAR(30)
DECLARE @Sector INT


SELECT @LabCodActividad = LabCodActividad FROM tCsPadronClientes WITH(NOLOCK) WHERE CodUsuario = @CodUsuario

IF @LabCodActividad IS NULL
	BEGIN 
	SET @LabCodActividad = 0
	END

SELECT @CodAlterno = CodAlterno FROM tClActividad WITH(NOLOCK) WHERE CodActividad =  @LabCodActividad AND Activo = 1

IF ISNULL(@CodAlterno,0) = 0
	BEGIN 
	SET @CodAlterno = 0
	END
	
SET @Indicador = SUBSTRING (@CodAlterno,1,2)
SELECT @Sector  = CodSectorEconomico FROM tCIFRS9SectorEconomico WITH(NOLOCK) WHERE valor = @Indicador


IF ISNULL(@Sector,0) = 0
	BEGIN 
	SET @Sector = 2
	END
	
--SELECT @LabCodActividad,@CodAlterno,@Indicador,@Sector

RETURN (@Sector) 
END


GO