SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaColocacionRenoReac] @fecini smalldatetime,@fecfin smalldatetime, @codoficina varchar(500)
as
--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecini='20180901'
--set @fecfin='20180930'
--declare @codoficina varchar(500) 
--set @codoficina ='4,5,6'

select codigo 
into #sucursales
from dbo.fduTablaValores(@codoficina)

create table #Ptmos (codprestamo varchar(25) not null,codusuario varchar(15),desembolso smalldatetime,monto money,codproducto char(3))
insert into #Ptmos 
select codprestamo,codusuario,desembolso,monto,codproducto
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
dbo.fdufechaaperiodo(p.desembolso) periodo
,sum(p.monto) totalmonto
,count(p.codprestamo) totalnro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) renovadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) renovadonro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) reactivadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) reactivadonro
from #Ptmos p with(nolock)
left outer join #liqreno l with(nolock) on l.codprestamo=p.codprestamo
group by dbo.fdufechaaperiodo(p.desembolso)
order by dbo.fdufechaaperiodo(p.desembolso)

drop table #liqreno
drop table #Ptmos
drop table #sucursales



GO