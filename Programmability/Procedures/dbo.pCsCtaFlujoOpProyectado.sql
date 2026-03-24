SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCtaFlujoOpProyectado] @FecFin smalldatetime  AS

DECLARE @FecIni smalldatetime
--DECLARE @FecFin smalldatetime

--SET @FecFin = '20121031'
--SET @FecIni = cast(year(@FecFin) as varchar(4)) + replicate('0',2-len(cast(month(@FecFin) as varchar(2)))) + cast(month(@FecFin) as varchar(2)) + '01'
SET @FecIni = '20120101'
--print @FecFin
--print @FecIni

DECLARE @IdSession varchar(20) --Variable de session

CREATE TABLE #FOP(
                Codigo               varchar(10),
                Descripcion        varchar(200),
                Nivel                   int,
	              NivelReporte	  int,
                OrdenNivel         int,
                Operacion          varchar(200),
                CuentaCampo 	   varchar(200),     
                Valor               decimal(16,4)
)

exec pCsCtaCuentasBalance @FecIni,@FecFin,'07','1',@IdSession out --Llena la tabla "tCsCoPlantilla" con los datos solicitados

-- INSERTA DATOS DE LA BALANZA DEL PERIODO CORRESPONDIENTE
INSERT INTO #FOP (Codigo, Descripcion, Nivel, NivelReporte,OrdenNivel, Operacion, CuentaCampo,Valor)
SELECT     Codigo, Descripcion, Nivel, NivelReporte, OrdenNivel, Operacion, CuentaCampo, valor
FROM         tCsCoPlantillaproces with(nolock)
WHERE IdSession = @IdSession


select * from #FOP

drop table #FOP
GO