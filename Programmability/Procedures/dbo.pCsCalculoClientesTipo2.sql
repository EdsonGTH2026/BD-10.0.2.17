SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP Procedure pCsCalculoClientesTipo2
CREATE Procedure [dbo].[pCsCalculoClientesTipo2]
@Fecha	SmallDateTime, 
@Tipo	Varchar(50)
As

--Set @Tipo   = 'AHORRADOR'
--Set @Tipo   = 'ACREDITADO'
--Set @Tipo   = 'AVAL'
--Set @Tipo   = 'CODEUDOR'
--Set @Tipo   = 'USUARIO REMESA'
--Set @Tipo   = 'ASEGURADO'
--Set @Tipo   = 'NO FINANCIERO'

Print '---------------------->>>>>>>>>>xxxxxxxxx      : ' + @Tipo + ' °°°°° ' + Cast(@Fecha As Varchar(100))

Declare @Anterior SmallDateTime

Set @Anterior = DateAdd(day, -1, @Fecha)

Delete From tCsPadronClientesTipo Where Fecha = @Fecha And Tipo = @Tipo

Print 'Eliminación de Datos para generar nuevamente: ' + Cast(@@Rowcount as Varchar(30))

If @Tipo = 'AHORRADOR'
Begin
	Insert Into tCsPadronClientesTipo (Fecha, CodUsuario, Tipo, Titular, Activo)
	SELECT     Fecha, CodUsCuenta, Tipo, MAX(Titular) AS Titular, Activo
	FROM         (SELECT     Fecha, CodUsCuenta, Tipo = @Tipo, Titular = 0, Activo = 1
	                       FROM          tCsClientesAhorrosFecha
	                       WHERE      (Fecha = @Fecha)
	                       UNION
	                       SELECT     Fecha, CodUsuario, Tipo = @Tipo, Titular = 1, Activo = 1
	                       FROM         tCsAhorros
	                       WHERE     (Fecha = @Fecha)) Datos
	WHERE     (LTRIM(RTRIM(ISNULL(CodUsCuenta, ''))) <> '')
	GROUP BY Fecha, CodUsCuenta, Tipo, Activo
	
	Print '----------------------------------------------------------' + Cast(@Fecha as Varchar(100))
	Print 'Inserción Principal: ' + Cast(@@Rowcount as Varchar(30))
	Print '----------------------------------------------------------'

	UPDATE  tCsPadronClientesTipo
	SET		Referencia	= Datos.Referencia,
			Registro	= Ahorros.FecApertura 
	FROM         (SELECT     CodUsCuenta, MAX(CodCuenta) AS Referencia
						   FROM          tCsClientesAhorrosFecha
						   WHERE      Fecha = @Fecha
						   GROUP BY CodUsCuenta) Datos INNER JOIN
						  tCsPadronClientesTipo ON Datos.CodUsCuenta COLLATE Modern_Spanish_CI_AI = tCsPadronClientesTipo.CodUsuario INNER JOIN
							  (SELECT DISTINCT Codcuenta, fecapertura
								FROM          tcspadronahorros) Ahorros ON Datos.Referencia = Ahorros.Codcuenta
	WHERE     (tCsPadronClientesTipo.Tipo = @Tipo)
	Print 'Primera Actualización: ' + Cast(@@Rowcount as Varchar(30))
	UPDATE    tCsPadronClientesTipo
	SET              Referencia = CodCuenta
	FROM         tCsPadronClientesTipo INNER JOIN
						  tCsClientesAhorros ON tCsPadronClientesTipo.CodUsuario = tCsClientesAhorros.CodUsCuenta
	WHERE     (tCsPadronClientesTipo.Tipo = @Tipo) AND (Ltrim(rtrim(IsNull(tCsPadronClientesTipo.Referencia, ''))) = '') AND (tCsPadronClientesTipo.Fecha = @Fecha)
	Print 'Segunda Actualización: ' + Cast(@@Rowcount as Varchar(30))
	UPDATE    tCsPadronClientesTipo
	SET              Referencia = CodCuenta, Registro = FechaApertura
	FROM         tCsPadronClientesTipo INNER JOIN
						  tCsAhorros ON tCsPadronClientesTipo.CodUsuario = tCsAhorros.CodUsuario
	WHERE     (tCsAhorros.Fecha = @Fecha) And (tCsPadronClientesTipo.Tipo = @Tipo) AND (Ltrim(rtrim(IsNull(tCsPadronClientesTipo.Referencia, ''))) = '') AND (tCsPadronClientesTipo.Fecha = @Fecha)	
	Print 'Tercera Actualización: ' + Cast(@@Rowcount as Varchar(30))
