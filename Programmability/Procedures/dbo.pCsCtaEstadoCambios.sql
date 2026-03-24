SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCtaEstadoCambios] @FecIni smalldatetime, @FecFin smalldatetime  AS

--DECLARE @FechaIni smalldatetime
--DECLARE @FechaFin smalldatetime

--SET @FechaIni = '20080801'
--SET @FechaFin = '20080831'

DECLARE @IdSession varchar(20) --Variable de session

CREATE TABLE #EstadoCambios(
                Codigo               varchar(10),
                Descripcion        varchar(200),
                Nivel                   int,
	NivelReporte	int,
                OrdenNivel         int,
                Operacion          varchar(200),
                CuentaCampo 	   varchar(200),     
                Valor               decimal(16,4),
	Oculto 		char(1),
	Grupo 		varchar(10),
	Fuente 		varchar(10)
)

exec pCsCtaCuentasBalance @FecIni,@FecFin,'06','1',@IdSession out --Llena la tabla "tCsCoPlantilla" con los datos solicitados

-- INSERTA DATOS DE LA BALANZA DEL PERIODO CORRESPONDIENTE
INSERT INTO #EstadoCambios (Codigo, Descripcion, Nivel,NivelReporte, OrdenNivel, Operacion, CuentaCampo,Valor,Oculto,Grupo,Fuente)
SELECT     Codigo, Descripcion, Nivel,NivelReporte, OrdenNivel, Operacion, CuentaCampo, valor,Oculto,Grupo,Fuente
FROM         tCsCoPlantillaProces
WHERE IdSession = @IdSession

select * from #EstadoCambios

drop table #EstadoCambios
GO