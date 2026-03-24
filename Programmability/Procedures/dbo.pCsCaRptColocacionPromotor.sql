SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptColocacionPromotor] @codoficina varchar(2000)
as
set nocount on
--declare @codoficina varchar(500) 
--set @codoficina ='321'

declare @fecfin smalldatetime
select @fecfin=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'

declare @fec smalldatetime
set @fec=dateadd(day,(-1)*day(@Fecfin),@Fecfin)+1

declare @fechas table(fecha smalldatetime)
while(@fec<=@Fecfin)
begin
	--print dbo.fdufechaatexto(@fec,'DD-MM-AAAA') + ' ' + str(datepart(weekday,@fec))
	if(datepart(weekday,@fec) not in (1,7))
	begin
		declare @x int
		select @x=count(*) from tcaclfechasnoven with(nolock) where fechanoven=@fec
		--print @x
		if (@x=0)
		begin
			insert into @fechas
			select @fec
		end 
	end
	set @Fec=@Fec+1
end
declare @nro int
select @nro=count(*) --nro 
from @fechas

select codigo 
into #sucursales
from dbo.fduTablaValores(@codoficina)

create table #Ptmos (codprestamo varchar(25) not null,codusuario varchar(15),desembolso smalldatetime,monto money,codproducto char(3),codasesor varchar(15))
insert into #Ptmos 
select codprestamo,codusuario,desembolso,monto,codproducto,ultimoasesor
from tcspadroncarteradet with(nolock)
where desembolso>=@fecini
and desembolso<=@fecfin
and codoficina<>'97'
and codoficina in(select codigo from #sucursales)

create table #liqreno(codprestamo varchar(25) not null,desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)
insert into #liqreno
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion
from #Ptmos p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
--and p.codproducto = (case when a.codproducto ='370' then '370' else '170' end)
group by p.codprestamo,p.desembolso,p.codusuario
having max(a.cancelacion) is not null

select
--dbo.fdufechaaperiodo(p.desembolso) periodo
--p.codprestamo,
case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor
,sum(p.monto) totalmonto
,count(p.codprestamo) totalnro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) renovadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) renovadonro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) reactivadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) reactivadonro

,sum(p.monto) - sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end)
	- sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) nuevomonto
,count(p.codprestamo) - count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end)
	- count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) nuevonro
,case when @nro=0 then 0 else count(p.codprestamo)/cast(@nro as money) end PromDiario
from #Ptmos p with(nolock)
left outer join #liqreno l with(nolock) on l.codprestamo=p.codprestamo
left outer join tcspadronclientes pr with(nolock) on pr.codusuario=p.codasesor
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=p.codasesor and e.fecha=@fecfin-->huerfano
group by case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end
--,p.codprestamo
--order by dbo.fdufechaaperiodo(p.desembolso)

drop table #liqreno
drop table #Ptmos
drop table #sucursales
GO