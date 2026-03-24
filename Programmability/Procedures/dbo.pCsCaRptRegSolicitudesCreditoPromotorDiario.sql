SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptRegSolicitudesCreditoPromotorDiario] @codoficina varchar(100)
as
set nocount on
--declare @codoficina varchar(4)
--set @codoficina='37'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

Declare @Fecha SmallDateTime
Select @Fecha=FechaConsolidacion From vCsFechaConsolidacion

declare @fec smalldatetime
set @fec=dateadd(day,(-1)*day(@Fecha),@Fecha)+1

declare @fechas table(fecha smalldatetime)
while(@fec<=@Fecha)
begin
	insert into @fechas
	select @fec

	set @Fec=@Fec+1
end
--select * from @fechas
select promotor,fechasolicitud,count(codsolicitud) nro
from (
	select f.fecha fechasolicitud
	,s.codsolicitud
	,case when e.codpuesto<>66 then 'HUERFANO'
	else
	case when e.codusuario is null then 'HUERFANO' else s.promotor end
	end Promotor
	from @fechas f
	left outer join tCaASolicitudesCredito s with(nolock) on s.fechasolicitud=f.fecha and s.codoficina in(select codigo from @sucursales)
	left outer join tCsEmpleadosFecha e with(nolock) on e.codusuario=s.codpromotor and e.fecha=@fecha
	--where s.codoficina=@codoficina
	--and s.promotor='GUERRERO RAMIREZ JOVANA'
	--order by f.fecha
) a
group by promotor,fechasolicitud
GO