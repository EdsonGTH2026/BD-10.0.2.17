SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pUsCargaSecundarios] (
             @NombreTerminal varchar(20),
             @CodUsuario char(15),
	@CodSist varchar(2),
	@CodProd varchar(4),
	@CodTipoUs varchar(5),
	@EsPerNatural bit
	)

AS
set nocount on -- <-- Noel. Optimizacion
/*
DECLARE @NombreTerminal varchar(20)
DECLARE @CodUsuario varchar(15)
DECLARE @CodSist varchar(2)
DECLARE @CodProd varchar(4) 
DECLARE @CodTipoUs varchar(5)
DECLARE @EsPerNatural bit 

SET @NombreTerminal = 'HOLA'
SET @CodUsuario = '1RVD1302711'
SET @CodSist = 'CA'
SET @CodProd = '000'
SET @CodTipoUs = '1-00'
SET @EsPerNatural = 1
--exec pUsCargaSecundarios  'Hola','1RVD1302711', 'CA', '000', '1-00', 1
*/
--Para Armar query
DECLARE @Query varchar(700)
DECLARE @Query2 varchar(700)
-- Para recorrer campos y mascara
DECLARE @CurCampo varchar(20)
DECLARE @CurMascara varchar(20)
DECLARE @CurLista varchar(250)
DECLARE @AuxDesc varchar(100)
-- Borra tabla auxiliar
DELETE FROM tUsAuxSecundarios WHERE NombreTerminal = @NombreTerminal
--Crea Tabla Auxiliar
SET @Query  =	'INSERT INTO tUsAuxSecundarios SELECT ' + CHAR(39) + @NombreTerminal + CHAR(39) + ' as NombreTerminal, Gr.Nombre, sec.Campo, sec.Descripcion, sec.Mascara, sec.Lista, sec.MultipleElec, sec.SoloParentesis, sec.Requerido, sec.Grupo, sec.Orden, SPACE(100) as Valor,  SPACE(100) as CodGrabar 
		FROM tUsUsuarioSecClasif as sec INNER JOIN tClDescGruposTablas as Gr ON (sec.Grupo = Gr.Grupo)and(Gr.Tabla = ' + CHAR(39) + 'tUsUsuarioSecClasif' + CHAR(39) + ')  '

IF @CodProd <> ''
BEGIN
  IF @EsPerNatural = 1
  BEGIN
    IF @CodTipoUs <> ''
    BEGIN
      SET @Query  = @Query  + 'WHERE (sec.CodSistema = ' + CHAR(39) + @CodSist + CHAR(39) + ')and(sec.CodProducto = ' + CHAR(39) + @CodProd + CHAR(39) + ')and(sec.EsPerNatural = ' + CONVERT(Char(1),@EsPerNatural) + ')and(sec.CodTipoUs = ' + CHAR(39) + @CodTipoUs + CHAR(39) + ')and(sec.Activo= 1)'
    END
    ELSE
    BEGIN
      SET @Query  = @Query  + 'WHERE (sec.CodSistema = ' + CHAR(39) + @CodSist + CHAR(39) + ')and(sec.CodProducto = ' + CHAR(39) + @CodProd + CHAR(39) + ')and(sec.EsPerNatural = ' + CONVERT(Char(1),@EsPerNatural) + ')and(sec.Activo= 1)'
    END
  END    
  ELSE
  BEGIN
      SET @Query  = @Query  +'WHERE (sec.CodSistema = ' + CHAR(39) + @CodSist + CHAR(39) +')and(sec.CodProducto = ' + CHAR(39) + @CodProd + CHAR(39) + ')and(sec.EsPerNatural = ' + CONVERT(Char(1),@EsPerNatural)  + ') and(sec.Activo= 1)'
  END
END
ELSE
BEGIN
  IF @EsPerNatural = 1
  BEGIN
    IF @CodTipoUs <> ''
    BEGIN
	SET @Query  =  @Query  +'WHERE (sec.CodSistema = ' + CHAR(39) + @CodSist + CHAR(39) + ')and(sec.CodProducto = ' + CHAR(39) + '000' + CHAR(39) + ') and(sec.EsPerNatural = ' +  CONVERT(Char(1),@EsPerNatural)  + ')and(sec.CodTipoUs = ' + CHAR(39) + @CodTipoUs + CHAR(39) + ') and(sec.Activo= 1)'
    END
    ELSE
    BEGIN
	SET @Query  = @Query  +'WHERE (sec.CodSistema = ' + CHAR(39) + @CodSist + CHAR(39) + ')and(sec.CodProducto = ' + CHAR(39) + '000' + CHAR(39) + ') and(sec.EsPerNatural = ' + CONVERT(Char(1),@EsPerNatural)  + ')and(sec.Activo= 1)'
    END
  END
  ELSE
  BEGIN
    SET @Query  = @Query  +'WHERE (sec.CodSistema = ' + CHAR(39) + @CodSist + CHAR(39) + ')and(sec.CodProducto = ' + CHAR(39) + '000' + CHAR(39) + ') and(sec.EsPerNatural = ' + CONVERT(Char(1),@EsPerNatural)  + ')and(sec.Activo= 1)'
  END
