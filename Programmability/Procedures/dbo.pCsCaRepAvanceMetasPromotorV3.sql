SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCaRepAvanceMetasPromotorV3] @Fecha smalldatetime
as
set nocount on

--declare @Fecha smalldatetime
--set @Fecha = '20190521'

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

--=======================================

	--limpia la tabla si hay registros de otra fecha
	if exists(select * from tCsCaRepAvanMetPromDesembolsosTemp where FechaDesembolso <> @Fecha)
	begin
		delete from tCsCaRepAvanMetPromDesembolsosTemp 
	end
	
	--Si no existe informacion a la fecha, los inserta
	if not exists(select * from tCsCaRepAvanMetPromDesembolsosTemp where FechaDesembolso = @Fecha)
	begin
		insert into tCsCaRepAvanMetPromDesembolsosTemp (CodAsesor, FechaDesembolso, nroprestamos, monto )
		SELECT 	p.CodAsesor, FechaDesembolso, count(codprestamo) nroprestamos, 	sum(MontoDesembolso) monto
		FROM [10.0.2.14].finmas.dbo.tCaPrestamos as p
		WHERE FechaDesembolso>= @Fecha
		AND FechaDesembolso<= @Fecha
		AND p.CodOficina <> '97' 
		AND Estado<>'TRAMITE'AND Estado<>'ANULADO' 
		GROUP BY p.CodAsesor, FechaDesembolso
	end

--=======================================
	--Limpia la tabla temporal de Asesor monto
	delete from tCsCaRepAvanMetPromAsesorMontoTemp

	--Llena la tabla
	insert into tCsCaRepAvanMetPromAsesorMontoTemp (CodAsesor, TotalPanel)
	select b.CodAsesor, 	sum(b.montoaprobado) as TotalPanel 
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
	group by b.CodAsesor

--=======================================
/*
create table #Principal(
Id 				int Identity not null,
Fecha			smalldatetime null,
Region			varchar(30) null,
CodOficina		varchar(3) null,
Sucursal		varchar(50) null,
CodPromotor		varchar(20) null,
Promotor		varchar(50) null,
--Meta 			money null,
CarteraVigIni 	money null,
--MetaCartVigFin	money null,
CarteraVigAlDia	money null,
Crecimiento		money null,
MetaCrecimiento money null,	 
CobranzaProg	money null,
ColocadoHoy		money null,
EnPanel			money null,
FaltaParaMeta	money null,
EnRiesgoVencida	money null
)
*/

-- select  * from tCsCaRepAvanceMetasPromotor where codoficina = '4'

--Oficinas y Saldo Inicial
insert into tCsCaRepAvanceMetasPromotor (Fecha, codoficina, Sucursal, CarteraVigIni, CodPromotor, Promotor )

select @Fecha, o.CodOficina, o.NomOficina, ca.saldocapital, ca.codusuario, ca.coordinador
from tClOficinas as o with(nolock)
left join (
		select e.codusuario,isnull(ca.saldocapital,0) saldocapital,e.nombres + ' ' + e.paterno + ' ' + e.materno as coordinador,o.nomoficina sucursal, o.codoficina
		from tcsempleados e with(nolock)
		left outer join (
			select c.codasesor, sum(d.saldocapital) as saldocapital
			from tcscartera c with(nolock)
			inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
			where c.fecha=@FechaIniMes and c.cartera='ACTIVA'
			and c.nrodiasatraso < 31
			group by c.codasesor
		) ca on ca.codasesor=e.codusuario
		inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
		where 1= 1
		and e.codpuesto=66 
		and e.estado=1 
) ca on ca.codoficina=o.codoficina
where (convert(integer,o.CodOficina) < 90 or  convert(integer,o.CodOficina) >= 300 )
and  o.Tipo <> 'Cerrada'

--Actualiza cartera vigente al dia
update x set
x.CarteraVigAlDia = z.saldocapital --z.CartVigDia
from tCsCaRepAvanceMetasPromotor as x
inner join (
		select e.codusuario,isnull(ca.saldocapital,0) saldocapital,e.nombres + ' ' + e.paterno + ' ' + e.materno as coordinador,o.nomoficina sucursal, o.codoficina
		from tcsempleados e with(nolock)
		left outer join (
			select c.codasesor, sum(d.saldocapital) as saldocapital
			from tcscartera c with(nolock)
			inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
			where c.fecha=@Fecha and c.cartera='ACTIVA'
			and c.nrodiasatraso < 31
			group by c.codasesor
		) ca on ca.codasesor=e.codusuario
		inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
		where 1= 1
		and e.codpuesto=66 
		and e.estado=1 
) as z on z.CODOFICINA = x.codoficina and z.codusuario = x.CodPromotor

--ACTUALIZA REGION
update x set
x.Region = z.Nombre
from tCsCaRepAvanceMetasPromotor as x
inner join (
		select o.CodOficina, o.Zona, o.NomOficina, 
		z.Nombre, z.Responsable,
		u.NombreCompleto as Regional
		from tClOficinas as o with(nolock)
		inner join tclzona as z with(nolock) on z.Zona = o.Zona
		inner join tsgusuarios as u with(nolock) on u.CodUsuario = z.Responsable
) as z on z.CODOFICINA = x.codoficina


