SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/********************************************************
	pUsGrabaSecundarios
	Permite grabar datos secundarios

	Autor: Dulfredo Rojas
	Ultima Revision: 16/12/2003
*********************************************************/
CREATE procedure [dbo].[pUsGrabaSecundarios] (
             @NombreTerminal varchar(20),
             @CodUsuario char(15)
	)
with encryption
AS
set nocount on
/*
DECLARE @NombreTerminal varchar(20)
DECLARE @CodUsuario varchar(15)

SET @NombreTerminal = 'HOLA'
SET @CodUsuario = '1RVD1302711'
--exec pUsGrabaSecundarios  'Hola','1RVD1302711'
*/
--Para Armar query
DECLARE @Query varchar(700)
-- Para recorrer campos y mascara
DECLARE @CurCampo varchar(20)
DECLARE @CurValor varchar(100)
DECLARE @CurMascara varchar(20)
DECLARE @CurLista varchar(250)
DECLARE @CurCodGrabar varchar(100)

-- Actualiza valores de Campo
  DECLARE CursorCampos Scroll Cursor For 
	SELECT Campo, Valor, Mascara, Lista, CodGrabar 
	FROM tUsAuxSecundarios 
	WHERE (NombreTerminal = @NombreTerminal) 
	ORDER BY Grupo, Orden
  OPEN CursorCampos
  FETCH FIRST FROM CursorCampos INTO @CurCampo, @CurValor, @CurMascara, @CurLista, @CurCodGrabar
  WHILE (@@Fetch_Status <> -1)
    BEGIN
	Print '-------------------------'
      	Print 'Campo	: ' + Isnull(@CurCampo, 'Nulo')
	Print '-------------------------'
	Print 'Valor	: ' + IsNull(@CurValor, 'Nulo')
	Print 'Mascara	: ' + IsNull(@CurMascara, 'Nulo')
	Print 'Lista	: ' + IsNull(@CurLista, 'Nulo')
	Print 'Grabar	: ' + IsNull(@CurCodGrabar, 'Nulo')	
	Print '-------------------------'	

      IF len(@CurValor) > 0
      BEGIN 
        IF @CurMascara = 'Bit'
        BEGIN
	  IF @CurValor = 'Si'  
	  BEGIN
  	    SET @Query = 'UPDATE tUsUsuarioSecundarios SET ' + @CurCampo + ' =  1' +
	                            ' WHERE (CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) + ')'	          
	  END
	  ELSE  -- Si es Bit con 'No'
	  BEGIN
  	   SET @Query = 'UPDATE tUsUsuarioSecundarios SET ' + @CurCampo + ' =  0 ' + 
	                            ' WHERE (CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) + ')'	          
	  END
        END
        ELSE  -- Si no es Bit
        BEGIN
          IF @CurMascara = 'Form'
          BEGIN
            IF @CurLista = 'Actividad' or @CurLista = 'Ubigeo' or @CurLista = 'Ocupacion'
            BEGIN
	      SET @Query = 'UPDATE tUsUsuarioSecundarios SET ' + @CurCampo + ' = ' + CHAR(39) + @CurCodGrabar + CHAR(39) +
	                   ' WHERE (CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) + ')'       
	    END
 	  END
	  ELSE  -- Si no es Bit, ni Form
	  BEGIN
/*	    IF @CurMascara = 'Lista'
	    BEGIN
	      
	    END
	    ELSE  -- Si no es Bit, ni Form, ni Lista
	    BEGIN*/
  	      IF @CurLista = 'Numero'
	      BEGIN
	         SET @Query = 'UPDATE tUsUsuarioSecundarios SET ' + @CurCampo + ' = '  + @CurValor + 
	                              ' WHERE (CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) + ')'
	      END
	      ELSE  -- Si no es Bit ni # (número), ni Form
	      BEGIN
                 SET @Query = 'UPDATE tUsUsuarioSecundarios SET ' + @CurCampo + ' = ' + CHAR(39) + @CurValor + CHAR(39) +
	                              ' WHERE (CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) + ')'
	      END
/*	    END*/
	  END
        END 
        Print 'Query : ' + @Query 
        exec (@Query)
      END
      FETCH NEXT FROM CursorCampos INTO @CurCampo, @CurValor, @CurMascara, @CurLista, @CurCodGrabar
    END
  CLOSE CursorCampos
  DEALLOCATE CursorCampos

-- Borra tabla auxiliar
-- DELETE FROM tUsAuxSecundarios WHERE (NombreTerminal = @NombreTerminal) (13/10/2004)Se comentó dado que cerraba el recordset una vez que se terminaba de validar

RETURN


--------------------------------------------------------------------------------


GO