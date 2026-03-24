SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRIECartera] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20160831'

create table #tca(
	codprestamo varchar(25),
	prestamoid varchar(25),
	codserviciop varchar(25)
)
insert into #tca (codprestamo,prestamoid,codserviciop)
select codprestamo,codanterior,codserviciop from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100

create table #anu(codprestamo varchar(25))
insert into #anu
select codprestamo from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100 and estado='ANULADO'

--29,236
SELECT c.codprestamo,d.codusuario,c.codfondo,c.estado
,case when c.codfondo=20 
then (d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido)*0.3
else d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido end saldocartera
,c.nrodiasatraso
,d.saldocapital,d.interesvigente,d.interesvencido,d.moratoriovigente,d.moratoriovencido
,d.interesctaorden,d.moratorioctaorden,d.otroscargos,d.impuestos,d.cargomora
,fup.fechaultpago,mup.MontoultPago,c.fechavencimiento,mprog.montocuota,pd.secuenciacliente
,c.nrocuotas,c.nrocuotaspagadas
FROM tCsCartera c with(nolock) 
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=d.codprestamo and pd.codusuario=d.codusuario
left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto) 
left outer join (
	select codprestamo,codusuario,max(fechapagoconcepto) fechaultpago
	from tcspadronplancuotas with(nolock)
	where --codconcepto='CAPI' --and codprestamo='084-123-06-06-00055'
	--and 
	fechapagoconcepto is not null
	group by codprestamo,codusuario
) fup on fup.codprestamo=d.codprestamo and fup.codusuario=d.codusuario
left outer join (
	select codprestamo,codusuario,fechapagoconcepto,sum(montopagado) MontoultPago
	from tcspadronplancuotas with(nolock)
	--where codconcepto='CAPI' --and codprestamo='084-123-06-06-00055'
	group by codprestamo,codusuario,fechapagoconcepto
) mup on mup.codprestamo=d.codprestamo and mup.codusuario=d.codusuario and mup.fechapagoconcepto=fup.fechaultpago
left outer join (
	select codprestamo,codusuario,sum(montocuota) montocuota
	from tcspadronplancuotas with(nolock)
	where seccuota=1
	group by codprestamo,codusuario
) mprog on mprog.codprestamo=d.codprestamo and mprog.codusuario=d.codusuario

where c.fecha=@fecha and c.codoficina<>'97'--c.cartera='ACTIVA' and 
and c.codprestamo not in (select codprestamo from #anu)
and c.codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))



drop table #tca
drop table #anu
GO