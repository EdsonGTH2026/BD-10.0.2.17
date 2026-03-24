SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsEnviosDelgadoCargaArchivo] AS

SET NOCOUNT ON

DECLARE @Ubicacion varchar(200)

SET @Ubicacion = '\\curbizagastegui\FinMas\924000S45591.TXT'

DECLARE @csql varchar(1000)

SET @csql = 'BULK INSERT FinAmigoConsolidado.dbo.tCsEnviosDelgado '
SET @csql = @csql + 'FROM ''' + @Ubicacion + ''' '
SET @csql = @csql + 'WITH (DATAFILETYPE = ''char'') '

--PRINT @csql

EXEC (@csql)

SET NOCOUNT OFF
GO