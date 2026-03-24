SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsReporteContrato1
--Exec pCsReporteContrato1 115, 'kvalera', 'ZZZ', '004-CAA000813'
--Exec pCsReporteContrato1 1, '', '', ''

CREATE Procedure [dbo].[pCsReporteContrato1]
	@Dato			Int,
	@Usuario		Varchar(50) ,
	@Ubicacion		Varchar(500),
	@Prestamo		Varchar(25)
As

Declare @Sistema	Varchar(2)
Declare @DFirmante 	Varchar(100) 
Declare @SFirmante 	Varchar(100)
Declare @Cad1	   	Varchar(100)
Declare @Cad2	   	Varchar(100)
Declare @Int1	   	Int
Declare @Int2	   	Int
Declare @Cadena		Varchar(8000)
Declare @Servidor 	Varchar(50)
Declare @BaseDatos	Varchar(50)
Declare @Firma		Varchar(100)

CREATE TABLE #Temp (
	[CodPrestamo] 		[varchar] (50) 		COLLATE Modern_Spanish_CI_AI NULL ,
	[Nombre] 		[varchar] (1000) 	COLLATE Modern_Spanish_CI_AI NULL) 

--|---------------------------------------------------------------------------------------------|
--|DATO:																						|
--|  1. Para Datos del Contrato, se conecta al FINMAS Real.										|
--|  2. Para Datos del Pagare.																	|
--|  3. Para Carta de Cobranza con Firmante Responsable de Agencia.								|
--|  4. Para Carta de Cobranza con Firmante Asesor 	de Crédito.									|
--|  5. Para Carta Final; Citatorio.															|
--|  6.	Para Carta Final; Ultimo Aviso.															|
--|  7. Para Carta Final; Embargo Preventivo.													|
--|  8. Se Utiliza para FINMAS Paralelo o de Sistema de Pruebas.								|
--|  9. Se deja Vacio antes era el ZURICH.														|
--| 10.	Se usa para la generación de Datos Generales del Plan de Pagos.							|
--| 11.	Para Plan de Pagos Responsable 	de Agencia. Es Opcion es padre para la Opción 10.		|
--| 12.	Para Plan de Pagos Coordinador 	de Operaciones. Es Opcion es padre para la Opción 10.	|
--| 13.	Para Zurich con Firmante Responsable 	de Agencia.										|
--| 14.	Para Zurich con Firmante Coordinandor 	de Operaciones.									|
--|		ACTA DE COMITE DE CREDITO																|
--| 15. Para Actas de Comites de Créditos (Genera Información de Acta Consulta).				|
--| 16. Para Actas de Comites de Créditos (Muestra Cabecera de Acta).							|
--| 17. Para Actas de Comites de Créditos (Genera Información de Acta Culminación).				|
--|---------------------------------------------------------------------------------------------|
--| 18.	Para Autorización de Huellas.															|
--| 19.	Para Autorizacion de Saldos de Ahorros.													|
--| 20.	Para Carátula de Crédito y Ahorro.														|
--| 21.	Para Check List.																		|
--|---------------------------------------------------------------------------------------------|

If Ltrim(rtrim(@Ubicacion)) = ''
Begin
	Set @Ubicacion = 'ZZZ'
End 

If @Dato > 100 --PARA PRUEBAS VERIFICAR ANTES DE AUMENTAR VALORES A @DATO.
Begin
	Set @Servidor 	= 'DC-FINAMIGO-SRV'
	Set @BaseDatos	= 'Finamigo_Conta_AAs'
	Set @Dato 		= @Dato - 100 -- Siempre debe tener tres de diferencia 23 - 20 = 3
End 
Else
Begin
	Set @Servidor 		= 'BD-FINAMIGO-DC'
	Set @BaseDatos		= 'Finmas'
