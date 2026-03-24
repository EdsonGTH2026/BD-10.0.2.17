SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pXaCaDesembolsosDiario
CREATE procedure [dbo].[pXaCaDesembolsosDiario]
as

declare @fecfin smalldatetime
select @fecfin=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'

declare @t table(fecha smalldatetime,nro int,monto money,nroprogresemos int,montoprogresemos money,nrofinamigo int,montofinamigo money)
insert into @t
select fechadesembolso fecha
,count(codprestamo) nro
,sum(montodesembolso) monto
,count(case when codfondo='20' then codprestamo else null end) nroprogresemos
,sum(case when codfondo='20' then (montodesembolso)*0.7 else 0 end) montoprogresemos
,count(case when codfondo<>'20' then codprestamo else null end) nrofinamigo
,sum(case when codfondo='20' then (montodesembolso)*0.3 else montodesembolso end) montofinamigo
from [10.0.2.14].finmas.dbo.tcaprestamos
where fechadesembolso=@fecfin+1 and estado='VIGENTE'
and codoficina not in('97','999')
group by fechadesembolso

select *
from (
	select dbo.fdufechaatexto(p.desembolso,'DD/MM/AAAA') fecha
	,count(p.codprestamo) nro
	,sum(p.monto) monto
	,count(case when c.codfondo=20 then p.codprestamo else null end) nroprogresemos
	,sum(case when c.codfondo=20 then (p.monto)*0.7 else 0 end) montoprogresemos
	,count(case when c.codfondo<>20 then p.codprestamo else null end) nrofinamigo
	,sum(case when c.codfondo=20 then (p.monto)*0.3 else p.monto end) montofinamigo
	from tcspadroncarteradet p with(nolock)	
	inner join tcscartera c with(nolock) on p.fechacorte=c.fecha and p.codprestamo=c.codprestamo
	where p.codoficina not in('97','999')
	and p.desembolso>=@fecini and p.desembolso<=@fecfin
	group by p.desembolso
	union
	select dbo.fdufechaatexto(fecha,'DD/MM/AAAA') fecha,nro,monto,nroprogresemos,montoprogresemos,nrofinamigo,montofinamigo from @t
) a
order by fecha desc
GO