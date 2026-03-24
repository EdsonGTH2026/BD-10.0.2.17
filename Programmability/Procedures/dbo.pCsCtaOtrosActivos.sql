SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCtaOtrosActivos] @FecIni smalldatetime, @FecFin smalldatetime  AS

--DECLARE @FechaIni smalldatetime
--DECLARE @FechaFin smalldatetime

--SET @FechaIni = '20080801'
--SET @FechaFin = '20080831'

DECLARE @IdSession varchar(20) --Variable de session

CREATE TABLE #OtrosActivos(
                Codigo               varchar(10),
                Descripcion        varchar(200),
                Nivel                   int,
	NivelReporte	int,
                OrdenNivel         int,
                Operacion          varchar(200),
                CuentaCampo 	   varchar(200),     
                Valor               decimal(16,4)
)

exec pCsCtaCuentasBalance @FecIni,@FecFin,'04','1',@IdSession out --Llena la tabla "tCsCoPlantilla" con los datos solicitados

-- INSERTA DATOS DE LA BALANZA DEL PERIODO CORRESPONDIENTE
INSERT INTO #OtrosActivos (Codigo, Descripcion, Nivel, NivelReporte,OrdenNivel, Operacion, CuentaCampo,Valor)
SELECT     Codigo, Descripcion, Nivel, NivelReporte,OrdenNivel, Operacion, CuentaCampo, valor
FROM         tCsCoPlantillaProces
WHERE IdSession = @IdSession


select * from #OtrosActivos

drop table #OtrosActivos
GO