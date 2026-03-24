SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsSgUtilCrosstab]
 @TABLA varchar(255),
 @PIVOT VARCHAR(255),
 @AGRUPACION varchar(255),
 @CAMPO varchar(255),
 @CALCULO varchar(20)
AS

SET NOCOUNT ON

/*
DECLARE @TABLA varchar(255)--,
DECLARE @PIVOT VARCHAR(255)--,
DECLARE @AGRUPACION varchar(255)--,
DECLARE @CAMPO varchar(255)--,
DECLARE @CALCULO varchar(20)

SET @TABLA = '_AAA'
SET @PIVOT = 'fecha'
SET @AGRUPACION = 'oficina, asesor'
SET @CAMPO = 'capital'
SET @CALCULO = 'sum'
*/

--Declaramos las variables que nos permitirán crear el sql con los "CASES"
DECLARE @STRG AS VARCHAR(8000)
DECLARE @SQL AS VARCHAR(8000)
CREATE TABLE #PIVOT ( PIVOT VARCHAR (8000) )
-- limpiamos las variables por si a caso

SET @STRG='' SET @SQL=''

/* En el siguiente código realizamos un "select distinct" del campo que usaremos como pivote, 
a cada registro le concatenamos su correspondiente "CASE" y lo almacenamos en una tabla temporal llamada #PIVOT
*/

SET @STRG=@STRG + 'INSERT INTO #PIVOT SELECT DISTINCT ''' + @CALCULO + '(CASE WHEN ' + @PIVOT + '=''''''+ RTRIM(CAST(' + @PIVOT + ' AS VARCHAR(500))) + '''''' THEN ' + @CAMPO 
+ ' ELSE NULL END) AS '''''' + RTRIM(CAST(' + @PIVOT + ' AS VARCHAR(500))) + '''''', '' AS PIVOT
FROM ' + @TABLA + ' WHERE ' + @PIVOT + ' IS NOT NULL' EXECUTE (@STRG)

print @STRG

/*
--el sql dinámico de más arriba genera un script similar a éste,
-- (cambia según los parámetros que se ingresen) 
--generamos la consulta final, donde seleccionamos las columnas según la tabla #PIVOT y realizamos la agrupación correspondiente. 
*/ 

SET @SQL ='SELECT ' + @AGRUPACION + ', '
SELECT @SQL= @SQL + RTRIM(convert(varchar(500), pivot))
FROM #PIVOT ORDER BY PIVOT

SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
--PRINT @SQL
IF @AGRUPACION<>'*'
BEGIN
SET @SQL=@SQL + ' FROM ' + @TABLA + ' GROUP BY ' + @AGRUPACION
END
ELSE
BEGIN
SET @SQL=@SQL + '''TODOS'' AS T FROM ' + @TABLA
END   

/* Ejecutamos la consulta, si quieres ver como queda, cambia el: EXECUTE(@SQL) por PRINT(@SQL) */ 
print @SQL
EXECUTE (@SQL) 

drop table #PIVOT

SET NOCOUNT OFF
GO