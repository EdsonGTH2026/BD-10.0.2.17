SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE procedure [dbo].[pCsRptCaCarteraxSucxPro_FinAmigoAlta] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20160303'

create table #cartera(
	fecha smalldatetime,
	tipo varchar(15),
	region varchar(50),
	sucursal varchar(200),
	producto varchar(200),
	nroclie int,
	nroptmo int,
	montodesembolso money,
	t_saldo money,
	D0nroclie int,
	D0nroptmo int,
	D0saldo  money,
	D0a7nroclie int,
	D0a7nroptmo int,
	D0a7saldo  money,
	D8a15nroclie int,
	D8a15nroptmo int,
	D8a15saldo  money,
	D16a30nroclie int,
	D16a30nroptmo int,
	D16a30saldo  money,
	D31a60nroclie int,
	D31a60nroptmo int,
	D31a60saldo  money,
	D61a89nroclie int,
	D61a89nroptmo int,
	D61a89saldo  money,
	Dm90nroclie int,
	Dm90nroptmo int,
	Dm90saldo  money,
	vigilancia int
)

insert into #cartera
select fecha,tipo,region,sucursal,producto,count(distinct codusuario) nroclie, count(distinct codprestamo) nroptmo
,sum(montodesembolso) montodesembolso
,sum(t_saldo) t_saldo
,count(distinct D0nroclie) D0nroclie,count(distinct D0nroptmo) D0nroptmo,sum(D0saldo) D0saldo
,count(distinct D0a7nroclie) D0a7nroclie,count(distinct D0a7nroptmo) D0a7nroptmo,sum(D0a7saldo) D0a7saldo
,count(distinct D8a15nroclie) D8a15nroclie,count(distinct D8a15nroptmo) D8a15nroptmo,sum(D8a15saldo) D8a15saldo
,count(distinct D16a30nroclie) D16a30nroclie,count(distinct D16a30nroptmo) D16a30nroptmo,sum(D16a30saldo) D16a30saldo
,count(distinct D31a60nroclie) D31a60nroclie,count(distinct D31a60nroptmo) D31a60nroptmo,sum(D31a60saldo) D31a60saldo
,count(distinct D61a89nroclie) D61a89nroclie,count(distinct D61a89nroptmo) D61a89nroptmo,sum(D61a89saldo) D61a89saldo
,count(distinct Dm90nroclie) Dm90nroclie,count(distinct Dm90nroptmo) Dm90nroptmo,sum(Dm90saldo) Dm90saldo
,vigilancia
from (
SELECT c.Fecha,case when o.tipo='Cerrada' then 'CERRADAS' ELSE 'ACTIVAS' END tipo
,replicate('0',3-len(isnull(ce.CodOficina,c.codoficina))) + rtrim(isnull(ce.CodOficina,c.codoficina)) + ' ' + o.nomoficina sucursal

,case when pc.codproducto='302' then '163' else pc.codproducto end codproducto
,case when pc.Nombreprod='Convenio amigo (C)' then 'Convenios' when pc.Nombreprod='Convenio amigo (P)' then 'Convenios' else pc.Nombreprod end producto

,cd.codusuario,c.CodPrestamo
,cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido t_saldo
,cd.montodesembolso
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso=0 then cd.codusuario else null end
 else null end D0nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso=0 then cd.codprestamo else null end
 else null end D0nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso=0
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end
 else 0 end D0saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>0 and c.NroDiasAtraso<8 then cd.codusuario else null end
 else null end D0a7nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>0 and c.NroDiasAtraso<8 then cd.codprestamo else null end
 else null end D0a7nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>0 and c.NroDiasAtraso<8
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end 
 else 0 end D0a7saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<16 then cd.codusuario else null end
 else null end D8a15nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<16 then cd.codprestamo else null end
 else null end D8a15nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<16
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end
 else 0 end D8a15saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<31 then cd.codusuario else null end
 else null end D16a30nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<31 then cd.codprestamo else null end
 else null end D16a30nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<31
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end
 else 0 end D16a30saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<61 then cd.codusuario else null end
 else null end D31a60nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<61 then cd.codprestamo else null end
 else null end D31a60nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<61
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end
 else 0 end D31a60saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90 then cd.codusuario else null end
 else null end D61a89nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90 then cd.codprestamo else null end
 else null end D61a89nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end 
 else 0 end D61a89saldo
,case when c.Estado='VENCIDO' then cd.codusuario else null end Dm90nroclie
,case when c.Estado='VENCIDO' then cd.codprestamo else null end Dm90nroptmo
,case when c.Estado='VENCIDO' then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end Dm90saldo
,z.nombre region
,case when isnull(ce.codoficina,c.codoficina) in ('28','11','31','18','7','15','12','19','32','35','24','17','3','36') then 1 else 0 end vigilancia
FROM tCsCartera c with(nolock)
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)
left outer join tcscarterasuce ce with(nolock) on c.codprestamo=ce.codprestamo
left outer join tcloficinas o with(nolock) on o.codoficina=isnull(ce.codoficina,c.codoficina)
left outer join tclzona z with(nolock) on z.zona=o.zona
where c.fecha=@fecha and c.cartera='ACTIVA' and c.codoficina<97
) a
group by fecha,tipo,sucursal,region,producto,vigilancia

