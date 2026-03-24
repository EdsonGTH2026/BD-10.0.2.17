SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		Christofer Urbizagastegui Montoya
-- Create date: 17/05/2010
-- Description:	Resultados por unidad de negocio por fecha de corte
-- =============================================
CREATE PROCEDURE [dbo].[pCsCtaResultadoUnidadNegocio] @fecha smalldatetime	
AS
BEGIN
SET NOCOUNT ON

--declare @fecha smalldatetime
---SET @fecha = '20100331'

declare @cs_div decimal(16,2)
declare @cs_div_co decimal(16,2)
set @cs_div = 1000000
set @cs_div_co = 1000

create table #cuadro (
  CodOficina	varchar(4)	,
  NomOficina	varchar(30)	,
  Meses int,
  caasesor int default(0),
  caclientes int default(0),
  camonto decimal (16,2) default(0),
  ahasesor int default(0),
  ahclientes int default(0),
  ahmonto decimal (16,2) default(0),
  sgopera int default(0),
  sgmonto decimal (16,2) default(0),
  reopera int default(0),
  remonto decimal (16,2) default(0),
  txopera int default(0),
  txmonto decimal (16,2) default(0),
  tjopera int default(0),
  tjmonto decimal (16,2) default(0),
  coingres decimal (16,2) default(0),
  comargen decimal (16,2) default(0),
  cogadmyop decimal (16,2) default(0),
  cooingygas decimal (16,2) default(0),
  corenai decimal (16,2) default(0)
)

insert #cuadro ( CodOficina,	NomOficina,  Meses )
SELECT codoficina,nomoficina,  datediff(month,isnull(fechaapertura,@fecha), @fecha) meses from tcloficinas 
where cast(codoficina as int)>1 and cast(codoficina as int)<70 --or codoficina='98'
order by cast(codoficina as int)  

declare @codoficina varchar(4)
declare @nro int
declare @nro2 int
declare @monto decimal(16,2)

--CARTERA
declare cartera cursor for
  
  SELECT     ca.CodOficina, COUNT(DISTINCT ca.CodAsesor) AS NroAse, COUNT(DISTINCT cad.CodUsuario) AS NroClie, 
                        SUM(cad.SaldoCapital + cad.InteresVigente + + cad.InteresVencido  + cad.MoratorioVigente + cad.MoratoriovENCIDO) AS Cartera
  FROM         tCsCartera AS ca INNER JOIN
                        tCsCarteraDet AS cad ON ca.Fecha = cad.Fecha AND ca.CodPrestamo = cad.CodPrestamo
  WHERE     (ca.Fecha = @fecha) and ca.cartera='ACTIVA'
  GROUP BY ca.CodOficina
  
open cartera

FETCH NEXT FROM cartera 
INTO @codoficina, @nro, @nro2, @monto

WHILE @@FETCH_STATUS = 0
BEGIN

  update #cuadro
  set  caasesor = @nro,  caclientes = @nro2,  camonto = @monto/@cs_div
  WHERE codoficina = @codoficina

  FETCH NEXT FROM cartera 
  INTO @codoficina, @nro, @nro2, @monto
END 
CLOSE cartera
DEALLOCATE cartera

--AHORROS
declare ahorros cursor for
  
SELECT     CodOficina, COUNT(DISTINCT CodAsesor) AS Nroase, COUNT(DISTINCT CodUsuario) AS Nroclie, SUM(SaldoCuenta) AS Monto
FROM         tCsAhorros AS ah
WHERE     (Fecha = @fecha)
GROUP BY CodOficina
  
open ahorros

FETCH NEXT FROM ahorros 
INTO @codoficina, @nro, @nro2, @monto

WHILE @@FETCH_STATUS = 0
BEGIN

  update #cuadro
  set  ahasesor = @nro,  ahclientes = @nro2,  ahmonto = @monto/@cs_div
  WHERE codoficina = @codoficina

  FETCH NEXT FROM ahorros 
  INTO @codoficina, @nro, @nro2, @monto
END 
CLOSE ahorros
DEALLOCATE ahorros

--seguros
declare seguros cursor for
  
select codoficina, count(codoficina) nroope, sum(montototaltran) monto from tcstransacciondiaria 
where fecha>= cast(year(@fecha) as varchar(4))+ '0101' and fecha<=@fecha and codsistema = 'TC' 
and tipotransacnivel1='I' and tipotransacnivel3 in(2,3,9,10,13,14,15,17)
group by codoficina
  
open seguros

FETCH NEXT FROM seguros 
INTO @codoficina, @nro, @monto

WHILE @@FETCH_STATUS = 0
BEGIN

  update #cuadro
  set  sgopera = @nro,  sgmonto = @monto/@cs_div
  WHERE codoficina = @codoficina
  
  FETCH NEXT FROM seguros 
  INTO @codoficina, @nro, @monto
END 
CLOSE seguros
DEALLOCATE seguros

--remesas --> 1 y 11
declare remesas cursor for
  
select codoficina, count(codoficina) nroope, sum(montototaltran) monto from tcstransacciondiaria 
where fecha>= cast(year(@fecha) as varchar(4))+ '0101' and fecha<=@fecha and codsistema = 'TC' 
and tipotransacnivel1='E' and tipotransacnivel3 in(1,11)
group by codoficina
  
