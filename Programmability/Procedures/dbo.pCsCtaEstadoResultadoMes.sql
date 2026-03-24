SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCtaEstadoResultadoMes] @FechaIni smalldatetime,@FechaFin smalldatetime,@AgOficina Bit,@CodOficina varchar(800), @AgMes bit = 1
AS
BEGIN
	SET NOCOUNT ON;

--declare @FechaIni smalldatetime
--declare @FechaFin smalldatetime
--declare @AgOficina Bit
--declare @CodOficina varchar(800)
--declare @AgMes bit 

--SET @FechaIni   = '20120101'
--SET @FechaFin  	= '20121031'
--SET @AgOficina = 1
--SET @CodOficina = '2,3'--'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23'
--set @AgMes = 1

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

DECLARE @csql varchar(4000)
DECLARE @csql2 varchar(4000)

SET @csql = 'insert into #tbAux (CodCta, CodOficina, CodFondo, AnteDebe, AntHaber, SalFinDebe, SalFinHaber) '

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

--select * from #tbAux

SET @csql = ''

if (@AgOficina=0)
	begin
		SET @csql = 'SELECT Codoficina,sum(C51) C51,sum(C52) C52,sum(C53) C53,sum(C54) C54,sum(C55) C55, '
		SET @csql = @csql + 'sum(C57) C57,sum(C58) C58, sum(C61) C61,sum(C62) C62,sum(C65) C65,sum(C66) C66 ,sum(C59) C59 '
		
		SET @csql = @csql + ',sum(mC51) mC51,sum(mC52) mC52,sum(mC53) mC53,sum(mC54) mC54,sum(mC55) mC55, '
		SET @csql = @csql + 'sum(mC57) mC57,sum(mC58) mC58, sum(mC61) mC61,sum(mC62) mC62,sum(mC65) mC65,sum(mC66) mC66 ,sum(mC59) mC59 '
		
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
		SET @csql = @csql + 'case codcta when ''59'' then saldofinal else 0 end C59, '
		
		SET @csql = @csql + 'case codcta when ''51'' then SaldoMes else 0 end mC51, '
		SET @csql = @csql + 'case codcta when ''52'' then SaldoMes else 0 end mC52, '
		SET @csql = @csql + 'case codcta when ''53'' then SaldoMes else 0 end mC53, '
		SET @csql = @csql + 'case codcta when ''54'' then SaldoMes else 0 end mC54, '
		SET @csql = @csql + 'case codcta when ''55'' then SaldoMes else 0 end mC55, '
		SET @csql = @csql + 'case codcta when ''57'' then SaldoMes else 0 end mC57, '
		SET @csql = @csql + 'case codcta when ''58'' then SaldoMes else 0 end mC58, '
		SET @csql = @csql + 'case codcta when ''61'' then SaldoMes else 0 end mC61, '
		SET @csql = @csql + 'case codcta when ''62'' then SaldoMes else 0 end mC62, '
		SET @csql = @csql + 'case codcta when ''65'' then SaldoMes else 0 end mC65, '
		SET @csql = @csql + 'case codcta when ''66'' then SaldoMes else 0 end mC66, '
		SET @csql = @csql + 'case codcta when ''59'' then SaldoMes else 0 end mC59 '
		
		SET @csql = @csql + 'FROM ( '
		SET @csql = @csql + 'SELECT RES.CodCta, RES.CodOficina, case substring(RES.CodCta,1,1) when ''5'' '
		SET @csql = @csql + 'then ( SUM(RES.SalFinDebe)  - SUM(RES.SalFinHaber) )/1000 else (SUM(RES.SalFinHaber) - SUM(RES.SalFinDebe) )/1000 end SaldoFinal '
		SET @csql = @csql + ', (case substring(RES.CodCta,1,1) when ''5''  '
		SET @csql = @csql + 'then ( SUM(RES.SalFinDebe)  - SUM(RES.SalFinHaber) )/1000 else (SUM(RES.SalFinHaber) - SUM(RES.SalFinDebe) )/1000 end ) '
		SET @csql = @csql + '- sum(SalAntedebe)/1000 SaldoMes '
		
		SET @csql = @csql + 'FROM ( '

		SET @csql = @csql + 'SELECT codcta, '''' as codoficina , sum(SalFinDebe) SalFinDebe, sum(SalFinHaber) SalFinHaber, sum(Antedebe) SalAntedebe FROM ('
		SET @csql = @csql + 'SELECT CodCta, CodOficina, SalFinDebe, SalFinHaber,Antedebe '
		SET @csql = @csql + 'FROM #tbAux '
		SET @csql = @csql + ') ga GROUP BY codcta'

		SET @csql = @csql + ') RES '
		SET @csql = @csql + 'GROUP BY RES.CodCta, RES.CodOficina ) A) B '
		SET @csql = @csql + 'GROUP BY Codoficina '
		
		exec(@csql)
	end
else
	begin
		DECLARE @CTA53 decimal(16,4)
		SELECT @CTA53 = sum(isnull(C53,0)) FROM (
		SELECT (SUM(SalFinDebe) - SUM(SalFinHaber))/1000 as C53
		FROM #tbAux
		WHERE CodCta = '53' and Codoficina = '99') a

    SET @csql2 = ' SELECT Codoficina,sum(C51) C51,sum(C52) C52, case codoficina when ''98'' then 0 when ''1'' then 0 else ' + STR(@CTA53,6,2) + ' end C53,sum(C54) C54, '
    SET @csql2 = @csql2 + 'sum(C55) C55,sum(C57) C57,sum(C58) C58,sum(C61) C61,sum(C62) C62,sum(C65) C65,sum(C66) C66 ,sum(C51) + sum(C52) C51_C52, '
    SET @csql2 = @csql2 + 'sum(C61)+ sum(C62) C61_C62, ((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - '
    SET @csql2 = @csql2 + '(case codoficina when ''98'' then 0 when ''1'' then 0 else ' + STR(@CTA53,6,2) + ' end) MargenFinanciero, '
    SET @csql2 = @csql2 + '(((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - (case codoficina when ''98'' then 0  '
    SET @csql2 = @csql2 + 'when ''1'' then 0 else ' + STR(@CTA53,6,2) + ' end))-sum(C54) MargenFinanAjustado, '
    SET @csql2 = @csql2 + 'sum(C65)-sum(C55) ResultadoIntermedia, ((((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - (case codoficina '
    SET @csql2 = @csql2 + 'when ''98'' then 0 when ''1'' then 0 else ' + STR(@CTA53,6,2) + ' end))-sum(C54)) + (sum(C65)-sum(C55)) EgreIngreTotaOpe, '
    SET @csql2 = @csql2 + '(((((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - (case codoficina when ''98'' then 0 when ''1'' then 0 '
    SET @csql2 = @csql2 + 'else ' + STR(@CTA53,6,2) + ' end))-sum(C54)) + (sum(C65)-sum(C55)))-sum(C57) ResultadoOperacion, '
    SET @csql2 = @csql2 + 'sum(C66)-sum(C58) Gastos, ((((((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - (case codoficina when ''98'' then 0 when ''1'' '
    SET @csql2 = @csql2 + 'then 0 else ' + STR(@CTA53,6,2) + ' end))-sum(C54)) + (sum(C65)-sum(C55)))-sum(C57)) + (sum(C66)-sum(C58)) ResultadoAntes, ''Agrupa'' Agrupa, 0 Cero,''Mes      '' ColMes '
		
    SET @csql2 = @csql2 + 'FROM (SELECT codoficina, '
    SET @csql2 = @csql2 + 'case codcta when ''51'' then SaldoMes else 0 end C51, '
    SET @csql2 = @csql2 + 'case codcta when ''52'' then SaldoMes else 0 end C52, '
    SET @csql2 = @csql2 + 'case codcta when ''53'' then SaldoMes else 0 end C53, '
    SET @csql2 = @csql2 + 'case codcta when ''54'' then SaldoMes else 0 end C54, '
    SET @csql2 = @csql2 + 'case codcta when ''55'' then SaldoMes else 0 end C55, '
    SET @csql2 = @csql2 + 'case codcta when ''57'' then SaldoMes else 0 end C57, '
    SET @csql2 = @csql2 + 'case codcta when ''58'' then SaldoMes else 0 end C58, '
    SET @csql2 = @csql2 + 'case codcta when ''61'' then SaldoMes else 0 end C61, '
    SET @csql2 = @csql2 + 'case codcta when ''62'' then SaldoMes else 0 end C62, '
    SET @csql2 = @csql2 + 'case codcta when ''65'' then SaldoMes else 0 end C65, '
    SET @csql2 = @csql2 + 'case codcta when ''66'' then SaldoMes else 0 end C66, '
    SET @csql2 = @csql2 + 'case codcta when ''59'' then SaldoMes else 0 end C59 '

    SET @csql2 = @csql2 + 'FROM ( '
    SET @csql2 = @csql2 + 'SELECT RES.CodCta, RES.CodOficina, case substring(RES.CodCta,1,1) when ''5'' then (SUM(RES.SalFinDebe) - SUM(RES.SalFinHaber))/1000 '
    SET @csql2 = @csql2 + 'else (SUM(RES.SalFinHaber) - SUM(RES.SalFinDebe))/1000 end SaldoFinal '
		
    SET @csql2 = @csql2 + ', (case substring(RES.CodCta,1,1) when ''5''  '
    SET @csql2 = @csql2 + 'then ( SUM(RES.SalFinDebe)  - SUM(RES.SalFinHaber) )/1000 else (SUM(RES.SalFinHaber) - SUM(RES.SalFinDebe) )/1000 end ) '
    SET @csql2 = @csql2 + ' - ( case substring(RES.CodCta,1,1) when ''5'' then (sum(Antedebe)/1000) else (-1)*(sum(Antedebe)/1000) end ) SaldoMes '
		
    SET @csql2 = @csql2 + 'FROM (SELECT SUBSTRING(CodCta, 1, 2) AS CodCta, CodOficina, SalFinDebe, SalFinHaber,Antedebe '
    SET @csql2 = @csql2 + 'FROM #tbAux) RES '
    SET @csql2 = @csql2 + 'GROUP BY RES.CodCta, RES.CodOficina) A) B '
    SET @csql2 = @csql2 + 'GROUP BY Codoficina '

		SET @CTA53 = round(isnull(@CTA53/18,0),2)
    if(@AgMes=1)
		  begin
		    SET @csql = 'UNION SELECT Codoficina,sum(C51) C51,sum(C52) C52, case codoficina when ''98'' then 0 when ''1'' then 0 else ' + STR(@CTA53,6,2) + ' end C53,sum(C54) C54, '
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
		    SET @csql = @csql + 'then 0 else ' + STR(@CTA53,6,2) + ' end))-sum(C54)) + (sum(C65)-sum(C55)))-sum(C57)) + (sum(C66)-sum(C58)) ResultadoAntes, ''Agrupa'' Agrupa, 0 Cero,''Acumulado'' ColMes '
    		
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
		    SET @csql = @csql + 'SELECT RES.CodCta, RES.CodOficina, case substring(RES.CodCta,1,1) when ''5'' then (SUM(RES.SalFinDebe) - SUM(RES.SalFinHaber))/1000 '
		    SET @csql = @csql + 'else (SUM(RES.SalFinHaber) - SUM(RES.SalFinDebe))/1000 end SaldoFinal '
    		
		    SET @csql = @csql + ', (case substring(RES.CodCta,1,1) when ''5''  '
		    SET @csql = @csql + 'then ( SUM(RES.SalFinDebe)  - SUM(RES.SalFinHaber) )/1000 else (SUM(RES.SalFinHaber) - SUM(RES.SalFinDebe) )/1000 end ) '
		    SET @csql = @csql + '- sum(Antedebe)/1000 SaldoMes '
    		
		    SET @csql = @csql + 'FROM (SELECT SUBSTRING(CodCta, 1, 2) AS CodCta, CodOficina, SalFinDebe, SalFinHaber,Antedebe '
		    SET @csql = @csql + 'FROM #tbAux) RES '
		    SET @csql = @csql + 'GROUP BY RES.CodCta, RES.CodOficina) A) B '
		    SET @csql = @csql + 'GROUP BY Codoficina order by ColMes'
		  end
		else begin SET @csql = '' end
		  
		exec(@csql2 + @csql)
		
	end

drop table #tbAux

END
GO

GRANT EXECUTE ON [dbo].[pCsCtaEstadoResultadoMes] TO [marista]
GO