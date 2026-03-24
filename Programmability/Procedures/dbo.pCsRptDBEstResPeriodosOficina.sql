SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE procedure [dbo].[pCsRptDBEstResPeriodosOficina] @codoficina varchar(4),@periodofin varchar(6)
as
--declare @codoficina varchar(4)
--declare @periodofin varchar(6)

--set @codoficina='4'
--set @periodofin='201304'

declare @periodoini varchar(6)
--set @periodoini='201301'
select @periodoini=cast(año as char(4))+'01' from tclperiodo where periodo=@periodofin

declare @primerdia smalldatetime
declare @ultimodia smalldatetime

select @primerdia=cast(año as char(4))+'0101' from tclperiodo where periodo=@periodofin
select @ultimodia=ultimodia from tclperiodo where periodo=@periodofin

declare @primerdiaant smalldatetime
declare @ultimodiaant smalldatetime
set @ultimodiaant=dateadd(year,-1,@ultimodia)
set @primerdiaant=cast(year(@ultimodiaant) as varchar(4)) + replicate('0',2-len(cast(month(@ultimodiaant) as varchar(2)))) + cast(month(@ultimodiaant) as varchar(2)) + '01'
--print '@ultimodiaant:' 
--print @ultimodiaant
--print '@@primerdiaant:' 
--print @primerdiaant

declare @nm int
set @nm=cast(substring(@periodofin,5,2) as int)

create table #f(fechas smalldatetime)

insert  #f
select ultimodia from tclperiodo where periodo>=@periodoini and periodo<=@periodofin
union select @ultimodiaant ultimodia

create table #datos(
  periodo varchar(6),
  codoficina varchar(4),
  sucursal varchar(200),
  gerente varchar(200),
  fecingreso smalldatetime, --esta es general es decir en finamigo
  tiempocargo int default(0), --valor no se tiene actualmente
  iniciooperacion smalldatetime, --de la agencia
  mesesoperando int default(0), --de la agencia
  nrocreditostotal int default(0), --historico?
  nrocreditosactivo int default(0),
  porparticipacion decimal(3,2) default(0),
  poreficiencia decimal(16,2) default(0), --falta definir bien
  mntocreditototal decimal(16,2) default(0), --historico?
  mntocreditoprom decimal(16,2) default(0),
  mntocobrado decimal(16,2) default(0),
  castigos int default(0),
  mesesequi int default(0), --falta definir bien
  mora30d decimal(3,2) default(0),
  mora1dia decimal(3,2) default(0),
  saldocap decimal(16,2) default(0),
	nroasesores int default(0)
)

insert into #datos (periodo, codoficina, sucursal,iniciooperacion,gerente,fecingreso)
--select p.periodo,o.codoficina,o.nomoficina,o.fechaapertura
--,e.nombres +' '+ e.paterno +' '+ e.materno Gerente,e.ingreso
--from tcloficinas o with(nolock) 
--inner join tcsempleados e with(nolock) on e.codoficinanom=o.codoficina
--and e.estado=1 and e.codpuesto=41
--cross join (select periodo from tclperiodo where periodo>=@periodoini and periodo<=@periodofin) p
--where o.codoficina=@codoficina
select p.periodo,o.codoficina,replicate('0',2-len(cast(o.codoficina as int))) + o.codoficina + ' - ' +  rtrim(o.nomoficina) nomoficina,o.fechaapertura
,e.nombres +' '+ e.paterno +' '+ e.materno Gerente,e.ingreso
from tcloficinas o with(nolock) 
inner join tcsempleados e with(nolock) on e.codoficinanom=o.codoficina
and e.estado=1 and e.codpuesto=41
cross join (
            select dbo.fduFechaAPeriodo(fechas) periodo from #f
            --select periodo from tclperiodo where periodo>=@periodoini and periodo<=@periodofin 
            --union select dbo.fduFechaAPeriodo(@ultimodiaant) periodo
            ) p
where o.codoficina=@codoficina

--montos de colocacion
update #datos
set nrocreditosactivo=a.nro,mntocreditoprom=a.promedio,mora30d=a.mo30d,mora1dia=a.mo0d,porparticipacion=a.xparticipa,saldocap=a.saldok
from #datos d
inner join (
select dbo.fduFechaAPeriodo(c.fecha) periodo,c.nro,c.promedio,c.mo30d,c.mo0d,cast(c.nro as decimal(16,2))/cast(gl.nroglobal as decimal(16,2)) * 100 xparticipa,saldok
from (
select cd.fecha,count(distinct cd.codprestamo) nro,avg(cd.montodesembolso) promedio
,sum(cd.saldocapital) saldok
,sum(case when ca.nrodiasatraso>30 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end)
/sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) * 100 mo30d
,sum(case when ca.nrodiasatraso>0 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) 
/sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) * 100 mo0d
from tcscarteradet cd with(nolock)
inner join tcscartera ca with(nolock) on ca.fecha=cd.fecha and ca.codprestamo=cd.codprestamo
where cd.fecha in (
                  --select ultimodia from tclperiodo where periodo>=@periodoini and periodo<=@periodofin
                  --union select @ultimodiaant ultimodia
                  select fechas from #f
                  )