End

If @Tipo = 'ACREDITADO'
Begin
	Insert Into tCsPadronClientesTipo (Fecha, CodUsuario, Tipo, Titular, Activo)
	SELECT     Fecha, CodUsuario, Tipo, MAX(Titular) AS Titular, Activo
	FROM         (SELECT     tCsCarteraDet.Fecha, tCsCarteraDet.CodUsuario, @Tipo AS Tipo, 
	                                              CASE WHEN tCsCarteraDet.Codusuario = tCsCartera.codusuario THEN 1 ELSE 0 END AS Titular, 1 AS Activo
	                       FROM          tCsCarteraDet INNER JOIN
	                                              tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
	                       WHERE      (tCsCarteraDet.Fecha = @Fecha)) Datos
	GROUP BY Fecha, CodUsuario, Tipo, Activo
	Print '----------------------------------------------------------' + Cast(@Fecha as Varchar(100))
	Print 'Inserción Principal: ' + Cast(@@Rowcount as Varchar(30))
	Print '----------------------------------------------------------'
	UPDATE    tCsPadronClientesTipo
	SET		Referencia	= Datos.Referencia,
			Registro	= Credito.Desembolso 
	FROM         (SELECT     CodUsuario, MAX(CodPrestamo) AS Referencia
						   FROM          tCsCarteraDet
						   WHERE      Fecha = @Fecha
						   GROUP BY CodUsuario) Datos INNER JOIN
						  tCsPadronClientesTipo ON Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientesTipo.CodUsuario INNER JOIN
							  (SELECT DISTINCT CodPrestamo, Desembolso
								FROM          tcspadroncarteradet) Credito ON Datos.Referencia = Credito.CodPrestamo
	WHERE     (tCsPadronClientesTipo.Fecha = @Fecha) AND (tCsPadronClientesTipo.Tipo = @Tipo)
	Print 'Primera Actualización: ' + Cast(@@Rowcount as Varchar(30))
End

