SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*------ 
VER. ZCCU_2026.01.13
*/ 
CREATE PROCEDURE [dbo].[psControlCajaMovimientos] (@Fecha SMALLDATETIME)  
AS 

BEGIN  

	EXEC [10.0.2.14].[FINMAS].[DBO].[psControlCajaMovimientos] @Fecha---'20260113'
END;
GO