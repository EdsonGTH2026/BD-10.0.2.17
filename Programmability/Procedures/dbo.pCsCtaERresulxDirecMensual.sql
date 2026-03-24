SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCtaERresulxDirecMensual] @FechaFin smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

--declare @FechaFin smalldatetime
--SET @FechaFin  	= '20121031'

create table #tbAux
(
	periodo			varchar(6),
	CodCta			varchar(25),
	CodOficina		varchar(5),
	CodLAux1		varchar(5),
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
declare @n int
set @n = 0

declare @Fx smalldatetime
while(@n<month(@FechaFin))
begin
  set @Fx = dateadd(month,-@n,@FechaFin)
  
  SET @csql = 'insert into #tbAux (periodo,CodCta, CodOficina, CodLAux1, AnteDebe, AntHaber, SalFinDebe, SalFinHaber) '
  SET @csql = @csql + 'SELECT periodo,codcta, codoficina, CodLAux1, saldoanterior, anthaber, sfindebe, sfinhaber FROM ( '
  SET @csql = @csql + 'SELECT periodo,codcta, codoficina, CodLAux1, SUM(saldoanterior) saldoanterior,  '
  SET @csql = @csql + 'SUM(anthaber) anthaber, SUM(saldoanterior)+SUM(sfindebe) sfindebe, SUM(sfinhaber) sfinhaber '
  SET @csql = @csql + 'FROM ( '
  SET @csql = @csql + 'select '+cast( year(@Fx) as varchar(4))+replicate('0',2-len(cast(month(@Fx) as varchar(2))))+cast(month(@Fx) as varchar(2))+' periodo,codcta, codoficina, CodLAux1, 0 saldoanterior, 0 anthaber, '
  SET @csql = @csql + 'mesdebe + diadebe sfindebe, meshaber + diahaber sfinhaber  '
  SET @csql = @csql + 'from ['+@Servidor+'].'+@BaseDatos+'.dbo.tCoMayoresLibroAux '
  SET @csql = @csql + 'where tipo=''TN'' and tiplaux1=18 and gestion='+ cast( year(@Fx) as varchar(4)) +' and mes=' + cast( month(@Fx) as varchar(2)) + ' AND substring(codcta,1,1) in (5,6) '
  SET @csql = @csql + 'union '
  SET @csql = @csql + 'select '+cast( year(@Fx) as varchar(4))+replicate('0',2-len(cast(month(@Fx) as varchar(2))))+cast( month(@Fx) as varchar(2))+' periodo,codcta, codoficina, CodLAux1, sum(antdebe - anthaber) + sum(mesdebe + diadebe - (meshaber + diahaber )) saldoanterior '
  SET @csql = @csql + ', 0 anthaber, 0 salfindebe, 0 salfinhaber '
  SET @csql = @csql + 'from ['+@Servidor+'].'+@BaseDatos+'.dbo.tCoMayoresLibroAux  '
  SET @csql = @csql + 'where tipo=''TN'' and tiplaux1=18 and gestion='+ cast( year(@Fx) as varchar(4)) +' and mes=' + cast(( month(@Fx) -1) as varchar(2)) + ' AND substring(codcta,1,1) in (5,6) '
  SET @csql = @csql + 'group by codcta,gestion,mes,codoficina, CodLAux1 '
  SET @csql = @csql + ') A '
  SET @csql = @csql + 'GROUP BY codcta, periodo,codoficina, CodLAux1 '
  SET @csql = @csql + ') B '
  --SET @csql = @csql + 'WHERE  codoficina in ('+@codoficina+') '
  --print @csql
  exec (@csql)
  set @n=@n+1
end

SET @csql = ''

DECLARE @CTA53 decimal(16,4)
SELECT @CTA53 = sum(C53) FROM (
SELECT (SUM(SalFinDebe) - SUM(SalFinHaber))/1000 as C53
FROM #tbAux
WHERE CodCta = '53' and Codoficina = '99') a

SET @CTA53 = round(isnull(@CTA53/18,0),2)

SET @csql = 'SELECT b.periodo,p.ultimodia,b.CodLAux1, d.NombRel '
SET @csql = @csql + ', ((((((sum(C61)+ sum(C62)) - (sum(C51) + sum(C52))) - (0))-sum(C54)) + (sum(C65)-sum(C55)))-sum(C57)) + (sum(C66)-sum(C58)) Componente '
SET @csql = @csql + 'FROM (SELECT periodo,CodLAux1, '
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
SET @csql = @csql + 'SELECT RES.periodo,RES.CodCta, RES.CodLAux1, case substring(RES.CodCta,1,1) when ''5'' then (SUM(RES.SalFinDebe) - SUM(RES.SalFinHaber))/1000 '
SET @csql = @csql + 'else (SUM(RES.SalFinHaber) - SUM(RES.SalFinDebe))/1000 end SaldoFinal '
SET @csql = @csql + 'FROM (SELECT periodo,SUBSTRING(CodCta, 1, 2) AS CodCta, CodLAux1, SalFinDebe, SalFinHaber '
SET @csql = @csql + 'FROM #tbAux) RES '
SET @csql = @csql + 'GROUP BY RES.periodo,RES.CodCta, RES.CodLAux1) A) B '
--SET @csql = @csql + 'inner join tcloficinas o with(nolock) on o.codoficina=b.codoficina '
SET @csql = @csql + 'inner join tClPeriodo p with(nolock) on p.periodo COLLATE Modern_Spanish_CI_AS=b.periodo '
SET @csql = @csql + 'inner join ['+@Servidor+'].'+@BaseDatos+'.dbo.tCoClLibroAuxDetalle d on d.CodLAux=b.CodLAux1 and d.TipLAux=18 '
SET @csql = @csql + 'GROUP BY b.CodLAux1, b.periodo, d.NombRel,p.ultimodia '
--print len(@csql)
--print @csql

exec(@csql)

drop table #tbAux

END
GO