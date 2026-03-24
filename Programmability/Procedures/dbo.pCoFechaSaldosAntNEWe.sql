SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
--------------------------------------------------------------------------
--	Sistema de Contabilidad 15/05/2006									--
--																		--
--	Nombre Archivo : pCoFechaSaldosAntNEW									--
--	Descripción : Calculo de fecha Para saldos Anteriores				--
--		      															--		
--	Fecha (creación) : 													--
--	Autor : Vhludeno													--
--	Revisado por:	 													--
--------------------------------------------------------------------------
-- exec pCoFechaSaldosAntNEW '01/02/2006','02/28/2006','','','',0,0

CREATE PROCEDURE [dbo].[pCoFechaSaldosAntNEWe] (
		@FechaIni		varchar(12),		--Fecha Inicio 	del Reporte
		@FechaFin		varchar(12),		--Fecha Fin 	del Reporte
		@FechaIniMesAnterior 	varchar(12) out ,	--Fecha Mes Anterior   
		@FechaIniPrimerDiaMes	varchar(12) out ,	--Fecha Primer dia del Mes de Fecha de Inicio
		@FechaIniMenosUnDia 	varchar(12) out ,	-- Fecha de Inico Menos  un Dia
		@FechaCierreMasUnDia 	varchar(12) out	,	--Fecha de Cierre mas un Dia 
		@TipoDeCaso		smallint out,		--Tipo de Caso
		@FechaUltCierre 	varchar(12) out,	--Fecha de Ultimo cierre
		@FechaFinMenosUnDia	varchar(12) out,	
		@PrimerDiaMes		varchar(1)  out		-- 0: se suma Ant y Mes de tCoMayores, 1: se suma Ant 



)	

with encryption  AS
set nocount on 
----------------------------------------------------------------
--	V A R I A  B L E S 
----------------------------------------------------------------
--DECLARE @FechaUltCierre 	varchar(10)	
----------------------------------------------------------------
--	1.1  CALCULO DE FECHA GLOBALES  
----------------------------------------------------------------
--Fecha Ultimo Cierre		
SELECT  @FechaUltCierre=convert(varchar(10),FechaUltCierre,101)  from tCoGrParam
--   ****   VARIABLES DE SALIDA  *****
--Fecha Mes Anterior   
SET @FechaIniMesAnterior =right('00'+convert(varchar(10),Month(DATEADD(mm, -1, @FechaIni)),101),2)+'/01/'+Cast(Year(@FechaIni) as varchar(4)) 
--Fecha Primer dia del Mes de Fecha de Inicio
SET @FechaIniPrimerDiaMes =right('00'+Cast(Month(@FechaIni) as varchar(2)),2)+'/01/'+Cast(Year(@FechaIni) as varchar(4))  
-- Fecha de Inico Menos  un Dia
SET @FechaIniMenosUnDia=convert(varchar(10), DATEADD(dd, -1, @FechaIni),101) 
--Fecha de Cierre mas un Dia 
SET @FechaCierreMasUnDia=convert(varchar(10), DATEADD(dd, +1, @FechaUltCierre),101) 
--Fecha  final  menos  un dia
set @FechaFinMenosUnDia= convert(varchar(10), DATEADD(dd, -1, @FechaFin),101) 
--
----------------------------------------------------------------
--	1.1 * * * * * * F I N  * * * * * *  * * *    
----------------------------------------------------------------

----------------------------------------------------------------
--  ************************************************************
--	CALCULO SEGUN FECHA DE CIERRE  
--  ************************************************************
----------------------------------------------------------------

----------------------------------------------------------------
--	CASO 1 FECHA INICIO > FECHA CIERRE
-- SELECT  convert(varchar(10),FechaUltCierre,101)  from tCoGrParam
----------------------------------------------------------------
IF CONVERT( datetime ,@FechaIni)>CONVERT( datetime ,@FechaUltCierre )
  Begin	
	--para ver se sacamos de ant o (ant y mes) de tcomayores
	IF Month( @FechaUltCierre) + 1 =  Month(@FechaIni)
	BEGIN
		--procesamos el ant,mes de tcomayores de el ultimo cierre
		SET @PrimerDiaMes = 0
		SET @FechaIniMesAnterior = @FechaUltCierre
		SET @TipoDeCaso=2
	END
	ELSE
	BEGIN
		SET @PrimerDiaMes = 1
		SET @TipoDeCaso=1
	END
		
  End	
----------------------------------------------------------------
--	CASO 2 LA  FECHA  INICIO MENOR  A CIERRE
----------------------------------------------------------------
IF CONVERT( datetime ,@FechaIni)<CONVERT( datetime ,@FechaUltCierre)
BEGIN

	SET @PrimerDiaMes = 0
	SET @TipoDeCaso=2
	
END
----------------------------------------------------------------
--	CASO 3 FECHA DE INICIO IGUAL  AL  CIERRE
----------------------------------------------------------------
IF CONVERT( datetime ,@FechaIni)=CONVERT( datetime ,@FechaUltCierre)
BEGIN	
	SET @PrimerDiaMes = 0
	SET @TipoDeCaso = 3
END
----------------------------------------------------------------
--	CASO 4 solo para gestiones pasadas..
----------------------------------------------------------------
IF YEAR(CONVERT( datetime ,@FechaFin)) > YEAR (CONVERT( datetime ,@FechaUltCierre))
BEGIN	
	SET @PrimerDiaMes = 0
	SET @TipoDeCaso = 4
END

GO