If @Tipo = 'AVAL'
Begin
	Insert Into tCsPadronClientesTipo (Fecha, CodUsuario, Tipo, Titular, Activo)
	SELECT     *, @Tipo AS Tipo, 1 AS Titular, 1 AS Activo
	FROM         (SELECT DISTINCT Fecha, LTRIM(RTRIM(ISNULL(ISNULL(tCsPadronClientes.CodUsuario, tCsPadronClientes_1.CodUsuario), ''))) AS CodUsuario
	                       FROM          tCsDiaGarantias LEFT OUTER JOIN
	                                              tCsPadronClientes tCsPadronClientes_1 ON tCsDiaGarantias.DocPropiedad = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN
	                                              tCsPadronClientes ON tCsDiaGarantias.DocPropiedad = tCsPadronClientes.CodOrigen
	                       WHERE      tCsDiaGarantias.Fecha = @Fecha) Datos
	WHERE     (CodUsuario <> '')
	Print '----------------------------------------------------------' + Cast(@Fecha as Varchar(100))
	Print 'Inserción Principal: ' + Cast(@@Rowcount as Varchar(30))
	Print '----------------------------------------------------------'
	UPDATE    tCsPadronClientesTipo
	SET     Referencia	= Datos.Referencia,
			Registro	= Registro.Registro
	FROM         (SELECT     CodUsuario, MAX(Codigo) AS referencia
						   FROM          (SELECT DISTINCT 
																		  tCsDiaGarantias.Fecha, LTRIM(RTRIM(ISNULL(ISNULL(tCsPadronClientes.CodUsuario, tCsPadronClientes_1.CodUsuario), ''))) AS CodUsuario, 
																		  tCsDiaGarantias.Codigo
												   FROM          tCsDiaGarantias LEFT OUTER JOIN
																		  tCsPadronClientes tCsPadronClientes_1 ON tCsDiaGarantias.DocPropiedad = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN
																		  tCsPadronClientes ON tCsDiaGarantias.DocPropiedad = tCsPadronClientes.CodOrigen
												   WHERE      (tCsDiaGarantias.Fecha = @Fecha)) Datos
						   GROUP BY CodUsuario) Datos INNER JOIN
						  tCsPadronClientesTipo ON Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientesTipo.CodUsuario INNER JOIN
							  (SELECT     tCsDiaGarantias.Codigo, tCsPadronClientes.CodUsuario, MIN(tCsDiaGarantias.Fecha) AS Registro
								FROM          tCsDiaGarantias INNER JOIN
													   tCsPadronClientes ON tCsDiaGarantias.DocPropiedad = tCsPadronClientes.CodOrigen
								GROUP BY tCsDiaGarantias.Codigo, tCsPadronClientes.CodUsuario) Registro ON Datos.CodUsuario = Registro.CodUsuario AND 
						  Datos.referencia = Registro.Codigo
	WHERE     (tCsPadronClientesTipo.Tipo = @Tipo) AND (tCsPadronClientesTipo.Fecha = @Fecha)	
	Print 'Primera Actualización: ' + Cast(@@Rowcount as Varchar(30))
End

If @Tipo = 'CODEUDOR'
Begin
	Insert Into tCsPadronClientesTipo (Fecha, CodUsuario, Tipo, Titular, Activo)
	SELECT DISTINCT tCsCartera.Fecha, tCsPrestamoCodeudor.CodUsuario, @Tipo AS Tipo, 1 AS Titular, 1 AS Activo
	FROM         tCsPrestamoCodeudor INNER JOIN
						  tCsCartera ON tCsPrestamoCodeudor.CodOficina = tCsCartera.CodOficina AND tCsPrestamoCodeudor.CodSolicitud = tCsCartera.CodSolicitud INNER JOIN
						  tCsPadronClientes ON tCsPrestamoCodeudor.CodUsuario = tCsPadronClientes.CodUsuario
	WHERE     (tCsCartera.Fecha = @Fecha)
	Print '----------------------------------------------------------' + Cast(@Fecha as Varchar(100))
	Print 'Inserción Principal: ' + Cast(@@Rowcount as Varchar(30))
	Print '----------------------------------------------------------'
	UPDATE    tCsPadronClientesTipo
	SET     Referencia	= tCsCartera.CodPrestamo,
			Registro	= tCsPrestamoCodeudor.Registro
	FROM         tCsPrestamoCodeudor INNER JOIN
						  tCsCartera ON tCsPrestamoCodeudor.CodOficina = tCsCartera.CodOficina AND tCsPrestamoCodeudor.CodSolicitud = tCsCartera.CodSolicitud INNER JOIN
						  tCsPadronClientesTipo ON tCsPrestamoCodeudor.CodUsuario = tCsPadronClientesTipo.CodUsuario
	WHERE     (tCsCartera.Fecha = @Fecha) And Tipo = @Tipo
	Print 'Primera Actualización: ' + Cast(@@Rowcount as Varchar(30))
	UPDATE    tCsPadronClientesTipo
	SET     Referencia = tCsPrestamoCodeudor.CodPrestamo, 
			Registro = tCsPrestamoCodeudor.Registro
	FROM         tCsPadronClientesTipo INNER JOIN
						  tCsPrestamoCodeudor ON tCsPadronClientesTipo.CodUsuario = tCsPrestamoCodeudor.CodUsuario
	WHERE     (tCsPadronClientesTipo.Tipo = @Tipo) AND (Ltrim(rtrim(IsNull(tCsPadronClientesTipo.Referencia, ''))) = '') AND (tCsPadronClientesTipo.Fecha = @Fecha)
	Print 'Segunda Actualización: ' + Cast(@@Rowcount as Varchar(30))
