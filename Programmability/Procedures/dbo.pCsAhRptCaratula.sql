SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--EXEC pCsAhRptCaratula 'mmata','AH','098-203-06-2-8-00752','V01MMARSEDTA083611233212AH00752018'
--DROP PROC pCsAhRptCaratula
CREATE PROCEDURE [dbo].[pCsAhRptCaratula]
               ( @Usuario VARCHAR(50)  ,  
                 @Sistema CHAR(2)      ,  
                 @Dato    VARCHAR(100) ,  
                 @Firma   VARCHAR(100) )
AS
/*
Declare @Usuario Varchar(50) ,
        @Sistema CHAR(2)     ,  
        @Dato    VARCHAR(100),  
        @Firma   VARCHAR(100)
    Set @Usuario = 'mmata'   
    Set @Sistema = 'AH'        
    Set @Dato    = '098-203-06-2-4-00885-0-0' 
    Set @Firma   = 'V01MMANRAEDG521412112247CA88500001'   
--*/
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
FROM  tcsFirmaElectronica INNER JOIN
	  tcsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma INNER JOIN
	  tcsFirmaReporteDetalle ON tCsFirmaReporte.Firma = tCsFirmaReporteDetalle.Firma INNER JOIN
		  (SELECT     Firma, SUM(Saldo1) AS Total, MAX(Fecha1) AS FechaVencimiento
			FROM          tCsFirmaReporteDetalle AS tCsFirmaReporteDetalle_1
			WHERE      (Grupo = 'H')
			GROUP BY Firma) AS Total ON tCsFirmaElectronica.Firma = Total.Firma INNER JOIN
	  tAhProductos tAhProductos ON tCsFirmaReporte.Dato4 = tAhProductos.idProducto INNER JOIN
	  tCsUDIS ON tCsFirmaReporte.Fecha1 - 1 = tCsUDIS.Fecha LEFT OUTER JOIN
		  (SELECT     Firma, Fila, Clausula, Tipo, Orden, Titulo, Texto
			FROM          [10.0.1.17].FinamigoConsolidado.dbo.tCsFirmaReporteClausula AS tCsFirmaReporteClausula_2
			WHERE      (Tipo = 'Pagare') AND (Fila = 1)) AS Pagare ON tCsFirmaElectronica.Firma = Pagare.Firma LEFT OUTER JOIN
		  (SELECT     Firma, Fila, Clausula, Tipo, Orden, Titulo, Texto
			FROM          [10.0.1.17].FinamigoConsolidado.dbo.tCsFirmaReporteClausula AS tCsFirmaReporteClausula_1
			WHERE      (Tipo = 'Declaracion') AND (Fila = 1)) AS tCsFirmaReporteClausula ON tCsFirmaElectronica.Firma = tCsFirmaReporteClausula.Firma LEFT OUTER JOIN
	  tCaClModalidadPlazo ON tCsFirmaReporte.Dato1 = tCaClModalidadPlazo.ModalidadPlazo
WHERE (tCsFirmaElectronica.Activo = 1) 
  AND (tCsFirmaReporteDetalle.Grupo IN ('A', 'C', 'E')) 
  AND (tCsFirmaElectronica.Usuario = @Usuario)
  AND (tCsFirmaElectronica.Firma   = @Firma)  
  AND (Sistema = @Sistema) 
  --AND (Dato    = @Dato)
--SELECT * FROM tCsFirmaElectronica WHERE Firma = 'V01MMARSEDTA083611233212AH00752018'
GO