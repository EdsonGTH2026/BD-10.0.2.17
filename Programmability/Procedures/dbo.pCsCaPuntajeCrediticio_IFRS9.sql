SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*---- FUNCION PARA EL CALCULO DEL PUNTAJE CREDITICIO: Nuevo calculo de reservas IFRS9
---- ZCCU  2025.10.08
---- VERSION A PRODUCTIVO 2025.11.10
---- 
*/
CREATE PROCEDURE [dbo].[pCsCaPuntajeCrediticio_IFRS9] (@FechaFin SMALLDATETIME)     
AS

BEGIN



--DECLARAR VARIABLES
DECLARE @Fecha SMALLDATETIME  -----FECHA DE CORTE
DECLARE @Nota TABLE (CodUsuario VARCHAR(30),NOTA VARCHAR(8000))
DECLARE @PuntajeMaxATR INT
DECLARE @PuntajePromAtrasos INT
DECLARE @PuntajeTotal INT
DECLARE @FechaIni SMALLDATETIME  
SET @Fecha =@FechaFin--- '20250831'-- '20250820'-----FECHA DE CORTE
SET @FechaIni= (dbo.fdufechaaperiodo(dateadd(month,-3,@fecha)))+'01' 
------------------------------------

DECLARE  @Periodos TABLE (Row INT IDENTITY (1,1) ,Fecha SMALLDATETIME)
INSERT INTO @Periodos VALUES(@Fecha)
INSERT INTO @Periodos
SELECT UltimoDia from tclperiodo with(nolock)
WHERE UltimoDia  >=  @FechaIni and UltimoDia < @Fecha
ORDER BY UltimoDia DESC


DECLARE  @UsuariosCA TABLE (CodUsuario VARCHAR(30))
INSERT INTO @UsuariosCA
SELECT  C.CodUsuario
FROM tCsCartera C WITH(NOLOCK)
WHERE 1=1
AND C.Fecha = @Fecha
AND C.codprestamo not in (SELECT codprestamo FROM tCsCarteraAlta WITH(NOLOCK))
AND C.CodPrestamo NOT IN (SELECT CUENTA FROM tCreditosExcluidos WITH(NOLOCK))
AND SUBSTRING (C.CodPrestamo,5,1) NOT IN ('3')
AND C.codoficina not in('97','230','231','999')
AND cartera='ACTIVA' 
AND C.CodProducto NOT IN ('168','123','169')
--and c.CodUsuario in (
--'ACL700527FND01 ',
--'VGJ720729M0899 ',
--'BAE900310M0247 ',
--'SHM940809F3243 ',
--'VGJ040524F4QQ8 ',
--'NGA741230F2422 ',
--'GMA810828M4928 ',
--'GHA920120F0049 ',
--'HAD860711F7730 ',
--'JFM921010M0QL7 ',
--'LMA751209F0712 '
--)


DECLARE  @ptms TABLE (CodUsuario VARCHAR(30),CodPrestamo VARCHAR(30))
INSERT INTO @ptms
select Codusuario,CodPrestamo from tCsPadronCarteraDet  WITH(NOLOCK) 
--WHERE CODUSUARIO IN ('RHG731207F0361','RJN740921F9434')
WHERE CODUSUARIO IN (SELECT CodUsuario FROM @UsuariosCA )

--/*ATR - ATRASO DE LA CARTERA  */

DECLARE  @CA TABLE (Row INT ,Fecha SMALLDATETIME,CodUsuario VARCHAR(30),CodPrestamo VARCHAR(30),NroDiasAtraso INT,ATR INT,CADENA VARCHAR(8000))
INSERT INTO @CA

SELECT P.Row ,C.Fecha,CodUsuario,CodPrestamo,NroDiasAtraso,[DBO].[fduCalculaATR_IFRS9] (NroDiasAtraso)'ATR',''
FROM tCsCartera C WITH(NOLOCK)
INNER JOIN @Periodos P ON P.Fecha=C.Fecha 
WHERE 
C.Fecha IN (SELECT Fecha from @Periodos )
--and CodUsuario = @CodUsuario
and CodPrestamo in (select CodPrestamo from @ptms)
AND C.codprestamo not in (SELECT codprestamo FROM tCsCarteraAlta WITH(NOLOCK))
AND SUBSTRING (C.CodPrestamo,5,1) NOT IN ('3')
AND C.codoficina not in('97','230','231','999')
AND cartera='ACTIVA' 
AND C.CodProducto NOT IN ('168','123','169')
ORDER BY Codusuario,C.Fecha DESC

 
DECLARE  @Max_ATR TABLE (Row INT IDENTITY(1,1),CodUsuario VARCHAR(30),Max_ATR INT)
INSERT INTO @Max_ATR 
 
