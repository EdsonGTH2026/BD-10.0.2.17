SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCtaBalanzaComparativa] (@PeriodoIni smalldatetime, @PeriodoFin smalldatetime) AS
SET NOCOUNT ON
--DECLARE @PeriodoIni smalldatetime, @PeriodoFin smalldatetime

--SET @PeriodoIni = '20081231'
--SET @PeriodofIN = '20090131'

DECLARE @AgOficina 			char(1)--Bit
DECLARE @FechaIni 			varchar(12)
DECLARE @FechaFin 			varchar(12)
DECLARE @Sesion 			varchar(12)
DECLARE @CodOficina 			varchar(800) 
DECLARE @CodFondo 			varchar(800) 
DECLARE @pNiveles 			varchar(50) 
DECLARE @Ctas  			varchar(1)  
DECLARE @PrimerDiaMes  		varchar(1)  
DECLARE @AgFondo 			char(1)--Bit
DECLARE @PvIntMayor  		varchar(1)
DECLARE @pOtraExp 			varchar(1)
DECLARE @VerOfiFdo			char(1)--bit
DECLARE @pCtasCuadreOfFdo		char(1)--bit
DECLARE @CtasCuadreIntEmp		char(1)--bit
DECLARE @pCodMonedaExp  		varchar(4)--int
DECLARE @EliValCero 			varchar(1)

SET @Sesion			= 'S070625-7954'
--SET @FechaIni   	= '20081201'
--SET @FechaFin  	= '20081231'

SET @FechaIni   	= SUBSTRING(dbo.fduFechaAAAAMMDD(@PeriodoIni),1,6) + '01'
SET @FechaFin  		= dbo.fduFechaAAAAMMDD(@PeriodoIni)

PRINT @FechaIni
PRINT @FechaFin

SET @AgOficina = 0

--SET @CodOficina	='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,98,99,70,71'
EXEC pCsCboTablaValoresCadena 'tClOficinas','CodOficina','', @CodOficina out
print @CodOficina
--SET @CodFondo		='01,02,03,05,06,07,08,09,10,11,12,13'
EXEC pCsCboTablaValoresCadena 'tClFondos','CodFondo',' codFondo<>''00'' ', @CodFondo out
print @CodFondo

SET @pNiveles		 	= '1 2 3 4 5 6 7 8'
SET @PrimerDiaMes 	 	= '0'		
SET @AgFondo			= '0'
SET @PvIntMayor 		= '1'
SET @pOtraExp   		= '1'
SET @VerOfiFdo		= '0'		-- Vista por  Oficina  Fondo 
SET @pCtasCuadreOfFdo	= '0'	-- Para excluir las cuentas de cuadre de Oficinas y fondos 
SET @CtasCuadreIntEmp	= '0'	-- Inter Empresa
SET @pCodMonedaExp  	= '1'	
SET @EliValCero 		= '0'	
SET @Ctas 				= '1'	-- '2' : solo cuentas de resultados, 1 todos  	


DECLARE @Servidor	varchar(50)
DECLARE @BaseDatos	varchar(50)
DECLARE @csql 		varchar(8000)

SELECT @BaseDatos=NombreBD, @Servidor=NombreIP FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = cast(year(@PeriodoIni) as varchar(4)))

--Tabla temporal contable contiene los datos de la balanza
--DECLARE @tbAux table (
CREATE table #tbAux (
	Sesion			varchar(25),
	CodCta			varchar(25),
	CodOficina		varchar(5),
	CodFondo		varchar(5),
	DescCta			varchar(100),
	AnteDebe		decimal(16,4),
	AntHaber		decimal(16,4),
	MovDebe			decimal(16,4),
	MovHaber		decimal(16,4),
	SalAntTotal		decimal(16,4),
	SalFinDebe		decimal(16,4),
	SalFinHaber		decimal(16,4),
	SubMovDebe		decimal(16,4),
	SubMovHaber		decimal(16,4),
	SubSalFinDebe	decimal(16,4),
	SubSalFinHaber	decimal(16,4)
)
--Primer periodo
--DELETE FROM FINMAS_CONTA2008.dbo.tCsCoAux
SET @csql = 'DELETE FROM ['+ @Servidor +'].' + @BaseDatos+'.dbo.tCsCoAux '
print @csql
EXEC (@csql)