END
SET @Query  = @Query  + 'ORDER BY sec.Grupo, sec.Orden'
exec (@Query)
--SELECT * FROM #Tabla
print @Query
-- Actualiza valores de Campo
  DECLARE CursorCampos Scroll Cursor For SELECT Campo, Mascara, Lista FROM tUsAuxSecundarios WHERE NombreTerminal = @NombreTerminal
  OPEN CursorCampos
  FETCH FIRST FROM CursorCampos INTO @CurCampo, @CurMascara, @CurLista
  WHILE (@@Fetch_Status <> -1)
  BEGIN
    IF @CurMascara = 'Fecha'
    BEGIN
      SET @Query = 'UPDATE tUsAuxSecundarios SET Valor = isnull( CONVERT(Varchar(10), (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) +'),101),' + CHAR(39) + CHAR(39) + ')
                    WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) 
    End
    ELSE  -- si no es fecha
    BEGIN
      IF @CurMascara = 'Bit'
      BEGIN
        SET @Query = 'UPDATE tUsAuxSecundarios SET Valor = CASE CONVERT(Varchar(2), (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) +')) WHEN Null THEN ' + CHAR(39) + CHAR(39) + ' WHEN 1 THEN '  + CHAR(39) + 'Si' + CHAR(39) + ' ELSE ' + CHAR(39) + 'No' + CHAR(39) + ' END ' + '
                      WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) 
      End
      ELSE -- Si no es Fecha y Bit
      BEGIN
        IF @CurMascara = 'Form'
        BEGIN
          IF @CurLista = 'Actividad'
          BEGIN
            SET @Query = 'CONVERT(Varchar(100), ( SELECT CodActividad + ' + CHAR(39) +' - ' + CHAR(39) + '  + Nombre FROM tClActividad WHERE CodActividad =
                          (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = '  + CHAR(39) + @CodUsuario + CHAR(39) +' ) )  )'
            SET @Query = 'UPDATE tUsAuxSecundarios SET Valor = (' + @Query  +' )
                          WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) 
            exec (@Query)
            SET @Query = 'UPDATE tUsAuxSecundarios SET CodGrabar = isnull( CONVERT(Varchar(100), (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) +')),' + CHAR(39) + CHAR(39) + ')
                          WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) 
            exec (@Query)
          End
          ELSE -- Form, no actividad
          BEGIN
            IF @CurLista = 'Ubigeo'
            BEGIN
              SET @Query = 'CONVERT(Varchar(100), ( SELECT CodUbigeo + ' + CHAR(39) +' - ' + CHAR(39) + '  + NomUbigeo FROM tClUbigeo WHERE CodUbigeo =
                            (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = '  + CHAR(39) + @CodUsuario + CHAR(39) +' ) )  )'
              SET @Query = 'UPDATE tUsAuxSecundarios SET Valor = (' + @Query  +' )
                            WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) 
              exec (@Query)
              SET @Query = 'UPDATE tUsAuxSecundarios SET CodGrabar = isnull( CONVERT(Varchar(100), (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) +')),' + CHAR(39) + CHAR(39) + ')
                            WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) 
              exec (@Query)
            End
            ELSE  -- Form, no actividad, no Ubigeo
            BEGIN
              IF @CurLista = 'Ocupacion'
              BEGIN
                SET @Query = 'CONVERT(Varchar(100), ( SELECT CodOcupacion + ' + CHAR(39) +' - ' + CHAR(39) + '  + Nombre FROM tClOcupaciones WHERE CodOcupacion =
                              (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = '  + CHAR(39) + @CodUsuario + CHAR(39) +' ) )  )'
                SET @Query = 'UPDATE tUsAuxSecundarios SET Valor = (' + @Query  +' )
                              WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) 
                exec (@Query)
                SET @Query = 'UPDATE tUsAuxSecundarios SET CodGrabar = isnull( CONVERT(Varchar(100), (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) +')),' + CHAR(39) + CHAR(39) + ')
                              WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) 
                exec (@Query)
              END -- FIN: Form, no actividad, no Ubigeo, No ocupación
/*            ELSE   -- Form, no actividad, no Ubigeo, no Ocupacion
              BEGIN
                SET @Query = 'UPDATE tUsAuxSecundarios SET Valor = isnull( CONVERT(Varchar(100), (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) +')),' + CHAR(39) + CHAR(39) + ')
                              WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ', Valor = ' + @AuxDesc
              END*/
            END -- FIN: Form, no actividad, no Ubigeo
          END -- FIN: Form, no actividad
/*          SET @Query = 'UPDATE tUsAuxSecundarios SET CodGrabar = isnull( CONVERT(Varchar(100), (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) +')),' + CHAR(39) + CHAR(39) + ') 
                        WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) +
                       ', Valor = ' + @AuxDesc*/
        End -- FIN: Form
        ELSE --Si no es Fecha, Bit, Form
        BEGIN
          SET @Query = 'UPDATE tUsAuxSecundarios SET Valor = isnull( CONVERT(Varchar(100), (SELECT ' + @CurCampo + ' FROM tUsUsuarioSecundarios WHERE CodUsuario = ' + CHAR(39) + @CodUsuario + CHAR(39) +')),' + CHAR(39) + CHAR(39) + ')
                        WHERE Campo = ' + CHAR(39) + @CurCampo + CHAR(39) + ' and NombreTerminal = ' + CHAR(39) + @NombreTerminal + CHAR(39) 
        End  --FIN: Si no es Fecha, Bit ni Form
      End  --FIN: Si no es Fecha ni Bit
    End --FIN: Si no es Fecha
    -- SELECT @Query
    exec (@Query)
    FETCH NEXT FROM CursorCampos INTO @CurCampo, @CurMascara, @CurLista
  End --FIN While
  Close CursorCampos
  DEALLOCATE CursorCampos
--INSERT INTO tUsAuxSecundarios SELECT * FROM #Tabla

RETURN



--------------------------------------------------------------------------------


GO