SELECT Codusuario,MAX(ISNULL(ATR,0)) FROM @CA GROUP BY Codusuario


DECLARE  @PROM_DIAS_ATRASO TABLE (Row INT IDENTITY(1,1),CodUsuario VARCHAR(30),PROM_DIAS_ATRASO INT)
INSERT INTO @PROM_DIAS_ATRASO 

SELECT Codusuario, ISNULL(NroDiasAtraso,0) FROM @CA WHERE Fecha = @Fecha --GROUP BY Codusuario

/*SECTOR ECONOMICO*/
DECLARE  @Sector TABLE (Row INT IDENTITY(1,1),CodUsuario VARCHAR(30),Sector  INT)
INSERT INTO @Sector 
SELECT CA.CodUsuario,ISNULL([DBO].[fduCASectorEconomicoCli_IFRS9] (CA.CodUsuario),2) --'SECTOR'    
FROM @CA CA GROUP BY Codusuario


--/*ASIGNA VALOR AL PUNTAJE DE MAXIMO ATRASOS */
DECLARE  @PuntajeMaximoAtrasos TABLE (Row INT IDENTITY(1,1),CodUsuario VARCHAR(30),Max_ATR  INT,sector int,valor int)
INSERT INTO @PuntajeMaximoAtrasos 
select s.CodUsuario,m.Max_ATR,s.sector,isnull(puntaje.Valor,0)
from @Sector S 
INNER JOIN @Max_ATR M on s.CodUsuario= M.CodUsuario
INNER JOIN  tcIFRS9PuntajeCreditoPI puntaje  WITH(NOLOCK) on puntaje.CodSectorEconomico=s.Sector AND Tipo = 1 AND  Max_ATR <= RangoMaximo AND  Max_ATR >= RangoMinimo


--/*ASIGNA VALOR AL PUNTAJE DE PROMEDIO DE ATRASOS */
DECLARE  @PuntajePromedioAtrasos TABLE (Row INT IDENTITY(1,1),CodUsuario VARCHAR(30),PROM_DIAS_ATRASO  INT,valor int)
INSERT INTO @PuntajePromedioAtrasos 
select s.CodUsuario,m.PROM_DIAS_ATRASO,isnull(puntaje.Valor,0)
from @Sector S 
INNER JOIN @PROM_DIAS_ATRASO M on s.CodUsuario= M.CodUsuario
INNER JOIN  tcIFRS9PuntajeCreditoPI puntaje  WITH(NOLOCK) on puntaje.CodSectorEconomico=s.Sector AND Tipo = 2 AND  PROM_DIAS_ATRASO <= RangoMaximo AND  PROM_DIAS_ATRASO >= RangoMinimo


--------------------------------------------------------------- 



