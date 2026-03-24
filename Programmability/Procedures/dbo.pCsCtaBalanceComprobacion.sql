SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCtaBalanceComprobacion] @FechaIni smalldatetime , @FechaFin smalldatetime, @AgOficina char(1), @CodOficina varchar(2000)=''  AS
--DECLARE @FechaIni smalldatetime
--DECLARE @FechaFin smalldatetime
--DECLARE @AgOficina char(1)
--DECLARE @CodOficina varchar(800)

--SET @CodOficina = ''
--SET @FechaIni = '20081201'
--SET @FechaFin = '20081231'
--SET @AgOficina  = 0

--DECLARE @Servidor varchar(50)
--DECLARE @BaseDatos varchar(50)

--SELECT @BaseDatos=NombreBD, @Servidor=NombreIP FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = cast(year(@FechaFin) as varchar(4)))

--DECLARE @csql varchar(800)
--SET @csql =   '['+@Servidor + '].'  + @BaseDatos + '.dbo.pCsCoBalanceComprobacion '''+dbo.fduFechaAAAAMMDD(@FechaIni)+''', '''+dbo.fduFechaAAAAMMDD(@FechaFin)+''', '''+@AgOficina+''', '''+@CodOficina+''' '

--execute (@csql)

--NUEVO REPORTE--

--declare @FechaIni smalldatetime
--declare @FechaFin smalldatetime
--declare @AgOficina Bit
--declare @CodOficina varchar(800)

--SET @FechaIni   = '20090101'
--SET @FechaFin  	= '20090731'
--SET @AgOficina = 1
--SET @CodOficina = '2'--'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23'

create table #tbAux
(
	Sesion			varchar(25),
	CodCta			varchar(25),
	CodOficina		varchar(5),
	CodFondo		varchar(5),
	DescCta		varchar(100),
	AnteDebe		decimal(16,4),
	AntHaber		decimal(16,4),
	MovDebe		decimal(16,4),
	MovHaber		decimal(16,4),
	SalAntTotal		decimal(16,4),
	SalFinDebe		decimal(16,4),
	SalFinHaber		decimal(16,4),
	SubMovDebe		decimal(16,4),
	SubMovHaber		decimal(16,4),
	SubSalFinDebe		decimal(16,4),
	SubSalFinHaber		decimal(16,4)
)

DECLARE @Servidor varchar(50)
DECLARE @BaseDatos varchar(50)
SELECT @BaseDatos=NombreBD, @Servidor=NombreIP FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = cast(year(@FechaFin) as varchar(4)))

DECLARE @csql varchar(3000)

SET @csql = 'insert into #tbAux (CodCta, CodOficina, CodFondo, AnteDebe, AntHaber, SalFinDebe, SalFinHaber) '
--SET @csql = @csql + 'SELECT CodCta, CodOficina, CodFondo, antdebe, anthaber, mesdebe, meshaber '
--SET @csql = @csql + 'FROM ['+@Servidor+'].'+@BaseDatos+'.dbo.tcomayores '
--SET @csql = @csql + 'WHERE Gestion='+ cast( year(@FechaFin) as varchar(4)) +' '
--SET @csql = @csql + 'and Mes=' + cast( month(@FechaFin) as varchar(2))
--SET @csql = @csql + 'and LEN(CodCta)=2 AND substring(codcta,1,1) in (5,6) '

SET @csql = @csql + 'SELECT codcta, codoficina, codfondo, saldoanterior, anthaber, sfindebe, sfinhaber FROM ( '
SET @csql = @csql + 'SELECT codcta, codoficina, codfondo, SUM(saldoanterior) saldoanterior,  '
SET @csql = @csql + 'SUM(anthaber) anthaber, SUM(saldoanterior)+SUM(sfindebe) sfindebe, SUM(sfinhaber) sfinhaber '
SET @csql = @csql + 'FROM ( '
SET @csql = @csql + 'select codcta, codoficina, codfondo, 0 saldoanterior, 0 anthaber, '
SET @csql = @csql + 'mesdebe + diadebe sfindebe, meshaber + diahaber sfinhaber  '
SET @csql = @csql + 'from ['+@Servidor+'].'+@BaseDatos+'.dbo.tcomayores '
SET @csql = @csql + 'where tipo=''TN'' and gestion='+ cast( year(@FechaFin) as varchar(4)) +' and mes=' + cast( month(@FechaFin) as varchar(2)) + ' and LEN(CodCta)=2 AND substring(codcta,1,1) in (5,6) ' -- and codcta='55' 
SET @csql = @csql + 'union '
SET @csql = @csql + 'select codcta, codoficina, codfondo, sum(antdebe - anthaber) + sum(mesdebe + diadebe - (meshaber + diahaber )) saldoanterior '
SET @csql = @csql + ', 0 anthaber, 0 salfindebe, 0 salfinhaber '
SET @csql = @csql + 'from ['+@Servidor+'].'+@BaseDatos+'.dbo.tcomayores  '
SET @csql = @csql + 'where tipo=''TN'' and gestion='+ cast( year(@FechaFin) as varchar(4)) +' and mes=' + cast(( month(@FechaFin) -1) as varchar(2)) + ' and LEN(CodCta)=2 AND substring(codcta,1,1) in (5,6) '--and codcta='55' 
SET @csql = @csql + 'group by codcta, codoficina, codfondo '
SET @csql = @csql + ') A '
SET @csql = @csql + 'GROUP BY codcta, codoficina, codfondo '
SET @csql = @csql + ') B '

if (@AgOficina=1)
BEGIN
	SET @csql = @csql + 'WHERE  codoficina in ('+@codoficina+') '
END
exec (@csql)

SET @csql = ''

if (@AgOficina=0)
	begin
		SET @csql = 'SELECT Codoficina,sum(C51) C51,sum(C52) C52,sum(C53) C53,sum(C54) C54,sum(C55) C55, '
		SET @csql = @csql + 'sum(C57) C57,sum(C58) C58, sum(C61) C61,sum(C62) C62,sum(C65) C65,sum(C66) C66 ,sum(C59) C59 '
		SET @csql = @csql + 'FROM (SELECT codoficina, '
		SET @csql = @csql + 'case codcta when ''51'' then saldofinal else 0 end C51, '
		SET @csql = @csql + 'case codcta when ''52'' then saldofinal else 0 end C52, '
		SET @csql = @csql + 'case codcta when ''53'' then saldofinal else 0 end C53, '
		SET @csql = @csql + 'case codcta when ''54'' then saldofinal else 0 end C54, '
		SET @csql = @csql + 'case codcta when ''55'' then saldofinal else 0 end C55, '
		SET @csql = @csql + 'case codcta when ''57'' then saldofinal else 0 end C57, '
		SET @csql = @csql + 'case codcta when ''58'' then saldofinal else 0 end C58, '
		SET @csql = @csql + 'case codcta when ''61'' then saldofinal else 0 end C61, '
		SET @csql = @csql + 'case codcta when ''62'' then saldofinal else 0 end C62, '
		SET @csql = @csql + 'case codcta when ''65'' then saldofinal else 0 end C65, '
		SET @csql = @csql + 'case codcta when ''66'' then saldofinal else 0 end C66, '
		SET @csql = @csql + 'case codcta when ''59'' then saldofinal else 0 end C59 '
		SET @csql = @csql + 'FROM ( '
		SET @csql = @csql + 'SELECT RES.CodCta, RES.CodOficina, case substring(RES.CodCta,1,1) when ''5'' '
		SET @csql = @csql + 'then ( SUM(RES.SalFinDebe)  - SUM(RES.SalFinHaber) )/1000 else (SUM(RES.SalFinHaber) - SUM(RES.SalFinDebe) )/1000 end SaldoFinal '
		SET @csql = @csql + 'FROM ( '

		SET @csql = @csql + 'SELECT codcta, '''' as codoficina , sum(SalFinDebe) SalFinDebe, sum(SalFinHaber) SalFinHaber FROM ('
		SET @csql = @csql + 'SELECT CodCta, CodOficina, SalFinDebe, SalFinHaber '
		SET @csql = @csql + 'FROM #tbAux '
		SET @csql = @csql + ') ga GROUP BY codcta'

		SET @csql = @csql + ') RES '
		SET @csql = @csql + 'GROUP BY RES.CodCta, RES.CodOficina ) A) B '
		SET @csql = @csql + 'GROUP BY Codoficina '
	end