and ca.cartera='ACTIVA'
and cd.codoficina=@codoficina
group by cd.fecha
) c inner join(
  --para averiguar el porcentaje de participacion y % eficiencia
  select fecha, count(distinct codprestamo) nroglobal, sum(montodesembolso) montoglobal
  from tcscarteradet with(nolock)
  where fecha in (select fechas from #f
                  --select ultimodia from tclperiodo where periodo>=@periodoini and periodo<=@periodofin
                  --union select @ultimodiaant ultimodia
                  )
  group by fecha
)gl on gl.fecha=c.fecha
) a on a.periodo=d.periodo

--nrosesores
update #datos
set nroasesores=a.nro
from #datos d
inner join (
select dbo.fduFechaAPeriodo(fecha) periodo, count(distinct codasesor) nro--, c.nombrecompleto
from tcscartera with(nolock)
--inner join tcspadronclientes c on c.codusuario=tcscartera.codasesor
where cartera='ACTIVA' and codoficina=@codoficina
and fecha in(--'20130731','20130630'
  select fechas from #f
)
and codasesor not in (select codusuario from tcsempleados where codpuesto in (26,15,50,41,17))
group by dbo.fduFechaAPeriodo(fecha)
) a on a.periodo=d.periodo

--castigos
update #datos
set castigos=a.saldok
from #datos d
inner join (
select dbo.fduFechaAPeriodo(p.pasecastigado) periodo,count(p.codprestamo) nro,sum(saldocapital) saldok
from tcspadroncarteradet p with(nolock)
inner join tcscartera ca with(nolock) on ca.fecha=dateadd(day,-1,p.pasecastigado) and ca.codprestamo=p.codprestamo
where (p.pasecastigado>=@primerdia and p.pasecastigado<=@ultimodia)
and p.codoficina=@codoficina
group by dbo.fduFechaAPeriodo(p.pasecastigado)
) a on a.periodo=d.periodo

update #datos
set castigos=a.saldok
from #datos d
inner join (
select dbo.fduFechaAPeriodo(p.pasecastigado) periodo,count(p.codprestamo) nro,sum(saldocapital) saldok
from tcspadroncarteradet p with(nolock)
inner join tcscartera ca with(nolock) on ca.fecha=dateadd(day,-1,p.pasecastigado) and ca.codprestamo=p.codprestamo
where (p.pasecastigado>=@primerdiaant and p.pasecastigado<=@ultimodiaant)
and p.codoficina=@codoficina
group by dbo.fduFechaAPeriodo(p.pasecastigado)
) a on a.periodo=d.periodo

--cobrado
update #datos
set mntocobrado=a.monto
from #datos d
inner join (
select dbo.fduFechaAPeriodo(t.fecha) periodo, sum(montocapitaltran) monto
from tcstransacciondiaria t with(nolock)
inner join tcscartera ca with(nolock) on ca.fecha=dateadd(day,-1,t.fecha) and ca.codprestamo=t.codigocuenta
where t.fecha>=@primerdia and t.fecha<=@ultimodia
and t.codsistema='CA' and t.tipotransacnivel1='I'
and t.extornado=0 and t.codoficina=@codoficina
and t.tipotransacnivel3 in (104,105)
and ca.cartera='ACTIVA'
group by dbo.fduFechaAPeriodo(t.fecha)
) a on a.periodo=d.periodo

update #datos
set mntocobrado=a.monto
from #datos d
inner join (
select dbo.fduFechaAPeriodo(t.fecha) periodo, sum(montocapitaltran) monto
from tcstransacciondiaria t with(nolock)
inner join tcscartera ca with(nolock) on ca.fecha=dateadd(day,-1,t.fecha) and ca.codprestamo=t.codigocuenta
where t.fecha>=@primerdiaant and t.fecha<=@ultimodiaant
and t.codsistema='CA' and t.tipotransacnivel1='I'
and t.extornado=0 and t.codoficina=@codoficina
and t.tipotransacnivel3 in (104,105)
and ca.cartera='ACTIVA'
group by dbo.fduFechaAPeriodo(t.fecha)
) a on a.periodo=d.periodo

--desembolsados o montos totales historicos
update #datos
set nrocreditostotal=a.nro,mntocreditototal=a.monto
from #datos d
inner join (
select dbo.fduFechaAPeriodo(desembolso) periodo,count(codprestamo) nro,sum(monto) monto
from tcspadroncarteradet with(nolock)
where desembolso>=@primerdia and desembolso<=@ultimodia
and codoficina=@codoficina
group by dbo.fduFechaAPeriodo(desembolso)
) a on a.periodo=d.periodo

