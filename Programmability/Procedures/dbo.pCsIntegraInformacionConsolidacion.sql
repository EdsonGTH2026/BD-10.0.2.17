SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsIntegraInformacionConsolidacion

CREATE Procedure [dbo].[pCsIntegraInformacionConsolidacion]
	@Fecha 		SmallDateTime, 
	@Proceso 	Varchar(50)
AS 
Declare @Carpeta Varchar(100), @Backup	Bit, @Servidor	Varchar(100), @BaseDatos Varchar(100),  @AlternoS Varchar(100), @AlternoB Varchar(100), @ForzarCarga Varchar(4)
Declare @responsable Varchar(50)

Set @Backup		= 0					--0: Inactivo 1: Activo
Set @Carpeta 		= '\\Cg-finamigo-srv\BackupOperativo\'	--Ruta de Backup, funciona si es que el backup esta activo
--Set @ForzarCarga	= '71'					--Forzar Carga

Declare @Porcentaje	Decimal(18, 4)

If @Proceso = 'CI'
Begin
	Set @Porcentaje	= 0
	Set	@Proceso 	= 'CA' 
End
If @Proceso = 'CF'
Begin
	Set @Porcentaje	= 100
	Set	@Proceso 	= 'CA'
End

SELECT @Responsable = Responsable
FROM   tCsCierres
WHERE  Fecha = @Fecha

--Set 	@AlternoS	= '10.0.1.14'
--Set 	@AlternoB	= 'FinmasCentral'
Declare @BackupC	Bit
Declare @Base		Varchar(4000)
Declare @Cadena		Varchar(4000)
Declare @Cadena1	Varchar(4000)
Declare @Cabecera	Varchar(4000)
Declare @Detalle	Varchar(4000)
Declare @Modulo		Varchar(50)
Declare @Verificador 	Int
Declare @Verificador1 	Int
Declare @Verificador2 	Int
Declare @CodOficina 	Varchar(200)
Declare @CampoFecha	Bit
Declare @Campo		Varchar(4000)
Declare @Sumatoria	Varchar(4000)
Declare @Tabla 		Varchar(50)
Declare @Cerrado 	Bit
Declare @Frase		Varchar(4000)
Declare @Error		Int
Declare @C		Int

Set @Carpeta = @Carpeta + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')  + '_' + SubString(Upper(@Responsable), 1, 3)

SELECT @Cerrado = Cerrado
FROM   tCsCierres
WHERE  Fecha = @Fecha - 1

If @Cerrado is null Begin Set @Cerrado = 0 End

If @Proceso Not In ('CO', 'CA', 'FR', 'FO', 'RU')
	Set @Cerrado = 0

If @Proceso In ('FR', 'RU')
	Set @Cerrado = 0

if NOT EXISTS (Select 1 From tCsCierres 
               Where Fecha = @Fecha)
Begin 
    Insert Into tCsCierres
           ( Fecha, Cargado, Cerrado,  Responsable) 
    Values (@Fecha, 0      , 0      , @Responsable)
End

Delete From tCsCierresMensajes 
Where Fecha = @Fecha

SELECT @C = Cerrado
FROM   tCsCierres
WHERE  Fecha = @Fecha

If @C is null 
    Set @C = 0

If @C = 1
	Set @Cerrado = 0