declare @fechaAlta smalldatetime
select @fechaAlta=min(FechaUltCierre) from [10.0.2.14].finmas.dbo.tclparametros where codoficina>100

insert into #cartera
select fecha,tipo,region,sucursal,producto,count(distinct codusuario) nroclie, count(distinct codprestamo) nroptmo
,sum(montodesembolso) montodesembolso
,sum(t_saldo) t_saldo
,count(distinct D0nroclie) D0nroclie,count(distinct D0nroptmo) D0nroptmo,sum(D0saldo) D0saldo
,count(distinct D0a7nroclie) D0a7nroclie,count(distinct D0a7nroptmo) D0a7nroptmo,sum(D0a7saldo) D0a7saldo
,count(distinct D8a15nroclie) D8a15nroclie,count(distinct D8a15nroptmo) D8a15nroptmo,sum(D8a15saldo) D8a15saldo
,count(distinct D16a30nroclie) D16a30nroclie,count(distinct D16a30nroptmo) D16a30nroptmo,sum(D16a30saldo) D16a30saldo
,count(distinct D31a60nroclie) D31a60nroclie,count(distinct D31a60nroptmo) D31a60nroptmo,sum(D31a60saldo) D31a60saldo
,count(distinct D61a89nroclie) D61a89nroclie,count(distinct D61a89nroptmo) D61a89nroptmo,sum(D61a89saldo) D61a89saldo
,count(distinct Dm90nroclie) Dm90nroclie,count(distinct Dm90nroptmo) Dm90nroptmo,sum(Dm90saldo) Dm90saldo
,vigilancia
from (
SELECT c.Fecha,case when o.tipo='Cerrada' then 'CERRADAS' ELSE 'ACTIVAS' END tipo
,replicate('0',3-len(isnull(ce.CodOficina,c.codoficina))) + rtrim(isnull(ce.CodOficina,c.codoficina)) + ' ' + o.nomoficina sucursal

,case when pc.codproducto='302' then '163' else pc.codproducto end codproducto
,case when pc.Nombreprod='Convenio amigo (C)' then 'Convenios' when pc.Nombreprod='Convenio amigo (P)' then 'Convenios' else pc.Nombreprod end producto

,cd.codusuario,c.CodPrestamo
,cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido t_saldo
,cd.montodesembolso
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso=0 then cd.codusuario else null end
 else null end D0nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso=0 then cd.codprestamo else null end
 else null end D0nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso=0
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end
 else 0 end D0saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>0 and c.NroDiasAtraso<8 then cd.codusuario else null end
 else null end D0a7nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>0 and c.NroDiasAtraso<8 then cd.codprestamo else null end
 else null end D0a7nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>0 and c.NroDiasAtraso<8
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end 
 else 0 end D0a7saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<16 then cd.codusuario else null end
 else null end D8a15nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<16 then cd.codprestamo else null end
 else null end D8a15nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<16
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end
 else 0 end D8a15saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<31 then cd.codusuario else null end
 else null end D16a30nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<31 then cd.codprestamo else null end
 else null end D16a30nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<31
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end
 else 0 end D16a30saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<61 then cd.codusuario else null end
 else null end D31a60nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<61 then cd.codprestamo else null end
 else null end D31a60nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<61
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end
 else 0 end D31a60saldo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90 then cd.codusuario else null end
 else null end D61a89nroclie
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90 then cd.codprestamo else null end
 else null end D61a89nroptmo
,case when c.Estado<>'VENCIDO' then
  case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90
  then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end 
 else 0 end D61a89saldo
,case when c.Estado='VENCIDO' then cd.codusuario else null end Dm90nroclie
,case when c.Estado='VENCIDO' then cd.codprestamo else null end Dm90nroptmo
,case when c.Estado='VENCIDO' then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
  else 0 end Dm90saldo
,z.nombre region
,case when isnull(ce.codoficina,c.codoficina) in ('28','11','31','18','7','15','12','19','32','35','24','17','3','36') then 1 else 0 end vigilancia
FROM tCsCartera c with(nolock)
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)
left outer join tcscarterasuce ce with(nolock) on c.codprestamo=ce.codprestamo
left outer join tcloficinas o with(nolock) on o.codoficina=isnull(ce.codoficina,c.codoficina)
left outer join tclzona z with(nolock) on z.zona=o.zona
where c.fecha=@fechaalta and c.cartera='ACTIVA' and c.codoficina>100
) a
group by fecha,tipo,sucursal,region,producto,vigilancia

select * from #cartera

drop table #cartera
GO