SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCaRepProductividadPorDia] @Fecha smalldatetime
as
set nocount on

create table #Principal(
Id 				int Identity not null,
Region			varchar(30) null,
CodOficina		varchar(3) null,
Sucursal		varchar(50) null,
SolIngresadasNum	int null,
SolIngresadasMonto	money null,
ColocacionNum		int null,
ColocacionMonto		money null,
PorEntregarNum		int null,
PorEntregarMonto	money null

)

--Sucursales y regiones
insert into #Principal (codoficina, Sucursal, Region )
select o.CodOficina, o.NomOficina, z.Nombre
from tClOficinas as o
left join (
	select o.CodOficina, o.Zona, o.NomOficina, 
		z.Nombre, z.Responsable,
		u.NombreCompleto as Regional
		from tClOficinas as o
		inner join tclzona as z on z.Zona = o.Zona
		inner join tsgusuarios as u on u.CodUsuario = z.Responsable
) z on z.codoficina=o.codoficina
where (convert(integer,o.CodOficina) < 90 or  convert(integer,o.CodOficina) >= 300 )
and  o.Tipo <> 'Cerrada'


--ACTUALIZA INGRESADAS
update #Principal set SolIngresadasNum = 0, SolIngresadasMonto = 0

update x set
x.SolIngresadasNum = z.SolNumero ,
x.SolIngresadasMonto =	z.SolMonto
from #Principal as x
inner join (
		select 
		c.codoficina,
		count(codsolicitud) as SolNumero,
		sum(montoaprobado) as SolMonto
		--c.codoficina, o.NomOficina AS sucursal,
		--c.codsolicitud, c.montoaprobado, c.fechasolicitud,
		--CodAsesor,e.nombrecompleto as promotor
		from [10.0.2.14].finmas.dbo.tcasolicitud as c
		INNER JOIN [10.0.2.14].finmas.dbo.tClOficinas as o ON c.CodOficina=o.CodOficina
		LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tUsUsuarios as e ON e.CodUsuario=c.CodAsesor
		where c.fechasolicitud = @Fecha and len(c.codsolicitud)<=12
		group by c.codoficina
) as z on z.codoficina = x.codoficina

--ACTUALIZA COLOCACION
update #Principal set ColocacionNum = 0, ColocacionMonto = 0

update x set
x.ColocacionNum = z.nroprestamos ,
x.ColocacionMonto =	z.monto
from #Principal as x
inner join (
		SELECT o.NomOficina, p.CodOficina, FechaDesembolso,
		count(codprestamo) nroprestamos, sum(MontoDesembolso) monto
		FROM [10.0.2.14].finmas.dbo.tCaPrestamos as p
		LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tClOficinas as o ON o.CodOficina=p.CodOficina
		WHERE 
        --FechaDesembolso>=@Fecha AND FechaDesembolso<=@Fecha 
        FechaDesembolso = @Fecha
        AND p.CodOficina <> '97'
		AND Estado<>'TRAMITE'AND Estado<>'ANULADO' and Estado<>'APROBADO'
		GROUP BY o.NomOficina, p.CodOficina, FechaDesembolso
) as z on z.codoficina = x.codoficina


--AcTUALIZA POR ENTREGA

declare @FecProc smalldatetime
select @FecProc = max(fechaproceso) from [10.0.2.14].finmas.dbo.tClParametros
--select @FecProc

update #Principal set PorEntregarNum = 0, PorEntregarMonto = 0

if @FecProc = @Fecha
begin
	--print 'fecha igual a proceso'
	--Ejecuta este script si la fecha es igual a la fecha de procesos de finmas
	update x set
	x.PorEntregarNum = z.numero ,
	x.PorEntregarMonto = z.monto
	from #Principal as x
	inner join (
		select a.CodOficina, count(a.codsolicitud) as numero, sum(b.montoaprobado) as monto
		--a.codsolicitud, a.CodOficina,o.NomOficina AS sucursal, a.CodProducto, a.fechahora	
		--,b.montoaprobado, a.Estado, b.codpresante, a.fondeador, b.codasesor, u.NombreCompleto	
		from [10.0.2.14].finmas.dbo.tcasolicitudproce a 	
		INNER JOIN [10.0.2.14].finmas.dbo.tcasolicitud b ON b.CodSolicitud= a.codsolicitud AND b.codoficina=a.codoficina	
		INNER JOIN [10.0.2.14].finmas.dbo.tUsUsuarios u ON u.CodUsuario=b.CodAsesor	
		INNER JOIN [10.0.2.14].finmas.dbo.tClOficinas o ON a.CodOficina=o.CodOficina 	
		WHERE estado = 7
		group by a.CodOficina
		) as z on z.codoficina = x.codoficina

end
else
begin
	--print 'fecha diferente a proceso'
	--Ejecuta este script si la fecha es diferente a la fecha de procesos de finmas
	update x set
	x.PorEntregarNum = z.numero ,
	x.PorEntregarMonto = z.monto
	from #Principal as x
	inner join (
			select 
			a.CodOficina,
			count(a.codsolicitud) as numero,
			sum(b.montoaprobado) as monto 
			from [10.0.2.14].finmas.dbo.tcasolicitudproce a 
			inner join [10.0.2.14].finmas.dbo.tcasolicitudprocedet as sp on sp.IdProceso = a.IdProceso 
			INNER JOIN [10.0.2.14].finmas.dbo.tcasolicitud b ON b.CodSolicitud= a.codsolicitud AND b.codoficina=a.codoficina
			WHERE sp.estado = 7
			and convert(varchar,sp.fechahora,112) = convert(varchar,@Fecha,112)
			group by a.CodOficina
	) as z on z.codoficina = x.codoficina
end

select  
Region, Sucursal, SolIngresadasNum, SolIngresadasMonto, ColocacionNum, ColocacionMonto, PorEntregarNum, PorEntregarMonto      
from #Principal
order by Region

drop table #Principal












GO

GRANT EXECUTE ON [dbo].[pCsCaRepProductividadPorDia] TO [public]
GO