SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboCuentaOperativa2] @Dato Int, @Usuario Varchar(25)
AS BEGIN
Declare	@Servidor	Varchar(50),
		@BaseDatos	Varchar(50),
		@Ubicacion 	Varchar(5000),
		@CUbicacion	Varchar(1000),
		@Cadena		Varchar(4000),
		@OtroDato	Varchar(5000),
		@Cad1 		Varchar(4000),
		@Cad2 		Varchar(4000),
		@Fecha		SmallDateTime

	Set @Servidor 	= 'BD-FINAMIGO-DC'--'BD-FINAMIGO-DC'
	Set @BaseDatos	= 'Finmas'
SET NOCOUNT OFF
	CREATE TABLE #Temp (
		[CodPrestamo] 	[varchar] (50) 		COLLATE Modern_Spanish_CI_AI NULL ,
		[Nombre] 		[varchar] (1000) 	COLLATE Modern_Spanish_CI_AI NULL) 

	CREATE TABLE #Temp1 (
		[CodPrestamo] 	[varchar] (50) 		COLLATE Modern_Spanish_CI_AI NULL) 

	SELECT  @Ubicacion =  Ubicacion
	FROM (SELECT tSgUsuarios.Usuario, 
			 CASE WHEN ltrim(rtrim(isnull(tClZona.Zona, ''))) <> '' THEN ltrim(rtrim(isnull(tClZona.Zona, ''))) 
				  WHEN tSgUsuarios.TodasOficinas = 1 THEN 'ZZZ' ELSE tSgUsuarios.CodOficina END AS Ubicacion 
		  FROM tSgUsuarios LEFT OUTER JOIN tClZona ON tSgUsuarios.CodUsuario = tClZona.Responsable) Datos
		  WHERE (Usuario = @Usuario)

	Exec pGnlCalculaParametros 1, @Ubicacion, @CUbicacion Out, @Ubicacion Out, @OtroDato Out

	If @Dato In(6,7)		-- 6: Para Comite de Créditos, 7:Para Integrantes del Acta
		Begin			
			SELECT   @CUbicacion  = CodOficina
			FROM     tSgUsuarios
			WHERE    (Usuario = @Usuario)
		
			IF @Dato = 6
				Begin	
					Set @Cadena	= 'SELECT CodPrestamo, Nombre From ['+ @Servidor +'].['+ @BaseDatos 
					Set @Cadena	= @Cadena + '].dbo.vCaComiteDia vCaComiteDia Where CodOficina IN ('+ @CUbicacion +') '
				End
			If @Dato = 7
				Begin
				
					If Not((SELECT Count(*) FROM tCsComiteIntegrantes WHERE (CodOficina = @CUbicacion )) > 0 And
						   (SELECT DATEDIFF([minute], MAX(Registro), GETDATE()) FROM tCsComiteIntegrantes WHERE 
							(CodOficina = @CUbicacion ))> 10)
						Begin
						
							Declare curFragmento1 Cursor For 
								SELECT TipoActa
								FROM   [BD-FINAMIGO-DC].Finmas.dbo.tCaComiteTipo A
								WHERE  (Activo = 1)		
							Open curFragmento1
							Fetch Next From curFragmento1 Into @Cad2
							While @@Fetch_Status = 0
								Begin 
									DELETE FROM tCsComiteIntegrantes Where CodOficina = @CUbicacion  And Tipo = @Cad2
									PRINT 'JANNET2'
									INSERT INTO tCsComiteIntegrantes
											SELECT  Tipo = @Cad2,  
													CodOficina = @CUbicacion , 
													Codigo = ltrim(rtrim(Datos.Codigo)), 
													Datos.Nombre, 
													Datos.Puesto, 
													tCaComiteIntegrantePermitido.Grupo, 
													tCaComiteIntegrantePermitido.PMinimo, 
													Registro = GetDate(), 
													tCaComiteTipo.Nombre AS TipoActa
											FROM (SELECT DISTINCT CodAsesor AS Codigo, 
																  Nombre = NomAsesor + 
																  ' (' + CASE WHEN Agencia = 1 AND 
																  Puesto <> 41 THEN 'Reponsable de Agencia' 
																  ELSE Ltrim(rtrim(CodPuesto)) END + ')', 
																  Puesto = CASE WHEN Agencia = 1 AND Puesto <> 41 THEN 41 
																  ELSE Puesto END
													FROM (SELECT tCaClAsesores.CodOficina, 
																 tCaClAsesores.CodAsesor, 
																 tCaClAsesores.NomAsesor, 
																 ISNULL(tCsClPuestos.Descripcion, 'No definido') AS CodPuesto, 
																 0 AS Agencia, 
																 Puesto = Isnull(tCsClPuestos.Codigo, 0)
														  FROM tCsEmpleados INNER JOIN tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario 
								 										    INNER JOIN tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo 
								 											RIGHT OUTER JOIN [BD-FINAMIGO-DC].Finmas.dbo.tCaClAsesores tCaClAsesores ON tCsPadronClientes.CodOrigen = tCaClAsesores.CodAsesor
														   WHERE (tCaClAsesores.Activo = 1) And (tCsEmpleados.Estado = 1)
										UNION
											SELECT tCaClParametros.CodOficina, 
																	  tCaClParametros.CodEncargadoCA, 
																	  tUsUsuarios.NombreCompleto, 
																	  ISNULL(tCsClPuestos.Descripcion, 
																	  'No definido') AS CodPuesto, 
																	  1 AS Agencia, 
																	  Puesto = Isnull(tCsClPuestos.Codigo, 0)
																FROM tCsEmpleados INNER JOIN tCsPadronClientes 
																		ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario																INNER JOIN tCsClPuestos ON tCsEmpleados.CodPuesto = 
																											tCsClPuestos.Codigo 
																RIGHT OUTER JOIN [BD-FINAMIGO-DC].Finmas.dbo.tCaClParametros tCaClParametros 
																INNER JOIN [BD-FINAMIGO-DC].Finmas.dbo.tUsUsuarios tUsUsuarios ON tCaClParametros.CodEncargadoCA = tUsUsuarios.CodUsuario ON tCsPadronClientes.CodOrigen = tUsUsuarios.CodUsuario
														   UNION
															   SELECT CodOficina = @CUbicacion , 
																	  tCsPadronClientes.CodOrigen, 
																	  tCsPadronClientes.NombreCompleto, 
																	  tCsClPuestos.Descripcion, 
																	  0 AS Agencia, 
																	  CodPuesto = Isnull(tCsClPuestos.Codigo, 0)
																FROM tCsEmpleados INNER JOIN tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario INNER JOIN tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo WHERE (tCsEmpleados.CodPuesto IN (34, 32, 30, 26, 39, 38)) AND (tCsEmpleados.Estado = 1)
														   UNION
																SELECT tClOficinas.CodOficina, 
																	   tCsPadronClientes.CodOrigen, 
																	   tCsPadronClientes.NombreCompleto, 
																	   tCsClPuestos.Descripcion, 
																	   0 AS agencia, 
																	   CodPuesto = Isnull(tCsClPuestos.Codigo, 0)
																   FROM tClOficinas INNER JOIN tClZona ON tClOficinas.Zona = tClZona.Zona 
																		INNER JOIN tCsPadronClientes ON tClZona.Responsable = tCsPadronClientes.CodUsuario 
																		INNER JOIN tCsEmpleados ON tCsPadronClientes.CodUsuario = tCsEmpleados.Codusuario 
																		INNER JOIN tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo) Datos
																	WHERE (CodOficina = @CUbicacion )) Datos 
																	INNER JOIN [BD-FINAMIGO-DC].Finmas.dbo.tCaComiteIntegrantePermitido tCaComiteIntegrantePermitido ON Datos.Puesto = tCaComiteIntegrantePermitido.CodPuesto 
																	INNER JOIN [BD-FINAMIGO-DC].Finmas.dbo.tCaComiteTipo tCaComiteTipo ON tCaComiteIntegrantePermitido.TipoActa = tCaComiteTipo.TipoActa
																	WHERE     (tCaComiteIntegrantePermitido.TipoActa = @Cad2)
																	ORDER BY Datos.Puesto DESC
							Fetch Next From curFragmento1 Into @Cad2
							End 
							Close curFragmento1
							Deallocate 	curFragmento1
			End		
			Set @Cadena = 'Select * from (SELECT DISTINCT CodUsuario As CodPrestamo, Nombre FROM tCsComiteIntegrantes WHERE (CodOficina = ''' + @CUbicacion  + '''))Datos Order by nombre'
		End
	End
	SET NOCOUNT ON
END


GO