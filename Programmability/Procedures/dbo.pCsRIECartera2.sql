SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRIECartera2] @fechas smalldatetime
as
set nocount on
declare @fecha smalldatetime
--set @fecha='20170320' --33,753
set @fecha=@fechas

create table #tbgl(
	codprestamo varchar(25),
	codusuario varchar(15),
	garantialiquida decimal(16,2)
)
insert into #tbgl
select ca.codprestamo,cd.codusuario--,'porcentaje'=case when ca.saldocapital=0 then 0 else (cd.SaldoCapital/ca.saldocapital) end
,(case when ca.saldocapital=0 then 0 else (cd.SaldoCapital/ca.saldocapital) end)*a.montogar garantialiquida--,a.montogar
FROM tCsCarteraDet cd INNER JOIN tCsCartera ca ON ca.CodPrestamo = cd.CodPrestamo AND ca.Fecha = cd.Fecha
inner join 
(	SELECT codigo codprestamo,sum(garantia) montogar FROM tCsDiaGarantias 
	where fecha=@fecha and TipoGarantia IN ('-A-', 'GADPF', 'GARAH') and estado not in('LIBERADO','') and len(codigo)>12
	group by codigo
) a on a.codprestamo=ca.codprestamo
WHERE (ca.Fecha=@fecha)

--create table #tca(
--	codprestamo varchar(25),
--	prestamoid varchar(25),
--	codserviciop varchar(25)
--)
--insert into #tca (codprestamo,prestamoid,codserviciop)
--select codprestamo,codanterior,codserviciop from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100


create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
from tcscartera with(nolock)
where fecha=@fecha
--and cartera='ACTIVA' and codoficina not in('97','230','231')
and codoficina not in('230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)

select c.codprestamo,d.codusuario,c.fecha,c.nrodiasatraso,d.saldocapital-d.capitalvencido capitalvigente,d.interesvigente
,d.capitalvencido,d.interesvencido,d.moratoriovigente,d.moratoriovencido
,c.codoficina sucursalid ,o.nomoficina nombresucursal,o.tipo 'Estatus Sucursal'
,es.estado,case when substring(c.codprestamo,5,1)='1' then 'Comercial' when substring(c.codprestamo,5,1)='3' then 'Consumo' else 'No definido' end TipoCredito
,pr.NombreProd NombreProducto,isnull(gl.garantialiquida,0) 'MontoGarLiquida',case when c.tiporeprog in('SINRE','REFRE','REPRO') then 'No' else 'Si' end Reestructura
,c.fechadesembolso,c.fechavencimiento,d.montodesembolso,'Pago periodico parcial de capital e intereses' 'ModalidadPago'
,c.nrocuotas,c.estado,'?' 'Saldo traspaso cartera vencida'
,z.nombre 'Region',case when pr.tecnologia=2 then 'Solidario' else 'Individual' end tecnologia,c.codgrupo,c.tasaintcorriente
,r.MontoGarLiq,r.SaldoCalificacion,r.ParteCubierta,r.ParteExpuesta,r.PorcParteCubierta,r.PorcParteExpuesta,r.EPRC_ParteCubierta,r.EPRC_ParteExpuesta,r.EPRC_InteresesVencidos,r.EPRC_TOTAL
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
left outer join tclubigeo co with(nolock) on co.codubigeo=o.codubigeo
--left outer join (select codarbolconta,descubigeo municipio from tclubigeo with(nolock) where codubigeotipo='MUNI') mu on mu.codarbolconta=substring(co.codarbolconta,1,19)
left outer join (select codarbolconta,descubigeo estado from tclubigeo with(nolock) where codubigeotipo='ESTA') es on es.codarbolconta=substring(co.codarbolconta,1,13)
inner join tcaproducto pr on pr.codproducto=c.codproducto
left outer join #tbgl gl on gl.codprestamo=c.codprestamo and gl.codusuario=d.codusuario
inner join tclzona z on z.zona=o.zona
left outer join tcscarterareserva r with(nolock) on r.fecha=d.fecha and r.codprestamo=d.codprestamo and r.codusuario=d.codusuario
where c.fecha=@fecha
--and c.codoficina>100
--and c.cartera='ACTIVA'
--and c.codprestamo not in (select codprestamo from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100 and estado='ANULADO')
--and c.codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))
--and c.cartera='ACTIVA'
and c.codprestamo in(select codprestamo from #ptmos)

drop table #tbgl
drop table #ptmos
GO

GRANT EXECUTE ON [dbo].[pCsRIECartera2] TO [jarriagaa]
GO