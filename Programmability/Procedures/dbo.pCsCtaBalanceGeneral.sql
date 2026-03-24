SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCtaBalanceGeneral] @FecIni smalldatetime, @FecFin smalldatetime  AS

--DECLARE @FechaIni smalldatetime
--DECLARE @FechaFin smalldatetime

--SET @FechaIni = '20080801'
--SET @FechaFin = '20080831'

DECLARE @IdSession varchar(20) --Variable de session

CREATE TABLE #BalanceGarl(
                Codigo               varchar(10),
                Descripcion        varchar(200),
                Nivel                   int,
	   NivelReporte	  int,
                OrdenNivel         int,
                Operacion          varchar(200),
                CuentaCampo 	   varchar(200),     
                Valor               decimal(16,4)
)

exec pCsCtaCuentasBalance @FecIni,@FecFin,'03','1',@IdSession out --Llena la tabla "tCsCoPlantilla" con los datos solicitados

-- INSERTA DATOS DE LA BALANZA DEL PERIODO CORRESPONDIENTE
INSERT INTO #BalanceGarl (Codigo, Descripcion, Nivel, NivelReporte,OrdenNivel, Operacion, CuentaCampo,Valor)
SELECT     Codigo, Descripcion, Nivel, NivelReporte, OrdenNivel, Operacion, CuentaCampo, valor
FROM         tCsCoPlantillaproces
WHERE IdSession = @IdSession


select * from #BalanceGarl

drop table #BalanceGarl
GO