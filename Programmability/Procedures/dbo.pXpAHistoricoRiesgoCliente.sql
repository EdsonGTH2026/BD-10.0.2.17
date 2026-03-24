SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*------ HISTORICO RIESGO CLIENTE POR CURP 
VER. ZCCU_2026.01.12 Se crear el sp para BUSCAR todos los registros del grado de riesgo de un mismo cliente,buscado por Curp
--Para nueva plataforma de PLD
*/ 
CREATE PROCEDURE [dbo].[pXpAHistoricoRiesgoCliente] (@CURP varchar(18))  
AS 


BEGIN  
	----DECLARE @CURP VARCHAR(18)
	----SET @CURP = 'ROAM850507HMCDLR01' 


     exec [10.0.2.14].[FINMAS].[DBO].[pXpHistoricoRiesgoCliente] @CURP
     
END;
GO