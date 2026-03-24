SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----exec pCsCuadroSucursalxActivoHuerfanoCoordinador '20180909'
CREATE procedure [dbo].[pCsCuadroSucursalxActivoHuerfanoCoordinador] @fecha smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20180930'

declare @T1 datetime
declare @T2 datetime

declare @fecini smalldatetime
declare @fecfin smalldatetime
--set @fecini='20180801'
--set @fecfin='20180831'

set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
set @fecfin=@fecha

--declare @fecha smalldatetime
--set @fecha='20180831'

set @T1=getdate()
--drop table #tca
create table #tca(
	codprestamo varchar(25),
	prestamoid varchar(25),
	codserviciop varchar(25)
)
insert into #tca (codprestamo,prestamoid,codserviciop)
select codprestamo,codanterior,codserviciop from [10.0.2.14].finmas.dbo.tcaprestamos where (codoficina>100 and codoficina<300) and codoficina not in('97','230','231')

set @T2=getdate()
print 'Tiempo 1 - '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' milseg.'
set @T1 = getdate()

--20,459
--22,053 unisap conta
--drop table #ptmos
create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo 
--into _CarteraPtmos1217
from tcscartera with(nolock)
where fecha=@fecha --and cartera='ACTIVA' 
and codoficina not in('97','230','231')
and codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))

select --primerasesor
case when e.codusuario is null or e.codpuesto<>66 then 'Huerfano' else e.codusuario end primerasesor
,p.codoficina
,sum(monto) montocolocado
Into #Desembolsos
from tcspadroncarteradet p with(nolock)
left outer join tcsempleadosfecha e on e.codusuario=p.primerasesor and e.fecha=@fecha
where p.desembolso>=@fecini and p.desembolso<=@fecfin
and p.codoficina<>'97'
--group by dbo.fdufechaaperiodo(desembolso)
--group by primerasesor
group by case when e.codusuario is null or e.codpuesto<>66 then 'Huerfano' else e.codusuario end,p.codoficina

----select dbo.fdufechaaperiodo(pcd.desembolso) periodo
--select case when pcd.desembolso<'20180101' then 'Anterior' else dbo.fdufechaaperiodo(pcd.desembolso) end periodo
select case when pcd.codoficina>100 and pcd.codoficina<300 then 
				case when pcd.codoficina='150' then '150'
					 when pcd.codoficina='112' then '41'
					 when pcd.codoficina='114' then '25'
					 when pcd.codoficina='131' then '37'
					 when pcd.codoficina='167' then '84'
				else cast(cast(pcd.codoficina as int)+200 as varchar(4)) end
			when pcd.codoficina='22' then '322'
			else pcd.codoficina end codoficina
,case when e.codusuario is null or e.codpuesto<>66 then 'Huerfano' else e.codusuario end codusuario
,sum(
	case when c.estado<>'CASTIGADO' then cast(d.saldocapital as decimal(16,2)) else 0 end
) 'SaldoCapital' --+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden+d.cargomora+d.impuestos+d.otroscargos
,count(
	case when c.estado<>'CASTIGADO' then pcd.codprestamo else null end
	) 'NroTotal' 
,sum(cast(
	case when c.estado<>'CASTIGADO' then
		case when @fecha<pcd.s2inicio or pcd.s2inicio is null then --no tiene fecha reasignacion
			case when c.estado='VIGENTE' then
				case when (e.codusuario is null or e.codpuesto<>66) then d.saldocapital else 0 end 
			else 0 end
		else 0 end
	else 0 end
		as decimal(16,2))) VigenteSaldoHuerfano
,sum(cast(
	case when c.estado<>'CASTIGADO' then
		case when @fecha<pcd.s2inicio or pcd.s2inicio is null then --no tiene fecha reasignacion
			case when c.estado='VIGENTE' then 
				case when (e.codusuario is not null and e.codpuesto=66) then d.saldocapital else 0 end
			else 0 end 
		else 0 end
	else 0 end
		as decimal(16,2))) VigenteSaldoActivo--PropiaVigente
