SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCtaEstadoVariaciones] @FecIni smalldatetime, @FecFin smalldatetime  AS

--DECLARE @FechaIni smalldatetime
--DECLARE @FechaFin smalldatetime

--SET @FechaIni = '20080801'
--SET @FechaFin = '20080831'

DECLARE @IdSession varchar(20) --Variable de session

CREATE TABLE #EstadoVariaciones(
                Codigo               varchar(10),
                Descripcion        varchar(200),
                Nivel                   int,
	NivelReporte	int,
                OrdenNivel         int,
                Operacion          varchar(200),
                CuentaCampo 	   varchar(200),     
                Valor               decimal(16,4)
)

exec pCsCtaCuentasBalance @FecIni,@FecFin,'05','1',@IdSession out --Llena la tabla "tCsCoPlantilla" con los datos solicitados

-- INSERTA DATOS DE LA BALANZA DEL PERIODO CORRESPONDIENTE
INSERT INTO #EstadoVariaciones (Codigo, Descripcion, Nivel,NivelReporte, OrdenNivel, Operacion, CuentaCampo,Valor)
SELECT     Codigo, Descripcion, Nivel, NivelReporte,OrdenNivel, Operacion, CuentaCampo, valor
FROM         tCsCoPlantillaProces
WHERE IdSession = @IdSession

SELECT A.Codigo, A.Descripcion, A.Nivel, A.OrdenNivel, A.Operacion, A.CuentaCampo, A.valor, tCsCoA.NomPadreA, tCsCoB.NomPadreB
FROM (
	SELECT Codigo, Descripcion, Nivel, OrdenNivel, Operacion, CuentaCampo, valor, SUBSTRING(Codigo, 1, 2) + REPLICATE('0', 8) AS PadreA, 
    SUBSTRING(Codigo, 1, 1) + REPLICATE('0', 9) AS PadreB FROM #EstadoVariaciones) A LEFT OUTER JOIN 
			(SELECT codigo, case substring(codigo,2,1) when '3' then '' else descripcion end NomPadreA FROM #EstadoVariaciones) tCsCoA ON A.PadreA = tCsCoA.codigo LEFT OUTER JOIN
            (SELECT codigo, descripcion NomPadreB FROM #EstadoVariaciones) tCsCoB ON A.PadreB = tCsCoB.codigo
WHERE     (A.Nivel = 2)

drop table #EstadoVariaciones
GO