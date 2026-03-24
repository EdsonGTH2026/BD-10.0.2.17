SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCaRepAvanceMetas] @Fecha smalldatetime
as
set nocount on

--declare @Fecha smalldatetime
--set @Fecha = '20190506'

declare @FechaHoy smalldatetime
set @FechaHoy = @Fecha
--Le resta un dia 
set @Fecha = dateadd(d,-1,@Fecha)



declare @FechaIniMes smalldatetime
declare @FechaFinMes smalldatetime

--select substring(convert(varchar,@Fecha, 112), 5,2)
set @FechaIniMes = substring(convert(varchar,@Fecha, 112), 1,4) + substring(convert(varchar,@Fecha, 112), 5,2) + '01'
set @FechaIniMes = dateadd(d, -1, @FechaIniMes) --se le resta 1 dia para que de el ultimo dia del mes anterior

set @FechaFinMes = substring(convert(varchar,@Fecha, 112), 1,4) + substring(convert(varchar,@Fecha, 112), 5,2) + '01'
set @FechaFinMes = dateadd(m, 1, @FechaFinMes)  --a la fecha ini mes, se le suma 1 mes
set @FechaFinMes = dateadd(d, -1, @FechaFinMes) --se resta un dia para obtener el ultimo dia del mes actual

--select @FechaIniMes as '@FechaIniMes', @FechaFinMes as '@FechaFinMes', @Fecha as '@Fecha'

create table #Principal(
Id 				int Identity not null,
Regional		varchar(50) null,
CodOficina		varchar(3) null,
Sucursal		varchar(50) null,
Meta 			money null,
CarteraVigIni 	money null,
MetaCartVigFin	money null,
CarteraVigAlDia	money null,
CobranzaProg	money null,
EnRiesgoVencida	money null default 0,
EnPanel			money null,
ColocadoHoy		money null,
FaltaParaMeta	money null
)

--select * from #Principal
/*
insert into #Principal (codoficina, CarteraVigIni, Sucursal)
-- Sucursales a una fecha 
select distinct e.codoficinanom,isnull(ca.saldocapital,0) saldocapital,
--e.nombres + ' ' + e.paterno + ' ' + e.materno coordinador,
o.nomoficina sucursal
from tcsempleados e with(nolock)
left outer join (
	select c.codoficina, sum(d.saldocapital) saldocapital
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	where c.fecha= @FechaIniMes --'20190401' 
	and c.cartera='ACTIVA'
	and c.nrodiasatraso < 31
	group by c.codoficina
) ca on ca.codoficina=e.codoficinanom
inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
where e.codpuesto=70 and e.estado=1 
--order by e.codoficinanom
*/

--Cartera vigente x susursal
insert into #Principal (codoficina, Sucursal, CarteraVigIni )
select o.CodOficina, o.NomOficina, ca.saldocapital
from tClOficinas as o
left join (
	select c.codoficina, sum(d.saldocapital) saldocapital
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	where c.fecha= @FechaIniMes
	and c.cartera='ACTIVA'
	and c.nrodiasatraso < 31
	group by c.codoficina
) ca on ca.codoficina=o.codoficina
where (convert(integer,o.CodOficina) < 90 or  convert(integer,o.CodOficina) >= 300 )
and  o.Tipo <> 'Cerrada'



--ACTUALIZA REGIONALES
update x set
x.Regional = z.Regional
from #Principal as x
inner join (
		select o.CodOficina, o.Zona, o.NomOficina, 
		z.Nombre, z.Responsable,
		u.NombreCompleto as Regional
		from tClOficinas as o
		inner join tclzona as z on z.Zona = o.Zona
		inner join tsgusuarios as u on u.CodUsuario = z.Responsable
) as z on z.CODOFICINA = x.codoficina


