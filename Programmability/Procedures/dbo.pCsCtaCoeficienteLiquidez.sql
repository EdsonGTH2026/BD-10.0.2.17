SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCtaCoeficienteLiquidez]  @FechaIni smalldatetime, @FechaFin smalldatetime AS


--DECLARE @FechaIni smalldatetime
--DECLARE @FechaFin smalldatetime

--SET @FechaIni = '20080801'
--SET @FechaFin = '20080831'

DECLARE @IdSession varchar(20) --Variable de session
CREATE TABLE #Coeficiente (
                Codigo		 varchar(10),
                Descripcion    		 varchar(200),
                Nivel                  	 int,
		NivelReporte	int,
                OrdenNivel   		 int,
                Operacion                     varchar(200),
                CuentaCampo 		varchar(200),     
                ValorOri                         decimal(16,4),
                ValorAnt                        decimal(16,4) 
)

exec pCsCtaCuentasBalance @FechaIni,@FechaFin,'02','1',@IdSession out --Llena la tabla "tCsCoPlantilla" con los datos solicitados

-- INSERTA DATOS DE LA BALANZA DEL PERIODO CORRESPONDIENTE

INSERT INTO #Coeficiente (Codigo, Descripcion, Nivel, NivelReporte,OrdenNivel, Operacion, CuentaCampo,ValorOri,ValorAnt)
SELECT     Codigo, Descripcion, Nivel, NivelReporte,OrdenNivel, Operacion, CuentaCampo, valor,0 as ValorAnt
FROM         tCsCoPlantillaProces
WHERE IdSession = @IdSession

-- DATOS VARIABLES DE LA BALANZA DEL PERIODO ANTERIOR

DECLARE @FecAntIni smalldatetime

DECLARE @FecAntFin smalldatetime

 

SELECT   @FecAntFin = DATEADD([day], - 1, PrimerDia) --20080731

FROM         tClPeriodo

WHERE     (Periodo = dbo.fduFechaATexto(@FechaIni,'aaaaMM'))

 

SELECT   @FecAntIni = PrimerDia --20080701

FROM         tClPeriodo

WHERE     (Periodo = dbo.fduFechaATexto(@FecAntFin,'aaaaMM'))

--PRINT @FecAntFin

--PRINT @FecAntIni

exec pCsCtaCuentasBalance @FecAntIni,@FecAntFin,'02','1',@IdSession out

 

-- INSERTA DATOS DE LA BALANZA DEL PERIODO ANTERIOR

INSERT INTO #Coeficiente (Codigo, Descripcion, Nivel, NivelReporte,OrdenNivel, Operacion, CuentaCampo,ValorOri,ValorAnt)

SELECT     Codigo, Descripcion, Nivel, NivelReporte,OrdenNivel, Operacion, CuentaCampo, 0 AS ValorOri,valor as ValorAnt

FROM         tCsCoPlantillaProces

WHERE IdSession = @IdSession

 

 

select codigo,Descripcion, Nivel, OrdenNivel, sum(ValorOri) ValorOri, sum(ValorAnt) ValorAnt, (sum(ValorOri)+ sum(ValorAnt))/2 ValorMedio FROM #Coeficiente

group by codigo,Descripcion, Nivel, OrdenNivel

 

drop table #Coeficiente
GO