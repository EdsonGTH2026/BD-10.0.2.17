SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduCodUsuario] (@Codusuario varchar(20))  
RETURNS varchar(20) AS  
BEGIN 

DECLARE @CodUsuarioValido varchar(20)
DECLARE @TValorASCII  TINYINT

SET @TValorASCII = 49

SET @CodUsuarioValido = @CodUsuario + CHAR(@TValorASCII)

WHILE EXISTS (
		SELECT CodUsuario FROM tUsUsuarios WHERE CodUsuario = @CodUsuarioValido
		UNION
		SELECT CodUsuario FROM tCsPadronClientes WHERE Codorigen = @CodUsuarioValido
		)
BEGIN

SET @TValorASCII = CASE WHEN @TValorASCII = 57 THEN 65
			      WHEN @TValorASCII BETWEEN 49 AND 56 OR @TValorASCII BETWEEN 65 AND 89 THEN @TValorASCII + 1 
			      ELSE 42 END

SET @CodUsuarioValido = @CodUsuario + CHAR(@TValorASCII)

END

return (@CodUsuarioValido)

END




GO