End

If @Tipo In ('USUARIO REMESA', 'ASEGURADO', 'NO FINANCIERO') 
BEGIN
	If @Tipo In('USUARIO REMESA')
	Begin
		Insert Into tCsPadronClientesTipo (Fecha, CodUsuario, Tipo, Titular, Activo)
		SELECT    DISTINCT    Fecha, CodUsuario, @Tipo, Titular, Activo
		FROM            vCsClientesServicios
		WHERE        (Fecha = @Fecha) AND RE = 1 And CodUsuario <> ''
		Print '----------------------------------------------------------' + Cast(@Fecha as Varchar(100))
		Print 'Inserción Principal: ' + Cast(@@Rowcount as Varchar(30))
		Print '----------------------------------------------------------'
		UPDATE tCsPadronClientesTipo
		Set Referencia = Datos.Referencia
		FROM            (SELECT    Fecha, CodUsuario, Tipo = @Tipo, Titular, Activo, MAX(Referencia) AS Referencia
				  FROM            vCsClientesServicios
				  WHERE        (RE = 1) AND (Fecha = @Fecha)
				  GROUP BY Fecha, CodUsuario, Titular, Activo) AS Datos INNER JOIN
				 tCsPadronClientesTipo ON Datos.Fecha = tCsPadronClientesTipo.Fecha AND Datos.CodUsuario = tCsPadronClientesTipo.CodUsuario AND 
				 Datos.Tipo = tCsPadronClientesTipo.Tipo
		Print 'Primera Actualización: ' + Cast(@@Rowcount as Varchar(30))
	End
	If @Tipo In('ASEGURADO')
	Begin
		Insert Into tCsPadronClientesTipo (Fecha, CodUsuario, Tipo, Titular, Activo)
		SELECT    DISTINCT    Fecha, CodUsuario, @Tipo, Titular, Activo
		FROM            vCsClientesServicios
		WHERE        (Fecha = @Fecha) AND SG = 1 And CodUsuario <> ''
		Print '----------------------------------------------------------' + Cast(@Fecha as Varchar(100))
		Print 'Inserción Principal: ' + Cast(@@Rowcount as Varchar(30))
		Print '----------------------------------------------------------'
		UPDATE tCsPadronClientesTipo
		Set Referencia = Datos.Referencia
		FROM            (SELECT    Fecha, CodUsuario, Tipo = @Tipo, Titular, Activo, MAX(Referencia) AS Referencia
				  FROM            vCsClientesServicios
				  WHERE        (SG = 1) AND (Fecha = @Fecha)
				  GROUP BY Fecha, CodUsuario, Titular, Activo) AS Datos INNER JOIN
				 tCsPadronClientesTipo ON Datos.Fecha = tCsPadronClientesTipo.Fecha AND Datos.CodUsuario = tCsPadronClientesTipo.CodUsuario AND 
				 Datos.Tipo = tCsPadronClientesTipo.Tipo
		Print 'Primera Actualización: ' + Cast(@@Rowcount as Varchar(30))
	End
	If @Tipo In('NO FINANCIERO')
	Begin
		Insert Into tCsPadronClientesTipo (Fecha, CodUsuario, Tipo, Titular, Activo)
		SELECT    DISTINCT    Fecha, CodUsuario, @Tipo, Titular, Activo
		FROM            vCsClientesServicios
		WHERE        (Fecha = @Fecha) AND NF = 1 And CodUsuario <> ''
		Print '----------------------------------------------------------' + Cast(@Fecha as Varchar(100))
		Print 'Inserción Principal: ' + Cast(@@Rowcount as Varchar(30))
		Print '----------------------------------------------------------'
		UPDATE tCsPadronClientesTipo
		Set Referencia = Datos.Referencia
		FROM            (SELECT    Fecha, CodUsuario, Tipo = @Tipo, Titular, Activo, MAX(Referencia) AS Referencia
				  FROM            vCsClientesServicios
				  WHERE        (NF = 1) AND (Fecha = @Fecha)
				  GROUP BY Fecha, CodUsuario, Titular, Activo) AS Datos INNER JOIN
				 tCsPadronClientesTipo ON Datos.Fecha = tCsPadronClientesTipo.Fecha AND Datos.CodUsuario = tCsPadronClientesTipo.CodUsuario AND 
				 Datos.Tipo = tCsPadronClientesTipo.Tipo
		Print 'Primera Actualización: ' + Cast(@@Rowcount as Varchar(30))
	End
		
	UPDATE tCsPadronClientesTipo
	Set 	Registro	= Substring(Referencia, 5, 8),
		CodOficina	= Cast(Substring(Referencia, 1, 3) as Int)
	WHERE  (Fecha = @Fecha) AND Tipo = @Tipo
	Print 'Segunda Actualización: ' + Cast(@@Rowcount as Varchar(30))