--ACTUALIZA META
update x set
x.Meta = z.Monto
from #Principal as x
inner join (
		select Codigo, Monto from tCsCaMetas where TipoCodigo = 1
		and fecha = @FechaFinMes
) as z on z.Codigo = x.codoficina

--Actualiza cartera vigente al dia
update x set
x.CarteraVigAlDia = z.saldocapital --z.CartVigDia
from #Principal as x
inner join (
		--select ca.codoficina, sum(isnull(ca.saldocapital,0)) as CartVigDia
		--from tcsempleados e with(nolock)
		--left outer join (
			select c.codoficina, sum(d.saldocapital) saldocapital
			from tcscartera c with(nolock)
			inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
			where c.fecha= @Fecha
			and c.cartera='ACTIVA'
			and c.nrodiasatraso < 31
			group by c.codoficina
		--) ca on ca.codoficina=e.codoficinanom
		--inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
		--where e.codpuesto=70 and e.estado=1 
		--and ca.codoficina = @CodOficina
		--group by ca.codoficina
) as z on z.CODOFICINA = x.codoficina


--ACTUALIZA META CARTERA VIGENTE FINAL
update #Principal set MetaCartVigFin = isnull(Meta,0) + CarteraVigIni;


--ACTUALIZA COBRANZA PROGRAMADA
update x set
x.CobranzaProg = z.CobProgSuc
from #Principal as x
inner join (
	select  c.CODOFICINA, 
	(sum (a.CAPI ) * 1.15) as CobProgSuc
	--sum (a.CAPI + a.INTE + a.INPE +a.sdv+a.MORA ) as CobProgSuc
	FROM tCsCarteraDet d with(nolock)
	INNER JOIN tCsCartera c with(nolock) ON d.Fecha = c.Fecha AND d.CodPrestamo = c.CodPrestamo
	--INNER JOIN tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
	--LEFT OUTER JOIN tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha= @Fecha -->huerfano
	inner join (
		SELECT 
			CodPrestamo, CodUsuario
			,sum(CASE CodConcepto WHEN 'capi' THEN MontoCuota  ELSE 0 END) AS CAPI
			,sum(CASE CodConcepto WHEN 'inte' THEN MontoCuota  ELSE 0 END) AS INTE
			,sum(CASE CodConcepto WHEN 'inte' THEN MontoDevengado  ELSE 0 END) AS INTEDEV
			,sum(CASE CodConcepto WHEN 'inpe' THEN MontoCuota  ELSE 0 END) AS INPE
			,sum(CASE CodConcepto WHEN 'SDV' THEN MontoCuota  ELSE 0 END) AS SDV
			,sum(CASE CodConcepto WHEN 'MORA' THEN MontoCuota  ELSE 0 END) AS MORA
			,sum(CASE CodConcepto WHEN 'MORA' THEN MontoDevengado  ELSE 0 END) AS MORAD
			FROM tCsPadronPlanCuotas with(nolock)
			WHERE 
             (EstadoCuota <> 'cancelado') AND 
			--(FechaVencimiento >@FechaHoy) --con esta no daba
			(FechaVencimiento >@Fecha) 
            AND (FechaVencimiento <= @FechaFinMes)
			GROUP BY 
		CodPrestamo, CodUsuario
	) as a on d.CodPrestamo=a.CodPrestamo AND d.CodUsuario=a.CodUsuario 
	WHERE (d.Fecha=@Fecha) AND (c.cartera='ACTIVA') 
	--AND c.CODOFICINA='321'
	and c.nrodiasatraso < 31
	group by c.CODOFICINA
) as z on z.CODOFICINA = x.codoficina


-- ACTUALIZA RIESGO PASO VENCIDO
update x set
x.EnRiesgoVencida = isnull( z.Monto,0)
from #Principal as x
inner join (
		SELECT c.CODOFICINA,
		sum(d.saldocapital) as Monto
		FROM tCsCarteraDet d with(nolock)
		INNER JOIN tCsCartera c with(nolock) ON d.Fecha = c.Fecha AND d.CodPrestamo = c.CodPrestamo
		WHERE (d.Fecha=@Fecha) AND (c.cartera='ACTIVA') 
		and c.nrodiasatraso >=15
		and c.nrodiasatraso <=30
		--AND c.CODOFICINA='4'
		group by c.CODOFICINA
) as z on z.CODOFICINA = x.codoficina