open remesas

FETCH NEXT FROM remesas 
INTO @codoficina, @nro, @monto

WHILE @@FETCH_STATUS = 0
BEGIN

  update #cuadro
  set  reopera = @nro,  remonto = @monto/@cs_div
  WHERE codoficina = @codoficina
  
  FETCH NEXT FROM remesas 
  INTO @codoficina, @nro, @monto
END 
CLOSE remesas
DEALLOCATE remesas
-- telmex = 18
declare telmex cursor for
  
select codoficina, count(codoficina) nroope, sum(montototaltran) monto from tcstransacciondiaria 
where fecha>= cast(year(@fecha) as varchar(4))+ '0101' and fecha<=@fecha and codsistema = 'TC' 
and tipotransacnivel1='I' and tipotransacnivel3 in(18)
group by codoficina
  
open telmex

FETCH NEXT FROM telmex 
INTO @codoficina, @nro, @monto

WHILE @@FETCH_STATUS = 0
BEGIN

  update #cuadro
  set  txopera = @nro,  txmonto = @monto/@cs_div
  WHERE codoficina = @codoficina
  
  FETCH NEXT FROM telmex 
  INTO @codoficina, @nro, @monto
END 
CLOSE telmex
DEALLOCATE telmex
-- tarjeta saludo = 19
declare tarjeta cursor for
  
select codoficina, count(codoficina) nroope, sum(montototaltran) monto from tcstransacciondiaria 
where fecha>= cast(year(@fecha) as varchar(4))+ '0101' and fecha<=@fecha and codsistema = 'TC' 
and tipotransacnivel1='I' and tipotransacnivel3 in(19)
group by codoficina
  
open tarjeta

FETCH NEXT FROM tarjeta 
INTO @codoficina, @nro, @monto

WHILE @@FETCH_STATUS = 0
BEGIN

  update #cuadro
  set  tjopera = @nro,  tjmonto = @monto/@cs_div
  WHERE codoficina = @codoficina
  
  FETCH NEXT FROM tarjeta 
  INTO @codoficina, @nro, @monto
END 
CLOSE tarjeta
DEALLOCATE tarjeta

-- envio remesa nacional = 6 --> ojo

--CONTABLES ESTADO RESULTADOS
--declare @fecha smalldatetime
--SET @fecha = '20100331'

declare @cadofi varchar(2000)
declare @ofi varchar(4)

set @cadofi = ''

declare ofi cursor for
  select  codoficina from tcloficinas
open ofi

FETCH NEXT FROM ofi
INTO @ofi
WHILE @@FETCH_STATUS = 0
BEGIN
  set @cadofi = @cadofi + @ofi + ','
  FETCH NEXT FROM ofi 
  INTO @ofi
END 
CLOSE ofi
DEALLOCATE ofi
set @cadofi = substring(@cadofi, 1, len(@cadofi)-1)


declare @FechaIni smalldatetime
declare @FechaFin smalldatetime

SELECT @FechaIni = primerdia FROM tclperiodo  where periodo = dbo.fduFechaATexto(@Fecha,'AAAAMM')
set @FechaFin = @Fecha

create table #tbconta (
 oficina varchar(4),
 c51 decimal(16,4),
 c52 decimal(16,4),
 c53 decimal(16,4),
 c54 decimal(16,4),
 c55 decimal(16,4),
 c57 decimal(16,4),
 c58 decimal(16,4),
 c61 decimal(16,4),
 c62 decimal(16,4),
 c65 decimal(16,4),
 c66 decimal(16,4),
 c51_52 decimal(16,4),
 c61_62 decimal(16,4),
 mf decimal(16,4),
 mfa decimal(16,4),
 ri decimal(16,4),
 eito decimal(16,4),
 ro decimal(16,4),
 gasto decimal(16,4),
 raim decimal(16,4),
 agrupa varchar(50),
 cero decimal(16,4)
)

insert into #tbconta
exec pCsCtaBalanceComprobacion @FechaIni , @FechaFin, '1', @cadofi 

declare @c61_62 decimal(16,4)
declare @mf decimal(16,4)
declare @c57 decimal(16,4)
declare @eito decimal(16,4) 
declare @raim decimal(16,4)

declare contaer cursor for
select oficina,c61_62,mf,c57,eito,raim  from #tbconta
open contaer

FETCH NEXT FROM contaer
INTO @codoficina,@c61_62,@mf,@c57,@eito,@raim
WHILE @@FETCH_STATUS = 0
BEGIN

  update #cuadro
  set  coingres = @c61_62/@cs_div_co,  comargen = @mf/@cs_div_co,  cogadmyop = @c57/@cs_div_co,  cooingygas = @eito/@cs_div_co,  corenai =@raim/@cs_div_co
  WHERE codoficina = @codoficina

  FETCH NEXT FROM contaer 
  INTO @codoficina,@c61_62,@mf,@c57,@eito,@raim
END 
CLOSE contaer
DEALLOCATE contaer

select * from #cuadro
drop table #tbconta
drop table #cuadro

SET NOCOUNT Off
END
GO