End
If @Dato In (1, 8, 20) -- PARA CONTRATOS/CARATULA
Begin
	If Ltrim(Rtrim(@Usuario)) = ''
	Begin 
		Select TOP 1 @Usuario = Usuario from tSgUsuarios
		Where Activo = 1 And ltrim(rtrim(Usuario)) <> ''
		Order by NewId()
	End
	If Ltrim(Rtrim(@Prestamo)) = ''
	Begin 
		Select Top 1 @Prestamo = CodPrestamo from (
		Select Distinct CodPrestamo From tCsPadronCarteraDet
		Where EstadoCalculado Not in ('CANCELADO', 'CASTIGADO') And Desembolso <= (Select FechaConsolidacion From vCsFechaConsolidacion)) Datos
		Order by Newid()
	End	
	
	If Len(@Prestamo) = 19
	Begin
		Set @Sistema = 'CA'
	End
	Else
	Begin
		Set @Sistema = 'AH'
	End
	
	If @Dato = 20 And @Sistema = 'AH' -- Se calcula Datos de Ahorro
	Begin
		Exec pCsReporteContrato 1, @Usuario, @Ubicacion, @Prestamo	
	End
	
	If @Dato = 1 -- Se Conecta con el FINMAS real
	Begin
		Exec pCsReporteContrato 1, @Usuario, @Ubicacion, @Prestamo	
	End
	If @Dato = 8 -- Se Conecta con el FINMAS paralelo
	Begin
		Exec pCsReporteContrato 3, @Usuario, @Ubicacion, @Prestamo	
	End	
	If @Dato In (1,8)
	Begin
		SELECT DISTINCT 
							  tCsFirmaElectronica.Firma, tCsFirmaElectronica.Dato, tCsFirmaReporte.Sujeto, tCsFirmaReporte.Direccion, UPPER(tCsFirmaReporte.Denominacion) AS Denominacion, 
							  UPPER(tCsFirmaReporte.Denominacion1) AS Denominacion1, UPPER(tCsFirmaReporte.Denominacion2) AS Denominacion2, 
							  tCsFirmaReporteDetalle.Sujeto + ISNULL(' / ' + tCsFirmaReporteDetalle.Nacionalidad, '') AS Nombres, CASE WHEN ltrim(rtrim(tCsFirmaReporte.Sujeto2)) 
							  <> '' THEN ISNULL(UPPER(' ' + tCsFirmaReporte.Dato5 + ' ' + tCsFirmaReporte.Sujeto2 + ' en lo sucesivo ' + tCsFirmaReporte.Dato6), '') ELSE '' END AS Avales, 
							  tCsFirmaReporteDetalle.EstadoCivil, ISNULL(tCsFirmaReporteDetalle.Actividad, '') + '/' + ISNULL(tCsFirmaReporteDetalle.Ocupacion, '') AS Ocupacion, 
							  tCsFirmaReporteDetalle.Direccion AS DireccionCliente, tCsFirmaReporteDetalle.Identificacion, tCsFirmaReporteDetalle.Saldo1 AS Coordinador, 
							  tCsFirmaReporteClausula.Texto AS Declaracion, UPPER(tCsFirmaReporte.DGarantia) AS DGarantia, dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'DD') 
							  + '/' + dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'MM') + '/' + dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'AAAA') AS Expedicion, Pagare.Texto AS Pagare,
							  tCsFirmaReporte.RECA, Ubicacion = @Ubicacion, Prestamo = @Prestamo, Usuario = @Usuario
		FROM         tCsFirmaElectronica INNER JOIN
							  tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma INNER JOIN
							  tCsFirmaReporteDetalle ON tCsFirmaReporte.Firma = tCsFirmaReporteDetalle.Firma LEFT OUTER JOIN
								  (SELECT     *
									FROM          tCsFirmaReporteClausula
									WHERE      Tipo = 'Pagare' AND Fila = 1) Pagare ON tCsFirmaElectronica.Firma = Pagare.Firma COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
								  (SELECT     *
									FROM          tCsFirmaReporteClausula
									WHERE      Tipo = 'Declaracion' AND Fila = 1) tCsFirmaReporteClausula ON tCsFirmaElectronica.Firma = tCsFirmaReporteClausula.Firma
		WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteDetalle.Grupo = 'A') AND (tCsFirmaElectronica.Usuario = @Usuario)
		ORDER BY tCsFirmaReporteDetalle.Saldo1 DESC
	End
	If @Dato In (20) And @Sistema = 'CA'
	Begin
		SELECT DISTINCT 
							  tCsFirmaElectronica.Firma, tCsFirmaElectronica.Dato, tCsFirmaReporte.Sujeto, UPPER(tCsFirmaReporte.Denominacion) AS Denominacion, tCsFirmaReporte.RECA, 
							  tCaProducto.NombreProd, dbo.fduCATPrestamo(3, tCsFirmaReporte.Saldo1, tCsFirmaReporte.Saldo4 / tCaClModalidadPlazo.FactorMensual, 
							  tCsFirmaReporte.Saldo2 / 12, CASE RIGHT(IsNull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%'), 1) 
							  WHEN '%' THEN CAST(LEFT(Isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%'), Len(isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%')) - 1) AS Decimal(10, 4)) 
							  / 100.0000 * tCsFirmaReporte.Saldo1 ELSE CAST(Isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00') AS Decimal(10, 4)) END) AS CAT, 
							  tCsFirmaReporte.Saldo2 AS TasaOrdinaria, tCsFirmaReporte.Saldo1 AS Monto, Total.Total, CASE RIGHT(IsNull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%'), 1) 
							  WHEN '%' THEN CAST(LEFT(Isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%'), Len(isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%')) - 1) AS Decimal(10, 4)) 
							  / 100.0000 * tCsFirmaReporte.Saldo1 ELSE CAST(Isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00') AS Decimal(10, 4)) END AS Apertura, 
							  tCsFirmaReporte.Fecha1 as FechaApertura,
							  Total.FechaVencimiento, 
							  Case When tCsFirmaReporte.Saldo4 = 1 Then Ltrim(rtrim(STR(tCsFirmaReporte.Saldo4, 5, 0))) + ' ' + tCaClModalidadPlazo.Singular Else 
							  Ltrim(rtrim(STR(tCsFirmaReporte.Saldo4, 5, 0))) + ' ' +
							  tCaClModalidadPlazo.Plural End As Plazo, tCsFirmaReporte.Saldo6 AS TasaMoratoria,
							  Isnull(tCsFirmaReporte.Dato2, '') AS ComisionApertura,
							  tCsFirmaReporte.Saldo3 AS CobroMora, tCsFirmaReporteDetalle.Sujeto As Firmante,
							  CASE Grupo WHEN 'A' THEN 'Acreditado' WHEN 'C' THEN 'Codeudor' WHEN 'E' THEN 'Aval' END AS TipoFirmante
		FROM         tCsFirmaElectronica INNER JOIN
							  tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma INNER JOIN
							  tCsFirmaReporteDetalle ON tCsFirmaReporte.Firma = tCsFirmaReporteDetalle.Firma INNER JOIN
							  tCaProducto ON tCsFirmaReporte.Dato4 = tCaProducto.CodProducto INNER JOIN
								  (SELECT     Firma, SUM(Saldo1) AS Total, MAX(Fecha1) AS FechaVencimiento
									FROM          tCsFirmaReporteDetalle AS tCsFirmaReporteDetalle_1
									WHERE      (Grupo = 'H')
									GROUP BY Firma) AS Total ON tCsFirmaElectronica.Firma = Total.Firma LEFT OUTER JOIN
								  (SELECT     Firma, Fila, Clausula, Tipo, Orden, Titulo, Texto
									FROM          tCsFirmaReporteClausula AS tCsFirmaReporteClausula_2
									WHERE      (Tipo = 'Pagare') AND (Fila = 1)) AS Pagare ON tCsFirmaElectronica.Firma = Pagare.Firma LEFT OUTER JOIN
								  (SELECT     Firma, Fila, Clausula, Tipo, Orden, Titulo, Texto
									FROM          tCsFirmaReporteClausula AS tCsFirmaReporteClausula_1
									WHERE      (Tipo = 'Declaracion') AND (Fila = 1)) AS tCsFirmaReporteClausula ON tCsFirmaElectronica.Firma = tCsFirmaReporteClausula.Firma LEFT OUTER JOIN
							  tCaClModalidadPlazo ON tCsFirmaReporte.Dato1 = tCaClModalidadPlazo.ModalidadPlazo
		WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteDetalle.Grupo In ('A', 'C', 'E')) AND (tCsFirmaElectronica.Usuario = @Usuario)
	End
	If @Dato In (20) And @Sistema = 'AH'
	Begin
		SELECT DISTINCT 
							  tCsFirmaElectronica.Firma, tCsFirmaElectronica.Dato, tCsFirmaReporte.Sujeto, UPPER(tCsFirmaReporte.Denominacion) AS Denominacion, tAhProductos.RECA, 
							  CAST(tAhProductos.idProducto AS Varchar(3)) + tAhProductos.Nombre AS NombreProd, dbo.fduCATPrestamo(4, tCsFirmaReporte.Saldo1, DATEDIFF(day, 
							  tCsFirmaReporte.Fecha1, Total.FechaVencimiento), tCsFirmaReporte.Saldo2, CASE RIGHT(IsNull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%'), 1) 
							  WHEN '%' THEN CAST(LEFT(Isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%'), Len(isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%')) - 1) AS Decimal(10, 4)) 
							  / 100.0000 * tCsFirmaReporte.Saldo1 ELSE CAST(Isnull(Ltrim(rtrim(RIGHT(tCsFirmaReporte.Dato2, Len(tCsFirmaReporte.Dato2) - 1))), '0.00') AS Decimal(10, 4)) END) 
							  AS CAT, tCsFirmaReporte.Saldo2 AS TasaOrdinaria, tCsFirmaReporte.Saldo1 AS Monto, Total.Total, CASE RIGHT(IsNull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%'), 1) 
							  WHEN '%' THEN CAST(LEFT(Isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%'), Len(isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%')) - 1) AS Decimal(10, 4)) 
							  / 100.0000 * tCsFirmaReporte.Saldo1 ELSE CAST(Isnull(Ltrim(rtrim(RIGHT(tCsFirmaReporte.Dato2, Len(tCsFirmaReporte.Dato2) - 1))), '0.00') AS Decimal(10, 4)) 
							  END AS Mantenimiento, tCsFirmaReporte.Fecha1 AS FechaApertura, Total.FechaVencimiento, 
							  CASE WHEN tCsFirmaReporte.Saldo4 = 1 THEN Ltrim(rtrim(STR(tCsFirmaReporte.Saldo4, 5, 0))) 
							  + ' ' + tCaClModalidadPlazo.Singular ELSE Ltrim(rtrim(STR(tCsFirmaReporte.Saldo4, 5, 0))) + ' ' + tCaClModalidadPlazo.Plural END AS Plazo, 
							  tCsFirmaReporte.Saldo6 AS TasaMoratoria, ISNULL(tCsFirmaReporte.Dato2, '') AS ComisionMantenimiento, tCsFirmaReporte.Saldo3 AS CobroMora, 
							  tCsFirmaReporteDetalle.Sujeto AS Firmante, CASE Grupo WHEN 'A' THEN 'Cliente' WHEN 'C' THEN 'Codeudor' WHEN 'E' THEN 'Aval' END AS TipoFirmante, 
							  CASE ltrim(rtrim(isnull(replace(tCsFirmaReporte.Dato7, char(13), ''), ''))) WHEN '' THEN '- Sin Comisiones.' ELSE tCsFirmaReporte.Dato7 END AS Comisiones, 
							  CASE idtipoprod WHEN 1 THEN '- En efectivo.' + char(13) + Isnull(tAhProductos.Disposicion, '') ELSE Isnull(tAhProductos.Disposicion, '') END AS Disposicion, 
							  CASE idtipoprod WHEN 1 THEN Rtitulo ELSE RIGHT(Rtitulo, 21) END AS Contrato, 
							  CASE WHEN tCsFirmaReporte.Saldo1 > (UDI * 400000.000000) THEN 'NO' ELSE 'SI' END AS Mostrar
		FROM         tCsFirmaElectronica INNER JOIN
							  tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma INNER JOIN
							  tCsFirmaReporteDetalle ON tCsFirmaReporte.Firma = tCsFirmaReporteDetalle.Firma INNER JOIN
								  (SELECT     Firma, SUM(Saldo1) AS Total, MAX(Fecha1) AS FechaVencimiento
									FROM          tCsFirmaReporteDetalle AS tCsFirmaReporteDetalle_1
									WHERE      (Grupo = 'H')
									GROUP BY Firma) AS Total ON tCsFirmaElectronica.Firma = Total.Firma INNER JOIN
							  tAhProductos ON tCsFirmaReporte.Dato4 = tAhProductos.idProducto INNER JOIN
							  tCsUDIS ON tCsFirmaReporte.Fecha1 - 1 = tCsUDIS.Fecha LEFT OUTER JOIN
								  (SELECT     Firma, Fila, Clausula, Tipo, Orden, Titulo, Texto
									FROM          tCsFirmaReporteClausula AS tCsFirmaReporteClausula_2
									WHERE      (Tipo = 'Pagare') AND (Fila = 1)) AS Pagare ON tCsFirmaElectronica.Firma = Pagare.Firma LEFT OUTER JOIN
								  (SELECT     Firma, Fila, Clausula, Tipo, Orden, Titulo, Texto
									FROM          tCsFirmaReporteClausula AS tCsFirmaReporteClausula_1
									WHERE      (Tipo = 'Declaracion') AND (Fila = 1)) AS tCsFirmaReporteClausula ON tCsFirmaElectronica.Firma = tCsFirmaReporteClausula.Firma LEFT OUTER JOIN
							  tCaClModalidadPlazo ON tCsFirmaReporte.Dato1 = tCaClModalidadPlazo.ModalidadPlazo
		WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteDetalle.Grupo IN ('A', 'C', 'E')) AND (tCsFirmaElectronica.Usuario = @Usuario)
	End
End
If @Dato = 2 --PARA PAGARE
Begin
	SELECT DISTINCT 
	                      tCsFirmaElectronica.Firma, tCsFirmaElectronica.Dato, tCsFirmaReporte.Sujeto, tCsFirmaReporte.Direccion, UPPER(tCsFirmaReporte.Denominacion) AS Denominacion, 
	                      UPPER(tCsFirmaReporte.Denominacion1) AS Denominacion1, UPPER(tCsFirmaReporte.Denominacion2) AS Denominacion2, 
	                      CASE WHEN ltrim(rtrim(tCsFirmaReporte.Sujeto2)) 
	                      <> '' THEN ISNULL(UPPER(' ' + tCsFirmaReporte.Dato5 + ' ' + tCsFirmaReporte.Sujeto2 + ' en lo sucesivo ' + tCsFirmaReporte.Dato6), '') ELSE '' END AS Avales, 
	                      tCsFirmaReporteClausula.Texto AS Declaracion, UPPER(tCsFirmaReporte.DGarantia) AS DGarantia, dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'DD') 
	                      + '/' + dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'MM') + '/' + dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'AAAA') AS Expedicion, Pagare.Texto AS Pagare, 
	                      tCsFirmaReporteClausula.Texto, tCsFirmaReporteClausula.Fila, Integrantes.Integrantes
	FROM         (SELECT     *
	                       FROM          tCsFirmaReporteClausula
	                       WHERE      Tipo = 'Pagare' AND Fila = 1) Pagare RIGHT OUTER JOIN
	                      tCsFirmaElectronica INNER JOIN
	                      tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma LEFT OUTER JOIN
	                          (SELECT     Firma, COUNT(*) AS Integrantes
	                            FROM          tCsFirmaReporteDetalle
	                            WHERE      (Grupo IN ('A', 'C', 'E'))
	                            GROUP BY Firma) Integrantes ON tCsFirmaElectronica.Firma = Integrantes.Firma COLLATE Modern_Spanish_CI_AI ON 
	                      Pagare.Firma COLLATE Modern_Spanish_CI_AI = tCsFirmaElectronica.Firma LEFT OUTER JOIN
	                          (SELECT     tCsFirmaReporteClausula.*
	                            FROM          tCsFirmaReporteClausula
	                            WHERE      (tCsFirmaReporteClausula.Tipo = 'Pagare') AND (tCsFirmaReporteClausula.Fila > 1) AND (tCsFirmaReporteClausula.Orden < 100)) 
	                      tCsFirmaReporteClausula ON tCsFirmaElectronica.Firma = tCsFirmaReporteClausula.Firma
	WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = @Usuario)
