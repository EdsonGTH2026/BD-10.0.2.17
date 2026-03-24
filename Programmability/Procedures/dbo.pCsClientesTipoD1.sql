SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--Exec pCsClientesTipoD1 '20110601'
CREATE Procedure [dbo].[pCsClientesTipoD1]

@Fecha SmallDateTime

As
Declare @CodUsuario			Varchar(15)
Declare @Referencia			Varchar(100)
Declare @NombreCompleto		Varchar(100)
Declare @Temporal			Varchar(100)
Declare @Procesar			Bit
Declare @CodOficina			Varchar(4)

UPDATE  tcsPadronClientesTipo
Set NombreCompleto = 'REVIZAR'
Where NombreCompleto Is Null and Fecha = @Fecha And Activo = 0

DELETE FROM tCsPadronClientesTipo
WHERE     (CodUsuario IN
                          (SELECT     tCsPadronClientesTipo.CodUsuario
                            FROM          tCsPadronClientesTipo LEFT OUTER JOIN
                                                   tCsPadronAhorros ON tCsPadronClientesTipo.Referencia = tCsPadronAhorros.CodCuenta
                            WHERE      (tCsPadronClientesTipo.NombreCompleto = 'REVIZAR') AND (tCsPadronClientesTipo.Fecha = @Fecha) AND (tCsPadronClientesTipo.Activo = 0) AND 
                                                   (tCsPadronClientesTipo.Tipo = 'AHORRADOR') AND (tCsPadronAhorros.CodCuenta IS NULL))) AND (Tipo = 'AHORRADOR') AND (Fecha = @Fecha)

Set @CodUsuario = 'X'

While @CodUsuario <> ''
Begin 
	Set @CodUsuario = ''
	SELECT     TOP 1 @CodUsuario = Antiguo
	FROM         (SELECT     Antiguo
						   FROM          (SELECT DISTINCT Fecha, Antiguo, Nuevo
												   FROM          (SELECT     Fecha, Antiguo, Nuevo, CASE WHEN CharIndex(LEFT(ltrim(rtrim(Nuevo)), Len(Nuevo) - 1), ltrim(rtrim(Antiguo)), 1) 
																								  > 0 THEN 1 WHEN CharIndex(LEFT(ltrim(rtrim(Antiguo)), Len(Antiguo) - 1), ltrim(rtrim(Nuevo)), 1) 
																								  > 0 THEN 1 WHEN RIGHT(ltrim(rtrim(Antiguo)), 7) = RIGHT(ltrim(rtrim(Nuevo)), 7) THEN 1 WHEN LEFT(ltrim(rtrim(Antiguo)), 3) 
																								  = LEFT(ltrim(rtrim(Nuevo)), 3) THEN 1 END AS Validar
																		   FROM          (SELECT     tCsPadronClientesTipo.Fecha, tCsPadronClientesTipo.CodUsuario AS Antiguo, 
																														  tCsPadronClientesTipo_1.CodUsuario AS Nuevo
																								   FROM          tCsPadronClientesTipo INNER JOIN
																														  tCsPadronClientesTipo AS tCsPadronClientesTipo_1 ON 
																														  tCsPadronClientesTipo.Fecha = tCsPadronClientesTipo_1.Fecha AND 
																														  tCsPadronClientesTipo.Tipo = tCsPadronClientesTipo_1.Tipo AND 
																														  tCsPadronClientesTipo.CodUsuario <> tCsPadronClientesTipo_1.CodUsuario AND 
																														  tCsPadronClientesTipo.Referencia = tCsPadronClientesTipo_1.Referencia
																								   WHERE      (tCsPadronClientesTipo.NombreCompleto = 'REVIZAR') AND (tCsPadronClientesTipo.Fecha = @Fecha) AND 
																														  (tCsPadronClientesTipo.Activo = 0)) AS Datos) AS Datos
												   WHERE      (Validar = 1)) AS Datos
						   GROUP BY Antiguo
						   HAVING      (COUNT(*) = 1)) AS Datos
	ORDER BY NEWID()
	
	If @CodUsuario Is null Begin Set @CodUsuario = '' End
	
	If @CodUsuario <> ''
	Begin 
		Delete From tCsPadronClientesTipo 
		Where CodUsuario = @CodUsuario and Fecha = @Fecha
	End
	Else
	Begin
		Break
	End
End 

Declare curParametro Cursor For
	Select Distinct CodUsuario, Referencia, CodOficina 
	From tcsPadronClientesTipo
	Where NombreCompleto = 'REVIZAR' and Fecha = @Fecha
	Open curParametro
