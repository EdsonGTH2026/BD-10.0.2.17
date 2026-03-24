SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsADatosxGrupoRegional] @fecha smalldatetime, @codoficina as varchar(300)
as
--declare @codoficina as varchar(200)
--declare @fecha smalldatetime

--set @codoficina='10,11,12,13,14,15,16'
--set @fecha='20130411'

create table #dtmp(
  codoficina varchar(15),
  nombreasesor varchar(250),
  nroclientes int default(0),
  nroprestamos int default(0),
  saldocartera decimal(16,2) default(0),
  saldoatrasado decimal(16,2) default(0),
  saldovencido decimal(16,2) default(0),
  moravencida decimal(16,2) default(0),
  nrodesembolsado decimal(16,2) default(0),
  desembolsado decimal(16,2) default(0),
  nroprogramado int default(0),
  programado decimal(16,2) default(0),
  nrorecuperado int default(0),
  recuperado decimal(16,2) default(0),
  condonado decimal(16,2) default(0)
)

insert #dtmp (codoficina,nombreasesor,nroclientes,nroprestamos,saldocartera,saldoatrasado,saldovencido)
SELECT codoficina,nomoficina, count(distinct codusuario) nroclientes, count(distinct codprestamo) nroprestamos
,sum(saldocartera) saldocartera,sum(saldoatrasado) saldoatrasado,sum(saldovencido) saldovencido
from (
SELECT o.codoficina,o.nomoficina,cd.codusuario, c.codprestamo
,cd.saldocapital  + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido saldocartera
,case when c.estado='VENCIDO'
    then 
      cd.saldocapital  + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido 
  else 0 end saldovencido
,case when c.tiporeprog in ('SINRE','REFRE') then
  case when c.nrodiasatraso>0 and c.nrodiasatraso<90 
  then cd.saldocapital  + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido else 0 end 
 else 0 end saldoatrasado
FROM tCsCarteraDet cd with(nolock) inner join
tCscartera c with(nolock) on cd.fecha=c.fecha and cd.codprestamo=c.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
where c.codoficina in (select codigo from dbo.fduTablaValores(@codoficina))--('3','4','5','6','7','8','9','10','11','12','19')
and c.fecha=@fecha
and c.cartera='ACTIVA' 

) b
group by codoficina,nomoficina


update #dtmp
set programado=pr.monto,nroprogramado=pr.nro
from #dtmp t inner join (
select c.codoficina,count(distinct p.codprestamo) nro
,sum(p.montodevengado-p.montopagado-p.montocondonado) monto
from tCsPlanCuotas p with(nolock) inner join tcscartera c with(nolock) on c.codprestamo=p.codprestamo and c.fecha=p.fecha
where p.fecha=(@fecha-1)--'20130406'--
and p.estadoconcepto<>'CANCELADO'
and p.fechavencimiento=@fecha--'20130407'
and p.codoficina in (select codigo from dbo.fduTablaValores(@codoficina))--('3','4','5','6','7','8','9','10','11','12','19')
group by c.codoficina
) pr on pr.codoficina=t.codoficina

update #dtmp
set nrorecuperado=pr.nro,recuperado=pr.recuperaciones,condonado=pr.condonaciones
from #dtmp t inner join (
SELECT codoficina,count(distinct codigocuenta) nro, sum(case when tipotransacnivel3<>2 then montototaltran else 0 end) Recuperaciones
, sum(case when tipotransacnivel3=2 then montototaltran else 0 end) Condonaciones
FROM tCsTransaccionDiaria t with(nolock)
where codsistema='CA'
and codoficina in (select codigo from dbo.fduTablaValores(@codoficina))--('3','4','5','6','7','8','9','10','11','12','19')
and fecha=@fecha
and tipotransacnivel1<>'E' and extornado=0
group by codoficina
) pr on pr.codoficina=t.codoficina

update #dtmp
set nrodesembolsado=pr.nro,desembolsado=pr.monto
from #dtmp t inner join (
  SELECT codoficina,count(distinct codprestamo) nro, sum(monto) monto
  FROM tcspadroncarteradet with(nolock)
  where codoficina in (select codigo from dbo.fduTablaValores(@codoficina))--('3','4','5','6','7','8','9','10','11','12','19')
  and desembolso=@fecha
  group by codoficina
) pr on pr.codoficina=t.codoficina

update #dtmp 
set moravencida= case when saldocartera=0 then 0 else (saldovencido/saldocartera)*100 end

select * 
from #dtmp 

drop table #dtmp
GO