SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCARptProgresemosCartera]
as
declare @fecha smalldatetime
--set @fecha='20190131'
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo from tcscartera with(nolock)
where fecha=@fecha --and cartera='ACTIVA' 
and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from tCsCarteraAlta)
and codfondo=20

SELECT c.fecha,o.nomoficina sucursal,c.codprestamo
,cl.nombrecompleto nombrecliente,dbo.fduFechaATexto(c.fechadesembolso,'DD/MM/')+cast(year(c.fechadesembolso) as varchar(4)) 'FechaOtorgamiento'
,d.montodesembolso 'MontoDesembolsoTotal',c.estado estadocredito,c.nrodiasatraso,d.saldocapital capitaltotal
,d.interesvigente+d.interesvencido+d.interesctaorden interestotal
,case when c.codfondo=20 then (d.saldocapital)*0.7 else 0 end capitalprogresemos
,case when c.codfondo=20 then (d.interesvigente+d.interesvencido+d.interesctaorden)*0.7 else 0 end interesprogresemos
,c.tasaintcorriente 'TasaIntCorriente'
,m.Descripcion 'Frecuencia'
,c.tiporeprog
FROM tCsCartera c with(nolock)
inner join tCsCarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcspadroncarteradet pcd with(nolock) on pcd.codprestamo=d.codprestamo and pcd.codusuario=d.codusuario
left outer join tcspadronclientes cl with(nolock) on cl.codusuario=d.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
left outer join tCaClModalidadPlazo m with(nolock) on m.ModalidadPlazo=c.ModalidadPlazo
where c.fecha=@fecha and c.codprestamo in(select codprestamo from #ptmos)

drop table #ptmos
GO

GRANT EXECUTE ON [dbo].[pCsCARptProgresemosCartera] TO [jmartinezc]
GO

GRANT EXECUTE ON [dbo].[pCsCARptProgresemosCartera] TO [jarriagaa]
GO