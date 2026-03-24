SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCboTablaValoresCadena] @Tabla varchar(100),@Campo varchar(100),@Where varchar(100), @cad varchar(800) output AS

SET NOCOUNT ON

--DECLARE @cad varchar(1000)

DECLARE @ctext varchar(8000)
--DECLARE @Tabla varchar(100)
--DECLARE @Campo varchar(100)
--DECLARE @Where varchar(100)

--SET @Tabla = 'tclFondos'	-- tclFondos
--SET @Campo = 'codfondo'	-- codfondo <> 00
--SET @Where = 'codfondo <> ''00'' '

CREATE TABLE #tmpValores (valor varchar(800))

SET @ctext = 'DECLARE @csql as varchar(800) '
SET @ctext = @ctext + ' SET @csql = '''' '
SET @ctext = @ctext + 'DECLARE @codigo varchar(100) '
SET @ctext = @ctext + 'DECLARE campos CURSOR FOR '
SET @ctext = @ctext + '	SELECT '+@Campo+' FROM '+@Tabla+' '
IF(@Where<>'') SET @ctext = @ctext + ' WHERE ' + @Where
SET @ctext = @ctext + 'OPEN campos '
SET @ctext = @ctext + 'FETCH NEXT FROM campos '
SET @ctext = @ctext + 'INTO @codigo '
SET @ctext = @ctext + 'WHILE @@FETCH_STATUS = 0 '
SET @ctext = @ctext + 'BEGIN '
SET @ctext = @ctext + '	SET @csql = @csql + @codigo + '','' '
SET @ctext = @ctext + '   FETCH NEXT FROM campos '
SET @ctext = @ctext + '   INTO @codigo '
SET @ctext = @ctext + 'END '
SET @ctext = @ctext + 'CLOSE campos '
SET @ctext = @ctext + 'DEALLOCATE campos '
SET @ctext = @ctext + 'SET @csql = substring(@csql,0,len(@csql)) '
SET @ctext = @ctext + '  INSERT INTO #tmpValores SELECT @csql '

--PRINT @ctext
EXEC (@ctext)

SELECT @cad = valor FROM #tmpValores

DROP TABLE #tmpValores

SET NOCOUNT OFF
GO