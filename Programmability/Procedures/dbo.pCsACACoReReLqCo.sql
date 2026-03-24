SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACACoReReLqCo]
as
set nocount on

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion
--set @fecha='20190131'
declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
declare @fecfin smalldatetime
set @fecfin=@fecha

create table #Ptmos2 (codprestamo varchar(25) not null,codusuario varchar(15),desembolso smalldatetime,monto money,codproducto char(3),codoficina varchar(4))
CREATE INDEX [IX_Ptmos2] ON [dbo].[#Ptmos2]([codusuario],[desembolso],[codproducto]) WITH  FILLFACTOR = 100 ON [PRIMARY]

insert into #Ptmos2 
select codprestamo,codusuario,desembolso,monto,codproducto,codoficina
from tcspadroncarteradet with(nolock)
where desembolso>=@fecini
and desembolso<=@fecfin
and codoficina<>'97'
--and codoficina='330'

create table #liqreno(codprestamo varchar(25) not null,desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)
insert into #liqreno
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion
from #Ptmos2 p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
--and p.codproducto = (case when a.codproducto ='370' then '370' else '170' end)
group by p.codprestamo,p.desembolso,p.codusuario
having max(a.cancelacion) is not null

declare @tb table(
periodo varchar(6),
codoficina varchar(4),
totalmonto money,
totalnro int,
renovadomonto money,
renovadonro int,
reactivadomonto money,
reactivadonro int,
nuevomonto money,
nuevonro int
)

insert into @tb (periodo,codoficina,totalmonto,totalnro,renovadomonto,renovadonro,reactivadomonto,reactivadonro,nuevomonto,nuevonro)
select
dbo.fdufechaaperiodo(p.desembolso) periodo,p.codoficina
,sum(p.monto) totalmonto
,count(p.codprestamo) totalnro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) renovadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) renovadonro
,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) reactivadomonto
,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) reactivadonro
,sum(p.monto)-sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end)
	-sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) nuevomonto
,count(p.codprestamo)-count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end)
	-count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) nuevonro
from #Ptmos2 p with(nolock)
left outer join #liqreno l with(nolock) on l.codprestamo=p.codprestamo
group by dbo.fdufechaaperiodo(p.desembolso),p.codoficina

declare @Lq table(
	periodo varchar(6),
	codoficina varchar(4),
	nro money,
	monto int
)

insert into @Lq
select dbo.fdufechaaperiodo(cancelacion) periodo
,case when codoficina='131' then '37'
	  when codoficina='114' then '25'
	  else
		case when cast(CodOficina as int)>100 and cast(CodOficina as int)<300 then cast((cast(CodOficina as int)+200) as varchar(4))  else CodOficina end 
	  end codoficina
,count(codprestamo) nro,sum(monto) monto
from tcspadroncarteradet with(nolock)
where cancelacion>=@fecini and cancelacion<=@fecfin
and codoficina not in('97','231','230')
group by dbo.fdufechaaperiodo(cancelacion)
,case when codoficina='131' then '37'
	  when codoficina='114' then '25'
	  else
		case when cast(CodOficina as int)>100 and cast(CodOficina as int)<300 then cast((cast(CodOficina as int)+200) as varchar(4))  else CodOficina end 
	  end

declare @Co table(
	periodo varchar(6),
	codoficina varchar(4),
	nro int,
	capital money,
	interes money,
	cargos money
)
insert into @Co
select dbo.fdufechaaperiodo(fecha) periodo
,case when codoficinacuenta='131' then '37'
	  when codoficinacuenta='114' then '25'
	  else
		case when cast(codoficinacuenta as int)>100 and cast(codoficinacuenta as int)<300 then cast((cast(codoficinacuenta as int)+200) as varchar(4))  else codoficinacuenta end 
	  end codoficina
,count(codigocuenta) nro
,sum(montocapitaltran) capital
,sum(montointerestran) interes
,sum(montocargos) cargos
from tcstransacciondiaria with(nolock)
where fecha>=@fecini and fecha<=@fecfin
and codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
and codoficina not in('97','231','230')
group by dbo.fdufechaaperiodo(fecha)
,case when codoficinacuenta='131' then '37'
	  when codoficinacuenta='114' then '25'
	  else
		case when cast(codoficinacuenta as int)>100 and cast(codoficinacuenta as int)<300 then cast((cast(codoficinacuenta as int)+200) as varchar(4))  else codoficinacuenta end 
	  end
	  
--select top 100 * from tcstransacciondiaria where codsistema='CA' and  fecha>='20190101' and fecha<='20190131' and codoficina=10
truncate table tCsACACoReReLqCo
insert into tCsACACoReReLqCo
select c.periodo,o.nomoficina,z.nombre region,totalmonto,totalnro,renovadomonto,renovadonro,reactivadomonto,reactivadonro,nuevomonto,nuevonro
,l.nro Liq_Nro,l.monto Liq_Monto
,co.nro Co_Nro,co.capital Co_Capital,co.interes Co_Interes,co.cargos Co_Cargos
---into tCsACACoReReLqCo
from @tb c
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
left outer join @Lq l on l.codoficina=c.codoficina
left outer join @Co co on co.codoficina=c.codoficina

drop table #liqreno
drop table #Ptmos2

--select * from tCsACACoReReLqCo
GO