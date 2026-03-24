SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsReporteContrato2]
@Dato		Int,
@Usuario	Varchar(50) ,
@CodPrestamo	Varchar(500)
As

If @Dato = 1
Begin
	SELECT     Firma, Fila, Clausula, Orden, Titulo, Texto, Dato, dbo.fduFragmentoSeparador(Texto, '*N*', '*N*', 1) AS T1, dbo.fduFragmentoSeparador(Texto, '*N*', '*N*', 2) AS T2, 
						  dbo.fduFragmentoSeparador(Texto, '*N*', '*N*', 3) AS T3
	FROM         (SELECT     tCsFirmaReporteClausula.Firma, tCsFirmaReporteClausula.Fila, '' AS Clausula, tCsFirmaReporteClausula.Orden, '' AS Titulo, 
												  tCsFirmaReporteClausula.Texto, tCsFirmaElectronica.Dato, tCsFirmaReporteClausula.Tipo
						   FROM          tCsFirmaElectronica INNER JOIN
												  tCsFirmaReporteClausula ON tCsFirmaElectronica.Firma = tCsFirmaReporteClausula.Firma
						   WHERE      (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteClausula.Tipo = 'Declaracion') AND 
												  (tCsFirmaElectronica.Dato = @CodPrestamo) AND (tCsFirmaReporteClausula.Fila = 2)
						   UNION
						   SELECT     tCsFirmaReporteClausula.Firma, tCsFirmaReporteClausula.Fila, UPPER(tCsFirmaReporteClausula.Clausula) AS Clausula, tCsFirmaReporteClausula.Orden, 
												 UPPER(tCsFirmaReporteClausula.Titulo) AS Titulo, tCsFirmaReporteClausula.Texto, tCsFirmaElectronica.Dato, tCsFirmaReporteClausula.Tipo
						   FROM         tCsFirmaElectronica INNER JOIN
												 tCsFirmaReporteClausula ON tCsFirmaElectronica.Firma = tCsFirmaReporteClausula.Firma
						   WHERE     (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteClausula.Tipo = 'Clausula') AND 
												 (tCsFirmaElectronica.Dato = @CodPrestamo)) AS Datos
	ORDER BY Tipo DESC, Fila
End
If @Dato = 2
Begin
	SELECT DISTINCT 
	                      tCsFirmaElectronica.Firma, tCsFirmaElectronica.Dato, tCsFirmaReporte.Sujeto, tCsFirmaReporte.Direccion, Denominacion = Upper(tCsFirmaReporte.Denominacion), Denominacion1=Upper(tCsFirmaReporte.Denominacion1), Denominacion2=Upper(tCsFirmaReporte.Denominacion2), 
	                      tCsFirmaReporteDetalle.Sujeto AS Nombres, tCsFirmaReporteDetalle.EstadoCivil, tCsFirmaReporteDetalle.Ocupacion, 
	                      tCsFirmaReporteDetalle.Direccion AS DireccionCliente, tCsFirmaReporteDetalle.Identificacion, tCsFirmaReporteDetalle.Saldo1 AS Coordinador
	FROM         tCsFirmaElectronica INNER JOIN
	                      tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma INNER JOIN
	                      tCsFirmaReporteDetalle ON tCsFirmaReporte.Firma = tCsFirmaReporteDetalle.Firma
	WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaReporteDetalle.Grupo = 'A') AND (tCsFirmaElectronica.Usuario = @Usuario) And
		tCsFirmaElectronica.Dato = @CodPrestamo
	ORDER BY tCsFirmaReporteDetalle.Saldo1 DESC
End
If @Dato = 3
Begin
	SELECT  DISTINCT   CASE Grupo WHEN 'A' THEN 'Acreditado' WHEN 'C' THEN 'Codeudor' WHEN 'E' THEN 'Aval' END AS Tipo, tCsFirmaReporteDetalle.Sujeto, 
						  tCsFirmaReporteDetalle.Direccion, PP.PP, tCsFirmaReporte.Fecha1 AS FechaApertura, Denominacion = Upper(tCsFirmaReporte.Denominacion), tCsFirmaReporte.Sujeto AS Sujeto1
	FROM         tCsFirmaElectronica INNER JOIN
						  tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma INNER JOIN
						  tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma LEFT OUTER JOIN
							  (SELECT      Firma, Case When MIn(Texto) =  max(Texto) Then MIn(Texto) Else  MIn(Texto) +  max(Texto) End AS PP
                            FROM          tCsFirmaReporteClausula
                            WHERE      (Orden = 100) AND (Tipo = 'Pagare')
                            Group by Firma) AS PP ON tCsFirmaElectronica.Firma = PP.Firma
	WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaReporteDetalle.Grupo IN ('A', 'C', 'E')) AND 
						  (tCsFirmaElectronica.Dato = @CodPrestamo)
End
If @Dato = 4
Begin
	SELECT     dbo.fduRellena('0', tCsFirmaReporteDetalle.Identificador, 2, 'D') AS Cuota, dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'DD') 
	                      + '/' + dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'MM') + '/' + dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'AAAA') AS Vencimiento, 
	                      dbo.fduNumeroTexto(tCsFirmaReporteDetalle.Saldo1, 2) AS Total
	FROM         tCsFirmaElectronica INNER JOIN
	                      tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
	WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Dato = @CodPrestamo) AND 
	                      (tCsFirmaReporteDetalle.Grupo = 'B')
End
GO