,count(
	case when c.estado<>'CASTIGADO' then	
		case when @fecha<pcd.s2inicio or pcd.s2inicio is null then --no tiene fecha reasignacion
			case when c.estado='VIGENTE' then
				case when e.codusuario is null or e.codpuesto<>66 then pcd.codprestamo
				else null end
		else null end
		else null end
	else null end
		) VigenteNroHuerfano
,count(
	case when c.estado<>'CASTIGADO' then
		case when @fecha<pcd.s2inicio or pcd.s2inicio is null then --no tiene fecha reasignacion
			case when c.estado='VIGENTE' then 
				case when (e.codusuario is not null and e.codpuesto=66) then pcd.codprestamo else null end
			else null end
		else null end
	else null end
		) VigenteNroActivo--PropiaNroVigente

,sum(cast(
	case when c.estado<>'CASTIGADO' then
		case when @fecha<pcd.s2inicio or pcd.s2inicio is null then --no tiene fecha reasignacion
			case when c.estado='VENCIDO' then
				case when e.codusuario is null or e.codpuesto<>66 then d.saldocapital else 0 end 
			else 0 end
		else 0 end
	else 0 end
	as decimal(16,2))) VencidoSaldoHuerfano
,sum(cast(
	case when c.estado<>'CASTIGADO' then
		case when @fecha<pcd.s2inicio or pcd.s2inicio is null then --no tiene fecha reasignacion
			case when c.estado='VENCIDO' then 
				case when (e.codusuario is not null and e.codpuesto=66) then d.saldocapital else 0 end --and pcd.primerasesor=pcd.ultimoasesor
			else 0 end 
		else 0 end
	else 0 end
		as decimal(16,2))) VencidoSaldoActivo--PropiaVencido
,count(
	case when c.estado<>'CASTIGADO' then
		case when @fecha<pcd.s2inicio or pcd.s2inicio is null then --no tiene fecha reasignacion
			case when c.estado='VENCIDO' then
				case when e.codusuario is null or e.codpuesto<>66 then pcd.codprestamo
				else null end
			else null end
		else null end
	else null end
		) VencidoNroHuerfano
,count(
	case when c.estado<>'CASTIGADO' then
		case when @fecha<pcd.s2inicio or pcd.s2inicio is null then --no tiene fecha reasignacion
			case when c.estado='VENCIDO' then 
				case when (e.codusuario is not null and e.codpuesto=66) then pcd.codprestamo else null end --and pcd.primerasesor=pcd.ultimoasesor
			else null end
		else null end
	else null end
		) VencidoNroActivo--PropiaNroVencido

,sum(cast(
		case when c.estado='CASTIGADO' then
			case when e.codusuario is null or e.codpuesto<>66 then 
			d.saldocapital--+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden+d.cargomora+d.impuestos+d.otroscargos
			else 0 end 
		else 0 end
		as decimal(16,2))) CastigadoSaldoHuerfano
,sum(cast(
		case when c.estado='CASTIGADO' then
			case when e.codusuario is not null and e.codpuesto=66 then 
			d.saldocapital--+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden+d.cargomora+d.impuestos+d.otroscargos
			else 0 end 
		else 0 end
		as decimal(16,2))) CastigadoSaldoActivo
,count(case when c.estado='CASTIGADO' then
			case when e.codusuario is null or e.codpuesto<>66 then pcd.codprestamo
			else null end
		else null end
		) CastigadoNroHuerfano
,count(case when c.estado='CASTIGADO' then
			case when e.codusuario is not null and e.codpuesto=66 then pcd.codprestamo
			else null end
		else null end
		) CastigadoNroActivo

,sum(cast(
	case when c.estado<>'CASTIGADO' then
		case when @fecha>=pcd.s2inicio and pcd.s2inicio is not null then --si tiene fecha reasignacion
				case when c.estado='VIGENTE' then d.saldocapital else 0 end 
		else 0 end 
	else 0 end
		as decimal(16,2))) ReasignadoVigente
