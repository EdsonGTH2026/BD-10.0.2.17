SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsMtsGridInfoConcen
CREATE procedure [dbo].[pCsMtsGridInfoConcen] @fecha smalldatetime,@codoficina varchar(4),@t int
as
--declare @fecha smalldatetime
--declare @codoficina varchar(4)
--declare @t int

--set @fecha='20150526'
--set @codoficina='4'
--set @t=1
--1:13seg | 2:1seg | 3:1seg
declare @fec1 smalldatetime
declare @fec2 smalldatetime

set @fec1=cast(dbo.fdufechaaperiodo(dateadd(month,1,@fecha)) + '01' as smalldatetime)
set @fec2=dateadd(day,-1,cast(dbo.fdufechaaperiodo(dateadd(month,2,@fecha)) + '01' as smalldatetime))

create table #cxpxp(
	codasesor varchar(25),
	codproducto varchar(5),
	Np int,
	Nc int,
	NcM60 int,
	SaldoCapital decimal(16,2),
	SaldoCartera decimal(16,2),
	SaldoCarteraM60 decimal(16,2),
	SaldoTotalCartera decimal(16,2),
	Concentracion as cast((SaldoCartera/SaldoTotalCartera) * 100 as decimal(16,2)),
	Pago decimal(16,2) default(0)
)

insert into #cxpxp (codasesor,codproducto,Np,Nc,NcM60,SaldoCapital,SaldoCartera,SaldoCarteraM60)
SELECT c.codasesor,isnull(op.codproducto,c.codproducto) codproducto,count(distinct c.codprestamo) Np
,count(distinct d.codusuario) Nc
,count(distinct case when c.nrodiasatraso>60 then d.codusuario else null end) NcM60
,sum(d.saldocapital) saldocapital
,sum(d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido) saldocartera
,sum(case when c.nrodiasatraso>0 then d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido else 0 end) saldocarteraM60
FROM tCsCartera c with(nolock)
inner join tCsCarteraDet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
left outer join tCsPadronCarteraOtroProd op with(nolock) on op.codprestamo=c.codprestamo
where c.fecha=@fecha and c.codoficina=@codoficina and c.cartera='ACTIVA'
group by c.codasesor,isnull(op.codproducto,c.codproducto)
order by c.codasesor

update #cxpxp
set SaldoTotalCartera=a.saldocartera
from #cxpxp p inner join (
	select codasesor,sum(saldocartera) saldocartera
	from #cxpxp
	group by codasesor
) a on a.codasesor=p.codasesor

create table #pa(
	codasesor varchar(15),
	codproducto varchar(5),
	montocuota decimal(16,2)
)

insert into #pa
SELECT c.codasesor,isnull(op.codproducto,c.codproducto) codproducto
	,sum(CuotasVenc.CAPI + CuotasVenc.INTE + CuotasVenc.INPE) MontoCuota 
	FROM tCsCarteraDet d with(nolock) INNER JOIN tCsCartera c with(nolock) ON d.Fecha = c.Fecha AND d.CodPrestamo = c.CodPrestamo 
	INNER JOIN (
		SELECT Fecha, CodPrestamo, CodUsuario, FechaVencimiento, SUM(CAPI) AS CAPI, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(INVE) AS INVE 
		FROM (
			SELECT Fecha, FechaVencimiento, CodPrestamo, CodUsuario
			, CASE CodConcepto WHEN 'capi' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS CAPI
			, CASE CodConcepto WHEN 'inte' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INTE
			, CASE CodConcepto WHEN 'inpe' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INPE
			, CASE CodConcepto WHEN 'inve' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INVE 
			FROM tCsPadronPlanCuotas with(nolock) WHERE (EstadoCuota <> 'cancelado') AND  (FechaVencimiento>=@fec1) AND (FechaVencimiento<=@fec2) and codoficina=@codoficina
		) A GROUP BY Fecha, FechaVencimiento, CodPrestamo, CodUsuario
	) CuotasVenc ON d.Fecha = CuotasVenc.Fecha AND d.CodPrestamo = CuotasVenc.CodPrestamo AND d.CodUsuario = CuotasVenc.CodUsuario
	left outer join tCsPadronCarteraOtroProd op with(nolock) on op.codprestamo=c.codprestamo
	WHERE (d.Fecha=@fecha) and c.cartera='ACTIVA'
	group by c.codasesor,isnull(op.codproducto,c.codproducto)

--select * from #pa

update #cxpxp
set pago=a.MontoCuota
from #cxpxp p inner join --(
	--SELECT c.codasesor,isnull(op.codproducto,c.codproducto) codproducto
	--,sum(CuotasVenc.CAPI + CuotasVenc.INTE + CuotasVenc.INPE) MontoCuota 
	--FROM tCsCarteraDet d with(nolock) INNER JOIN tCsCartera c with(nolock) ON d.Fecha = c.Fecha AND d.CodPrestamo = c.CodPrestamo 
	--INNER JOIN (
	--	SELECT Fecha, CodPrestamo, CodUsuario, FechaVencimiento, SUM(CAPI) AS CAPI, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(INVE) AS INVE 
	--	FROM (
	--		SELECT Fecha, FechaVencimiento, CodPrestamo, CodUsuario
	--		, CASE CodConcepto WHEN 'capi' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS CAPI
	--		, CASE CodConcepto WHEN 'inte' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INTE
	--		, CASE CodConcepto WHEN 'inpe' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INPE
	--		, CASE CodConcepto WHEN 'inve' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INVE 
	--		FROM tCsPadronPlanCuotas with(nolock) WHERE (EstadoCuota <> 'cancelado') AND  (FechaVencimiento>=@fec1) AND (FechaVencimiento<=@fec2)
	--	) A GROUP BY Fecha, FechaVencimiento, CodPrestamo, CodUsuario
	--) CuotasVenc ON d.Fecha = CuotasVenc.Fecha AND d.CodPrestamo = CuotasVenc.CodPrestamo AND d.CodUsuario = CuotasVenc.CodUsuario
	--left outer join tCsPadronCarteraOtroProd op with(nolock) on op.codprestamo=c.codprestamo
	--WHERE (d.Fecha=@fecha) and c.cartera='ACTIVA'
	--group by c.codasesor,isnull(op.codproducto,c.codproducto)