End
If @Dato In (3, 4, 5, 6, 7) -- 3 PARA CARTA CON FIRMANTE RESPONSABLE DE AGENCIA y 4 PARA CARTA CON FIRMANTE ASESOR
Begin
	Set @DFirmante	= ''
	Set @SFirmante 	= ''	

	If @Dato In (3, 4)
	Begin
		If @Dato = 3 Begin Set @Cad2 = 'COBRANZA RESPONSABLE' 	End
		If @Dato = 4 Begin Set @Cad2 = 'COBRANZA ASESOR' 	End
		
		Update 	tCsCartera 
		Set 	Carta = @Cad2, CEmision = GetDate()
		Where  	CodPrestamo = @Prestamo And Fecha In (Select FechaConsolidacion From vCsFechaConsolidacion)

		Exec pCsReporteContrato 4, @Usuario, @Ubicacion, @Prestamo	
		
		If @Dato = 3	--Responsable de Agencia
		Begin	
			SELECT DISTINCT @DFirmante = CASE codPuesto WHEN 41 THEN tcsclpuestos.descripcion ELSE 'Responsable de Agencia' END 
				FROM         tCsEmpleados LEFT OUTER JOIN
				                      tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo RIGHT OUTER JOIN
				                      tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario RIGHT OUTER JOIN
				                      tCsFirmaElectronica INNER JOIN
				                      tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma ON 
				                      tCsPadronClientes.NombreCompleto = tCsFirmaReporteDetalle.Direccion
				WHERE     (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteDetalle.Grupo = 'G') AND 
				                      (tCsFirmaReporteDetalle.Identificador = 1)
			If @DFirmante <> 'Responsable de Agencia'
			Begin
				UPDATE    tcloficinas
				SET              CodUsAcargo = Datos.CodUsuario
				FROM         (SELECT DISTINCT tCsFirmaReporteDetalle.EstadoCivil, tCsPadronClientes.CodUsuario
				                       FROM          tCsEmpleados LEFT OUTER JOIN
				                                              tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo RIGHT OUTER JOIN
				                                              tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario RIGHT OUTER JOIN
				                                              tCsFirmaElectronica INNER JOIN
				                                              tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma ON 
				                                              tCsPadronClientes.NombreCompleto = tCsFirmaReporteDetalle.Direccion
				                       WHERE      (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteDetalle.Grupo = 'G') AND 
				                                              (tCsFirmaReporteDetalle.Identificador = 1)) Datos INNER JOIN
				                      tClOficinas ON Datos.EstadoCivil COLLATE Modern_Spanish_CI_AI = tClOficinas.CodOficina
			End

			SELECT DISTINCT @SFirmante =  Direccion 
		                            FROM       tCsFirmaElectronica INNER JOIN
		                                       tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
		                            WHERE      (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteDetalle.Grupo = 'G') AND Identificador = 1
		End
		If @Dato = 4	--Asesor de Crédito
		Begin
			Set @DFirmante = 'Asesor de Crédito'
			SELECT DISTINCT @SFirmante =  Direccion 
		                            FROM          tCsFirmaElectronica INNER JOIN
		                                                   tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
		                            WHERE      (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteDetalle.Grupo = 'G') AND Identificador = 2
		End		
	End

	Set @Cad2	= ''

	If @Dato In (5, 6, 7)
	Begin
		Insert Into #Temp
		Exec pCsCboCuentaOperativa 3, @Usuario
		
		If @Dato = 5 Begin Set @Cad2 = 'CITATORIO' 		End
		If @Dato = 6 Begin Set @Cad2 = 'ULTIMO AVISO' 	End
		If @Dato = 7 Begin Set @Cad2 = 'EMBARGO' 		End	

		Declare CurCarta Cursor For 
			SELECT Top 10 CodPrestamo
			FROM   tCsCartera
			WHERE  (Fecha IN
			       (SELECT fechaconsolidacion
			        FROM vcsfechaconsolidacion)) AND (CodPrestamo LIKE '%'+ @Prestamo +'%') AND (CodPrestamo Not In (Select CodPrestamo From #Temp)) And NroDiasAtraso <> 0
		Open CurCarta
		Fetch Next From CurCarta Into @Cad1
		While @@Fetch_Status = 0
		Begin
			Update 	tCsCartera 
			Set 	Carta = @Cad2, CEmision = GetDate()
			Where  	CodPrestamo = @Cad1 And Fecha In (Select FechaConsolidacion From vCsFechaConsolidacion)
			Exec pCsReporteContrato 4, @Usuario, @Ubicacion, @Cad1	
		Fetch Next From CurCarta Into  @Cad1
		End 
		Close 		CurCarta
		Deallocate 	CurCarta	

		Set @DFirmante = 'Departamento Jurídico'
		SELECT   @SFirmante = LTRIM(RTRIM(Paterno)) + ' ' + LTRIM(RTRIM(Materno)) + ' ' + LTRIM(RTRIM(Nombres)) 
		FROM         tCsEmpleados
		WHERE     (CodPuesto = 26) AND (Salida IS NULL)			
	End	
	
	SELECT     Fecha.Firma, Fecha.Grupo, Fecha.Fecha, Fecha.CodPrestamo, SA.SaldoAtrasado, SO.SaldoOtros, ST.SaldoTotal, ISNULL(Fecha.G, Clientes.G) AS G, Fecha.Oficina, 
	                      Fecha.Telefono, tCsFirmaReporte.DireccionAgencia, Clientes.Sujeto, Clientes.Direccion, tCsFirmaReporteClausula.Orden, tCsFirmaReporteClausula.Texto, 
	                      SA.Responsable, SO.Asesor, ST.Operaciones, @DFirmante AS DFirmante, @SFirmante AS SFirmante, tCsCartera.NroDiasAtraso, Tipo.Texto AS Tipo, 
	                      dbo.fduFragmentoSeparador(tCsFirmaReporteClausula.Texto, '*N*', '*N*', 1) AS T1, dbo.fduFragmentoSeparador(tCsFirmaReporteClausula.Texto, '*N*', '*N*', 2) AS T2, 
	                      dbo.fduFragmentoSeparador(tCsFirmaReporteClausula.Texto, '*N*', '*N*', 3) AS T3, dbo.fduFragmentoSeparador(tCsFirmaReporteClausula.Texto, '*N*', '*N*', 4) AS T4, 
	                      dbo.fduFragmentoSeparador(tCsFirmaReporteClausula.Texto, '*N*', '*N*', 5) AS T5, dbo.fduFragmentoSeparador(tCsFirmaReporteClausula.Texto, '*N*', '*N*', 6) AS T6, 
	                      dbo.fduFragmentoSeparador(tCsFirmaReporteClausula.Texto, '*N*', '*N*', 7) AS T7, dbo.fduFragmentoSeparador(tCsFirmaReporteClausula.Texto, '*N*', '*N*', 8) AS T8, 
	                      dbo.fduFragmentoSeparador(tCsFirmaReporteClausula.Texto, '*N*', '*N*', 9) AS T9, @Cad2 AS Sello, Clientes.Coordinador
	FROM         (SELECT DISTINCT 
	                                              tCsFirmaElectronica.Firma, tCsFirmaReporteDetalle.Grupo, tCsFirmaReporteDetalle.Fecha1 AS Fecha, Dato AS CodPrestamo, Nacionalidad AS G, 
	                                              Texto AS Oficina, Identificacion AS Telefono
	                       FROM          tCsFirmaElectronica INNER JOIN
	                                              tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
	                       WHERE      (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Dato LIKE '%' + @Prestamo + '%') AND 
	                                              (tCsFirmaReporteDetalle.Grupo = 'G') AND (dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'AAAAMMDD') = dbo.fduFechaatexto(Getdate(), 'AAAAMMDD')))
	                       Fecha INNER JOIN
	                          (SELECT DISTINCT tCsFirmaElectronica.Firma, tCsFirmaReporteDetalle.Grupo, Saldo1 AS SaldoAtrasado, Direccion AS Responsable
	                            FROM          tCsFirmaElectronica INNER JOIN
	                                                   tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
	                            WHERE      (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Dato LIKE '%' + @Prestamo + '%') AND 
	                                                   (tCsFirmaReporteDetalle.Grupo = 'G') AND Identificador = '1' AND (dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'AAAAMMDD') 
	                                                   = dbo.fduFechaatexto(Getdate(), 'AAAAMMDD'))) SA ON Fecha.Firma = SA.Firma AND Fecha.Grupo = SA.Grupo INNER JOIN
	                          (SELECT DISTINCT tCsFirmaElectronica.Firma, tCsFirmaReporteDetalle.Grupo, Saldo1 AS SaldoOtros, Direccion AS Asesor
	                            FROM          tCsFirmaElectronica INNER JOIN
	                                                   tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
	                            WHERE      (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Dato LIKE '%' + @Prestamo + '%') AND 
	                                                   (tCsFirmaReporteDetalle.Grupo = 'G') AND Identificador = '2' AND (dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'AAAAMMDD') 
	                                                   = dbo.fduFechaatexto(Getdate(), 'AAAAMMDD'))) SO ON Fecha.Firma = SO.Firma AND Fecha.Grupo = SO.Grupo INNER JOIN
	                      tCsFirmaReporte ON Fecha.Firma COLLATE Modern_Spanish_CI_AI = tCsFirmaReporte.Firma INNER JOIN
	                          (SELECT     Datos.Firma, Datos.Sujeto, Datos.Direccion, G.Sujeto AS G, Datos.Coordinador
	                            FROM          (SELECT     Firma, Sujeto, Direccion, CASE Saldo1 WHEN 0 THEN 2 ELSE Saldo1 END AS Coordinador
	                                                    FROM          tCsFirmaReporteDetalle
	                                                    WHERE      (Grupo = 'A')
	                                                    UNION
	                                                    SELECT     Firma, Sujeto, Direccion, 4 AS Coordinador
	                                                    FROM         tCsFirmaReporteDetalle
	                                                    WHERE     (Grupo = 'C')
	                                                    UNION
	                                                    SELECT     Firma, Sujeto, Direccion, 3 AS Coordinador
	                                                    FROM         tCsFirmaReporteDetalle
	                                                    WHERE     (Grupo = 'E')) Datos INNER JOIN
	                                                       (SELECT     Firma, Sujeto, Direccion
	                                                         FROM          tCsFirmaReporteDetalle
	                                                         WHERE      (Grupo = 'A') AND saldo1 = 1) G ON Datos.Firma = G.Firma) Clientes ON Fecha.Firma = Clientes.Firma INNER JOIN
	                      tCsFirmaReporteClausula ON Fecha.Firma COLLATE Modern_Spanish_CI_AI = tCsFirmaReporteClausula.Firma INNER JOIN
	                      tCsCartera ON Fecha.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo INNER JOIN
	                      vCsFechaConsolidacion ON tCsCartera.Fecha = vCsFechaConsolidacion.FechaConsolidacion INNER JOIN
	                          (SELECT DISTINCT Firma, Texto
	                            FROM          tCsFirmaReporteClausula
	                            WHERE      Orden = 100) Tipo ON Fecha.Firma = Tipo.Firma INNER JOIN
	                          (SELECT DISTINCT tCsFirmaElectronica.Firma, tCsFirmaReporteDetalle.Grupo, Saldo1 AS SaldoTotal, Direccion AS Operaciones
	                            FROM          tCsFirmaElectronica INNER JOIN
	                                                   tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
	                            WHERE      (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Dato LIKE '%' + @Prestamo + '%') AND 
	                                                   (tCsFirmaReporteDetalle.Grupo = 'G') AND Identificador = '3' AND (dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'AAAAMMDD') 
	                                                   = dbo.fduFechaatexto(Getdate(), 'AAAAMMDD'))) ST ON Fecha.Firma = ST.Firma AND Fecha.Grupo = ST.Grupo
	WHERE     (tCsFirmaReporteClausula.Orden <> 100)
