SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsPagos] 
as

--sp_helptext 
--exec [pCsPagos]

set nocount on
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion
--set @fecha='20191231'

declare @fecini smalldatetime
--set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
set @fecini='20190101'

CREATE TABLE #tCaProgra(
	fecha smalldatetime,
	[region] [varchar](50) NULL,
	[sucursal] [varchar](30) NULL,
	[Atraso] [varchar] (30) NULL,
	--[codasesor] [varchar](15) NULL,
	[fechavencimiento] [smalldatetime] NOT NULL,
	[nro] [int] NULL,
	[Programado] [money] NULL,
	[Pagado] [money] NULL,
	[Condonado] [money] NULL,
	[saldo] [money] NULL,
	[NoPagosAdelantado] [int] NULL,
	[NoPagosPuntual] [int] NULL,
	[NoPagosAtrasado] [int] NULL,
	[PagoParcialAtrasado] [int] NULL,
	[PagoParcialAdelantado] [int] NULL,
	[PagoParcial] [int] NULL
) ON [PRIMARY]

declare @fechas table(i int identity,primerdia smalldatetime,ultimodia smalldatetime)
insert into @fechas
select primerdia,ultimodia 
from tclperiodo with(nolock) where primerdia>=@fecini and ultimodia<=@fecha
union
select dbo.fdufechaaperiodo(@fecha)+'01' primerdia, @fecha ultimodia


declare @i int
declare @n int
set @i=0
select @n=count(*) from @fechas

create table #ptmos (codprestamo varchar(25)
--,codasesor varchar(15)
,codoficina varchar(4))

declare @fini smalldatetime
declare @ffin smalldatetime

while (@i<@n+1)
begin
		select @fini=primerdia,@ffin=ultimodia from @fechas where i=@i
		truncate table #ptmos

		insert into #ptmos
		select distinct codprestamo
		--,codasesor
		,codoficina
		from tcscartera with(nolock)
		where fecha=@ffin 
		and cartera='ACTIVA' and codoficina not in('97','230','231') --and nrodiasatraso=0
		and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
		--and codoficina=@codoficina
		union
		select codprestamo
		--,ultimoasesor
		,codoficina
		from tcspadroncarteradet with(nolock)
		where cancelacion>=@fini and cancelacion<=@ffin
		union
		select codprestamo
		--,ultimoasesor
		,codoficina
		from tcspadroncarteradet with(nolock)
		where pasecastigado>=@fini and pasecastigado<=@ffin

		select c.codoficina,car.nrodiasatraso
		,p.codprestamo,p.seccuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado,sum(p.montocondonado) montocondonado
		,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota
		into #Pogra
		from tcspadronplancuotas p with(nolock)
		inner join #ptmos c on c.codprestamo=p.codprestamo
		inner join tcscartera car on p.codprestamo = car.codprestamo and p.fechavencimiento=car.fecha
		where p.codprestamo in(select codprestamo from #ptmos)
		and p.fechavencimiento>=@fini and p.fechavencimiento<=@ffin --and car.nrodiasatraso<15
		group by c.codoficina
		,car.nrodiasatraso
		,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota

		insert into #tCaProgra
		select @ffin,z.nombre region,o.nomoficina sucursal
		--,cl.nombrecompleto Promotor
		,case when p.nrodiasatraso>= 31 then 'e.31+'
		      when p.nrodiasatraso>= 16 then 'd.16-30'
		      when p.nrodiasatraso >= 8 then 'c.8-15'
		      when p.nrodiasatraso >= 1 then 'b.1-7'
		      when p.nrodiasatraso = 0 then 'a.0'
		      else '?' end atraso
		,p.fechavencimiento,count(p.codprestamo) nro,sum(p.montodevengado) Programado,sum(p.montopagado) Pagado,sum(p.montocondonado) Condonado
		,sum(p.montodevengado) - sum(p.montopagado) - sum(p.montocondonado) saldo
		,count(case when p.estadocuota='CANCELADO' and p.fechapago<p.fechavencimiento then p.codprestamo else null end) NoPagosAdelantado
		,count(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.codprestamo else null end) NoPagosPuntual
		,count(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.codprestamo else null end) NoPagosAtrasado
		,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago>p.fechavencimiento then p.codprestamo else null end) PagoParcialAtrasado
		,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago<p.fechavencimiento then p.codprestamo else null end) PagoParcialAdelantado
		,count(case when p.estadocuota<>'CANCELADO' and p.fechapago is not null and p.fechapago=p.fechavencimiento then p.codprestamo else null end) PagoParcial
		from #Pogra p
		--inner join tcspadronclientes cl with(nolock) on p.codasesor=cl.codusuario
		inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona
		group by z.nombre,o.nomoficina,case when p.nrodiasatraso>= 31 then 'e.31+'
		      when p.nrodiasatraso>= 16 then 'd.16-30'
		      when p.nrodiasatraso >= 8 then 'c.8-15'
		      when p.nrodiasatraso >= 1 then 'b.1-7'
		      when p.nrodiasatraso = 0 then 'a.0'
		      else '?' end 
		--,p.codasesor
		,p.fechavencimiento--,cl.nombrecompleto

		drop table #Pogra

		set @i=@i+1
end

select region,sucursal
--,promotor
,fechavencimiento,atraso
,nro, nopagosadelantado,nopagospuntual,nopagosatrasado,pagoparcialatrasado
,pagoparcialadelantado, pagoparcial
,(select primerdia from tclperiodo with(nolock) where primerdia<=fechavencimiento and ultimodia>=fechavencimiento) Cosecha
,(nopagosadelantado+nopagospuntual+nopagosatrasado) TotalPagos
,(nro-nopagosadelantado-nopagospuntual-nopagosatrasado-pagoparcialatrasado-pagoparcialadelantado-pagoparcial) PagosFaltantes
 from #tCaProgra
 

drop table #ptmos
drop table #tCaProgra
GO