END

UPDATE    tCsPadronClientesTipo
SET              Conyuge = LTRIM(RTRIM(ISNULL(tCsPadronClientes.CodConyuge, '')))
FROM         tCsPadronClientesTipo INNER JOIN
                      tCsPadronClientes ON tCsPadronClientesTipo.CodUsuario = tCsPadronClientes.CodUsuario
WHERE     (tCsPadronClientesTipo.Tipo = @Tipo) AND (tCsPadronClientesTipo.Fecha = @Fecha)
Print 'Actualización Conyuge: ' + Cast(@@Rowcount as Varchar(30))
UPDATE    tCsPadronClientesTipo
SET              Usuario = Datos.Usuario
FROM         (SELECT     Sistemas.CodUsuario, REPLACE(SUBSTRING(LTRIM(RTRIM(ISNULL(tCsPadronClientes.Nombres, ''))), 1, 1) 
                                              + CASE WHEN LTRIM(RTRIM(ISNULL(tCsPadronClientes.Paterno, ''))) = '' THEN LTRIM(RTRIM(ISNULL(tCsPadronClientes.Materno, ''))) 
                                              ELSE LTRIM(RTRIM(ISNULL(tCsPadronClientes.Paterno, ''))) END + SUBSTRING(LTRIM(RTRIM(ISNULL(tCsPadronClientes.Materno, ''))), 1, 1), ' ', '') 
                                              AS uSUARIO
                       FROM          (SELECT DISTINCT Ltrim(Rtrim(IsNull(CodAsesor, ''))) AS CodUsuario
                                               FROM          tCsAhorros
                                               WHERE      (Fecha = @Fecha)
                                               UNION
                                               SELECT DISTINCT Ltrim(Rtrim(IsNull(CodAsesor, ''))) AS CodUsuario
                                               FROM         tCsCartera
                                               WHERE     (Fecha = @Fecha)
                                               UNION
                                               SELECT DISTINCT Ltrim(Rtrim(IsNull(CodUsResp, ''))) AS CodUsuario
                                               FROM         tCsPadronClientes
                                               UNION
                                               SELECT DISTINCT Ltrim(Rtrim(IsNull(CodCajero, ''))) AS CodUsuario
                                               FROM         tCsTransaccionDiaria
                                               WHERE     (Fecha = @Fecha)
                                               UNION
                                               SELECT DISTINCT Ltrim(Rtrim(IsNull(CodUsuario, ''))) AS CodUsuario
                                               FROM         tCsEmpleados
                                               WHERE     (Estado = 1)) Sistemas INNER JOIN
                                              tCsPadronClientes ON Sistemas.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientes.CodUsuario
                       WHERE      (Sistemas.CodUsuario <> '')) Datos INNER JOIN
                      tCsPadronClientesTipo ON Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientesTipo.CodUsuario
