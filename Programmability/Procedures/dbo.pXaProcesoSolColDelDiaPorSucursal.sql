SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pXaProcesoSolColDelDiaPorSucursal]      
 (@CodOficinas AS VARCHAR(2000))      
AS       
/*    
DECLARE @CodOficinas AS VARCHAR(2000)    
SET @CodOficinas='309,308,456,467,468,469,471,473,475,477,478,479,480,481,484,485,301,344,325,501,474,493,489,130,330,26,483'    
*/ 
  
--- ELIMINA SUCURSALES QUE NO DEBEN MOSTRARSE* SOLICITADO POR MERCEDES 2025.01.23 ZCCU      
CREATE  TABLE #Oficinas(CodOficina VARCHAR(5))    
INSERT INTO #Oficinas    
SELECT Codigo from dbo.fduTablaValores(@CodOficinas)    
where Codigo not in (456,467,468,469,471,473,475,477,478,479,480,484,485,501,474,493,489,130,330,26,483)    
    
CREATE TABLE #pro (proceso VARCHAR(10), codigo VARCHAR(25), codoficina VARCHAR(5), monto MONEY)      
INSERT INTO #pro (proceso, codigo, codoficina, monto)      
EXEC [10.0.2.14].finmas.dbo.pXaProcesoSolColDelDiaPorSucursal @CodOficinas      
    
--- ELIMINA SUCURSALES QUE NO DEBEN MOSTRARSE* 2025.01.23 ZCCU     
DELETE FROM #pro where codoficina in (456,467,468,469,471,473,475,477,478,479,480,484,485,501,474,493,489,130,330,26,483)    
    
DECLARE @ca TABLE (sec INT IDENTITY(1,1), region VARCHAR(100), sucursal VARCHAR(200), sol_nro INT, sol_monto MONEY, cre_nro INT,       
       cre_monto MONEY, nro INT)      