update #datos
set nrocreditostotal=a.nro,mntocreditototal=a.monto
from #datos d
inner join (
select dbo.fduFechaAPeriodo(desembolso) periodo,count(codprestamo) nro,sum(monto) monto
from tcspadroncarteradet with(nolock)
where desembolso>=@primerdiaant and desembolso<=@ultimodiaant
and codoficina=@codoficina
group by dbo.fduFechaAPeriodo(desembolso)
) a on a.periodo=d.periodo


update #datos
set poreficiencia=case when saldocap=0 then 0 else (mntocobrado/saldocap) * 100 end,mesesoperando=datediff(month,iniciooperacion,p.ultimodia)
from #datos d
left outer join tclperiodo p on p.periodo collate Modern_Spanish_CI_AS=d.periodo

create table #er(
  periodo varchar(6),
  Codoficina varchar(4),
  C51	decimal(16,2) default(0),
  C52	decimal(16,2) default(0),-- no usado
  C53	decimal(16,2) default(0),-- no usado
  C54	decimal(16,2) default(0),
  C55	decimal(16,2) default(0),
  C57	decimal(16,2) default(0),
  C58	decimal(16,2) default(0),
  C61	decimal(16,2) default(0),-- no usado
  C62	decimal(16,2) default(0),-- no usado
  C65	decimal(16,2) default(0),
  C66	decimal(16,2) default(0),
  C51_C52	decimal(16,2) default(0),
  C61_C62	decimal(16,2) default(0),
  MargenFinanciero	decimal(16,2) default(0),
  MargenFinanAjustado	decimal(16,2) default(0),
  ResultadoIntermedia	decimal(16,2) default(0),
  EgreIngreTotaOpe	decimal(16,2) default(0),
  ResultadoOperacion	decimal(16,2) default(0),
  Gastos	decimal(16,2) default(0),
  ResultadoAntes	decimal(16,2) default(0),
  Agrupa	varchar(10), -- no usado
  Cero	char(1), -- no usado
  ColMes char(3) -- no usado
)

--periodo del año anterior
declare @pdtmp smalldatetime
set @pdtmp=cast(year(@ultimodiaant) as varchar(4))+'0101'

insert into #er 
(Codoficina,C51,C52,C53,C54,C55,C57,C58,C61,C62,C65,C66,C51_C52,C61_C62,MargenFinanciero,MargenFinanAjustado,ResultadoIntermedia,EgreIngreTotaOpe,ResultadoOperacion,Gastos,ResultadoAntes,Agrupa,Cero,ColMes)
exec pCsCtaEstadoResultadoMes @pdtmp,@ultimodiaant,1,@codoficina,0

update #er
set periodo=dbo.fduFechaAPeriodo(@ultimodiaant)
where periodo is null

--inicia bucle
declare @udtmp smalldatetime
declare @ptmp varchar(6)
select @udtmp=ultimodia from tclperiodo where periodo=@periodofin
set @ptmp=@periodofin

while (@nm<>0)
  begin
    --print @primerdia
    --print @udtmp
    
    insert into #er 
    (Codoficina,C51,C52,C53,C54,C55,C57,C58,C61,C62,C65,C66,C51_C52,C61_C62,MargenFinanciero,MargenFinanAjustado,ResultadoIntermedia,EgreIngreTotaOpe,ResultadoOperacion,Gastos,ResultadoAntes,Agrupa,Cero,ColMes)
    exec pCsCtaEstadoResultadoMes @primerdia,@udtmp,1,@codoficina,0

    update #er
    set periodo=@ptmp
    where periodo is null
    
    set @nm=@nm-1
    select @udtmp=ultimodia from tclperiodo where periodo=substring(@periodofin,1,4)+replicate('0',2-len(cast(@nm as varchar(2))))+cast(@nm as varchar(2))
    set @ptmp=substring(@periodofin,1,4)+replicate('0',2-len(cast(@nm as varchar(2))))+cast(@nm as varchar(2))--@periodofin
    --print @udtmp
    --print @ptmp
  end
  
select d.periodo,d.codoficina,d.sucursal,d.gerente,d.fecingreso,d.tiempocargo,d.iniciooperacion,d.mesesoperando,d.nrocreditostotal,d.nrocreditosactivo
,d.porparticipacion,d.poreficiencia,d.mntocreditototal,d.mntocreditoprom,d.mntocobrado,d.castigos,d.mesesequi,d.mora30d,d.mora1dia,d.saldocap,d.nroasesores
,e.C51,e.C52,e.C53,e.C54,e.C55,e.C57,e.C58,e.C61,e.C62,e.C65,e.C66,e.C51_C52,e.C61_C62,e.MargenFinanciero,e.MargenFinanAjustado,e.ResultadoIntermedia
,e.EgreIngreTotaOpe,e.ResultadoOperacion,e.Gastos,e.ResultadoAntes,e.Agrupa,e.Cero,e.ColMes
from #datos d
left outer join #er e on e.periodo=d.periodo

drop table #f
drop table #er
drop table #datos
GO