SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaColocacionRenoReac_vs2] @fecini smalldatetime,@fecfin smalldatetime, @codoficina varchar(2000)
as
--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecini='20200901'
--set @fecfin='20200918'
--declare @codoficina varchar(500) 
--set @codoficina ='15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120
--,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'

select codigo 
into #sucursales
from dbo.fduTablaValores(@codoficina)

create table #Ptmos (codprestamo varchar(25) not null,codusuario varchar(15),desembolso smalldatetime,monto money,codproducto char(3),tiporeprog varchar(10))
insert into #Ptmos 
select codprestamo,codusuario,desembolso,monto,codproducto,isnull(tiporeprog,'SINRE') tiporeprog
from tcspadroncarteradet with(nolock)
where desembolso>=@fecini
and desembolso<=@fecfin
and codoficina not in('97','999')
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
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then 
	--p.monto 
	case when p.tiporeprog not in('REEST','RENOV') then p.monto else 0 end
	else 0 end) renovadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then 
	--p.codusuario 
	case when p.tiporeprog not in('REEST','RENOV') then p.codusuario else null end
	else null end) renovadonro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then 
	--p.monto 
	case when p.tiporeprog='RENOV' then p.monto else 0 end
	else 0 end) anticipadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then 
	--p.codusuario 
	case when p.tiporeprog='RENOV' then p.codusuario else null end
	else null end) anticipadodonro
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