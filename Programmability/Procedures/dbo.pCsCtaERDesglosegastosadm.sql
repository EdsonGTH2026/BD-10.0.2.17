SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCtaERDesglosegastosadm] @FechaIni smalldatetime,@FechaFin smalldatetime,@CodOficina varchar(800)
AS
BEGIN
	SET NOCOUNT ON;

--declare @FechaIni smalldatetime
--declare @FechaFin smalldatetime
--declare @CodOficina varchar(800)

--SET @FechaIni   = '20120101'
--SET @FechaFin  	= '20121031'

--SET @CodOficina = '2'--'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23'

create table #tbAux
(
	CodCta			varchar(25),
	desccta     varchar(200),
	ctagrupo     varchar(200),
	CodOficina		varchar(5),
	CodFondo		varchar(5),
	desczona      varchar(300),
	AnteDebe		decimal(16,4),
	AntHaber		decimal(16,4),
	SalFinDebe_1		decimal(16,4) default(0),
	SalFinHaber_1		decimal(16,4) default(0),
	SalFinDebe_2		decimal(16,4) default(0),
	SalFinHaber_2		decimal(16,4) default(0),
	SalFinDebe_3		decimal(16,4) default(0),
	SalFinHaber_3		decimal(16,4) default(0),
	SalFinDebe_4		decimal(16,4) default(0),
	SalFinHaber_4		decimal(16,4) default(0)
)

DECLARE @Servidor varchar(50)
DECLARE @BaseDatos varchar(50)
SELECT @BaseDatos=NombreBD, @Servidor=NombreIP FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = cast(year(@FechaFin) as varchar(4)))

DECLARE @csql varchar(3000)
declare @n int
set @n = 0

declare @FFx smalldatetime

while (@n<4)
begin

  set @FFx=dateadd(month,-@n,@FechaFin)
  
  SET @csql = 'insert into #tbAux (CodCta, CodOficina, CodFondo, AnteDebe, AntHaber, SalFinDebe_'+cast(@n+1 as char(1))+', SalFinHaber_'+cast(@n+1 as char(1))+',desccta,ctagrupo) '
  SET @csql = @csql + 'SELECT B.codcta, B.codoficina, B.codfondo, B.saldoanterior, B.anthaber, B.sfindebe, B.sfinhaber, co.desccta,ca.desccta FROM ( '
  SET @csql = @csql + 'SELECT codcta, codoficina, codfondo, SUM(saldoanterior) saldoanterior,  '
  SET @csql = @csql + 'SUM(anthaber) anthaber, SUM(saldoanterior)+SUM(sfindebe) sfindebe, SUM(sfinhaber) sfinhaber '
  SET @csql = @csql + 'FROM ( '
  SET @csql = @csql + 'select codcta, codoficina, codfondo, 0 saldoanterior, 0 anthaber, '
  SET @csql = @csql + 'mesdebe + diadebe sfindebe, meshaber + diahaber sfinhaber  '
  SET @csql = @csql + 'from ['+@Servidor+'].'+@BaseDatos+'.dbo.tcomayores '
  SET @csql = @csql + 'where tipo=''TN'' and gestion='+ cast( year(@FFx) as varchar(4)) +' and mes=' + cast( month(@FFx) as varchar(2)) + ' and LEN(CodCta)=9 AND substring(codcta,1,2) =''57'' '
  SET @csql = @csql + 'union '
  SET @csql = @csql + 'select codcta, codoficina, codfondo, sum(antdebe - anthaber) + sum(mesdebe + diadebe - (meshaber + diahaber )) saldoanterior '
  SET @csql = @csql + ', 0 anthaber, 0 salfindebe, 0 salfinhaber '
  SET @csql = @csql + 'from ['+@Servidor+'].'+@BaseDatos+'.dbo.tcomayores  '
  SET @csql = @csql + 'where tipo=''TN'' and gestion='+ cast( year(@FFx) as varchar(4)) +' and mes=' + cast(( month(@FFx) -1) as varchar(2)) + ' and LEN(CodCta)=9 AND substring(codcta,1,2)=''57'' '
  SET @csql = @csql + 'group by codcta, codoficina, codfondo '
  SET @csql = @csql + ') A '
  SET @csql = @csql + 'GROUP BY codcta, codoficina, codfondo '
  SET @csql = @csql + ') B '
  SET @csql = @csql + 'inner join ['+@Servidor+'].'+@BaseDatos+'.dbo.tCoCuentas co on co.CodCta=B.CodCta '
  SET @csql = @csql + 'inner join ['+@Servidor+'].'+@BaseDatos+'.dbo.tCoCuentas ca on ca.CodCta=substring(B.CodCta,1,4) '
  SET @csql = @csql + 'WHERE  codoficina in ('+@codoficina+') '
  print @csql
  exec (@csql)
  
  set @n=@n+1
end

declare @oficinas varchar(200)
set @csql=' select nomoficina from tcloficinas where codoficina in ('+@codoficina+') '
exec pCsFxGeneraCadena @csql,@oficinas out

set @csql='declare @zona varchar(100) '
set @csql=@csql+'select @zona=nombre from tclzona where zona in( select zona from tcloficinas where codoficina in ('+@codoficina+')) '
set @csql=@csql+'update #tbAux '
set @csql=@csql+'set desczona=@zona+'': ''+ '''+@oficinas+''''
set @csql=@csql+''
exec(@csql)

select codcta,desccta,ctagrupo,desczona
,sum(SalFinDebe_1) SalFinDebe_1,sum(SalFinHaber_1) SalFinHaber_1, sum(SalFinDebe_1) - sum(SalFinHaber_1) SaldoFinal_1
,sum(SalFinDebe_2) SalFinDebe_2,sum(SalFinHaber_2) SalFinHaber_2, sum(SalFinDebe_2) - sum(SalFinHaber_2) SaldoFinal_2
,sum(SalFinDebe_3) SalFinDebe_3,sum(SalFinHaber_3) SalFinHaber_3, sum(SalFinDebe_3) - sum(SalFinHaber_3) SaldoFinal_3
,sum(SalFinDebe_4) SalFinDebe_4,sum(SalFinHaber_4) SalFinHaber_4, sum(SalFinDebe_4) - sum(SalFinHaber_4) SaldoFinal_4
from #tbAux
group by codcta,desccta,ctagrupo,desczona

drop table #tbAux

END
GO