--ACTUALIZA EN PANEL
update x set
x.EnPanel = z.TotalPanel
from #Principal as x
inner join (
	select 
	a.CodOficina, sum(b.montoaprobado) as TotalPanel 
	from [10.0.2.14].finmas.dbo.tcasolicitudproce a 
	INNER JOIN [10.0.2.14].finmas.dbo.tcasolicitud b  ON b.CodSolicitud= a.codsolicitud AND b.codoficina=a.codoficina
	INNER JOIN [10.0.2.14].finmas.dbo.tUsUsuarios u  ON u.CodUsuario=b.CodAsesor
	INNER JOIN [10.0.2.14].finmas.dbo.tClOficinas o  ON a.CodOficina=o.CodOficina 
	WHERE 
	estado = 1 or --Solicitado preliminar
	estado = 2 or -- solicitado
	estado = 3 or -- creditoexce
	estado = 4 or -- mesa de control
	estado = 5 or -- aceptado
	estado = 6 or -- fondeo
	estado = 7 or -- entrega
	estado = 21 or -- solicitado dev.
	estado = 22 or -- solicitado dev.
	estado = 23 or -- regional
	estado = 24 or -- regional 
	estado = 31 or -- credito
	estado = 61 -- fondeo progresemos
	group by a.CodOficina
) as z on z.CODOFICINA = x.codoficina


--COLOCADO HOY
update #Principal set ColocadoHoy = 0;

update x set
x.ColocadoHoy = isnull(z.monto,0)
from #Principal as x
inner join (
		--select CodOficina, sum(MontoDesembolso) as ColocadoHoy
		--from [10.0.2.14].finmas.dbo.tcaprestamos as p
		--where p.fechadesembolso = @FechaHoy --@Fecha
		--and p.Estado <> 'CANCELADO'
		--group by p.codoficina

		SELECT  
		o.NomOficina, 
		p.CodOficina, 
		FechaDesembolso, 
		count(codprestamo) nroprestamos, 
		sum(MontoDesembolso) monto
		FROM [10.0.2.14].finmas.dbo.tCaPrestamos as p
		LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tClOficinas as o ON o.CodOficina=p.CodOficina
		WHERE FechaDesembolso>=@FechaHoy AND FechaDesembolso<=@FechaHoy AND p.CodOficina <> '97' 
		AND Estado<>'TRAMITE'AND Estado<>'ANULADO' 
		GROUP BY o.NomOficina, p.CodOficina, FechaDesembolso

) as z on z.CODOFICINA = x.codoficina


--ACTUALIZA FALTA METAS
--Cartera vigente al (dia de la evaluacion) - Meta cartera vigente final -Cobranza programada-En riesgo de paso a vencida + En panel + Colocado hoy
--update #Principal set FaltaParaMeta = isnull(MetaCartVigFin,0)- isnull(CarteraVigAlDia,0) + isnull(CobranzaProg,0) + isnull(EnRiesgoVencida,0) -  isnull(EnPanel,0) - isnull(ColocadoHoy,0)
update #Principal set FaltaParaMeta = isnull(MetaCartVigFin,0)- isnull(CarteraVigAlDia,0) + isnull(CobranzaProg,0) -  isnull(EnPanel,0) - isnull(ColocadoHoy,0)

--Actualiza metas
--select * from tCsCaMetas

select * from #Principal
order by Sucursal

--Borra la tabla temporal
drop table #Principal






GO

GRANT EXECUTE ON [dbo].[pCsCaRepAvanceMetas] TO [public]
GO