If @Cerrado = 1
Begin	
	Insert Into tCsCierresArchivos
	SELECT D.*
	FROM tCsCierresArchivos CA
	RIGHT JOIN (
	    SELECT DISTINCT Fecha = @Fecha, O.CodOficina, tCsConsistenciaUsuario.Tabla, 0 AS Registros, 'Ninguna' AS Observacion
	    FROM tClOficinas O
	    CROSS JOIN (
	        SELECT Tabla
	        FROM  tCsConsistenciaUsuario
	        WHERE Consolidado = 1 AND Existe = 1
	        UNION
	        SELECT 'CONTABILIDAD'
	    ) tCsConsistenciaUsuario
	    WHERE O.Tipo in ('Operativo', 'Servicio', 'Matriz', 'Cerrada')
	) D ON CA.Fecha = D.Fecha AND CA.CodOficina = D.CodOficina AND CA.Tabla = D.Tabla
	WHERE CA.Fecha IS NULL
	
	Set @Campo 	= ''
	Set @Sumatoria	= ''
	
	Declare curUsuario Cursor For 
		SELECT DISTINCT A.Tabla, U.CampoFecha
		FROM  tCsCierresArchivos A
		INNER JOIN tCsConsistenciaUsuario U ON A.Tabla = U.Tabla
		WHERE A.Tabla <> 'CONTABILIDAD' AND A.Fecha = @Fecha AND U.CampoFecha IS NOT NULL
	
	Open curUsuario
	Fetch Next From curUsuario Into @Tabla, @CampoFecha
	While @@Fetch_Status = 0
	Begin 
		If @CampoFecha = 0
		Begin
			Set @Cadena = '
			        UPDATE tCsCierresArchivos 
                    SET registros = IsNull(maestra.registros, 0)
			        FROM (
			            SELECT CodOficina, COUNT(*) AS Registros
			            FROM ' + @Tabla + '
                        GROUP BY CodOficina
                    ) Maestra 
                    RIGHT OUTER JOIN tCsCierresArchivos A ON Maestra.CodOficina = A.CodOficina
			        WHERE A.Tabla = '''+ @Tabla +''' AND A.Fecha = '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''''
			Print	@Cadena
			Exec   (@Cadena)
		End
		If @CampoFecha = 1
		Begin
			Set @Cadena = '
			        UPDATE tCsCierresArchivos
			        SET registros = IsNull(maestra.registros, 0)
			        FROM (
			            SELECT Fecha, CodOficina, COUNT(*) AS Registros
			            FROM ' + @Tabla + '
			            WHERE Fecha = '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +'''
			            GROUP BY FEcha, CodOficina
			        ) Maestra
			        RIGHT OUTER JOIN tCsCierresArchivos A ON Maestra.CodOficina = A.CodOficina 
			                     AND Maestra.Fecha = A.Fecha 
			        WHERE A.Tabla = '''+ @Tabla +''' AND A.Fecha = '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''''
			Print	 @Cadena
			Exec	(@Cadena)
		End	
		
		Set @Campo 	= @Campo + 'CASE WHEN tabla = '''+ @Tabla +''' THEN Registros ELSE 0 END AS '+ @Tabla +', '
		Set @Sumatoria	= @Sumatoria + 'SUM('+ @Tabla +') AS '+ @Tabla +', '
	
	    Fetch Next From curUsuario Into @Tabla, @CampoFecha
	End 
	Close 		curUsuario
	Deallocate 	curUsuario
	
	UPDATE tClOficinas
	SET SeConsolida = 0 

	IF @Proceso = 'FO'
	Begin
	    SELECT Observadas.CodOficina, Observadas.Observadas, CAST(Observadas.Observadas AS decimal(18, 4)) / CAST(Total.Total AS decimal(18, 4)) * 100 AS FO
	    FROM (
	        SELECT Fecha, CodOficina, COUNT(*) AS Observadas
	        FROM (
	            SELECT *, ROUND(Diferencia / Mayor * 100, 2) AS Porcentaje
	            FROM (
	                SELECT Ahora.Fecha, Antes.CodOficina, Antes.Tabla, Antes.Antes, Ahora.Ahora, ABS(Ahora.Ahora - Antes.Antes) AS Diferencia, 
	                       CASE WHEN antes > ahora THEN cast(antes AS decimal(18, 4)) ELSE cast(ahora AS decimal(18, 4)) END AS Mayor
	                FROM (
	                    SELECT DISTINCT A.Fecha, A.CodOficina, A.Tabla, A.Registros AS Antes
	                    FROM tCsCierresArchivos A
	                    INNER JOIN tCsConsistenciaUsuario U ON A.Tabla = U.Tabla
                        WHERE A.Fecha = @Fecha - 1 AND U.CampoFecha = 1
                    ) Antes 
                    INNER JOIN (
                        SELECT DISTINCT A.Fecha, A.CodOficina, A.Tabla, A.Registros AS Ahora
                        FROM tCsCierresArchivos A
                        INNER JOIN tCsConsistenciaUsuario U ON A.Tabla = U.Tabla
                        WHERE A.Fecha = @Fecha AND U.CampoFecha = 1
                    ) Ahora ON Antes.CodOficina = Ahora.CodOficina AND Antes.Tabla = Ahora.Tabla
                    WHERE (ABS(Ahora.Ahora - Antes.Antes) <> 0)
                ) Datos
	            WHERE (ROUND(Diferencia / Mayor * 100, 2) = 100)
	        ) Datos
            GROUP BY Fecha, CodOficina
        ) Observadas 
        INNER JOIN (
            SELECT Fecha, CodOficina, COUNT(*) AS Total
            FROM (
                SELECT DISTINCT A.Fecha, A.CodOficina, A.Tabla, A.Registros AS Ahora
                FROM tCsCierresArchivos A
                INNER JOIN tCsConsistenciaUsuario U ON A.Tabla = U.Tabla
                WHERE A.Fecha = @Fecha AND U.CampoFecha = 1
            ) Total
            GROUP BY Fecha, CodOficina
        ) Total ON Observadas.Fecha = Total.Fecha AND Observadas.CodOficina = Total.CodOficina
    End
	
	PRINT 'SE PROCEDE A IDENTIFICAR LAS AGENCIAS QUE SE CERRARAN'

	UPDATE tClOficinas
	SET SeConsolida = 1
	WHERE CodOficina IN (
        SELECT Observadas.CodOficina
        FROM (
            SELECT Fecha, CodOficina, COUNT(*) AS Observadas
            FROM (
                SELECT *, ROUND(Diferencia / Mayor * 100, 2) AS Porcentaje
                FROM (
                    SELECT Ahora.Fecha, Antes.CodOficina, Antes.Tabla, Antes.Antes, Ahora.Ahora, ABS(Ahora.Ahora - Antes.Antes) AS Diferencia, 
                           CASE WHEN antes > ahora THEN cast(antes AS decimal(18, 4)) ELSE cast(ahora AS decimal(18, 4)) END AS Mayor
                    FROM (
                        SELECT DISTINCT A.Fecha, A.CodOficina, A.Tabla, A.Registros AS Antes
                        FROM tCsCierresArchivos A
                        INNER JOIN tCsConsistenciaUsuario U ON A.Tabla = U.Tabla
                        WHERE A.Fecha = @Fecha - 1 AND U.CampoFecha = 1
                    ) Antes 
                    INNER JOIN (
                        SELECT DISTINCT A.Fecha, A.CodOficina, A.Tabla, A.Registros AS Ahora
                        FROM tCsCierresArchivos A 
                        INNER JOIN tCsConsistenciaUsuario U ON A.Tabla = U.Tabla
                        WHERE A.Fecha = @Fecha AND U.CampoFecha = 1
                    ) Ahora ON Antes.CodOficina = Ahora.CodOficina AND Antes.Tabla = Ahora.Tabla
                    WHERE ABS(Ahora.Ahora - Antes.Antes) <> 0
                ) Datos
                WHERE ROUND(Diferencia / Mayor * 100, 2) = 100
            ) Datos
            GROUP BY Fecha, CodOficina
        ) Observadas 
        INNER JOIN (
            SELECT Fecha, CodOficina, COUNT(*) AS Total
            FROM (
                SELECT DISTINCT tCsCierresArchivos.Fecha, tCsCierresArchivos.CodOficina, tCsCierresArchivos.Tabla, tCsCierresArchivos.Registros AS Ahora
                FROM tCsCierresArchivos 
                INNER JOIN tCsConsistenciaUsuario ON tCsCierresArchivos.Tabla = tCsConsistenciaUsuario.Tabla
                WHERE (tCsCierresArchivos.Fecha = @Fecha) AND (tCsConsistenciaUsuario.CampoFecha = 1)
            ) Total
            GROUP BY Fecha, CodOficina
        ) Total ON Observadas.Fecha = Total.Fecha AND Observadas.CodOficina = Total.CodOficina
        WHERE CAST(Observadas.Observadas AS decimal(18, 4)) / CAST(Total.Total AS decimal(18, 4)) * 100 > @Porcentaje
    )
    AND Tipo IN ('Operativo', 'Servicio', 'Matriz','Cerrada')
	
	UPDATE tClOficinas
	SET    SeConsolida = 1
	WHERE  CodOficina IN (
	    SELECT DISTINCT A.CodOficina
	    FROM tCsCierresArchivos A
	    INNER JOIN tCsConsistenciaUsuario U ON A.Tabla = U.Tabla
        WHERE U.Consolidado = 1 AND A.Fecha = @Fecha AND U.CampoFecha = 1
        GROUP BY A.CodOficina
	    HAVING SUM(A.Registros) = 0
	)
		

	If @Proceso in ('FO')
	Begin
		UPDATE tClOficinas
		SET SeConsolida = 0
	End
	Declare Oficinas Cursor For
		SELECT CodOficina, Servidor, BaseDatos
		FROM   tClOficinas
		WHERE  SeConsolida = 1
		ORDER BY Cast(CodOficina as Int) Asc
	Open 	Oficinas
	Fetch Next From Oficinas Into @CodOficina, @Servidor, @BaseDatos
	While @@Fetch_Status = 0
	Begin
		--
		Print 'OFICINA: ' + @CodOficina
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[B]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		Begin drop table [dbo].[B]End
		Set @Cadena = 'CREATE TABLE [dbo].[B] ( '
		Set @Cadena = @Cadena + '[Cadena] [varchar] (1157) NULL ' 
		Set @Cadena = @Cadena + ') ON [PRIMARY] '
		Exec(@Cadena)
		Set @Cadena = 'NBTSTAT -a '+ Ltrim(rTrim(@Servidor))
		Insert Into B
		Exec master..xp_cmdshell @Cadena
		
		SELECT @Servidor =  RTRIM(LTRIM(SUBSTRING(LTRIM(RTRIM(Cadena)), 1, CHARINDEX('<00>', LTRIM(RTRIM(Cadena)), 1) - 1))) 
		FROM   B
		WHERE (Cadena LIKE '%<00>  UNIQUE%') OR (Cadena LIKE '%<00>  Único%')
	
		If Ltrim(Rtrim(@AlternoS)) <> ''
			Set @Servidor = Ltrim(Rtrim(@AlternoS))
		
		If Ltrim(Rtrim(@AlternoB)) <> ''
			Set @BaseDatos = Ltrim(Rtrim(@AlternoB))

		If @Servidor Is null 
		Begin
			Set @Cadena = 'Servidor no Encontrado'
			Select @Cadena as Observacion
		End
		Else
		Begin
			Delete From tCsCierresModulos Where CodOficina = @Codoficina And Consolidacion = @Fecha 
			Print @Servidor
			Set @Servidor = '[' + @Servidor + '].'	
			
			Set @Modulo = 'Ahorros'
			Insert Into tCsCierresModulos Values (@Fecha, @CodOficina, @Modulo, 1)
			Set @Modulo = 'Boveda'
			Insert Into tCsCierresModulos Values (@Fecha, @CodOficina, @Modulo, 1)
			Set @Modulo = 'Caja'
			Insert Into tCsCierresModulos Values (@Fecha, @CodOficina, @Modulo, 1)
			Set @Modulo = 'Cartera'
			Insert Into tCsCierresModulos Values (@Fecha, @CodOficina, @Modulo, 1)
			Set @Modulo = 'General'
			Insert Into tCsCierresModulos Values (@Fecha, @CodOficina, @Modulo, 1)			

			Set @Verificador = 0
			
			SELECT @Verificador = Count(*)
			FROM   tCsCierresModulos
			WHERE  Consolidacion = @Fecha AND CodOficina = @CodOficina AND Modulo IN ('General') AND Verificador = 1
			
			If @Verificador = 1
			Begin
				Print '--Forzo Actualización de Modulos-- Ahorros y Cartera'
				Update tCsCierresModulos
				Set Verificador = 1 
				Where Consolidacion = @Fecha And CodOficina = @CodOficina AND Modulo IN ('Ahorros', 'Cartera') AND Verificador = 0
			End
			
			UPDATE tCsCierresModulos
			SET    Verificador = 1
			WHERE  CodOficina = @ForzarCarga AND Consolidacion = @Fecha

			DELETE FROM tCsCierresMensajes
			Where CodOficina = @CodOficina AND Fecha = @Fecha	

			INSERT INTO tCsCierresMensajes
			SELECT M.Consolidacion, O.CodOficina AS Oficina, 
	               CASE Contador.Contador WHEN 0 THEN 'AGENCIA OPERANDO' 
					                      WHEN 1 THEN 'CIERRE DE CAJA CULMINADO, FALTA BOVEDA' 
					                      WHEN 2 THEN 'CIERRE DE CAJA Y BOVEDA CULMINADO, PUEDE INICIAR CIERRE OPERATIVO'
				                          WHEN 3 THEN 'PROCESANDO CIERRE OPERATIVO' 
					                      WHEN 4 THEN 'FALTA PROCESO FINAL DE CIERRE OPERATIVO' 
					                      WHEN 5 THEN 'LISTO PARA CARGARCE O AGENCIA CARGADA' 
				   END AS Observacion
		    FROM tCsCierresModulos M
		    INNER JOIN tClOficinas O ON M.CodOficina = O.CodOficina 
		    CROSS JOIN (SELECT COUNT(*) AS Contador
                        FROM  tCsCierresModulos
                        WHERE Consolidacion = @Fecha AND CodOficina = @CodOficina AND Verificador = 1
            ) Contador
			WHERE M.Consolidacion = @Fecha AND M.CodOficina = @CodOficina
			GROUP BY M.Consolidacion, O.CodOficina, Contador.Contador

			
			if NOT EXISTS (Select 1 From tCsCierresBackup 
			               Where CodOficina = @CodOficina And Fecha = @Fecha )
 			Begin 
 			    Insert Into tCsCierresBackup(Fecha, CodOficina, BackupC) Values (@Fecha, @CodOficina, 0) 
 			End
			
			SELECT @Verificador = Count(*)
			FROM   tCsCierresModulos
			WHERE  CodOficina = @CodOficina AND Consolidacion = @Fecha AND Verificador = 1

			Select 	@BackupC = BackupC 
			From 	tCsCierresBackup
			Where 	CodOficina = @CodOficina And Fecha = @Fecha
 			
			If @Verificador = 2 and @Backup = 1 and @BackupC = 0 and @Proceso = 'CA'
			Begin
				Set @Cadena = 'MD "' + @Carpeta 
				Truncate Table B
				Insert Into B
				Exec master..xp_cmdshell @Cadena

				Declare @Sigla		Varchar(10)	
				Declare @Destino	Varchar(100)	
				Declare @Tipo		Varchar(50)	
								
				Set @Sigla	= 'FNMG'
				Set @Destino	= ''	
				Set @Tipo	= 'INIT'	
				
				Update tCsCierresBackup
				Set Inicio = Null, Fin = Null
				Where Fecha = @Fecha And  CodOficina = @CodOficina

				Update tCsCierresBackup
				Set Inicio = Getdate()
				Where Fecha = @Fecha And  CodOficina = @CodOficina

				Set @Cadena 	= 'Exec ' + @Servidor + 'Master.dbo.spBackup ''' +  @Sigla + ''', '''+ SubString(Upper(@Responsable), 1, 3) +''', ''' + @BaseDatos + ''', ''' + @Carpeta + '\'', ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''', ''' + @Destino + ''', ''' +  @Tipo + ''', ''' + @CodOficina + ''''
				Print @Cadena 	
				--Exec (@Cadena)
				
				Set @Error = @@ERROR

				Update tCsCierresBackup
				Set Fin = Getdate()
				Where Fecha = @Fecha And  CodOficina = @CodOficina

				IF @Error <> 0 
				BEGIN
				 	Print 'ERROR'
					Print @Error
					Insert Into tCsCierresMensajes Values(@Fecha, @CodOficina, 'NO SE PUDO REALIZAR EL BACKUP')
				END
				ELSE
				BEGIN
				  	Update tCsCierresBackup Set BackupC = 1
					Where  CodOficina = @CodOficina And Fecha = @Fecha
					Insert Into tCsCierresMensajes Values(@Fecha, @CodOficina, 'BACKUP REALIZADO EN FORMA EXITOSA')
				END				
			End 
			
			If @Verificador = 5 And Rtrim(Ltrim(@CodOficina)) <> '' And @Proceso = 'CA'
			Begin
				Update tCsCierres 
				Set Cargado = 0
				Where Fecha = @Fecha

				Declare Estados Cursor For
					SELECT distinct 
					       'DELETE FROM ' + Tabla + ' WHERE CodOficina IN ('+ @CodOficina +') ' + CASE WHEN campofecha = 1 THEN ' AND Fecha = '''+ dbo.fduFechaAAAAMMDD(@Fecha) +'''' ELSE '' END AS Cadena,
						   'INSERT INTO ' + Tabla + ' Select * From ' + '[10.0.2.14].' +'['+ @BaseDatos +'].dbo.' + Tabla + ' WHERE CodOficina IN ('+ @CodOficina +') ' + CASE WHEN campofecha = 1 THEN ' AND Fecha = '''+ dbo.fduFechaAAAAMMDD(@Fecha) +'''' ELSE '' END as Cadena1	
					FROM  tCsConsistenciaUsuario
					WHERE Consolidado = 1 AND Existe = 1
				Open 	Estados
				Fetch Next From Estados Into @Cadena, @Cadena1
				While @@Fetch_Status = 0
				Begin				
					Print @Cadena
					Exec (@Cadena)			
					
					Print @Cadena1
					Exec (@Cadena1)
				Fetch Next From Estados Into @Cadena, @Cadena1
				End 
				Close 		Estados
				Deallocate 	Estados

				UPDATE tClOficinas
				SET  consolidadoahorros = DERIVEDTBL.Consolidado
				FROM (
				    SELECT CodOficina, MAX(Fecha) AS Consolidado
                    FROM tCsAhorros
				    WHERE CodOficina = @CodOficina And Fecha = @Fecha
                    GROUP BY CodOficina
                ) DERIVEDTBL 
                INNER JOIN tClOficinas ON DERIVEDTBL.CodOficina = tClOficinas.CodOficina
				
				
				UPDATE tClOficinas
				SET  consolidadocartera = DERIVEDTBL.Consolidado
				FROM (
				    SELECT CodOficina, MAX(Fecha) AS Consolidado
                    FROM tCscartera
					WHERE CodOficina = @CodOficina And Fecha = @Fecha
				    GROUP BY CodOficina
				) DERIVEDTBL 
				INNER JOIN tClOficinas ON DERIVEDTBL.CodOficina = tClOficinas.CodOficina
				
			End		
		End	
	Fetch Next From Oficinas Into @CodOficina, @Servidor, @BaseDatos
	End 
	Close 		Oficinas
	Deallocate 	Oficinas

	If @Proceso in ('FO')
	Begin
		UPDATE tClOficinas
		SET SeConsolida = 1
	End

End
Else
Begin
	SELECT @C = Cerrado
	FROM  tCsCierres
	WHERE Fecha = @Fecha
	
	If @C is null Begin Set @C = 0 End
	
	If @C = 1
	Begin
		Insert Into tCsCierresMensajes Values(@Fecha, 100, 'EL DIA QUE DESEA PROCESAR ESTA CERRADA')
		Insert Into tCsCierresMensajes Values(@Fecha, 100, 'NO SE PUEDE CONTINUAR CON EL PROCESO')
		Set @C = 'EL DIA QUE DESEA PROCESAR ESTA CERRADA'
	End

	SELECT @Cerrado = Cerrado
	FROM  tCsCierres
	WHERE Fecha = @Fecha - 1
	
	If @Cerrado is null Begin Set @Cerrado = 0 End
	
	If @Cerrado = 0 
	Begin
		Insert Into tCsCierresMensajes Values(@Fecha, 100, 'NO SE CORRIO EL DTS DEL DIA ANTERIOR')
		Insert Into tCsCierresMensajes Values(@Fecha, 100, 'NO SE PUEDE CONTINUAR CON EL PROCESO')
		Set @C = 'NO SE CORRIO EL DTS DEL DIA ANTERIOR'
	End
	
	If @Proceso Not In ('CO', 'CA', 'FR', 'FO', 'RU')
	Begin
		Insert Into tCsCierresMensajes Values(@Fecha, 100, 'NO SE PUEDE IDENTIFICAR LA ACCION DEL PROCESO')
		Set @C = 'NO SE PUEDE IDENTIFICAR LA ACCION DEL PROCESO'
	End
	
	If @Proceso In ('FR')
	Begin
		Exec pCsFrase @Frase Out
		Insert Into tCsCierresMensajes Values(@Fecha, 100, @Frase)
		Delete From tCsCierresMensajes
		Where Fecha = @Fecha And CodOficina = '100' And Mensaje Like 'Un día como hoy en%'
		
		Insert Into tCsCierresMensajes (Fecha, CodOficina, Mensaje)
		SELECT @Fecha, '100', 'Un día como hoy en ' + CAST(Año AS Varchar(4)) + ' : ' + Descripcion AS Frase
		FROM  tCsFraseDia
		WHERE Mes = Month(@Fecha) AND Dia = Day(@Fecha)
	End
End

Select @Verificador = Count(*)
From tClOficinas
Where SeConsolida = 1 And Tipo in ('Operativo', 'Servicio', 'Matriz','Cerrada')

Select @Verificador1 = Count(*)
From tCsCierres
Where Fecha = @Fecha And Cargado = 1

SELECT @Verificador2 = COUNT(*) 
FROM   vCsFechaConsolidacion
WHERE  FechaConsolidacion = @Fecha

If @Verificador = 0 And @Verificador1 = 0 And @Verificador2 = 1
Begin
	Delete From tCsCierres Where Fecha = @Fecha
	Insert Into tCsCierres (Fecha, Cargado, Cerrado, Responsable) Values (@Fecha, 1, 0, @Responsable)
End 

If @Verificador1 = 1
Begin
	Insert Into tCsCierresMensajes Values(@Fecha, 100, 'FECHA CON PROCESO DE CARGA CULMINADO')
End

Select @Verificador = Count(*)
From tCsCierres
Where Fecha = @Fecha And Cerrado = 0 And Cargado = 1

If @Verificador = 1
Begin
	If @Cerrado = 1 
	Begin
		Exec pCsFrase @Frase Out
		Insert Into tCsCierresMensajes Values(@Fecha, 100, @Frase)
		Insert Into tCsCierresMensajes Values(@Fecha, 100, 'AHORA PUEDES CORRER EL DTS DE CIERRE')
		Delete From tCsCierresMensajes
		Where Fecha = @Fecha And CodOficina = '100' And Mensaje Like 'Un día como hoy en%'
		Insert Into tCsCierresMensajes (Fecha, CodOficina, Mensaje)
		SELECT @Fecha, '100', 'Un día como hoy en ' + CAST(Año AS Varchar(4)) + ' : ' + Descripcion AS Frase
		FROM   tCsFraseDia
		WHERE  Mes = Month(@Fecha) AND Dia = Day(@Fecha)
	End	
End

Select @Verificador = Count(*)
From tCsCierres
Where Fecha = @Fecha And Cerrado = 1

If @Verificador = 1 And @Verificador1 = 1
Begin
	If @Cerrado = 1 
	Begin
		Insert Into tCsCierresMensajes Values(@Fecha, 100, 'FECHA CON PROCESO DE CIERRE CULMINADO')
	End		
End 

Insert Into tCsCierresMensajes Values(@Fecha, 100, 'EJECUCION DE SENTENCIA CULMINADA')

If @Proceso not in ('FO')
Begin
    SELECT dbo.fduFechaATexto(M.Fecha, 'AAAAMMDD') AS Fecha, '[' + dbo.fduRellena('0', M.CodOficina, 3, 'D') 
           + ' ' + 	CASE WHEN backupc = 0 AND inicio IS NULL 	AND fin IS NULL  THEN 'Sin BK' 
					     WHEN backupc = 0 AND inicio IS NOT NULL AND fin IS NULL THEN 'BK Pro' 
					     WHEN backupc = 0 AND inicio IS NOT NULL AND fin IS NOT NULL THEN 'BK Err' 
					     WHEN backupc = 1 AND inicio IS NOT NULL AND fin IS NOT NULL THEN 'BK Exi' 
						 ELSE 'BK NEs' 
				    END
	       + '] ' + ISNULL(tClOficinas.NomOficina, 'CONSOLIDADA') AS Oficina, M.Mensaje
    FROM tCsCierresMensajes M
    LEFT JOIN tCsCierresBackup B ON M.Fecha = B.Fecha AND M.CodOficina = B.CodOficina 
    LEFT OUTER JOIN tClOficinas ON M.CodOficina = tClOficinas.CodOficina
    WHERE M.Fecha = @Fecha
    ORDER BY M.CodOficina
End

GO