End
If @Dato In (10)
Begin
	SELECT     tCsFirmaReporte.Firma, tCsFirmaReporteDetalle.Texto AS Oficina, ISNULL(tCsFirmaReporteDetalle.Nacionalidad, tCsFirmaReporte.Sujeto) AS Grupo, 
	                      tCsFirmaReporteDetalle.Sujeto AS CodPrestamo, tCaProducto.NombreProdCorto, tCaClTecnologia.Veridico AS Tecnologia, 
	                      tCsFirmaReporteDetalle.Direccion AS Asesor, Participantes.Participantes, tCsFirmaReporte.Saldo1 AS Desembolso, tCsFirmaReporte.Saldo2 / 12.000 AS TasaInteres, 
	                      tCsFirmaReporte.Saldo6 / 12.000 AS TasaMoratorio, tCaClTipoPlan.DescTipoPlan AS TipoPlan, tCaClModalidadPlazo.Descripcion AS Frecuencia, 
	                      tCsFirmaReporte.Saldo4 AS Plazo, tCsFirmaReporte.Fecha2 AS FAprobacion, tCsFirmaReporte.Fecha1 AS FDesembolso, tClFondos.NemFondo, 
	                      tCsFirmaReporte.Dato10 AS Estado, ISNULL(tCsFirmaReporte.Dato11, Participantes.Cliente) AS CodUsuario, ISNULL(Secuencia.Tipo, 'N') AS Tipo, 
	                      ISNULL(Secuencia.Ultimo, '') AS Anterior, ISNULL(Secuencia.Secuencia, 0) + 1 AS Secuencia, Clientes.Identificador, Clientes.Sujeto, Clientes.Saldo1 AS Cordinador, 
	                      Clientes.Saldo2 AS Capital, ROUND(Clientes.Saldo2 / tCsFirmaReporte.Saldo1 * 100, 2) AS Porcentaje, ROUND(Clientes.Saldo5, 0) AS Cuota, Clientes.Identificacion, 
	                      Acta.Acta
	FROM         tCsFirmaReporte INNER JOIN
	                      tCsFirmaReporteDetalle ON tCsFirmaReporte.Firma = tCsFirmaReporteDetalle.Firma INNER JOIN
	                      tCaProducto ON tCsFirmaReporte.Dato4 = tCaProducto.CodProducto INNER JOIN
	                      tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia INNER JOIN
	                          (SELECT     Datos.Firma, Datos.Participantes, tCsPadronClientes.CodUsuario AS Cliente
	                            FROM          (SELECT     Firma, COUNT(*) AS Participantes, MAX(Identificador) AS Cliente
	                                                    FROM          tCsFirmaReporteDetalle
	                                                    WHERE      (Grupo = 'A')
	                                                    GROUP BY Firma) Datos LEFT OUTER JOIN
	                                                   tCsPadronClientes ON Datos.Cliente = tCsPadronClientes.CodOrigen) Participantes ON 
	                      tCsFirmaReporte.Firma = Participantes.Firma COLLATE Modern_Spanish_CI_AI INNER JOIN
	                      tCaClTipoPlan ON tCsFirmaReporte.Saldo5 = tCaClTipoPlan.CodTipoPlan INNER JOIN
	                      tCaClModalidadPlazo ON tCsFirmaReporte.Dato1 = tCaClModalidadPlazo.ModalidadPlazo INNER JOIN
	                      tClFondos ON tCsFirmaReporte.Dato9 = tClFondos.CodFondo INNER JOIN
	                      tCsFirmaElectronica ON tCsFirmaReporte.Firma = tCsFirmaElectronica.Firma INNER JOIN
	                      tCsFirmaReporteDetalle Clientes ON tCsFirmaReporte.Firma = Clientes.Firma INNER JOIN
	                          (SELECT DISTINCT Firma, Texto AS Acta
	                            FROM          tCsFirmaReporteDetalle
	                            WHERE      (Grupo = 'H')) Acta ON tCsFirmaReporte.Firma = Acta.Firma COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
	                          (SELECT DISTINCT 
	                                                   Datos.Tipo, Datos.Cliente, Datos.Fecha, Datos.Desembolso, Datos.CodPrestamo AS Ultimo, tCsPadronCarteraDet.SecuenciaGrupo AS Secuencia
	                            FROM          (SELECT     Datos.Tipo, Datos.Cliente, Datos.Fecha, Datos.Desembolso, MAX(tCsPadronCarteraDet.CodPrestamo) AS CodPrestamo
	                                                    FROM          (SELECT     Datos.Tipo, Datos.Cliente, Datos.Fecha, MAX(tCsPadronCarteraDet.Desembolso) AS Desembolso
	                                                                            FROM          (SELECT     'G' AS Tipo, CodGrupo AS Cliente, MAX(FechaCorte) AS Fecha
	                                                                                                    FROM          tCsPadronCarteraDet
	                                                                                                    WHERE      (CodGrupo IS NOT NULL) AND tCsPadronCarteraDet.CodPrestamo NOT IN (@Prestamo)
	                                                                                                    GROUP BY CodGrupo) Datos INNER JOIN
	                                                                                                   tCsPadronCarteraDet ON Datos.Cliente COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodGrupo AND 
	                                                                                                   Datos.Fecha = tCsPadronCarteraDet.FechaCorte
	                                                                            WHERE      tCsPadronCarteraDet.CodPrestamo NOT IN (@Prestamo)
	                                                                            GROUP BY Datos.Tipo, Datos.Cliente, Datos.Fecha) Datos INNER JOIN
	                                                                           tCsPadronCarteraDet ON Datos.Desembolso = tCsPadronCarteraDet.Desembolso AND Datos.Fecha = tCsPadronCarteraDet.FechaCorte AND 
	                                                                           Datos.Cliente = tCsPadronCarteraDet.CodGrupo
	                                                    WHERE      tCsPadronCarteraDet.CodPrestamo NOT IN (@Prestamo)
	                                                    GROUP BY Datos.Tipo, Datos.Cliente, Datos.Fecha, Datos.Desembolso) Datos INNER JOIN
	                                                   tCsPadronCarteraDet ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo AND 
	                                                   Datos.Cliente COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodGrupo AND Datos.Fecha = tCsPadronCarteraDet.FechaCorte AND 
	                                                   Datos.Desembolso = tCsPadronCarteraDet.Desembolso
	                            UNION
	                            SELECT DISTINCT 
	                                                  Datos.Tipo, Datos.Cliente, Datos.Fecha, Datos.Desembolso, Datos.CodPrestamo AS Ultimo, tCsPadronCarteraDet.SecuenciaCliente AS Secuencia
	                            FROM         (SELECT     Datos.Tipo, Datos.Cliente, Datos.Fecha, Datos.Desembolso, MAX(tCsPadronCarteraDet.CodPrestamo) AS CodPrestamo
	                                                   FROM          (SELECT     Datos.Tipo, Datos.Cliente, Datos.Fecha, MAX(tCsPadronCarteraDet.Desembolso) AS Desembolso
	                                                                           FROM          (SELECT     'C' AS Tipo, CodUsuario AS Cliente, MAX(FechaCorte) AS Fecha
	                                                                                                   FROM          tCsPadronCarteraDet
	                                                                                                   WHERE      tCsPadronCarteraDet.CodPrestamo NOT IN (@Prestamo)
	                                                                                                   GROUP BY CodUsuario) Datos INNER JOIN
	                                                                                                  tCsPadronCarteraDet ON Datos.Cliente COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodUsuario AND 
	                                                                                                  Datos.Fecha = tCsPadronCarteraDet.FechaCorte
	                                                                           WHERE      tCsPadronCarteraDet.CodPrestamo NOT IN (@Prestamo)
	                                                                           GROUP BY Datos.Tipo, Datos.Cliente, Datos.Fecha) Datos INNER JOIN
	                                                                          tCsPadronCarteraDet ON Datos.Desembolso = tCsPadronCarteraDet.Desembolso AND Datos.Fecha = tCsPadronCarteraDet.FechaCorte AND 
	                                                                          Datos.Cliente = tCsPadronCarteraDet.CodUsuario
	                                                   WHERE      tCsPadronCarteraDet.CodPrestamo NOT IN (@Prestamo)
	                                                   GROUP BY Datos.Tipo, Datos.Cliente, Datos.Fecha, Datos.Desembolso) Datos INNER JOIN
	                                                  tCsPadronCarteraDet ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo AND 
	                                                  Datos.Cliente COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodUsuario AND Datos.Fecha = tCsPadronCarteraDet.FechaCorte AND 
	                                                  Datos.Desembolso = tCsPadronCarteraDet.Desembolso) Secuencia ON ISNULL(tCsFirmaReporte.Dato11, Participantes.Cliente) 
	                      = Secuencia.Cliente COLLATE Modern_Spanish_CI_AI
	WHERE     (tCsFirmaReporteDetalle.Grupo = 'G') AND (tCsFirmaReporteDetalle.Identificador = '2') AND (tCsFirmaElectronica.Dato = @Prestamo) AND 
	                      (tCsFirmaElectronica.Usuario = @Usuario) AND (Clientes.Grupo = 'A')