INSERT INTO @ca (region, sucursal, sol_nro, sol_monto, cre_nro, cre_monto, nro)      
SELECT region, sucursal, SUM(ISNULL(sol_nro,0)) sol_nro, SUM(ISNULL(sol_monto,0)) sol_monto, SUM(ISNULL(cre_nro,0)) cre_nro, SUM(ISNULL(cre_monto,0)) cre_monto, SUM(ISNULL(nro,0)) nro      
FROM (      
 SELECT a.*,b.nro      
 FROM (      
  SELECT 0 i,'' region,'Total' sucursal,      
  COUNT(CASE WHEN proceso = 'solicitud' THEN codigo ELSE NULL END) sol_nro,      
  SUM(CASE WHEN proceso = 'solicitud' THEN monto ELSE 0 END) sol_monto,      
  COUNT(CASE WHEN proceso = 'credito' THEN codigo ELSE NULL END) cre_nro,      
  SUM(CASE WHEN proceso = 'credito' THEN monto ELSE 0 END) cre_monto      
  FROM #pro c WITH (NOLOCK)      
  INNER JOIN tcloficinas o WITH (NOLOCK) ON c.codoficina = o.codoficina      
  INNER JOIN tclzona z WITH (NOLOCK) ON z.zona = o.zona      
 ) a CROSS JOIN      
 (SELECT COUNT(codusuario) nro      
  FROM tcsempleados e WITH (NOLOCK)       
  INNER JOIN tcloficinas o WITH (NOLOCK) ON o.codoficina = e.codoficinanom      
  WHERE estado = 1       
  AND codpuesto = 66      
  --AND o.CodOficina IN (SELECT VALUE FROM dbo.fSplit(',', @CodOficinas)) --GDF-20211206     
  AND o.CodOficina IN (SELECT CodOficina FROM #Oficinas) --ZCCU-2025.01.23      
  AND o.Tipo NOT IN ('Cerrada') --GDF-20230324      
  ) b      
 UNION      
 SELECT a.*, ISNULL(e.nro,0) nro      
 FROM (      
  SELECT 1 i, z.nombre region, o.nomoficina sucursal,      
  COUNT(CASE WHEN proceso = 'solicitud' THEN codigo ELSE NULL END) sol_nro,      
  SUM(CASE WHEN proceso = 'solicitud' THEN monto ELSE 0 END) sol_monto,      
  COUNT(CASE WHEN proceso = 'credito' THEN codigo ELSE NULL END) cre_nro,      
  SUM(CASE WHEN proceso = 'credito' THEN monto ELSE 0 END) cre_monto      
  FROM #pro c WITH (NOLOCK)      
  INNER JOIN tcloficinas o WITH (NOLOCK) ON c.codoficina = o.codoficina      
  INNER JOIN tclzona z WITH (NOLOCK) ON z.zona = o.zona       
  GROUP BY z.nombre, o.nomoficina      
 ) a      
 LEFT OUTER JOIN (      
  SELECT o.nomoficina sucursal, COUNT(codusuario) nro      
  FROM tcsempleados e WITH (NOLOCK)       
  INNER JOIN tcloficinas o WITH (NOLOCK) ON o.codoficina = e.codoficinanom      
  WHERE estado = 1       
  AND codpuesto = 66      
  --AND o.CodOficina IN (SELECT VALUE FROM dbo.fSplit(',', @CodOficinas)) --GDF-20211206      
  AND o.CodOficina IN (SELECT CodOficina FROM #Oficinas) --ZCCU-2025.01.23      
  AND o.Tipo NOT IN ('Cerrada') --GDF-20230324      
  GROUP BY o.nomoficina      
 ) e ON e.sucursal = a.sucursal      
 UNION      
 SELECT DISTINCT 1 i, z.nombre region, o.nomoficina, 0 sol_nro, 0 sol_monto, 0 cre_nro, 0 cre_monto, 0 nro      
 FROM tcloficinas o WITH (NOLOCK)      
 INNER JOIN tclzona z WITH (NOLOCK) ON z.zona = o.zona      
 WHERE o.tipo <> 'Cerrada'      
 AND o.codoficina NOT IN(99,98,97)      
 --AND o.CodOficina IN (SELECT VALUE FROM dbo.fSplit(',', @CodOficinas)) --GDF-20211206     
 AND o.CodOficina IN (SELECT CodOficina FROM #Oficinas) --ZCCU-2025.01.23       
 AND o.Tipo NOT IN ('Cerrada') --GDF-20230324      
 UNION      
 SELECT a.*, e.nro      
 FROM (      
  SELECT 99 i, z.nombre region, 'Total' sucursal,      
  COUNT(CASE WHEN proceso = 'solicitud' THEN codigo ELSE NULL END) sol_nro,      
  SUM(CASE WHEN proceso = 'solicitud' THEN monto ELSE 0 END) sol_monto,      
  COUNT(CASE WHEN proceso = 'credito' THEN codigo ELSE NULL END) cre_nro,      
  SUM(CASE WHEN proceso = 'credito' THEN monto ELSE 0 END) cre_monto      
  FROM #pro c WITH (NOLOCK)      
  INNER JOIN tcloficinas o WITH (NOLOCK) ON c.codoficina = o.codoficina      
  INNER JOIN tclzona z WITH (NOLOCK) ON z.zona = o.zona       
  GROUP BY z.nombre) a      
 INNER JOIN (      
  SELECT z.nombre sucursal, COUNT(codusuario) nro      
  FROM tcsempleados e WITH (NOLOCK)       
  INNER JOIN tcloficinas o WITH (NOLOCK) ON o.codoficina = e.codoficinanom      
  INNER JOIN tclzona z WITH (NOLOCK) ON z.zona = o.zona       
  WHERE estado = 1       
  AND codpuesto = 66      
  --AND o.CodOficina IN (SELECT VALUE FROM dbo.fSplit(',', @CodOficinas)) --GDF-20211206      
  AND o.CodOficina IN (SELECT CodOficina FROM #Oficinas) --ZCCU-2025.01.23      
  AND o.Tipo NOT IN ('Cerrada') --GDF-20230324      
  GROUP BY z.nombre      
 ) e ON e.sucursal = a.region      
) a      
GROUP BY region, sucursal, i      
ORDER BY region, i      
      
SELECT c.sec, c.region, c.sucursal, c.sol_nro, c.sol_monto, c.cre_nro, c.cre_monto,       
 CASE WHEN c.nro = 0 THEN ISNULL(e.nro, 0) ELSE c.nro END nro,      
 CASE WHEN c.region = '' THEN 3 ELSE (CASE WHEN c.sucursal = 'Total' THEN 2 ELSE c.sec%2 END) END par       
FROM @ca c      
LEFT OUTER JOIN (      
 SELECT o.nomoficina sucursal, COUNT(codusuario) nro      
 FROM tcsempleados e WITH (NOLOCK)       
 INNER JOIN tcloficinas o WITH (NOLOCK) ON o.codoficina = e.codoficinanom      
 WHERE estado = 1       
 AND codpuesto = 66      
 --AND o.CodOficina IN (SELECT VALUE FROM dbo.fSplit(',', @CodOficinas)) --GDF-20211206     
 AND o.CodOficina IN (SELECT CodOficina FROM #Oficinas) --ZCCU-2025.01.23      
 AND o.Tipo NOT IN ('Cerrada') --GDF-20230324      
 GROUP BY o.nomoficina      
) e ON c.sucursal = e.sucursal      
ORDER BY sec      
      
DROP TABLE #pro    
DROP TABLE #Oficinas
GO