SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCARptProgresemosCarteraLiq]
as
declare @fecha smalldatetime
declare @fecini smalldatetime
--set @fecha='20190131'
select @fecha=fechaconsolidacion from vcsfechaconsolidacion
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'

SELECT @fecha fecha,o.nomoficina sucursal,c.codprestamo
,cl.nombrecompleto nombrecliente
,dbo.fduFechaATexto(c.fechadesembolso,'DD/MM/')+cast(year(c.fechadesembolso) as varchar(4)) 'FechaOtorgamiento'
,dbo.fduFechaATexto(c.fechavencimiento,'DD/MM/')+cast(year(c.fechavencimiento) as varchar(4)) 'FechaVencimiento'
,pcd.estadocalculado estadocredito
,pcd.cancelacion 'FechaLiquidacion'
,c.tiporeprog
FROM tcspadroncarteradet pcd with(nolock) 
inner join tCsCarteradet d with(nolock) on pcd.fechacorte=d.fecha and pcd.codprestamo=d.codprestamo
inner join tCsCartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fecha
left outer join tcspadronclientes cl with(nolock) on cl.codusuario=d.codusuario
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
left outer join tCaClModalidadPlazo m with(nolock) on m.ModalidadPlazo=c.ModalidadPlazo
where pcd.cancelacion>=@fecini and pcd.cancelacion<=@fecha
and c.codfondo=20
GO

GRANT EXECUTE ON [dbo].[pCsCARptProgresemosCarteraLiq] TO [jmartinezc]
GO

GRANT EXECUTE ON [dbo].[pCsCARptProgresemosCarteraLiq] TO [jarriagaa]
GO