End
If @Dato In(11, 12)
Begin
	SELECT     General.Firma, CAST(General.SecCuota AS Int) AS SecCuota, General.Vencimiento, General.Capital, General.Interes, General.Iva, General.Total, Cliente.CodUsuario, 
	                      Cliente.Nombre, Cliente.Capital AS CCapital, Cliente.Interes AS CInteres, Cliente.Iva AS CIva, Cliente.Total AS CTotal, P.Participantes, 
	                      tCsFirmaReporte.DireccionAgencia, Oficina.Telmex, Oficina.HAPLunesViernes, Oficina.HAPSabado, Multa.Multa, Multa.PIVA
	FROM         (SELECT     tCsFirmaReporteDetalle.Firma, tCsFirmaReporteDetalle.Identificador AS SecCuota, tCsFirmaReporteDetalle.Fecha1 AS Vencimiento, 
	                                              tCsFirmaReporteDetalle.Saldo2 AS Capital, tCsFirmaReporteDetalle.Saldo3 AS Interes, tCsFirmaReporteDetalle.Saldo4 AS Iva, 
	                                              tCsFirmaReporteDetalle.Saldo1 AS Total
	                       FROM          tCsFirmaReporteDetalle INNER JOIN
	                                              tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma
	                       WHERE      (tCsFirmaElectronica.Dato = @Prestamo) AND (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaReporteDetalle.Grupo = 'B')) 
	                      General INNER JOIN
	                          (SELECT     Firma, Ltrim(rtrim(str(Dec1, 5, 0))) AS Seccuota, Fecha1 AS Vencimiento, Saldo2 AS Capital, Saldo3 AS Interes, Saldo4 AS Iva, Saldo1 AS Total, 
	                                                   Sujeto AS CodUsuario, Direccion AS Nombre
	                            FROM          tCsFirmaReporteDetalle
	                            WHERE      (Grupo = 'H')) Cliente ON General.Firma = Cliente.Firma AND General.Vencimiento = Cliente.Vencimiento AND 
	                      General.SecCuota = Cliente.Seccuota INNER JOIN
	                          (SELECT     tCsFirmaElectronica.Firma, COUNT(*) AS Participantes
	                            FROM          tCsFirmaReporteDetalle INNER JOIN
	                                                   tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma
	                            WHERE      (tCsFirmaElectronica.Dato = @Prestamo) AND (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaReporteDetalle.Grupo = 'A')
	                            GROUP BY tCsFirmaElectronica.Firma) P ON General.Firma = P.Firma INNER JOIN
	                      tCsFirmaReporte ON General.Firma COLLATE Modern_Spanish_CI_AI = tCsFirmaReporte.Firma INNER JOIN
	                          (SELECT     tCsFirmaReporteDetalle.Firma, tClOficinas.Telmex, tClOficinas.HAPLunesViernes, tClOficinas.HAPSabado
	                            FROM          tCsFirmaReporteDetalle INNER JOIN
	                                                   tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma INNER JOIN
	                                                   tClOficinas ON tCsFirmaReporteDetalle.EstadoCivil = tClOficinas.CodOficina
	                            WHERE      (tCsFirmaElectronica.Dato = @Prestamo) AND (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaReporteDetalle.Grupo = 'G')
	                            GROUP BY tCsFirmaReporteDetalle.Firma, tClOficinas.Telmex, tClOficinas.HAPLunesViernes, tClOficinas.HAPSabado) Oficina ON General.Firma = Oficina.Firma INNER JOIN
                          (SELECT     tCsFirmaReporte.Firma, tCsFirmaReporte.Saldo3 AS Multa, IVA.PIVA
                            FROM          tCsFirmaReporte INNER JOIN
                                                       (SELECT     Firma, ROUND(AVG(ROUND(Saldo4 / Saldo3, 4)), 2) * 100 AS PIVA
                                                         FROM          tCsFirmaReporteDetalle
                                                         WHERE      (Grupo = 'H')
                                                         GROUP BY Firma) IVA ON tCsFirmaReporte.Firma = IVA.Firma COLLATE Modern_Spanish_CI_AI) Multa ON 
                      tCsFirmaReporte.Firma = Multa.Firma COLLATE Modern_Spanish_CI_AI	


	SELECT  @Cadena = 'UPDATE ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tCaPrestamos Set SelloElectronico = ''' + tCsFirmaElectronica.Firma + ''' Where CodPrestamo = ''' + tCsFirmaElectronica.Dato + '''' 
	FROM       tCsFirmaElectronica INNER JOIN
	           tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma
	WHERE     (tCsFirmaElectronica.Dato = @Prestamo) AND (tCsFirmaElectronica.Usuario = @Usuario)

	Exec(@Cadena)
End
If @Dato In (13, 14)
Begin
	If @Dato = 13 Begin Set @Dato = 1 End -- Para Responsable de Agencia
	If @Dato = 14 Begin Set @Dato = 3 End -- Para Coordinador de Operaciones
	
	SELECT     tCsFirmaElectronica.Firma, tCsFirmaReporteDetalle.Sujeto, tCsFirmaReporteDetalle.Direccion, tCsFirmaReporteDetalle.Actividad, tCsFirmaReporteDetalle.Ocupacion, 
	                      'Día ' + dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha2, 'DD') + ' Mes ' + dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha2, 'MM') 
	                      + ' Año ' + dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha2, 'AAAA') AS Nacimiento, LTRIM(RTRIM(STR(ISNULL(tCsFirmaReporteDetalle.Dec1, 0), 3))) 
	                      + ' Kgs.' AS Peso, LTRIM(RTRIM(STR(ISNULL(tCsFirmaReporteDetalle.Dec2, 0), 6, 2))) + ' Mts.' AS Estatura, UPPER(tUsClSexo.Genero) AS Sexo, 
	                      CAST(dbo.fduEdad(tCsFirmaReporteDetalle.Fecha2, tCsFirmaElectronica.Registro) AS varchar(5)) + ' Años.' AS Edad, tCsFirmaReporteDetalle.Identificador, 
	                      tCsFirmaReporteClausula.Texto, tCsFirmaReporteClausula.Orden, Firmado.Firmado, ISNULL(tCsFirmaReporteDetalle.Texto, '') AS Salud, 
	                      ISNULL(Secuencia.Secuencia, 0) + 1 AS Secuencia, Firmantes.Firmante
	FROM         (SELECT     Firma, Direccion AS Firmante
	                       FROM          tCsFirmaReporteDetalle
	                       WHERE      (Grupo = 'G') AND (Identificador = Cast(@Dato as Varchar(2)))) Firmantes RIGHT OUTER JOIN
	                      tCsFirmaReporteDetalle INNER JOIN
	                      tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma INNER JOIN
	                      tUsClSexo ON tCsFirmaReporteDetalle.Dec3 = tUsClSexo.Sexo INNER JOIN
	                      tCsFirmaReporteClausula ON tCsFirmaReporteDetalle.Firma = tCsFirmaReporteClausula.Firma INNER JOIN
	                          (SELECT     Firma, REPLACE(Texto, 'Lugar de Suscripción:', 'Firmado en:') AS Firmado
	                            FROM          tCsFirmaReporteClausula
	                            WHERE      (Tipo = 'Pagare') AND (Fila = 1)) Firmado ON tCsFirmaReporteDetalle.Firma = Firmado.Firma COLLATE Modern_Spanish_CI_AI ON 
	                      Firmantes.Firma COLLATE Modern_Spanish_CI_AI = tCsFirmaReporteDetalle.Firma LEFT OUTER JOIN
	                          (SELECT     tCsFirmaReporteDetalle.Identificador, DATEDIFF([month], MAX(tCsPadronCarteraDet.Desembolso), vCsFechaConsolidacion.FechaConsolidacion) AS Zurich
			FROM         vCsFechaConsolidacion CROSS JOIN
			                      tCsFirmaReporteDetalle INNER JOIN
			                      tCsPadronClientes INNER JOIN
			                      tCsPadronCarteraDet ON tCsPadronClientes.CodUsuario = tCsPadronCarteraDet.CodUsuario ON 
			                      tCsFirmaReporteDetalle.Identificador = tCsPadronClientes.CodOrigen
			WHERE     (tCsFirmaReporteDetalle.Grupo = 'A') AND (tCsPadronCarteraDet.Zurich = 1)
			GROUP BY tCsFirmaReporteDetalle.Identificador, vCsFechaConsolidacion.FechaConsolidacion) Zurich ON 
	                      tCsFirmaReporteDetalle.Identificador = Zurich.Identificador COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN
	                          (SELECT     Filtro.CodUsuario, Filtro.Secuencia, tCsPadronCarteraDet.CodPrestamo, DATEDIFF([Month], tCsPadronCarteraDet.Desembolso, 
	                                                   vCsFechaConsolidacion.FechaConsolidacion) AS A
	                            FROM          (SELECT     CodUsuario, MAX(SecuenciaCliente) AS Secuencia
	                                                    FROM          tCsPadronCarteraDet
	                                                    GROUP BY CodUsuario) Filtro INNER JOIN
	                                                   tCsPadronCarteraDet ON Filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodUsuario AND 
	                                                   Filtro.Secuencia = tCsPadronCarteraDet.SecuenciaCliente CROSS JOIN
	                                                   vCsFechaConsolidacion) Secuencia RIGHT OUTER JOIN
	                      tCsPadronClientes ON Secuencia.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientes.CodUsuario ON 
	                      tCsFirmaReporteDetalle.Identificador = tCsPadronClientes.CodOrigen
	WHERE     (tCsFirmaElectronica.Dato = @Prestamo) AND (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaReporteDetalle.Grupo = 'A') AND   (tCsFirmaReporteClausula.Tipo = 'Zurich') 
		    AND ((ISNULL(Secuencia.Secuencia, 0) + 1 = 1) Or Isnull(Secuencia.A, 0) >= 12  Or Isnull(Zurich.Zurich, 0) >= 12 )	
End
If @Dato In (15, 16, 17, 21)
Begin
	Declare @Acta 			Varchar(50)
		
	Set @Acta 			= Ltrim(rtrim(@Prestamo))
	
	Declare @NroActa		Varchar(50)
	Declare @CodOficina 	VarChar(4)
	Declare @Tipo			VarChar(3)
	Declare @Correlativo	Int
	
	Set @NroActa 		= Right(@Acta, 9)
	Set @CodOficina 	= Cast(Left (@Acta, 3) as Int)
	Set @Tipo			= SubString (@Acta, 5, 3)
	Set @Correlativo	= Cast(Right(@Acta, 6) as Int)
	
	If Ltrim(rtrim(@Ubicacion)) = '' Or Ltrim(rtrim(@Ubicacion)) = 'ZZZ' Begin Set @Ubicacion = '''''' End	
	
	If @Dato In (15, 17, 21) -- Para Generar Datos
	Begin
		If @Dato In (15, 21) -- Para Consulta 15: Pura Consulta 21: Check List
		Begin
			Set		@Cadena = 'Exec ['+ @Servidor +'].'+ @BaseDatos +'.dbo.pCaComiteActaDetalle 0, ''' + @NroActa + ''', ''' + @CodOficina + ''''
			Print   @Cadena
			Exec	(@Cadena)
		End
		If @Dato = 17		--Para Culminar 
		Begin
			Set		@Cadena = 'Exec ['+ @Servidor +'].'+ @BaseDatos +'.dbo.pCaComiteActaDetalle 1, ''' + @NroActa + ''', ''' + @CodOficina + ''''
			Print    @Cadena
			Exec	(@Cadena)
		End
		
		Delete from tCsComiteActaDetalle Where Acta = @NroActa and CodOficina = @CodOficina
	
		Set  @Cadena = 'Insert Into tCsComiteActaDetalle Select * From ['+ @Servidor +'].'+ @BaseDatos +'.dbo.tCaComiteActaDetalle Where Acta = ''' + @NroActa + ''' And CodOficina = ''' + @CodOficina + ''''
		Exec (@Cadena)	
		print 'CODIGO PARA REGISTRAR ASISTENTES DEL ACTA DE COMITE DE CREDITO'
		Set 	@Cadena = 'Insert Into #Temp SELECT CodUsuario, Nombre FROM tCsComiteIntegrantes WHERE (Tipo = '''+ @Tipo +''') AND (CodOficina = '''+ @CodOficina +''') AND (PMinimo = 100) OR (CodUsuario IN (' + @Ubicacion + '))'
		Print 	@Cadena
		Exec 	(@Cadena)
		
		Declare CurCarta Cursor For 
			SELECT     Grupo, M - I AS Falta
			FROM         (SELECT     G.Grupo, G.PMinimo, G.Total, G.M, ISNULL(I.Ingresados, 0) AS I
			                       FROM          (SELECT     Grupo, PMinimo, COUNT(*) AS Total, ROUND(PMinimo / 100 * COUNT(*), 0) AS M
			                                               FROM          tCsComiteIntegrantes
			                                               WHERE      (CodOficina = @CodOficina) AND (Tipo = @Tipo) AND (PMinimo <> 100)
			                                               GROUP BY Grupo, PMinimo) G LEFT OUTER JOIN
			                                                  (SELECT     tCsComiteIntegrantes.Grupo, COUNT(*) AS Ingresados
			                                                    FROM          tCsComiteIntegrantes INNER JOIN
			                                                                               (SELECT *, CodOficina = @CodOficina, Tipo = @Tipo From #Temp) TEMPd ON 
			                                                                           tCsComiteIntegrantes.CodUsuario = TEMPd.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 
			                                                                           tCsComiteIntegrantes.CodOficina = TEMPd.CodOficina COLLATE Modern_Spanish_CI_AI AND 
			                                                                           tCsComiteIntegrantes.Tipo = TEMPd.Tipo COLLATE Modern_Spanish_CI_AI
			                                                    WHERE      (tCsComiteIntegrantes.PMinimo <> 100)
			                                                    GROUP BY tCsComiteIntegrantes.Grupo) I ON G.Grupo = I.Grupo) Datos
			WHERE     (I < M)
		Open CurCarta
		Fetch Next From CurCarta Into @Cad1, @Int1
		While @@Fetch_Status = 0
		Begin
			Set @Cadena = 'Insert Into #Temp SELECT TOP '+ Cast(@Int1 as Varchar(10)) +' CodUsuario, Nombre FROM tCsComiteIntegrantes WHERE '
			Set @Cadena = @Cadena + '(CodUsuario NOT IN (SELECT CodPrestamo From #Temp)) AND (CodOficina = '''+ @CodOficina +''') AND '
			Set @Cadena = @Cadena + '(Tipo = '''+ @Tipo +''') AND (Grupo = '''+ @Cad1 +''')'
			Print @Cadena
			Exec(@Cadena)
		Fetch Next From CurCarta Into  @Cad1, @Int1
		End 
		Close 		CurCarta
		Deallocate 	CurCarta	

		Delete From tCsComiteActaAsistentes Where Acta = @Acta

		INSERT INTO tCsComiteActaAsistentes
		SELECT     Cabecera.Tipo, Cabecera.CodOficina, Cabecera.Acta, Cabecera.Registro, Cabecera.Hora, Cabecera.DescOficina, Cabecera.TipoActa, tCsComiteIntegrantes.CodUsuario, 
		           tCsComiteIntegrantes.Nombre, tCsComiteIntegrantes.Puesto, tCsComiteIntegrantes.Grupo, tCsComiteIntegrantes.PMinimo, 
			    MontoSolicitado = (SELECT SUM(MTS) FROM  (SELECT DISTINCT CodSolicitud, MTS
						                       FROM tCsComiteActaDetalle
						                       WHERE (Acta = @NroActa) AND (CodOficina = @CodOficina)) Datos)
		FROM         (SELECT     tCsComiteIntegrantes.Tipo, tCsComiteIntegrantes.CodOficina, @Acta AS Acta, MAX(tCsComiteIntegrantes.Registro) AS Registro, CONVERT(VARCHAR(20), 
		                                              MAX(tCsComiteIntegrantes.Registro), 108) AS Hora, tClOficinas.DescOficina, tCsComiteIntegrantes.TipoActa
		                       FROM          tCsComiteIntegrantes INNER JOIN
		                                              tClOficinas ON tCsComiteIntegrantes.CodOficina = tClOficinas.CodOficina
		                       WHERE      (tCsComiteIntegrantes.CodOficina = @CodOficina) AND (tCsComiteIntegrantes.Tipo = @Tipo)
		                       GROUP BY tCsComiteIntegrantes.Tipo, tCsComiteIntegrantes.CodOficina, tClOficinas.DescOficina, tCsComiteIntegrantes.TipoActa) Cabecera INNER JOIN
		                      tCsComiteIntegrantes ON Cabecera.Tipo COLLATE Modern_Spanish_CI_AI = tCsComiteIntegrantes.Tipo AND 
		                      Cabecera.CodOficina COLLATE Modern_Spanish_CI_AI = tCsComiteIntegrantes.CodOficina
		WHERE     (tCsComiteIntegrantes.CodUsuario IN
		                          (Select CodPrestamo From #Temp))
		If @Dato In (15, 17)
		Begin 
			SELECT  tCsComiteActaDetalle.CodSolicitud, tCsComiteActaDetalle.Asesor, tCsComiteActaDetalle.GrupoCliente, tCsComiteActaDetalle.Clientes, 
				tCsComiteActaDetalle.MontoSolicitado, tCsComiteActaDetalle.MontoAprobado, tCsComiteActaDetalle.MTS, tCsComiteActaDetalle.MTA, 
				CAST(tCsComiteActaDetalle.PPlazo AS varchar(5)) 
				+ ' ' + CASE WHEN tCsComiteActaDetalle.PPlazo > 1 THEN tCAClTipoPlaz_1.Plural WHEN tCsComiteActaDetalle.PPlazo = 1 THEN tCAClTipoPlaz_1.DescTipoPlaz ELSE
				'PLAZO INCORRECTO' END + ' - ' + tCaClTipoPlan_1.DescTipoPlan AS PPlanCuota, CAST(tCsComiteActaDetalle.Plazo AS varchar(5)) 
				+ ' ' + CASE WHEN tCsComiteActaDetalle.Plazo > 1 THEN tCAClTipoPlaz.Plural WHEN tCsComiteActaDetalle.Plazo = 1 THEN tCAClTipoPlaz.DescTipoPlaz ELSE 'PLAZO INCORRECTO'
				END + ' - ' + tCaClTipoPlan.DescTipoPlan AS PlanCuota, tCsComiteActaDetalle.TasaInteres / 12 AS TasaInteres, tCsComiteActaDetalle.Destino, 
				tCsComiteActaDetalle.LabActividad, tCsComiteActaDetalle.NemGarantia, tCsComiteActaDetalle.DescGarantia, tCsComiteActaDetalle.NombreProdCorto, 
				tCsComiteActaDetalle.CodEstado, tCsComiteActaDetalle.CodEstadoAnte, tCsComiteActaDetalle.Observacion, tCsComiteActaDetalle.CodUsuario,
				tCsComiteActaDetalle.FechaDesembolso, tCsComiteActaDetalle.FechaAprobacion, tCsComiteActaDetalle.Terminada, Casos = (SELECT COUNT(*) 
			FROM         (SELECT DISTINCT Acta, CodSolicitud, CodOficina
								   FROM          tCsComiteActaDetalle
								   WHERE      Acta = @NroActa AND CodOficina = @CodOficina) Datos)
			FROM         tCsComiteActaDetalle LEFT OUTER JOIN
								  tCAClTipoPlaz tCAClTipoPlaz_1 ON tCsComiteActaDetalle.PTipoPlaz = tCAClTipoPlaz_1.CodTipoPlaz LEFT OUTER JOIN
								  tCaClTipoPlan tCaClTipoPlan_1 ON tCsComiteActaDetalle.PCodTipoPlan = tCaClTipoPlan_1.CodTipoPlan LEFT OUTER JOIN
								  tCaClTipoPlan ON tCsComiteActaDetalle.CodTipoPlan = tCaClTipoPlan.CodTipoPlan LEFT OUTER JOIN
								  tCAClTipoPlaz ON tCsComiteActaDetalle.CodTipoPlaz = tCAClTipoPlaz.CodTipoPlaz
			WHERE     (tCsComiteActaDetalle.Acta = @NroActa) AND (tCsComiteActaDetalle.CodOficina = @CodOficina)
		End
		Else		-- Se asume que @Dato = 21
		Begin
			Declare @Evaluacion Varchar(100)
			Declare @Secuencia	Int
			
			CREATE TABLE #Acta(
				[Acta] [varchar](50) NOT NULL,
				[CodSolicitud] [varchar](15) NOT NULL,
				[CodOficina] [varchar](4) NOT NULL,
				[CodUsuario] [char](15) NOT NULL,
				[Codigo] [varchar](15) NULL,
				[Secuencia] [int] NULL,
				[SC] [int] NULL,
				[Evaluacion] [varchar](1) NOT NULL
			) ON [PRIMARY]	
			
			Set @Cadena = 'Insert Into #Acta SELECT     Acta, CodSolicitud, CodOficina, CodUsuario, Codigo, Secuencia + 1 AS Secuencia, SUM(C) + 1 AS SC, '
			Set @Cadena = @Cadena + 'CASE WHEN CodUsuario = Codigo THEN CASE WHEN (Secuencia + 1) % 2 = 0 THEN ''P'' ELSE ''I'' END WHEN (SUM(C) + 1) % 2 = '
			Set @Cadena = @Cadena + '0 THEN ''P'' ELSE ''I'' END AS Evaluacion FROM (SELECT Acta, CodSolicitud, CodOficina, CodUsuario, C, Codigo, '
			Set @Cadena = @Cadena + 'MAX(Secuencia) AS Secuencia FROM (SELECT tCsComiteActaDetalle.Acta, tCsComiteActaDetalle.CodSolicitud, '
			Set @Cadena = @Cadena + 'tCsComiteActaDetalle.CodOficina, tCsComiteActaDetalle.CodUsuario, CASE WHEN tCsPadronCarteraDet.CodPrestamo IS NULL '
			Set @Cadena = @Cadena + 'THEN 0 ELSE 1 END AS C, CASE WHEN Ltrim(Rtrim(isnull(tCsComiteActaDetalle.CodGrupo, ''''))) = '''' THEN '
			Set @Cadena = @Cadena + 'tCsPadronClientes_1.CodOrigen ELSE tCsComiteActaDetalle.CodGrupo END AS Codigo, ISNULL(CASE WHEN Ltrim(Rtrim(isnull'
			Set @Cadena = @Cadena + '(tCsComiteActaDetalle.CodGrupo, ''''))) = '''' THEN tCsPadronCarteraDet_1.SecuenciaGrupo ELSE isnull('
			Set @Cadena = @Cadena + 'tCsPadronCarteraDet_2.SecuenciaGrupo, 0) END, 0) AS Secuencia FROM tCsPadronCarteraDet AS tCsPadronCarteraDet_2 RIGHT '
			Set @Cadena = @Cadena + 'OUTER JOIN tCsComiteActaDetalle ON tCsPadronCarteraDet_2.CodGrupo = tCsComiteActaDetalle.CodGrupo AND '
			Set @Cadena = @Cadena + 'tCsPadronCarteraDet_2.Desembolso < tCsComiteActaDetalle.FechaDesembolso LEFT OUTER JOIN tCsPadronClientes AS '
			Set @Cadena = @Cadena + 'tCsPadronClientes_1 LEFT OUTER JOIN tCsPadronCarteraDet AS tCsPadronCarteraDet_1 ON tCsPadronClientes_1.CodUsuario = '
			Set @Cadena = @Cadena + 'tCsPadronCarteraDet_1.CodUsuario ON tCsComiteActaDetalle.CodUsuario = tCsPadronClientes_1.CodOrigen LEFT OUTER JOIN '
			Set @Cadena = @Cadena + 'tCsPadronCarteraDet INNER JOIN tCsPadronClientes ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario ON '
			Set @Cadena = @Cadena + 'tCsComiteActaDetalle.CodGrupo = tCsPadronCarteraDet.CodGrupo AND tCsComiteActaDetalle.FechaDesembolso > '
			Set @Cadena = @Cadena + 'tCsPadronCarteraDet.Desembolso AND tCsComiteActaDetalle.CodUsuario = tCsPadronClientes.CodOrigen WHERE '
			Set @Cadena = @Cadena + '(tCsComiteActaDetalle.Acta = '''+ @NroActa +''') AND (tCsComiteActaDetalle.CodOficina = '''+ @CodOficina +''')) AS Datos '
			Set @Cadena = @Cadena + 'GROUP BY Acta, CodSolicitud, CodOficina, CodUsuario, C, Codigo) AS Datos GROUP BY Acta, CodSolicitud, CodOficina, '
			Set @Cadena = @Cadena + 'CodUsuario, Codigo, Secuencia'
						
			Print @Cadena
			Exec (@Cadena)	
						
			--SELECT @Evaluacion = MIN (Evaluacion) FROM  (Select * from #Acta) AS Datos Group by  Acta, CodSolicitud, CodOficina, Codigo, Secuencia 
			
			SELECT     Datos.CodOficina, Datos.Acta, Datos.CodSolicitud, Datos.FechaDesembolso, Datos.Titulo, Datos.Secuencia, Datos.DescOficina, Datos.Evaluacion, Datos.Tecnologia, 
								  Datos.GrupoCliente, Datos.NombreProdCorto, Datos.Asesor, Datos.IP, Datos.Grupo, Datos.Clientes, Datos.SecuenciaCliente, CheckList.Grupo AS CodGrupo, 
								  CheckList.Detalle, CheckList.Nombre, CheckList.GrupoChekList
			FROM         (SELECT     tCsComiteActaDetalle.CodOficina, tCsComiteActaDetalle.Acta, tCsComiteActaDetalle.CodSolicitud, tCsComiteActaDetalle.FechaDesembolso, 
														  CASE WHEN Ltrim(Rtrim(isnull(tCsComiteActaDetalle.CodGrupo, ''))) 
														  = '' THEN 'CREDITO INDIVIDUAL' ELSE 'CREDITO SOLIDARIO' END + ' ' + CASE Acta_1.Secuencia WHEN 1 THEN 'PRIMER CICLO' ELSE 'REPRESTAMO' END
														   AS Titulo, Acta_1.Secuencia, tClOficinas.DescOficina, CASE WHEN Ltrim(Rtrim(isnull(tCsComiteActaDetalle.CodGrupo, ''))) 
														  = '' THEN '' ELSE (CASE Acta_1.Evaluacion WHEN 'I' THEN 'Ciclo Impar, o Par con evaluación  de alguno(s) o todos los integrantes' WHEN 'P' THEN 'Ciclo Par sin evaluación'
														   END) END AS Evaluacion, CASE WHEN Ltrim(Rtrim(isnull(tCsComiteActaDetalle.CodGrupo, ''))) = '' THEN 'CI' ELSE 'CS' END AS Tecnologia, 
														  tCsComiteActaDetalle.GrupoCliente, tCsComiteActaDetalle.NombreProdCorto, tCsComiteActaDetalle.Asesor, Acta_1.Evaluacion AS IP, Integrantes.Grupo, 
														  Integrantes.Clientes, Clientes.Secuencia As SecuenciaCliente
								   FROM          tCsComiteActaDetalle INNER JOIN
														  tClOficinas ON tCsComiteActaDetalle.CodOficina = tClOficinas.CodOficina INNER JOIN
															  (SELECT     CodOficina, Acta, CodSolicitud, Secuencia, MIN(Evaluacion) AS Evaluacion
																FROM          (SELECT     Acta, CodSolicitud, CodOficina, CodUsuario, Codigo, Secuencia, SC, Evaluacion
																						FROM          [#Acta]) AS Datos
																GROUP BY CodOficina, Acta, CodSolicitud, Secuencia) AS Acta_1 ON tCsComiteActaDetalle.Acta = Acta_1.Acta AND 
														  tCsComiteActaDetalle.CodOficina = Acta_1.CodOficina AND tCsComiteActaDetalle.CodSolicitud = Acta_1.CodSolicitud INNER JOIN
															  (SELECT     Acta, CodSolicitud, CodOficina, Asesor, CodUsuario, Clientes, 'A' AS Grupo
																FROM          tCsComiteActaDetalle AS tCsComiteActaDetalle_1
																WHERE      (Acta = @NroActa) AND (CodOficina = @CodOficina)) AS Integrantes ON Acta_1.Acta = Integrantes.Acta AND 
														  Acta_1.CodOficina = Integrantes.CodOficina AND Acta_1.CodSolicitud = Integrantes.CodSolicitud INNER JOIN
															  (SELECT     Acta, CodSolicitud, CodOficina, CodUsuario, Codigo, 
																					   Secuencia, SC, Evaluacion
																FROM          [#Acta] AS Acta) AS Clientes ON Integrantes.Acta = Clientes.Acta AND Integrantes.CodSolicitud = Clientes.CodSolicitud AND 
														  Integrantes.CodOficina = Clientes.CodOficina AND Integrantes.CodUsuario = Clientes.CodUsuario
								   WHERE      (tCsComiteActaDetalle.Acta = @NroActa) AND (tCsComiteActaDetalle.CodOficina = @CodOficina)
								   GROUP BY tCsComiteActaDetalle.CodSolicitud, LTRIM(RTRIM(ISNULL(tCsComiteActaDetalle.CodGrupo, ''))), tClOficinas.DescOficina, 
														  tCsComiteActaDetalle.FechaDesembolso, tCsComiteActaDetalle.CodOficina, tCsComiteActaDetalle.Acta, Acta_1.Secuencia, 
														  tCsComiteActaDetalle.GrupoCliente, tCsComiteActaDetalle.NombreProdCorto, tCsComiteActaDetalle.Asesor, Integrantes.Grupo, Integrantes.Clientes, 
														  Clientes.Secuencia, Acta_1.Evaluacion) AS Datos INNER JOIN
									  (SELECT     CheckList.Detalle, CheckList.Grupo, CheckList.Tecnologia, ParImpar.ParImpar, CheckList.Nombre, CheckList.Descripcion, CheckList.Activo, 
															   CheckList.GrupoChekList, CheckList.SecMin, CheckList.SecMax
										FROM          (SELECT     tCaClCheckListDetalle.Detalle, tCaClCheckListDetalle.Grupo, tCaClCheckListDetalle.Tecnologia, tCaClCheckListDetalle.ParImpar, 
																					   tCaClCheckListDetalle.Nombre, tCaClCheckListDetalle.Descripcion, tCaClCheckListDetalle.Activo, 
																					   tCaClCheckListGrupo.Nombre AS GrupoChekList, tCaClCheckListDetalle.SecMin, tCaClCheckListDetalle.SecMax
																FROM          tCaClCheckListDetalle INNER JOIN
																					   tCaClCheckListGrupo ON tCaClCheckListDetalle.Grupo = tCaClCheckListGrupo.Grupo
																WHERE      (tCaClCheckListDetalle.Tecnologia <> 'C') AND (tCaClCheckListDetalle.Activo = 1)
																UNION
																SELECT     tCaClCheckListDetalle_2.Detalle, tCaClCheckListDetalle_2.Grupo, 'CS' AS Tecnologia, tCaClCheckListDetalle_2.ParImpar, 
																					  tCaClCheckListDetalle_2.Nombre, tCaClCheckListDetalle_2.Descripcion, tCaClCheckListDetalle_2.Activo, 
																					  tCaClCheckListGrupo_2.Nombre AS GrupoChekList, tCaClCheckListDetalle_2.SecMin, tCaClCheckListDetalle_2.SecMax
																FROM         tCaClCheckListDetalle AS tCaClCheckListDetalle_2 INNER JOIN
																					  tCaClCheckListGrupo AS tCaClCheckListGrupo_2 ON tCaClCheckListDetalle_2.Grupo = tCaClCheckListGrupo_2.Grupo
																WHERE     (tCaClCheckListDetalle_2.Tecnologia = 'C') AND (tCaClCheckListDetalle_2.Activo = 1)
																UNION
																SELECT     tCaClCheckListDetalle_1.Detalle, tCaClCheckListDetalle_1.Grupo, 'CI' AS Tecnologia, tCaClCheckListDetalle_1.ParImpar, 
																					  tCaClCheckListDetalle_1.Nombre, tCaClCheckListDetalle_1.Descripcion, tCaClCheckListDetalle_1.Activo, 
																					  tCaClCheckListGrupo_1.Nombre AS GrupoChekList, tCaClCheckListDetalle_1.SecMin, tCaClCheckListDetalle_1.SecMax
																FROM         tCaClCheckListDetalle AS tCaClCheckListDetalle_1 INNER JOIN
																					  tCaClCheckListGrupo AS tCaClCheckListGrupo_1 ON tCaClCheckListDetalle_1.Grupo = tCaClCheckListGrupo_1.Grupo
																WHERE     (tCaClCheckListDetalle_1.Tecnologia = 'C') AND (tCaClCheckListDetalle_1.Activo = 1)) AS CheckList INNER JOIN
																   (SELECT     Detalle, Grupo, ParImpar
																	 FROM          tCaClCheckListDetalle AS tCaClCheckListDetalle_5
																	 WHERE      (Activo = 1) AND (LEFT(ParImpar, 1) <> 'T')
																	 UNION
																	 SELECT     Detalle, Grupo, 'I' AS ParImpar
																	 FROM         tCaClCheckListDetalle AS tCaClCheckListDetalle_4
																	 WHERE     (Activo = 1) AND (LEFT(ParImpar, 1) = 'T')
																	 UNION
																	 SELECT     Detalle, Grupo, 'P' AS ParImpar
																	 FROM         tCaClCheckListDetalle AS tCaClCheckListDetalle_3
																	 WHERE     (Activo = 1) AND (LEFT(ParImpar, 1) = 'T')) AS ParImpar ON CheckList.Detalle = ParImpar.Detalle AND CheckList.Grupo = ParImpar.Grupo) 
								  AS CheckList ON Datos.Tecnologia = CheckList.Tecnologia AND Datos.IP = CheckList.ParImpar AND Datos.SecuenciaCliente >= CheckList.SecMin AND 
								  Datos.SecuenciaCliente <= CheckList.SecMax
                      
            Drop Table #Acta
		End
	End	
	
	If @Dato = 16 -- Para Cabecera de Acta.
	Begin
		SELECT DISTINCT tCsComiteActaAsistentes.*, tCsComiteActaDetalle.Terminada, Casos = (SELECT COUNT(*) 
		FROM         (SELECT DISTINCT Acta, CodSolicitud, CodOficina
		                       FROM          tCsComiteActaDetalle
		                       WHERE      Acta = @NroActa AND CodOficina = @CodOficina) Datos)
		FROM         tCsComiteActaDetalle INNER JOIN
		                      tCsComiteActaAsistentes ON tCsComiteActaDetalle.Acta = RIGHT(tCsComiteActaAsistentes.Acta, 9) AND 
		                      tCsComiteActaDetalle.CodOficina = tCsComiteActaAsistentes.CodOficina
		WHERE tCsComiteActaAsistentes.Acta = @Acta
	End
End
If @Dato = 18
Begin
	
	Set @Cadena		= 'SELECT Copia = ''Empresa'', tCsFirmaElectronica.Firma, vUsHuellasAutorizacion.Observacion AS Motivo, vUsHuellasAutorizacion.NombreCompleto '
	Set	@Cadena		= @Cadena + 'AS NombreCompleto, tCsFirmaElectronica.Registro FROM ['+ @Servidor +'].'+ @BaseDatos +'.dbo.vUsHuellasAutorizacion AS '
	Set	@Cadena		= @Cadena + 'vUsHuellasAutorizacion INNER JOIN tCsFirmaElectronica ON vUsHuellasAutorizacion.CodUsuario = tCsFirmaElectronica.Dato WHERE '
	Set	@Cadena		= @Cadena + '(vUsHuellasAutorizacion.CodUsuario = ''' + @Prestamo  + ''') AND (tCsFirmaElectronica.Activo = 1) AND '
	Set	@Cadena		= @Cadena + '(tCsFirmaElectronica.Usuario = '''+ @Usuario +''') AND tCsFirmaElectronica.Sistema = ''US'' UNION SELECT Copia = ''Cliente'', '
	Set	@Cadena		= @Cadena + 'tCsFirmaElectronica.Firma, vUsHuellasAutorizacion.Observacion AS Motivo, vUsHuellasAutorizacion.NombreCompleto AS NombreCompleto, '
	Set	@Cadena		= @Cadena + 'tCsFirmaElectronica.Registro FROM ['+ @Servidor +'].'+ @BaseDatos +'.dbo.vUsHuellasAutorizacion AS vUsHuellasAutorizacion INNER '
	Set	@Cadena		= @Cadena + 'JOIN tCsFirmaElectronica ON vUsHuellasAutorizacion.CodUsuario = tCsFirmaElectronica.Dato WHERE (vUsHuellasAutorizacion.CodUsuario '
	Set	@Cadena		= @Cadena + '= ''' + @Prestamo  + ''') AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = '''+ @Usuario +''') AND '
	Set	@Cadena		= @Cadena + 'tCsFirmaElectronica.Sistema = ''US'''
	
	Print @Cadena
	Exec (@Cadena)
End
Drop Table #Temp

GO