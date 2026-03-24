SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRptTasasIngresosAHCA] @fecha smalldatetime
as 
--declare @fecha smalldatetime
--set @fecha='20150506'

declare @primerdia smalldatetime
select @primerdia=primerdia from tclperiodo where primerdia<=@fecha and ultimodia>=@fecha

declare @tppasiva decimal(8,2)
declare @tppasivavis decimal(8,2)
declare @tppasivadpf decimal(8,2)

select @tppasiva=avg(tasainteres)
,@tppasivavis=avg(case when substring(codcuenta,5,1)='1' then tasainteres else null end)
,@tppasivadpf=avg(case when substring(codcuenta,5,1)='2' then tasainteres else null end)
from tcsahorros where fecha=@fecha

create table #catmp(
  producto varchar(200),
  saldocartera decimal(16,2),
  interesdevengadomes decimal(16,2),
  tasapromedioactiva decimal(8,2),
  tasapromediopasiva as tasapvis + tasapdpf,
  margenbruto decimal(8,2),
  plazopromedio int,
  desembolsopromcli decimal(16,2),
  saldodesembolso decimal(16,2),
  estimaciones decimal(16,2),
  tasapvis decimal(8,2),
  tasapdpf decimal(8,2),
  tasapanuevos decimal(8,2),
  tasaparepre decimal(8,2),
  saldovencido decimal(16,2),
  mora90 as cast(saldovencido/saldocartera*100 as decimal(8,2)),
  plazoprommensual decimal(8,2),
  plazopromdiario decimal(8,2)
)

insert into #catmp
SELECT case when ca.codproducto in('163','302') then 'Convenio amigo' when ca.codproducto in('164','156') then 'Grupo Amigo / Solidario' else pc.Nombreprod end producto
,sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocartera
,0 intdev
,avg(ca.tasaintcorriente) tasapromedioactiva, 0 pasiva
,avg(ca.nrocuotas) plazopromedio
,avg(cd.montodesembolso) desembolsoclientepromedio
,sum(cd.montodesembolso) saldodesembolsado
,sum(cd.sreservacapital+cd.sreservainteres) estimaciones
,0 tasavis,0 tasadpf
,isnull(avg(case when cd.secuenciacliente=1 then ca.tasaintcorriente else null end),0) tasapromedioactivanuevo
,isnull(avg(case when cd.secuenciacliente<>1 then ca.tasaintcorriente else null end),0) tasapromedioactivarepre
,sum(case when ca.estado='VENCIDO' then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) saldovencido
,avg(cast(NroCuotas as decimal(5,2))*cast(NrodiasEntreCuotas as decimal(5,2))/30.00) plazoprommensual
,avg(NrodiasEntreCuotas) plazopromdiario
FROM tCsCartera ca with(nolock)
inner join tcscarteradet cd with(nolock) on ca.fecha=cd.fecha and ca.codprestamo=cd.codprestamo
left outer join tcspadroncarteraotroprod op on op.codprestamo=ca.codprestamo
inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,ca.codproducto)
where ca.fecha=@fecha and ca.codoficina<'97'
and ca.cartera='ACTIVA'
group by case when ca.codproducto in('163','302') then 'Convenio amigo' when ca.codproducto in('164','156') then 'Grupo Amigo / Solidario' else pc.Nombreprod end--pc.Nombreprod

update #catmp
set interesdevengadomes=DevengadoAcumulado
from #catmp a inner join (
  SELECT case when c.codproducto in('163','302') then 'Convenio amigo' when c.codproducto in('164','156') then 'Grupo Amigo / Solidario' else pc.Nombreprod end producto--pc.Nombreprod producto
  ,SUM(cd.InteresDevengado) AS DevengadoAcumulado
  FROM tCsCartera c with(nolock)  inner join tCsCarteraDet cd with(nolock) 
  on c.codprestamo=cd.codprestamo and c.fecha=cd.fecha
  left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
  inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)
  --WHERE (cd.Fecha>=@primerdia) AND (cd.Fecha<=@fecha)
  WHERE (cd.Fecha>=cast(year(@fecha) as varchar(4))+'0101') AND (cd.Fecha<=@fecha)
  and c.cartera='ACTIVA' and c.codoficina<'97'
  GROUP BY case when c.codproducto in('163','302') then 'Convenio amigo' when c.codproducto in('164','156') then 'Grupo Amigo / Solidario' else pc.Nombreprod end--pc.Nombreprod
) b on b.producto=a.producto

update #catmp
set tasapvis=@tppasivavis,tasapdpf=@tppasivadpf--tasapromediopasiva=@tppasiva,

update #catmp
set margenbruto=tasapromedioactiva-tasapromediopasiva

select * from #catmp

drop table #catmp
GO