WHERE     (tCsPadronClientesTipo.Fecha = @Fecha) And (tCsPadronClientesTipo.Tipo = @Tipo)
Print 'Actualización Usuario: ' + Cast(@@Rowcount as Varchar(30))

Insert Into tCsPadronClientesTipo (Fecha, CodUsuario, Tipo, Titular, Activo, Conclusion, Conyuge, Usuario, Referencia, Registro, CodOficina, NombreCompleto, Activacion, Inactivacion)
SELECT DISTINCT 
                         @Fecha AS Fecha, tCsPadronClientesTipo.CodUsuario, tCsPadronClientesTipo.Tipo, tCsPadronClientesTipo.Titular, 0 AS Activo,0 As Conclusion,  tCsPadronClientesTipo.Conyuge, 
                         tCsPadronClientesTipo.Usuario, tCsPadronClientesTipo.Referencia, tCsPadronClientesTipo.Registro, tCsPadronClientesTipo.CodOficina, 
                         tCsPadronClientes.NombreCompleto,  tCsPadronClientesTipo.Activacion,  tCsPadronClientesTipo.Inactivacion
FROM            tCsPadronClientesTipo LEFT OUTER JOIN
                         tCsPadronClientes ON tCsPadronClientesTipo.CodUsuario = tCsPadronClientes.CodUsuario
WHERE        (tCsPadronClientesTipo.Fecha = @Anterior) AND (tCsPadronClientesTipo.CodUsuario NOT IN
                             (SELECT        tCsPadronClientesTipo_1.CodUsuario
                               FROM            tCsPadronClientesTipo AS tCsPadronClientesTipo_1 LEFT OUTER JOIN
                                                         tCsPadronClientes AS tCsPadronClientes_1 ON tCsPadronClientesTipo_1.CodUsuario = tCsPadronClientes_1.CodUsuario
                               WHERE        (tCsPadronClientesTipo_1.Fecha = @Fecha) AND (tCsPadronClientesTipo_1.Tipo = @Tipo))) AND 
                         (tCsPadronClientesTipo.Tipo = @Tipo)

Print '----------------------------------------------------------' --+ Cast(@Fecha as Varchar(100))
Print 'Inserccion Anterior: ' + Cast(@@Rowcount as Varchar(30))
Print '----------------------------------------------------------' 
UPDATE    tCsPadronClientesTipo
SET              NombreCompleto = tCsPadronClientes.NombreCompleto
FROM         tCsPadronClientesTipo INNER JOIN
                      tCsPadronClientes ON tCsPadronClientesTipo.CodUsuario = tCsPadronClientes.CodUsuario
WHERE     (tCsPadronClientesTipo.Tipo = @Tipo) AND (tCsPadronClientesTipo.Fecha = @Fecha)
Print 'Actualización Nombre Completo : ' + Cast(@@Rowcount as Varchar(30))
UPDATE  tCsPadronClientesTipo
SET     CodOficina	= tCsPadronAhorros.CodOficina,
		Registro	= tCsPadronAhorros.FecApertura
FROM         tCsPadronClientesTipo INNER JOIN
                      tCsPadronAhorros ON tCsPadronClientesTipo.Referencia = tCsPadronAhorros.CodCuenta
Where tCsPadronClientesTipo.Tipo = @Tipo And tCsPadronClientesTipo.Fecha = @Fecha And tCsPadronClientesTipo.CodOficina Is Null
Print 'Actualización Oficina 1: ' + Cast(@@Rowcount as Varchar(30))
UPDATE  tCsPadronClientesTipo
SET     CodOficina	= tCsPadronCarteraDet.CodOficina,
		Registro	= tCsPadronCarteraDet.Desembolso