SET @csql = 'insert ['+@Servidor+'].' + @BaseDatos+'.dbo.tCsCoAux '
SET @csql = @csql + ' exec ['+ @Servidor +'].' + @BaseDatos+'.dbo.pCoRptBalCompNew '''+@FechaIni+''', '''+@FechaFin+''', '
SET @csql = @csql + ' '''+@Sesion+''', '''+@CodOficina+''','''+ @CodFondo+''', '''+@pNiveles+''', '+@Ctas+', '+@PrimerDiaMes+', '
SET @csql = @csql + ' '+@AgOficina+', '+@AgFondo+', '+@PvIntMayor+', '+@pOtraExp+', '+@VerOfiFdo+', '
SET @csql = @csql + ' '+@pCtasCuadreOfFdo+', '+@CtasCuadreIntEmp+', '+@pCodMonedaExp+', '+@EliValCero+' '
print @csql
EXEC (@csql)

--INSERT #tbAux SELECT * FROM FINMAS_CONTA2008.dbo.tCsCoAux
SET @csql = 'INSERT #tbAux SELECT * FROM ['+@Servidor+'].'+@BaseDatos+'.dbo.tCsCoAux '
print @csql
EXEC (@csql)

--Segundo periodo
SET @Sesion	= 'S070625-7953'
--SET @FechaIni   = '20081101'
--SET @FechaFin  = '20081130'

SET @FechaIni   		= SUBSTRING(dbo.fduFechaAAAAMMDD(@PeriodoFin),1,6) + '01'
SET @FechaFin  		= dbo.fduFechaAAAAMMDD(@PeriodoFin)

PRINT @FechaIni
PRINT @FechaFin

SELECT @BaseDatos=NombreBD, @Servidor=NombreIP FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = cast(year(@PeriodoFin) as varchar(4)))

SET @csql = 'DELETE FROM ['+ @Servidor+'].'+ @BaseDatos+'.dbo.tCsCoAux '
print @csql
EXEC (@csql)

SET @csql = 'insert ['+ @Servidor+'].'+@BaseDatos+'.dbo.tCsCoAux '
SET @csql = @csql + ' exec ['+ @Servidor+'].'+@BaseDatos+'.dbo.pCoRptBalCompNew '''+@FechaIni+''', '''+@FechaFin+''', '
SET @csql = @csql + ' '''+@Sesion+''', '''+@CodOficina+''','''+ @CodFondo+''', '''+@pNiveles+''', '+@Ctas+', '+@PrimerDiaMes+', '
SET @csql = @csql + ' '+@AgOficina+', '+@AgFondo+', '+@PvIntMayor+', '+@pOtraExp+', '+@VerOfiFdo+', '
SET @csql = @csql + ' '+@pCtasCuadreOfFdo+', '+@CtasCuadreIntEmp+', '+@pCodMonedaExp+', '+@EliValCero+' '
print @csql
EXEC (@csql)

--INSERT #tbAux SELECT * FROM FINMAS_CONTA2008.dbo.tCsCoAux
SET @csql = 'INSERT #tbAux SELECT * FROM ['+@Servidor+'].'+@BaseDatos+'.dbo.tCsCoAux '
print @csql
EXEC (@csql)

SELECT codcta,desccta, SUM(IniSalFinDebe) AS  IniSalFinDebe, SUM(IniSalFinHaber) AS IniSalFinHaber, SUM(FinSalFinDebe) AS FinSalFinDebe, SUM(FinSalFinHaber) AS FinSalFinHaber  FROM (
SELECT codcta,desccta,SalFinDebe as IniSalFinDebe,SalFinHaber as IniSalFinHaber, 0 as FinSalFinDebe, 0 as FinSalFinHaber FROM #tbAux where  Sesion = 'S070625-7953'
union
SELECT codcta,desccta,0 as IniSalFinDebe, 0 IniSalFinHaber ,SalFinDebe as FinSalFinDebe,SalFinHaber as  FinSalFinHaber FROM #tbAux where  Sesion = 'S070625-7954'
) A
GROUP BY codcta,desccta
ORDER BY codcta
--order by codcta

DROP TABLE #tbAux

SET NOCOUNT OFF
GO