SELECT CodUsuario AS 'CodUsuario'
,MAX(sector) Sector ,MAX(Max_ATR) Max_ATR  ,MAX(Puntaje_Max_ATR) Puntaje_Max_ATR
,MAX(Prom_Dias_Atraso) Prom_Dias_Atraso,MAX(Puntaje_Prom_Dias_Atra) Puntaje_Prom_Dias_Atra
,MAX(Puntaje_Prom_Dias_Atra)+ MAX(Puntaje_Max_ATR)  PuntajeTotal 
, LTRIM(STR( dbo.fdufechaatexto(MAX(PERIODO_1),'AAAAMMDD'))) PERIODO_1,MAX(DIAS_ATRASO_1)DIAS_ATRASO_1,MAX(ATR_1)ATR_1
, LTRIM(STR( dbo.fdufechaatexto(MAX(PERIODO_2),'AAAAMMDD'))) PERIODO_2,MAX(DIAS_ATRASO_2)DIAS_ATRASO_2,MAX(ATR_2)ATR_2
, LTRIM(STR( dbo.fdufechaatexto(MAX(PERIODO_3),'AAAAMMDD'))) PERIODO_3,MAX(DIAS_ATRASO_3)DIAS_ATRASO_3,MAX(ATR_2)ATR_3
, LTRIM(STR( dbo.fdufechaatexto(MAX(PERIODO_4),'AAAAMMDD'))) PERIODO_4,MAX(DIAS_ATRASO_4)DIAS_ATRASO_4,MAX(ATR_2)ATR_4
FROM ( SELECT CodUsuario,Fecha PERIODO_1 ,NroDiasAtraso DIAS_ATRASO_1,ATR ATR_1
		,0 PERIODO_2,0 DIAS_ATRASO_2,0 ATR_2
		,0 PERIODO_3,0 DIAS_ATRASO_3,0 ATR_3
		,0 PERIODO_4,0 DIAS_ATRASO_4,0 ATR_4
		,0 Max_ATR  ,0 Puntaje_Max_ATR,0 Sector 
		,0 Prom_Dias_Atraso, 0 Puntaje_Prom_Dias_Atra
		from @CA
		WHERE ROW = 1
		UNION 
		SELECT CodUsuario
		,0 PERIODO_1,0 DIAS_ATRASO_1,0 ATR_1
		,Fecha PERIODO_2,NroDiasAtraso DIAS_ATRASO_2,ATR  ATR_2
		,0 PERIODO_3,0 DIAS_ATRASO_3,0 ATR_3
		,0 PERIODO_4,0 DIAS_ATRASO_4,0 ATR_4
		,0 Max_ATR  ,0 Puntaje_Max_ATR,0 Sector 
		,0 Prom_Dias_Atraso, 0 Puntaje_Prom_Dias_Atra
		from @CA
		WHERE ROW = 2
		UNION
		SELECT CodUsuario
		,0 PERIODO_1,0 DIAS_ATRASO_1,0 ATR_1
		,0 PERIODO_2,0 DIAS_ATRASO_2,0 ATR_2
		,Fecha PERIODO_3,NroDiasAtraso DIAS_ATRASO_3,ATR ATR_3
		,0 PERIODO_4,0 DIAS_ATRASO_4,0 ATR_4
		,0 Max_ATR  ,0 Puntaje_Max_ATR,0 Sector 
		,0 Prom_Dias_Atraso, 0 Puntaje_Prom_Dias_Atra
		from @CA
		WHERE ROW = 3
		UNION
		SELECT CodUsuario
		,0 PERIODO_1,0 DIAS_ATRASO_1,0 ATR_1
		,0 PERIODO_2,0 DIAS_ATRASO_2,0 ATR_2
		,0 PERIODO_3,0 DIAS_ATRASO_3,0 ATR_3
		,Fecha PERIODO_4,NroDiasAtraso DIAS_ATRASO_4,ATR  ATR_4
		,0 Max_ATR  ,0 Puntaje_Max_ATR,0 Sector 
		,0 Prom_Dias_Atraso, 0 Puntaje_Prom_Dias_Atra

		from @CA
		WHERE ROW = 4
		UNION
		SELECT CodUsuario
		,0 PERIODO_1,0 DIAS_ATRASO_1,0 ATR_1
		,0 PERIODO_2,0 DIAS_ATRASO_2,0 ATR_2
		,0 PERIODO_3,0 DIAS_ATRASO_3,0 ATR_3
		,0 PERIODO_4,0 DIAS_ATRASO_4,0 ATR_4
		,Max_ATR Max_ATR  ,valor Puntaje_Max_ATR,sector Sector 
		,0 Prom_Dias_Atraso, 0 Puntaje_Prom_Dias_Atra
		from @PuntajeMaximoAtrasos
		UNION
		SELECT CodUsuario
		,0 PERIODO_1,0 DIAS_ATRASO_1,0 ATR_1
		,0 PERIODO_2,0 DIAS_ATRASO_2,0 ATR_2
		,0 PERIODO_3,0 DIAS_ATRASO_3,0 ATR_3
		,0 PERIODO_4,0 DIAS_ATRASO_4,0 ATR_4
		,0 Max_ATR  ,0 Puntaje_Max_ATR,0 Sector 
		,Prom_Dias_Atraso Prom_Dias_Atraso, valor Puntaje_Prom_Dias_Atra
		from @PuntajePromedioAtrasos
	)a
GROUP BY CodUsuario


END;
GO