FROM         tCsPadronClientesTipo INNER JOIN
                      tCsPadronCarteraDet ON tCsPadronClientesTipo.Referencia = tCsPadronCarteraDet.CodPrestamo
Where tCsPadronClientesTipo.Tipo = @Tipo And tCsPadronClientesTipo.Fecha = @Fecha And tCsPadronClientesTipo.CodOficina Is Null
Print 'Actualización Oficina 2: ' + Cast(@@Rowcount as Varchar(30))
UPDATE    tCsPadronClientesTipo
SET              CodOficina = tCsDiaGarantias.CodOficina
FROM         tCsPadronClientesTipo INNER JOIN
                      tCsDiaGarantias ON tCsPadronClientesTipo.Referencia = tCsDiaGarantias.Codigo
Where tCsPadronClientesTipo.Tipo = @Tipo And tCsPadronClientesTipo.Fecha = @Fecha And tCsPadronClientesTipo.CodOficina Is Null
Print 'Actualización Oficina 3: ' + Cast(@@Rowcount as Varchar(30))
UPDATE    tCsPadronClientesTipo
SET              Registro = FechaDesembolso, Referencia = CodPrestamo, CodOficina = TcsCartera.CodOficina
FROM         tCsPadronClientesTipo INNER JOIN
                      tCsPadronClientes ON tCsPadronClientesTipo.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN
                      tCsCartera ON tCsPadronClientes.CodOficina = tCsCartera.CodOficina AND tCsPadronClientesTipo.Referencia = tCsCartera.CodSolicitud
Where tCsPadronClientesTipo.Tipo = @Tipo And tCsPadronClientesTipo.Fecha = @Fecha And tCsPadronClientesTipo.CodOficina Is Null
Print 'Actualización Registro: ' + Cast(@@Rowcount as Varchar(30))
UPDATE    tCsPadronClientesTipo
SET              Conyuge = ''
WHERE     (LTRIM(RTRIM(ISNULL(Conyuge, ''))) = '')		AND (Fecha = @Fecha) AND (Tipo = @Tipo)
Print 'Actualización Blanco 1: ' + Cast(@@Rowcount as Varchar(30))
UPDATE    tCsPadronClientesTipo
SET              Usuario = ''
WHERE     (LTRIM(RTRIM(ISNULL(Usuario, ''))) = '')		AND (Fecha = @Fecha) AND (Tipo = @Tipo)
Print 'Actualización Blanco 2: ' + Cast(@@Rowcount as Varchar(30))
UPDATE    tCsPadronClientesTipo
SET              Referencia = ''
WHERE     (LTRIM(RTRIM(ISNULL(Referencia, ''))) = '')	AND (Fecha = @Fecha) AND (Tipo = @Tipo)
Print 'Actualización Blanco 3: ' + Cast(@@Rowcount as Varchar(30))
Update tCsPadronClientesTipo
Set Activo = 1
Where Tipo IN('ASEGURADO') And Datediff(Day, Registro, Fecha)		<= 365	AND (Fecha = @Fecha) AND (Tipo = @Tipo)
Print 'Detectando Actividad 1: ' + Cast(@@Rowcount as Varchar(30))
Update tCsPadronClientesTipo
Set Activo = 1
Where Tipo IN('USUARIO REMESA') And Datediff(Day, Registro, Fecha)	<= 30	AND (Fecha = @Fecha) AND (Tipo = @Tipo)
Print 'Detectando Actividad 2: ' + Cast(@@Rowcount as Varchar(30))
Update tCsPadronClientesTipo
Set Activo = 1
Where Tipo IN('NO FINANCIERO') And Datediff(Day, Registro, Fecha)	<= 30	AND (Fecha = @Fecha) AND (Tipo = @Tipo)
Print 'Detectando Actividad 3: ' + Cast(@@Rowcount as Varchar(30))
GO