--) 
#pa a on a.codasesor=p.codasesor and a.codproducto=p.codproducto

drop table #pa

if(@t=1)
begin
	select x.codasesor,pro.nombrecompleto promotor,sum(x.Np) Np,sum(x.Nc) Nc,sum(x.NcM60) NcM60
	,sum(x.SaldoCapital) SaldoCapital,sum(x.SaldoCartera) SaldoCartera,sum(x.SaldoCarteraM60) SaldoCarteraM60
	,ct.CarteraTotal, (sum(x.SaldoCartera)/ct.CarteraTotal)*100 Concentracion
	,case when e.estado=1 then 'ACTIVO' else 'BAJA' end estado,pu.Descripcion puesto
	,cast((sum(x.SaldoCarteraM60)/sum(x.SaldoCartera))*100 as decimal(16,2)) Mora
	,sum(pago) pago
	from #cxpxp x
	--inner join tcaproducto p with(nolock) on p.codproducto=x.codproducto
	inner join tcsempleados e with(nolock) on e.codusuario=x.codasesor
	inner join tCsClPuestos pu with(nolock) on e.codpuesto=pu.codigo
	inner join tcspadronclientes pro with(nolock) on pro.codusuario=x.codasesor
	cross join(
		select sum(SaldoCartera) CarteraTotal from #cxpxp
	) ct
	group by x.codasesor,pro.nombrecompleto,e.estado,pu.Descripcion,ct.CarteraTotal
	order by sum(x.SaldoCartera) desc
end

if(@t=2)
begin
	select x.codasesor,x.codproducto,p.NombreProd,x.Np,x.Nc,x.NcM60
	,x.SaldoCapital,x.SaldoCartera,x.SaldoCarteraM60,x.SaldoTotalCartera,x.Concentracion
	,cast((x.SaldoCarteraM60/x.SaldoCartera)*100 as decimal(16,2)) Mora
	,x.pago
	,isnull(MCN.ValorProg,0) MCN,isnull(MCR.ValorProg,0) MCR,isnull(MCD.ValorProg,0) MCD
	from #cxpxp x
	inner join tcaproducto p with(nolock) on p.codproducto=x.codproducto
	inner join tcspadronclientes pro with(nolock) on pro.codusuario=x.codasesor
	left outer join tCsBsMetaxUENdet MCN on MCN.NCamProducto=x.codproducto and MCN.ncamvalor=x.codasesor 
		and MCN.fecha=@fec2 and MCN.iCodTipoBS=5 and MCN.iCodIndicador=11--> metas de nuevos clientes
	left outer join tCsBsMetaxUENdet MCR on MCR.NCamProducto=x.codproducto and MCR.ncamvalor=x.codasesor 
		and MCR.fecha=@fec2 and MCR.iCodTipoBS=5 and MCR.iCodIndicador=8--> metas de nuevos renovados
	left outer join tCsBsMetaxUENdet MCD on MCD.NCamProducto=x.codproducto and MCD.ncamvalor=x.codasesor 
		and MCD.fecha=@fec2 and MCD.iCodTipoBS=5 and MCD.iCodIndicador=1--> metas de desembolsos
		order by x.SaldoCartera desc
end 

if(@t=3)
begin
	select x.codproducto,p.NombreProd,sum(x.Np) Np,sum(x.Nc) Nc,sum(x.NcM60) NcM60
	,sum(x.SaldoCapital) SaldoCapital,sum(x.SaldoCartera) SaldoCartera,sum(x.SaldoCarteraM60) SaldoCarteraM60
	,ct.CarteraTotal, (sum(x.SaldoCartera)/ct.CarteraTotal)*100 Concentracion
	,cast((sum(x.SaldoCarteraM60)/sum(x.SaldoCartera))*100 as decimal(16,2)) Mora
	,sum(x.pago) pago
	from #cxpxp x
	inner join tcaproducto p with(nolock) on p.codproducto=x.codproducto
	inner join tcsempleados e with(nolock) on e.codusuario=x.codasesor
	inner join tCsClPuestos pu with(nolock) on e.codpuesto=pu.codigo
	inner join tcspadronclientes pro with(nolock) on pro.codusuario=x.codasesor
	cross join(
		select sum(SaldoCartera) CarteraTotal from #cxpxp
	) ct 
	group by x.codproducto,p.NombreProd,ct.CarteraTotal
	order by sum(x.SaldoCartera) desc
end

drop table #cxpxp
GO