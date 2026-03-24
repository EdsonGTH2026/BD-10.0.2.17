SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*------ DETALLE DE GRADO RIESGO CLIENTE
VER. ZCCU_2026.01.12 Se crear el sp para BUSCAR el detalle del grado de riesgo de un cliente,buscado por Curp
--Para nueva plataforma de PLD
*/  
CREATE PROCEDURE [dbo].[pXpARiesgoClienteDetalle] (@ID INT)  
AS 

BEGIN  
	 --DECLARE @ID INT
	 --SET @ID = 84008 
 
 
     exec [10.0.2.14].[FINMAS].[DBO].[pXpRiesgoClienteDetalle] @ID
     
END;
GO