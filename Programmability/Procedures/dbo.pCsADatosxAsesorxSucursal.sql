SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsADatosxAsesorxSucursal]  @fecha smalldatetime, @codoficina as varchar(4)
AS
BEGIN
	SET NOCOUNT ON;

--declare @codoficina as varchar(4)
--declare @fecha smalldatetime

--set @codoficina='10'
--set @fecha='20130407'

create table ##dtmp(
  codasesor varchar(15),
  nombreasesor varchar(250),
  nroclientes int default(0),
  nroprestamos int default(0),
  saldocartera decimal(16,2) default(0),
  saldoatrasado decimal(16,2) default(0),
  saldovencido decimal(16,2) default(0),
  nroprogramado int default(0),
  programado decimal(16,2) default(0),
  nrorecuperado int default(0),
  recuperado decimal(16,2) default(0),
  condonado decimal(16,2) default(0)
)

insert ##dtmp (codasesor,nombreasesor,nroclientes,nroprestamos,saldocartera,saldoatrasado,saldovencido)
SELECT codasesor,asesor, count(distinct codusuario) nroclientes, count(distinct codprestamo) nroprestamos
,sum(saldocartera) saldocartera,sum(saldoatrasado) saldoatrasado,sum(saldovencido) saldovencido
from (

SELECT a.codusuario codasesor,a.nombrecompleto asesor, cd.codusuario, c.codprestamo
,cd.saldocapital  + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido saldocartera
,case when c.estado='VENCIDO'
    then 
    --case when c.tiporeprog not in ('SINRE','REFRE') then
      cd.saldocapital  + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido 
    --else 0 end 
  else 0 end saldovencido
,case when c.tiporeprog in ('SINRE','REFRE') then
  case when c.nrodiasatraso>0 and c.nrodiasatraso<90 
  then cd.saldocapital  + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido else 0 end 
 else 0 end saldoatrasado
FROM tCsCarteraDet cd with(nolock) inner join
tCscartera c with(nolock) on cd.fecha=c.fecha and cd.codprestamo=c.codprestamo
inner join tcspadronclientes a on a.codusuario=c.codasesor
where c.codoficina=@codoficina
and c.fecha=@fecha
and c.cartera='ACTIVA' 

) b
group by codasesor,asesor

update ##dtmp
set programado=pr.monto,nroprogramado=pr.nro
from ##dtmp t inner join (
select c.codasesor,count(distinct p.codprestamo) nro
,sum(p.montodevengado-p.montopagado-p.montocondonado) monto
from tCsPlanCuotas p with(nolock) inner join tcscartera c with(nolock) on c.codprestamo=p.codprestamo and c.fecha=p.fecha
where p.fecha=(@fecha-1)
and p.estadoconcepto<>'CANCELADO'
and p.fechavencimiento=@fecha
and p.codoficina=@codoficina
group by c.codasesor) pr on pr.codasesor=t.codasesor

update ##dtmp
set nrorecuperado=pr.nro,recuperado=pr.recuperaciones,condonado=pr.condonaciones
from ##dtmp t inner join (
SELECT codasesor,count(distinct codigocuenta) nro, sum(case when tipotransacnivel3<>2 then montototaltran else 0 end) Recuperaciones
, sum(case when tipotransacnivel3=2 then montototaltran else 0 end) Condonaciones
FROM tCsTransaccionDiaria t with(nolock)
where codsistema='CA'
and codoficina=@codoficina
and fecha=@fecha
and tipotransacnivel1<>'E' and extornado=0
group by codasesor) pr on pr.codasesor=t.codasesor

declare @s varchar(200)
set @s='select * '
set @s=@s+'from ##dtmp  '
exec(@s)
drop table ##dtmp


END
GO