Fetch Next From curParametro Into  @CodUsuario, @Referencia, @CodOficina
While @@Fetch_Status = 0
Begin
	Set @Procesar = 1
	
		If @Procesar = 1 --VERIFICA CREDITO INDIVIDUAL
		Begin
			If (Select Count(*) From (SELECT DISTINCT tCsPadronClientesTipo.CodUsuario, tCsPadronCarteraDet.CodUsuario AS Nuevo, tCsPadronClientes.NombreCompleto
					FROM         tCsPadronClientesTipo INNER JOIN
										  tCsPadronCarteraDet ON tCsPadronClientesTipo.Referencia = tCsPadronCarteraDet.CodPrestamo INNER JOIN
										  tCsPadronClientes ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario
					WHERE     (tCsPadronClientesTipo.Fecha = @Fecha) AND (tCsPadronClientesTipo.Tipo = 'ACREDITADO') AND 
										  (tCsPadronClientesTipo.CodUsuario IN (@CodUsuario))) Datos) = 1			
			Begin
				SELECT DISTINCT @CodUsuario = tCsPadronClientesTipo.CodUsuario, @Temporal = tCsPadronCarteraDet.CodUsuario, @NombreCompleto = tCsPadronClientes.NombreCompleto
					FROM         tCsPadronClientesTipo INNER JOIN
										  tCsPadronCarteraDet ON tCsPadronClientesTipo.Referencia = tCsPadronCarteraDet.CodPrestamo INNER JOIN
										  tCsPadronClientes ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario
					WHERE     (tCsPadronClientesTipo.Fecha = @Fecha) AND (tCsPadronClientesTipo.Tipo = 'ACREDITADO') AND 
										  (tCsPadronClientesTipo.CodUsuario IN (@CodUsuario))
				
				Print @CodUsuario
				Print @Temporal
				
				If (Select Count(*) From (Select Distinct CodUsuario From tcsPadronClientesTipo
											Where CodUsuario in (@CodUsuario, @Temporal)) as Datos ) > 1
				Begin 
					DELETE FROM tCsPadronClientesTipo
					WHERE     (CodUsuario + Tipo IN
											  (SELECT DISTINCT A.CodUsuario + A.Tipo
												FROM          (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																							   Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																		FROM          tCsPadronClientesTipo
																		WHERE      (CodUsuario = @CodUsuario) AND (Fecha = @Fecha)) AS A INNER JOIN
																		   (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																									Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																			 FROM          tCsPadronClientesTipo
																			 WHERE      (CodUsuario = @Temporal) AND (Fecha = @Fecha)) AS B ON A.Fecha = B.Fecha AND A.Tipo = B.Tipo)) AND (Fecha = @Fecha) 

					Set @Procesar = 0
				End 
				
				Update tCsPadronClientesTipo
				Set		CodUsuario = @Temporal, NombreCompleto = @NombreCompleto
				Where	CodUsuario = @CodUsuario and Fecha = @Fecha
				Set @Procesar = 0			
			End 
		End	
	
	If @Procesar = 1 --VERIFICA AHORRO
		Begin
			If (Select Count(*) From (SELECT DISTINCT tCsPadronClientesTipo.CodUsuario, tCsClientesAhorrosFecha.CodUsCuenta, tCsPadronClientes.NombreCompleto
					FROM         tCsPadronClientesTipo INNER JOIN
										  tCsClientesAhorrosFecha ON tCsPadronClientesTipo.Referencia = tCsClientesAhorrosFecha.CodCuenta AND 
										  RIGHT(LTRIM(RTRIM(tCsPadronClientesTipo.CodUsuario)), LEN(tCsPadronClientesTipo.CodUsuario) - 1) 
										  = RIGHT(LTRIM(RTRIM(tCsClientesAhorrosFecha.CodUsCuenta)), LEN(tCsClientesAhorrosFecha.CodUsCuenta) - 1) INNER JOIN
										  tCsPadronClientes ON tCsClientesAhorrosFecha.CodUsCuenta = tCsPadronClientes.CodUsuario
					WHERE     (tCsPadronClientesTipo.CodUsuario = @CodUsuario) And tCsPadronClientesTipo.Fecha = @Fecha) Datos) = 1			
			Begin
				SELECT DISTINCT @CodUsuario		= tCsPadronClientesTipo.CodUsuario, 
								@Temporal		= tCsClientesAhorrosFecha.CodUsCuenta, 
								@NombreCompleto	= tCsPadronClientes.NombreCompleto
					FROM         tCsPadronClientesTipo INNER JOIN
										  tCsClientesAhorrosFecha ON tCsPadronClientesTipo.Referencia = tCsClientesAhorrosFecha.CodCuenta AND 
										  RIGHT(LTRIM(RTRIM(tCsPadronClientesTipo.CodUsuario)), LEN(tCsPadronClientesTipo.CodUsuario) - 1) 
										  = RIGHT(LTRIM(RTRIM(tCsClientesAhorrosFecha.CodUsCuenta)), LEN(tCsClientesAhorrosFecha.CodUsCuenta) - 1) INNER JOIN
										  tCsPadronClientes ON tCsClientesAhorrosFecha.CodUsCuenta = tCsPadronClientes.CodUsuario
					WHERE     (tCsPadronClientesTipo.CodUsuario = @CodUsuario) And tCsPadronClientesTipo.Fecha = @Fecha
				
				Print @CodUsuario
				Print @Temporal
				
				If (Select Count(*) From (Select Distinct CodUsuario From tcsPadronClientesTipo
											Where CodUsuario in (@CodUsuario, @Temporal)) as Datos ) > 1
				Begin 
					DELETE FROM tCsPadronClientesTipo
					WHERE     (CodUsuario + Tipo IN
											  (SELECT DISTINCT A.CodUsuario + A.Tipo
												FROM          (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																							   Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																		FROM          tCsPadronClientesTipo
																		WHERE      (CodUsuario = @CodUsuario) AND (Fecha = @Fecha)) AS A INNER JOIN
																		   (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																									Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																			 FROM          tCsPadronClientesTipo
																			 WHERE      (CodUsuario = @Temporal) AND (Fecha = @Fecha)) AS B ON A.Fecha = B.Fecha AND A.Tipo = B.Tipo)) AND (Fecha = @Fecha) 

					Set @Procesar = 0
				End 
				
				Update tCsPadronClientesTipo
				Set		CodUsuario = @Temporal, NombreCompleto = @NombreCompleto
				Where	CodUsuario = @CodUsuario and Fecha = @Fecha
				Set @Procesar = 0			
			End 
		End
		
	If @Procesar = 1 --VERIFICA AHORRO INDIVIDUAL
	Begin
		If (Select Count(*) From (SELECT DISTINCT tCsClientesAhorrosFecha.CodUsCuenta, tCsClientesAhorrosFecha.CodUsuario, tCsPadronClientes.NombreCompleto
					FROM         tCsClientesAhorrosFecha INNER JOIN
										  tCsPadronClientes ON tCsClientesAhorrosFecha.CodUsCuenta = tCsPadronClientes.CodUsuario
					WHERE     (tCsClientesAhorrosFecha.CodCuenta = @Referencia) AND (tCsClientesAhorrosFecha.FormaManejo = 1) AND (tCsClientesAhorrosFecha.idEstado = 'AC')
					--And tCsPadronClientesTipo.Fecha = @Fecha
					) Datos) = 1			
		Begin
			Select Distinct @Temporal = tCsPadronClientes.CodUsuario, @NombreCompleto = tCsPadronClientes.NombreCompleto
					FROM         tCsClientesAhorrosFecha INNER JOIN
										  tCsPadronClientes ON tCsClientesAhorrosFecha.CodUsCuenta = tCsPadronClientes.CodUsuario
					WHERE     (tCsClientesAhorrosFecha.CodCuenta = @Referencia) AND (tCsClientesAhorrosFecha.FormaManejo = 1) AND (tCsClientesAhorrosFecha.idEstado = 'AC')
					--And tCsPadronClientesTipo.Fecha = @Fecha
			
			Print @CodUsuario
			Print @Temporal
			
			If (Select Count(*) From (Select Distinct CodUsuario From tcsPadronClientesTipo
										Where CodUsuario in (@CodUsuario, @Temporal)) as Datos ) > 1
			Begin 
				DELETE FROM tCsPadronClientesTipo
				WHERE     (CodUsuario + Tipo IN
										  (SELECT DISTINCT A.CodUsuario + A.Tipo
											FROM          (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																						   Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																	FROM          tCsPadronClientesTipo
																	WHERE      (CodUsuario = @CodUsuario) AND (Fecha = @Fecha)) AS A INNER JOIN
																	   (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																								Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																		 FROM          tCsPadronClientesTipo
																		 WHERE      (CodUsuario = @Temporal) AND (Fecha = @Fecha)) AS B ON A.Fecha = B.Fecha AND A.Tipo = B.Tipo)) AND (Fecha = @Fecha) 

				Set @Procesar = 0
			End 
			
			Update tCsPadronClientesTipo
			Set		CodUsuario = @Temporal, NombreCompleto = @NombreCompleto
			Where	CodUsuario = @CodUsuario and Fecha = @Fecha
			Set @Procesar = 0			
		End 
	End	
	If @Procesar = 1	--VERIFICA CREDITO 
	Begin
		If (SELECT COUNT(*) FROM (SELECT DISTINCT tCsPadronClientesTipo.CodUsuario, tCsPadronCarteraDet.CodUsuario AS Nuevo, tCsPadronClientes.NombreCompleto
				FROM         tCsPadronCarteraDet INNER JOIN
									  tCsPadronClientes ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN
									  tCsPadronClientesTipo ON tCsPadronCarteraDet.CodPrestamo = tCsPadronClientesTipo.Referencia AND 
									  (
									  
									  REPLACE(LEFT(LTRIM(RTRIM(tCsPadronClientes.CodUsuario)), LEN(tCsPadronClientes.CodUsuario) - 1), '-', 'X') 
									  = REPLACE(LEFT(LTRIM(RTRIM(tCsPadronClientesTipo.CodUsuario)), LEN(tCsPadronClientesTipo.CodUsuario) - 1), '-', 'X') 
									  OR
									   REPLACE(RIGHT(LTRIM(RTRIM(tCsPadronClientes.CodUsuario)), 7), '-', 'X') 
									  = REPLACE(RIGHT(LTRIM(RTRIM(tCsPadronClientesTipo.CodUsuario)), 7), '-', 'X')
									  OR
									  REPLACE(LEFT(LTRIM(RTRIM(tCsPadronClientes.CodUsuario)), 5), '-', 'X') 
									  = REPLACE(LEFT(LTRIM(RTRIM(tCsPadronClientesTipo.CodUsuario)), 5), '-', 'X')
									  OR 
									  tCsPadronClientesTipo.NombreCompleto = tCsPadronClientes.NombreCompleto)
				WHERE     (tCsPadronClientesTipo.CodUsuario IN (@CodUsuario)) And tCsPadronClientesTipo.Fecha = @Fecha) AS Datos) = 1
		Begin
			SELECT DISTINCT @CodUsuario		= tCsPadronClientesTipo.CodUsuario, 
							@Temporal		= tCsPadronCarteraDet.CodUsuario,
							@NombreCompleto = tCsPadronClientes.NombreCompleto FROM 
				tCsPadronCarteraDet INNER JOIN tCsPadronClientes ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario 
				INNER JOIN tCsPadronClientesTipo ON tCsPadronCarteraDet.CodPrestamo = tCsPadronClientesTipo.Referencia AND 
				(
				Replace(LEFT(LTRIM(RTRIM(tCsPadronClientes.CodUsuario)), LEN(tCsPadronClientes.CodUsuario) - 1), '-', 'X') = 
				Replace(LEFT(LTRIM(RTRIM(tCsPadronClientesTipo.CodUsuario)), LEN(tCsPadronClientesTipo.CodUsuario) - 1), '-', 'X') 
				OR 
				REPLACE(RIGHT(LTRIM(RTRIM(tCsPadronClientes.CodUsuario)), 7), '-', 'X') 
				= REPLACE(RIGHT(LTRIM(RTRIM(tCsPadronClientesTipo.CodUsuario)), 7), '-', 'X')									  
				OR
				 REPLACE(LEFT(LTRIM(RTRIM(tCsPadronClientes.CodUsuario)), 5), '-', 'X') 
				  = REPLACE(LEFT(LTRIM(RTRIM(tCsPadronClientesTipo.CodUsuario)), 5), '-', 'X')
				  OR 
				tCsPadronClientesTipo.NombreCompleto = tCsPadronClientes.NombreCompleto) WHERE (tCsPadronClientesTipo.CodUsuario IN 
				(@CodUsuario)) And tCsPadronClientesTipo.Fecha = @Fecha
			
			Print @CodUsuario
			Print @Temporal
			
			If (Select Count(*) From (Select Distinct CodUsuario From tcsPadronClientesTipo
										Where CodUsuario in (@CodUsuario, @Temporal)) as Datos ) > 1
			Begin 
				DELETE FROM tCsPadronClientesTipo
				WHERE     (CodUsuario + Tipo IN
										  (SELECT DISTINCT A.CodUsuario + A.Tipo
											FROM          (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																						   Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																	FROM          tCsPadronClientesTipo
																	WHERE      (CodUsuario = @CodUsuario) AND (Fecha = @Fecha)) AS A INNER JOIN
																	   (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																								Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																		 FROM          tCsPadronClientesTipo
																		 WHERE      (CodUsuario = @Temporal) AND (Fecha = @Fecha)) AS B ON A.Fecha = B.Fecha AND A.Tipo = B.Tipo)) AND (Fecha = @Fecha) 

				Set @Procesar = 0
			End 
			
			Update tCsPadronClientesTipo
			Set		CodUsuario = @Temporal, NombreCompleto = @NombreCompleto
			Where	CodUsuario = @CodUsuario and Fecha = @Fecha
			Set @Procesar = 0			
		End		
	End
	If @Procesar = 1	--VERIFICA ENVIOS DELGADO
	Begin
		If (SELECT COUNT(*) FROM (SELECT DISTINCT Datos.CodUsuario, tCsPadronClientes.CodUsuario AS Nuevo, tCsPadronClientes.NombreCompleto
				FROM         (SELECT     CodUsuario, CAST(CAST(LEFT(Referencia, 3) AS int) AS Varchar(4)) AS CodOficina, CAST(SUBSTRING(Referencia, 5, 8) AS SmallDateTime) AS Fecha, 
															  CAST(CAST(SUBSTRING(Referencia, 14, 3) AS Int) AS Varchar(4)) AS Transaccion
									   FROM          tCsPadronClientesTipo
									   WHERE      (Fecha = @Fecha) AND (Tipo NOT IN ('ACREDITADO', 'AHORRADOR', 'CODEUDOR', 'AVAL')) AND (CodUsuario IN (@CodUsuario))) AS Datos INNER JOIN
									  tCsTransaccionDiaria ON Datos.CodOficina = tCsTransaccionDiaria.CodOficina AND Datos.Fecha = tCsTransaccionDiaria.Fecha AND 
									  Datos.Transaccion = tCsTransaccionDiaria.TipoTransacNivel3 INNER JOIN
										  (SELECT     REPLACE(tCsEnviosDelgado.DLName + ' ' + tCsEnviosDelgado.DFName, '  ', ' ') AS NombreCompleto, tCsEnviosDelgado.DCity AS Agencia, 
																   CAST(RIGHT(tCsEnviosDelgadoConf.Datecr, 4) + LEFT(tCsEnviosDelgadoConf.Datecr, 2) + SUBSTRING(tCsEnviosDelgadoConf.Datecr, 4, 2) 
																   AS SmallDateTime) AS Fecha, tCsEnviosDelgadoConf._Time AS Hora, tCsEnviosDelgadoConf.Notes AS Observacion, 
																   tCsEnviosDelgadoConf.Id_Receiver AS DI, tClOficinas.CodOficina
											FROM          tCsEnviosDelgadoConf INNER JOIN
																   tCsEnviosDelgado ON tCsEnviosDelgadoConf.Invoice = tCsEnviosDelgado.Invoice AND 
																   tCsEnviosDelgadoConf.Invoice_Prov = tCsEnviosDelgado.Invoice_Prov INNER JOIN
																   tClOficinas ON tCsEnviosDelgado.IDBANK = tClOficinas.idBanksDelgado) AS Delgado ON tCsTransaccionDiaria.Fecha = Delgado.Fecha AND 
									  tCsTransaccionDiaria.CodOficina = Delgado.CodOficina INNER JOIN
									  tCsPadronClientes ON Delgado.NombreCompleto = tCsPadronClientes.NombreCompleto AND Left(Datos.CodUsuario, 7) = Left(tCsPadronClientes.CodUsuario, 7)) AS Datos) = 1
		Begin
			SELECT DISTINCT @CodUsuario = Datos.CodUsuario, @Temporal = tCsPadronClientes.CodUsuario, @NombreCompleto = tCsPadronClientes.NombreCompleto
				FROM         (SELECT     CodUsuario, CAST(CAST(LEFT(Referencia, 3) AS int) AS Varchar(4)) AS CodOficina, CAST(SUBSTRING(Referencia, 5, 8) AS SmallDateTime) AS Fecha, 
															  CAST(CAST(SUBSTRING(Referencia, 14, 3) AS Int) AS Varchar(4)) AS Transaccion
									   FROM          tCsPadronClientesTipo
									   WHERE      (Fecha = @Fecha) AND (Tipo NOT IN ('ACREDITADO', 'AHORRADOR', 'CODEUDOR', 'AVAL')) AND (CodUsuario IN (@CodUsuario))) AS Datos INNER JOIN
									  tCsTransaccionDiaria ON Datos.CodOficina = tCsTransaccionDiaria.CodOficina AND Datos.Fecha = tCsTransaccionDiaria.Fecha AND 
									  Datos.Transaccion = tCsTransaccionDiaria.TipoTransacNivel3 INNER JOIN
										  (SELECT     REPLACE(tCsEnviosDelgado.DLName + ' ' + tCsEnviosDelgado.DFName, '  ', ' ') AS NombreCompleto, tCsEnviosDelgado.DCity AS Agencia, 
																   CAST(RIGHT(tCsEnviosDelgadoConf.Datecr, 4) + LEFT(tCsEnviosDelgadoConf.Datecr, 2) + SUBSTRING(tCsEnviosDelgadoConf.Datecr, 4, 2) 
																   AS SmallDateTime) AS Fecha, tCsEnviosDelgadoConf._Time AS Hora, tCsEnviosDelgadoConf.Notes AS Observacion, 
																   tCsEnviosDelgadoConf.Id_Receiver AS DI, tClOficinas.CodOficina
											FROM          tCsEnviosDelgadoConf INNER JOIN
																   tCsEnviosDelgado ON tCsEnviosDelgadoConf.Invoice = tCsEnviosDelgado.Invoice AND 
																   tCsEnviosDelgadoConf.Invoice_Prov = tCsEnviosDelgado.Invoice_Prov INNER JOIN
																   tClOficinas ON tCsEnviosDelgado.IDBANK = tClOficinas.idBanksDelgado) AS Delgado ON tCsTransaccionDiaria.Fecha = Delgado.Fecha AND 
									  tCsTransaccionDiaria.CodOficina = Delgado.CodOficina INNER JOIN
									  tCsPadronClientes ON Delgado.NombreCompleto = tCsPadronClientes.NombreCompleto AND Left(Datos.CodUsuario, 7) = Left(tCsPadronClientes.CodUsuario, 7)
			
			Print @CodUsuario
			Print @Temporal
			
			If (Select Count(*) From (Select Distinct CodUsuario From tcsPadronClientesTipo
										Where CodUsuario in (@CodUsuario, @Temporal)) as Datos ) > 1
			Begin 
				DELETE FROM tCsPadronClientesTipo
				WHERE     (CodUsuario + Tipo IN
										  (SELECT DISTINCT A.CodUsuario + A.Tipo
											FROM          (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																						   Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																	FROM          tCsPadronClientesTipo
																	WHERE      (CodUsuario = @CodUsuario) AND (Fecha = @Fecha)) AS A INNER JOIN
																	   (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																								Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																		 FROM          tCsPadronClientesTipo
																		 WHERE      (CodUsuario = @Temporal) AND (Fecha = @Fecha)) AS B ON A.Fecha = B.Fecha AND A.Tipo = B.Tipo)) AND (Fecha = @Fecha) 

				Set @Procesar = 0
			End 
			
			Update tCsPadronClientesTipo
			Set		CodUsuario = @Temporal, NombreCompleto = @NombreCompleto
			Where	CodUsuario = @CodUsuario and Fecha = @Fecha
			Set @Procesar = 0			
		End		
	End
	If @Procesar = 1	--VERIFICA SERVICIOS
	Begin
		If (SELECT COUNT(*) FROM (SELECT DISTINCT Datos.CodUsuario, tCsTransaccionDiaria.CodUsuario AS Nuevo, tCsPadronClientes.NombreCompleto
				FROM         (SELECT     CodUsuario, CAST(CAST(LEFT(Referencia, 3) AS int) AS Varchar(4)) AS CodOficina, CAST(SUBSTRING(Referencia, 5, 8) AS SmallDateTime) AS Fecha, 
															  CAST(CAST(SUBSTRING(Referencia, 14, 3) AS Int) AS Varchar(4)) AS Transaccion
									   FROM          tCsPadronClientesTipo
									   WHERE      (Fecha = @Fecha) AND (Tipo NOT IN ('ACREDITADO', 'AHORRADOR', 'CODEUDOR', 'AVAL')) AND 
															  (CodUsuario IN (@CodUsuario))) AS Datos INNER JOIN
									  tCsTransaccionDiaria ON Datos.CodOficina = tCsTransaccionDiaria.CodOficina AND Datos.Fecha = tCsTransaccionDiaria.Fecha AND 
									  Datos.Transaccion = tCsTransaccionDiaria.TipoTransacNivel3 AND (
									  LEFT(LTRIM(RTRIM(tCsTransaccionDiaria.CodUsuario)), 3) 
									   = LEFT(LTRIM(RTRIM(Datos.CodUsuario)), 3) 
									   OR
									   RIGHT(LTRIM(RTRIM(tCsTransaccionDiaria.CodUsuario)), 7) 
									   = RIGHT(LTRIM(RTRIM(Datos.CodUsuario)), 7) 
									   )
									   INNER JOIN
									  tCsPadronClientes ON tCsTransaccionDiaria.CodUsuario = tCsPadronClientes.CodUsuario) AS Datos) = 1
		Begin
			SELECT DISTINCT @CodUsuario = Datos.CodUsuario, @Temporal = tCsTransaccionDiaria.CodUsuario, @NombreCompleto = tCsPadronClientes.NombreCompleto
			FROM         (SELECT     CodUsuario, CAST(CAST(LEFT(Referencia, 3) AS int) AS Varchar(4)) AS CodOficina, CAST(SUBSTRING(Referencia, 5, 8) AS SmallDateTime) AS Fecha, 
														  CAST(CAST(SUBSTRING(Referencia, 14, 3) AS Int) AS Varchar(4)) AS Transaccion
								   FROM          tCsPadronClientesTipo
								   WHERE    (Fecha = @Fecha) AND (Tipo NOT IN ('ACREDITADO', 'AHORRADOR', 'CODEUDOR', 'AVAL')) AND 
														  (CodUsuario IN (@CodUsuario))) AS Datos INNER JOIN
								  tCsTransaccionDiaria ON Datos.CodOficina = tCsTransaccionDiaria.CodOficina AND Datos.Fecha = tCsTransaccionDiaria.Fecha AND 
								  Datos.Transaccion = tCsTransaccionDiaria.TipoTransacNivel3 AND (
									  LEFT(LTRIM(RTRIM(tCsTransaccionDiaria.CodUsuario)), 3) 
									   = LEFT(LTRIM(RTRIM(Datos.CodUsuario)), 3) 
									   OR
									   RIGHT(LTRIM(RTRIM(tCsTransaccionDiaria.CodUsuario)), 7) 
									   = RIGHT(LTRIM(RTRIM(Datos.CodUsuario)), 7) 
									   ) INNER JOIN
								  tCsPadronClientes ON tCsTransaccionDiaria.CodUsuario = tCsPadronClientes.CodUsuario
			
			Print @CodUsuario
			Print @Temporal
			
			If (Select Count(*) From (Select Distinct CodUsuario From tcsPadronClientesTipo
										Where CodUsuario in (@CodUsuario, @Temporal)) as Datos ) > 1
			Begin 
				DELETE FROM tCsPadronClientesTipo
				WHERE     (CodUsuario + Tipo IN
										  (SELECT DISTINCT A.CodUsuario + A.Tipo
											FROM          (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																						   Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																	FROM          tCsPadronClientesTipo
																	WHERE      (CodUsuario = @CodUsuario) AND (Fecha = @Fecha)) AS A INNER JOIN
																	   (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																								Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																		 FROM          tCsPadronClientesTipo
																		 WHERE      (CodUsuario = @Temporal) AND (Fecha = @Fecha)) AS B ON A.Fecha = B.Fecha AND A.Tipo = B.Tipo)) AND (Fecha = @Fecha) 

				Set @Procesar = 0
			End 
			
			Update tCsPadronClientesTipo
			Set		CodUsuario = @Temporal, NombreCompleto = @NombreCompleto
			Where	CodUsuario = @CodUsuario and Fecha = @Fecha
			Set @Procesar = 0			
		End		
	End
	If @Procesar = 1	--VERIFICA CODEUDORES
	Begin
		If (SELECT COUNT(*) FROM (SELECT DISTINCT tCsPadronClientesTipo.CodUsuario, tCsPadronClientes.CodUsuario AS Nuevo, tCsPadronClientes.NombreCompleto
				FROM         tCsPadronClientesTipo INNER JOIN
									  tCsFirmaElectronica ON tCsPadronClientesTipo.Referencia = tCsFirmaElectronica.Dato INNER JOIN
									  tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma INNER JOIN
									  tCsPadronClientes ON tCsFirmaReporteDetalle.Sujeto = tCsPadronClientes.NombreCompleto
				WHERE     (tCsPadronClientesTipo.CodUsuario IN (@CodUsuario)) AND (tCsPadronClientesTipo.Tipo = 'CODEUDOR') AND (tCsFirmaReporteDetalle.Grupo = 'C')
				And tCsPadronClientesTipo.Fecha = @Fecha) AS Datos) = 1
		Begin
			SELECT DISTINCT @CodUsuario			= tCsPadronClientesTipo.CodUsuario, 
							@Temporal			= tCsPadronClientes.CodUsuario, 
							@NombreCompleto		= tCsPadronClientes.NombreCompleto
			FROM         tCsPadronClientesTipo INNER JOIN
								  tCsFirmaElectronica ON tCsPadronClientesTipo.Referencia = tCsFirmaElectronica.Dato INNER JOIN
								  tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma INNER JOIN
								  tCsPadronClientes ON tCsFirmaReporteDetalle.Sujeto = tCsPadronClientes.NombreCompleto
			WHERE     (tCsPadronClientesTipo.CodUsuario IN (@CodUsuario)) AND (tCsPadronClientesTipo.Tipo = 'CODEUDOR') AND (tCsFirmaReporteDetalle.Grupo = 'C')
			And tCsPadronClientesTipo.Fecha = @Fecha
			
			Print @CodUsuario
			Print @Temporal
			
			If (Select Count(*) From (Select Distinct CodUsuario From tcsPadronClientesTipo
										Where CodUsuario in (@CodUsuario, @Temporal)) as Datos ) > 1
			Begin 
				DELETE FROM tCsPadronClientesTipo
				WHERE     (CodUsuario + Tipo IN
										  (SELECT DISTINCT A.CodUsuario + A.Tipo
											FROM          (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																						   Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																	FROM          tCsPadronClientesTipo
																	WHERE      (CodUsuario = @CodUsuario) AND (Fecha = @Fecha)) AS A INNER JOIN
																	   (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																								Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																		 FROM          tCsPadronClientesTipo
																		 WHERE      (CodUsuario = @Temporal) AND (Fecha = @Fecha)) AS B ON A.Fecha = B.Fecha AND A.Tipo = B.Tipo)) AND (Fecha = @Fecha) 

				Set @Procesar = 0
			End 
			
			Update tCsPadronClientesTipo
			Set		CodUsuario = @Temporal, NombreCompleto = @NombreCompleto
			Where	CodUsuario = @CodUsuario and Fecha = @Fecha
			Set @Procesar = 0			
		End		
	End
	If @Procesar = 1
	Begin
		Create Table #A
		(
			CodUsuario		Varchar(25),
			Puntaje			Int,
			CodOrigen		Varchar(25),
			CodOficina		Varchar(4),
			NombreCompleto	Varchar(200)
		)
		Set @Temporal = @Codoficina +  @CodUsuario
		
		Insert into #A		
		Exec pCsEncontrarCodigo @Temporal
		
		If (Select Count(*) From #A Where Codoficina = @Codoficina) = 1 
		Begin			
			Select @Temporal = CodUsuario, @NombreCompleto = NombreCompleto From #A Where Codoficina = @Codoficina			
			Set @Procesar = 0		
		End		
		If @Procesar = 1 And (Select Count(*) from #A Where Left(@CodUsuario, 3) = Left(CodUsuario,3)) = 1
		Begin
			Select @Temporal = CodUsuario, @NombreCompleto = NombreCompleto From #A Where Left(@CodUsuario, 3) = Left(CodUsuario,3)
			Set @Procesar = 0
		End
		If @Procesar = 1 And (Select Count(*) from tcsPadronCarteraDet Where CodPrestamo = @Referencia And CodUsuario in (Select CodUsuario From #A)) = 1
		Begin
			Select @Temporal = #A.CodUsuario, @NombreCompleto = NombreCompleto
			From tcsPadronCarteraDet INNER JOIN #A ON  tcsPadronCarteraDet.CodUsuario = #A.CodUsuario
			Set @Procesar = 0
		End	
		If @Procesar = 1 And (Select Count(*) from (SELECT     Datos.CodUsuario, tCsTransaccionDiaria.CodUsuario AS Nuevo, tCsPadronClientes.NombreCompleto
								FROM         (SELECT     CodUsuario, CAST(CAST(LEFT(Referencia, 3) AS int) AS Varchar(4)) AS CodOficina, CAST(SUBSTRING(Referencia, 5, 8) AS SmallDateTime) AS Fecha, 
																			  CAST(CAST(SUBSTRING(Referencia, 14, 3) AS Int) AS Varchar(4)) AS Transaccion
													   FROM          tCsPadronClientesTipo
													   WHERE      (Fecha = @Fecha) AND (Tipo NOT IN ('ACREDITADO', 'AHORRADOR', 'CODEUDOR', 'AVAL')) AND (CodUsuario IN (@CodUsuario))) AS Datos INNER JOIN
													  tCsTransaccionDiaria ON Datos.Fecha = tCsTransaccionDiaria.Fecha AND Datos.Transaccion = tCsTransaccionDiaria.TipoTransacNivel3 AND 
													  Datos.CodOficina = tCsTransaccionDiaria.CodOficina INNER JOIN
													  tCsPadronClientes ON tCsTransaccionDiaria.CodUsuario = tCsPadronClientes.CodUsuario
								WHERE     (tCsTransaccionDiaria.CodUsuario IN (Select CodUsuario From #A))) As Datos) = 1
		Begin
			SELECT     @CodUsuario = Datos.CodUsuario, @Temporal = tCsTransaccionDiaria.CodUsuario, @NombreCompleto = tCsPadronClientes.NombreCompleto
			FROM         (SELECT     CodUsuario, CAST(CAST(LEFT(Referencia, 3) AS int) AS Varchar(4)) AS CodOficina, CAST(SUBSTRING(Referencia, 5, 8) AS SmallDateTime) AS Fecha, 
														  CAST(CAST(SUBSTRING(Referencia, 14, 3) AS Int) AS Varchar(4)) AS Transaccion
								   FROM          tCsPadronClientesTipo
								   WHERE      (Fecha = @Fecha) AND (Tipo NOT IN ('ACREDITADO', 'AHORRADOR', 'CODEUDOR', 'AVAL')) AND (CodUsuario IN (@CodUsuario))) AS Datos INNER JOIN
								  tCsTransaccionDiaria ON Datos.Fecha = tCsTransaccionDiaria.Fecha AND Datos.Transaccion = tCsTransaccionDiaria.TipoTransacNivel3 AND 
								  Datos.CodOficina = tCsTransaccionDiaria.CodOficina INNER JOIN
								  tCsPadronClientes ON tCsTransaccionDiaria.CodUsuario = tCsPadronClientes.CodUsuario
			WHERE     (tCsTransaccionDiaria.CodUsuario IN (Select CodUsuario From #A))
			Set @Procesar = 0
		End	
		
		If @Procesar = 0	
		Begin
			Print @CodUsuario
			Print @Temporal
			If (Select Count(*) From (Select Distinct CodUsuario From tcsPadronClientesTipo
										Where CodUsuario in (@CodUsuario, @Temporal)) as Datos ) > 1
			Begin 
				DELETE FROM tCsPadronClientesTipo
				WHERE     (CodUsuario + Tipo IN
										  (SELECT DISTINCT A.CodUsuario + A.Tipo
											FROM          (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																						   Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																	FROM          tCsPadronClientesTipo
																	WHERE      (CodUsuario = @CodUsuario) AND (Fecha = @Fecha)) AS A INNER JOIN
																	   (SELECT     Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, 
																								Inactivacion, CodOficinaFinal, SecuenciaGeneral, SecuenciaOficina
																		 FROM          tCsPadronClientesTipo
																		 WHERE      (CodUsuario = @Temporal) AND (Fecha = @Fecha)) AS B ON A.Fecha = B.Fecha AND A.Tipo = B.Tipo)) AND (Fecha = @Fecha) 

				Set @Procesar = 0
			End 
			
			Update tCsPadronClientesTipo
			Set		CodUsuario = @Temporal, NombreCompleto = @NombreCompleto
			Where	CodUsuario = @CodUsuario and Fecha = @Fecha
			Set @Procesar = 0			
		End
		
		Drop Table #A
	End
	
	
Fetch Next From curParametro Into  @CodUsuario, @Referencia, @CodOficina
End
Close 		curParametro
Deallocate 	curParametro

/*
Select * From tcsPadronClientesTipo
Where NombreCompleto = 'REVIZAR' and Fecha = @Fecha And Activo = 0

Select * from tCsTransaccionDiaria 
where CodOficina = '24' and Fecha = '20100331' and tipoTransacNivel3 = 13  
And CodUsuario = 'MCA0706941'               
                      
Select * From tcsPadronClientesTipo
Where CodUsuario in ('CME0603581')
Order by Fecha

Select * From tCsPadronClientes
Where FechaIngreso =  '20100327' And Codoficina = '10'

Select * From tCsPadronCarteraDet
Where CodPrestamo = '007-116-06-02-00288'
AEM0906701        

Select Count(*) from (
Select Distinct CodUsCuenta, CodUsuario From tCsClientesAhorrosFecha
Where CodCuenta = '009-108-06-2-9-00001'  And FormaManejo = 1 And idEsTado = 'AC') Datos


Select * From tCsAhorros
Where CodCuenta = '011-108-06-2-1-00002'
Order By Fecha
*/
GO