else
	begin
		DECLARE @CTA53 decimal(16,4)
		SELECT @CTA53 = sum(C53) FROM (
		SELECT (SUM(SalFinDebe) - SUM(SalFinHaber))/1000 as C53
		FROM #tbAux
		WHERE CodCta = '53' and Codoficina = '99') a

		SET @CTA53 = round(isnull(@CTA53/18,0),2)

		SET @csql = 'SELECT Codoficina,sum(C51) C51,sum(C52) C52, case codoficina when ''98'' then 0 when ''1'' then 0 else ' + STR(@CTA53,6,2) + ' end C53,sum(C54) C54, '
		SET @csql = @csql + 'sum(C55) C55,sum(C57) C57,sum(C58) C58,sum(C61) C61,sum(C62) C62,sum(C65) C65,sum(C66) C66 ,sum(C51) + sum(C52) C51_C52, '
		SET @csql = @csql + 'sum(C61)+ sum(C62) C61_C62, ((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - '
		SET @csql = @csql + '(case codoficina when ''98'' then 0 when ''1'' then 0 else ' + STR(@CTA53,6,2) + ' end) MargenFinanciero, '
		SET @csql = @csql + '(((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - (case codoficina when ''98'' then 0  '
		SET @csql = @csql + 'when ''1'' then 0 else ' + STR(@CTA53,6,2) + ' end))-sum(C54) MargenFinanAjustado, '
		SET @csql = @csql + 'sum(C65)-sum(C55) ResultadoIntermedia, ((((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - (case codoficina '
		SET @csql = @csql + 'when ''98'' then 0 when ''1'' then 0 else ' + STR(@CTA53,6,2) + ' end))-sum(C54)) + (sum(C65)-sum(C55)) EgreIngreTotaOpe, '
		SET @csql = @csql + '(((((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - (case codoficina when ''98'' then 0 when ''1'' then 0 '
		SET @csql = @csql + 'else ' + STR(@CTA53,6,2) + ' end))-sum(C54)) + (sum(C65)-sum(C55)))-sum(C57) ResultadoOperacion, '
		SET @csql = @csql + 'sum(C66)-sum(C58) Gastos, ((((((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - (case codoficina when ''98'' then 0 when ''1'' '
		SET @csql = @csql + 'then 0 else ' + STR(@CTA53,6,2) + ' end))-sum(C54)) + (sum(C65)-sum(C55)))-sum(C57)) + (sum(C66)-sum(C58)) ResultadoAntes, ''Agrupa'' Agrupa, 0 Cero '
		SET @csql = @csql + 'FROM (SELECT codoficina, '
		SET @csql = @csql + 'case codcta when ''51'' then saldofinal else 0 end C51, '
		SET @csql = @csql + 'case codcta when ''52'' then saldofinal else 0 end C52, '
		SET @csql = @csql + 'case codcta when ''53'' then saldofinal else 0 end C53, '
		SET @csql = @csql + 'case codcta when ''54'' then saldofinal else 0 end C54, '
		SET @csql = @csql + 'case codcta when ''55'' then saldofinal else 0 end C55, '
		SET @csql = @csql + 'case codcta when ''57'' then saldofinal else 0 end C57, '
		SET @csql = @csql + 'case codcta when ''58'' then saldofinal else 0 end C58, '
		SET @csql = @csql + 'case codcta when ''61'' then saldofinal else 0 end C61, '
		SET @csql = @csql + 'case codcta when ''62'' then saldofinal else 0 end C62, '
		SET @csql = @csql + 'case codcta when ''65'' then saldofinal else 0 end C65, '
		SET @csql = @csql + 'case codcta when ''66'' then saldofinal else 0 end C66 '
		SET @csql = @csql + 'FROM ( '
		SET @csql = @csql + 'SELECT RES.CodCta, RES.CodOficina, case substring(RES.CodCta,1,1) when ''5'' then (SUM(RES.SalFinDebe) - SUM(RES.SalFinHaber))/1000 '
		SET @csql = @csql + 'else (SUM(RES.SalFinHaber) - SUM(RES.SalFinDebe))/1000 end SaldoFinal '
		SET @csql = @csql + 'FROM (SELECT SUBSTRING(CodCta, 1, 2) AS CodCta, CodOficina, SalFinDebe, SalFinHaber '
		SET @csql = @csql + 'FROM #tbAux) RES '
		SET @csql = @csql + 'GROUP BY RES.CodCta, RES.CodOficina) A) B '
		SET @csql = @csql + 'GROUP BY Codoficina '
		print len(@csql)
		print @csql
	end

exec(@csql)

drop table #tbAux
GO

GRANT EXECUTE ON [dbo].[pCsCtaBalanceComprobacion] TO [marista]
GO