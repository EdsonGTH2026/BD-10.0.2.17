SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---- FUNCION PARA EL CALCULO DEL NRO ATRASO ATR: Nuevo calculo de reservas IFRS9
---- ZCCU 2025.08.23
---- 

CREATE FUNCTION [dbo].[fduCalculaATR_IFRS9] (@NroDiasAtraso INT)     
RETURNS INT      
AS

BEGIN
---------------------------- PRUEBAS 
/*
DECLARE @NroDiasAtraso INT
SET @NroDiasAtraso=31
*/
------------------------------------
--DECLARAR VARIABLES
DECLARE @ATR INT

IF ISNULL(@NroDiasAtraso,0) = 0
	BEGIN 
		SET @NroDiasAtraso = 0
		SET @ATR = 0
	END
ELSE 
	BEGIN 
		SET @ATR = (@NroDiasAtraso/30.3)+1
	END

--SELECT @ATR 
RETURN (@ATR) 
END


GO