,sum(cast(
	case when c.estado<>'CASTIGADO' then
		case when @fecha>=pcd.s2inicio and pcd.s2inicio is not null then --si tiene fecha reasignacion
			case when c.estado='VENCIDO' then d.saldocapital else 0 end 
		else 0 end
	else 0 end
		as decimal(16,2))) ReasignadoVencido
,count(
	case when c.estado<>'CASTIGADO' then
		case when @fecha>=pcd.s2inicio and pcd.s2inicio is not null then --si tiene fecha reasignacion
			case when c.estado='VIGENTE' then pcd.codprestamo else null end
		else null end
	else null end
		) ReasignadoNroVigente
,count(
	case when c.estado<>'CASTIGADO' then
		case when @fecha>=pcd.s2inicio and pcd.s2inicio is not null then --si tiene fecha reasignacion
			case when c.estado='VENCIDO' then pcd.codprestamo else null end
		else null end
	else null end
		) ReasignadoNroVencido

into #Cartera
FROM tCsCartera c with(nolock)
inner join tCsCarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcspadroncarteradet pcd with(nolock) on pcd.codprestamo=d.codprestamo
left outer join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor
--left outer join tcsempleados e on e.codusuario=c.codasesor
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha
where c.fecha=@fecha --and c.cartera='ACTIVA' --and c.estado='VENCIDO'
and c.codprestamo in(select codprestamo from #ptmos)

--and c.codoficina='330'
--group by case when pcd.codoficina>100 and pcd.codoficina<300 then cast(cast(pcd.codoficina as int)+200 as varchar(4)) when pcd.codoficina='22' then '322' else pcd.codoficina end
--,case when e.codusuario is null or e.codpuesto<>66 then 'Huerfano' else e.codusuario end
group by case when pcd.codoficina>100 and pcd.codoficina<300 then 
				case when pcd.codoficina='150' then '150'
					 when pcd.codoficina='112' then '41'
					 when pcd.codoficina='114' then '25'
					 when pcd.codoficina='131' then '37'
					 when pcd.codoficina='167' then '84'
				else cast(cast(pcd.codoficina as int)+200 as varchar(4)) end
			when pcd.codoficina='22' then '322'
			else pcd.codoficina end
,case when e.codusuario is null or e.codpuesto<>66 then 'Huerfano' else e.codusuario end

select @fecha fecha,c.codoficina,
o.nomoficina sucursal--,c.codusuario
,c.codusuario
--,case when c.codusuario='Huerfano' then 'Huerfano' else e.paterno+' '+e.materno+' '+e.nombres end coordinador
,case when c.codusuario='Huerfano' then 'Huerfano' else x.nombrecompleto end coordinador
,e.ingreso
,d.montocolocado,c.SaldoCapital,c.nrototal,c.VigenteSaldoHuerfano,c.VigenteSaldoActivo,c.VigenteNroHuerfano,c.VigenteNroActivo
,c.VencidoSaldoHuerfano,c.VencidoSaldoActivo,c.VencidoNroHuerfano,c.VencidoNroActivo
,c.CastigadoSaldoHuerfano,c.CastigadoSaldoActivo,c.CastigadoNroHuerfano,c.CastigadoNroActivo
,c.ReasignadoVigente,c.ReasignadoVencido,c.ReasignadoNroVigente,c.ReasignadoNroVencido
from #Cartera c
--left outer join #Desembolsos d on c.codusuario=d.primerasesor
left outer join #Desembolsos d on c.codusuario=d.primerasesor and c.codoficina=d.codoficina
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
left outer join tcsempleados e with(nolock) on e.codusuario=c.codusuario
left outer join tcspadronclientes x with(nolock) on x.codusuario=c.codusuario

drop table #tca
drop table #ptmos
drop table #Cartera
drop table #Desembolsos
GO

GRANT EXECUTE ON [dbo].[pCsCuadroSucursalxActivoHuerfanoCoordinador] TO [marista]
GO