--ACTUALIZA CRECIMIENTO
update tCsCaRepAvanceMetasPromotor set Crecimiento = 0

update x set
x.Crecimiento = z.crecimiento
from tCsCaRepAvanceMetasPromotor as x
inner join (
		select CodPromotor,crecimiento  from tCsACrecimientoPromotor 
) as z on z.CodPromotor = x.CodPromotor


--ACTUALIZA META
update tCsCaRepAvanceMetasPromotor set MetaCrecimiento = 0

update x set
x.MetaCrecimiento = z.Monto
from tCsCaRepAvanceMetasPromotor as x
inner join (
		select Codigo, isnull(Monto,0) as Monto from tCsCaMetas with(nolock) where TipoCodigo = 2 and meta = 1
) as z on z.Codigo = x.CodPromotor


--ACTUALIZA META CARTERA VIGENTE FINAL
--update tCsCaRepAvanceMetasPromotor set MetaCartVigFin = isnull(Meta,0) + CarteraVigIni;


--ACTUALIZA COBRANZA PROGRAMADA
update tCsCaRepAvanceMetasPromotor set CobranzaProg = 0

update x set
x.CobranzaProg = z.CobProgSuc
from tCsCaRepAvanceMetasPromotor as x
inner join (
		select  
		c.codasesor,
		(sum (a.CAPI ) * 1.12) as CobProgSuc
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
				WHERE --(EstadoCuota <> 'cancelado') AND 
				(FechaVencimiento > @Fecha) 
	            AND (FechaVencimiento <= @FechaFinMes)
				GROUP BY 
			CodPrestamo, CodUsuario
		) as a on d.CodPrestamo=a.CodPrestamo AND d.CodUsuario=a.CodUsuario 
		WHERE (d.Fecha= @Fecha) 
		AND (c.cartera='ACTIVA') 
		and c.nrodiasatraso < 31
		group by c.codasesor
) as z on z.codasesor = x.CodPromotor


--COLOCADO HOY
update tCsCaRepAvanceMetasPromotor set ColocadoHoy = 0;

update x set
x.ColocadoHoy = isnull(z.monto,0)
from tCsCaRepAvanceMetasPromotor as x
inner join tCsCaRepAvanMetPromDesembolsosTemp as z on z.CodAsesor = x.CodPromotor
/*
inner join (
		SELECT  
		p.CodAsesor,
		FechaDesembolso, 
		count(codprestamo) nroprestamos, 
		sum(MontoDesembolso) monto
		FROM [10.0.2.14].finmas.dbo.tCaPrestamos as p
		WHERE FechaDesembolso>= @Fecha
		AND FechaDesembolso<= @Fecha
		AND p.CodOficina <> '97' 
		AND Estado<>'TRAMITE'AND Estado<>'ANULADO' 
		GROUP BY p.CodAsesor, FechaDesembolso
) as z on z.CodAsesor = x.CodPromotor
*/

--ACTUALIZA EN PANEL
update tCsCaRepAvanceMetasPromotor set EnPanel = 0

update x set
x.EnPanel = z.TotalPanel
from tCsCaRepAvanceMetasPromotor as x
inner join tCsCaRepAvanMetPromAsesorMontoTemp as z on z.CodAsesor = x.CodPromotor
/*
inner join (	
	select 
	b.CodAsesor,
	sum(b.montoaprobado) as TotalPanel 
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
	group by b.CodAsesor
) as z on z.CodAsesor = x.CodPromotor
*/

-- ACTUALIZA RIESGO PASO VENCIDO
declare @DiasIniEnRiesgo int
set @DiasIniEnRiesgo = datepart(d,@Fecha)
if @DiasIniEnRiesgo > 2 set @DiasIniEnRiesgo = @DiasIniEnRiesgo -1  --le resta un dia 
--select @DiasIniEnRiesgo as '@DiasIniEnRiesgo'

update x set
x.EnRiesgoVencida = isnull( z.Monto,0)
from tCsCaRepAvanceMetasPromotor as x
inner join (
		SELECT 
		c.CodAsesor,
		sum(d.saldocapital) as Monto
		FROM tCsCarteraDet d with(nolock)
		INNER JOIN tCsCartera c with(nolock) ON d.Fecha = c.Fecha AND d.CodPrestamo = c.CodPrestamo
		WHERE (d.Fecha=@Fecha) AND (c.cartera='ACTIVA') 
		and c.nrodiasatraso >=@DiasIniEnRiesgo
		and c.nrodiasatraso <=30
		group by c.CodAsesor
) as z on z.CodAsesor = x.CodPromotor



--ACTUALIZA FALTA METAS
--meta = metacrecimiento - crecimiento + cobranzaprogramda-colocado-enpanel
--select (MetaCrecimiento - Crecimiento + CobranzaProg - ColocadoHoy - EnPanel) as 'FaltaMeta'  from #Principal

update tCsCaRepAvanceMetasPromotor set FaltaParaMeta = (MetaCrecimiento - Crecimiento + CobranzaProg - ColocadoHoy - EnPanel)
--update #Principal set FaltaParaMeta = (case when FaltaParaMeta < 0 then 0 else FaltaParaMeta end)


--select * from tCsCaRepAvanceMetasPromotor
--order by Sucursal

--Borra la tabla temporal
--drop table #Principal


GO