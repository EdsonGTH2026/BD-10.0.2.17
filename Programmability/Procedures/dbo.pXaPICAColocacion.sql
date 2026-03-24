SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaPICAColocacion '15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317
--,117,318,118,319,119,320,120,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132
--,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28',''
CREATE procedure [dbo].[pXaPICAColocacion] @codoficina varchar(2000),@codasesor varchar(15)
as
set nocount on
--declare @T1 datetime
--declare @T2 datetime

declare @fecha smalldatetime
select @fecha=fechaconsolidacion+1 from vcsfechaconsolidacion
--set @fecha='20180930'
declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
declare @fecfin smalldatetime
set @fecfin=@fecha

--declare @codoficina varchar(500)
--set @codoficina='15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28,434'
------set @codoficina='4'
--declare @codasesor varchar(15)
------------set @codasesor='CSL1612751'
------------set @codasesor='UMC7909181'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

create table #Ptmos2 (codprestamo varchar(25) not null,codusuario varchar(15),desembolso smalldatetime,monto money,codproducto char(3),codfondo int)
--ALTER TABLE #Ptmos2 WITH NOCHECK ADD CONSTRAINT [PK_#Ptmos2] PRIMARY KEY CLUSTERED (codprestamo)  ON [PRIMARY] 
CREATE INDEX [IX_Ptmos2] ON [dbo].[#Ptmos2]([codusuario],[desembolso],[codproducto]) WITH  FILLFACTOR = 100 ON [PRIMARY]

insert into #Ptmos2 
select p.codprestamo,p.codusuario,p.desembolso,p.monto,p.codproducto,c.codfondo
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on p.codprestamo=c.codprestamo and p.fechacorte=c.fecha
where p.desembolso>=@fecini
and p.desembolso<=@fecfin
and p.codoficina<>'97'
--and codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
and p.codoficina in(select codigo from @sucursales)
and (p.ultimoasesor=@codasesor or @codasesor='' or @codasesor is null)

--set @T2 = getdate()
--print 'T4 '+ cast( datediff(millisecond, @T1, @T2) as varchar(30))
--set @T1 = getdate()

create table #liqreno(codprestamo varchar(25) not null,desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)

insert into #liqreno
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion
from #Ptmos2 p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso
--and p.codproducto = (case when a.codproducto ='370' then '370' else '170' end)
group by p.codprestamo,p.desembolso,p.codusuario
having max(a.cancelacion) is not null

--set @T2 = getdate()
--print 'T5 '+ cast( datediff(millisecond, @T1, @T2) as varchar(30))
--set @T1 = getdate()
declare @f smalldatetime
set @f=@fecha--+1
create table #De(i int identity(1,1),periodo varchar(10),totalmonto money,totalnro int,renovadomonto money,renovadonro int,reactivadomonto money,reactivadonro int,nuevomonto money,nuevonro int,propio money,progresemos money)
insert into #De (periodo,totalmonto,totalnro,renovadomonto,renovadonro,reactivadomonto,reactivadonro,propio,progresemos)
exec pCsCaColocacionRenoReacDia @f,@codoficina

update #De set nuevomonto=totalmonto-renovadomonto-reactivadomonto,nuevonro=totalnro-renovadonro-reactivadonro
--select * from #De

declare @tb table(
periodo varchar(6),
totalmonto money,
totalnro int,
renovadomonto money,
renovadonro int,
renovadopor money,
reactivadomonto money,
reactivadonro int,
reactivadopor money,
nuevomonto money,
nuevonro int,
nuevopor money,
propio money,
progresemos money
)

insert into @tb (periodo,totalmonto,totalnro,renovadomonto,renovadonro,reactivadomonto,reactivadonro,nuevomonto,nuevonro,propio,progresemos)
select a.periodo,sum(a.totalmonto) totalmonto,sum(a.totalnro) totalnro
,sum(a.renovadomonto) renovadomonto,sum(a.renovadonro) renovadonro
,sum(a.reactivadomonto) reactivadomonto,sum(a.reactivadonro) reactivadonro
,sum(a.nuevomonto) nuevomonto,sum(a.nuevonro) nuevonro
,sum(a.propio) propio
,sum(a.progresemos) progresemos
from (
	select
	dbo.fdufechaaperiodo(p.desembolso) periodo
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
	,sum(case when p.codfondo=20 then p.monto*0.3 else p.monto end) propio
	,sum(case when p.codfondo=20 then p.monto*0.7 else 0 end) progresemos
	from #Ptmos2 p with(nolock)
	left outer join #liqreno l with(nolock) on l.codprestamo=p.codprestamo
	group by dbo.fdufechaaperiodo(p.desembolso)
	union
	select periodo,totalmonto,totalnro,renovadomonto,renovadonro,reactivadomonto,reactivadonro,nuevomonto,nuevonro,propio,progresemos
	from #de
) a
group by a.periodo

--select a.periodo,a.totalmonto+d.totalmonto totalmonto,a.totalnro+d.totalnro totalnro
--,a.renovadomonto+isnull(d.renovadomonto,0) renovadomonto,a.renovadonro+isnull(d.renovadonro,0) renovadonro,a.renovadopor
--,a.reactivadomonto+isnull(d.reactivadomonto,0) reactivadomonto,a.reactivadonro+isnull(d.reactivadonro,0) reactivadonro,a.reactivadopor
--,a.nuevomonto+isnull(d.nuevomonto,0) nuevomonto,a.nuevonro+isnull(d.nuevonro,0) nuevonro,a.nuevopor
--from (
--	select
--	dbo.fdufechaaperiodo(p.desembolso) periodo
--	,sum(p.monto) totalmonto
--	,count(p.codprestamo) totalnro
--	,sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) renovadomonto
--	,count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) renovadonro
--	,(sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end)
--		/sum(p.monto))*100 renovadopor
--	,sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) reactivadomonto
--	,count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) reactivadonro
--	,(sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end)
--		/sum(p.monto))*100 reactivadopor
--	,sum(p.monto)-sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end)
--		-sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end) nuevomonto
--	,count(p.codprestamo)-count(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end)
--		-count(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.codusuario else null end) nuevonro
--	,((sum(p.monto)-sum(case when dbo.fdufechaaperiodo(p.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end)
--		-sum(case when dbo.fdufechaaperiodo(p.desembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then p.monto else 0 end))
--		/sum(p.monto))*100 nuevopor
--	--into #Coloca
--	from #Ptmos2 p with(nolock)
--	left outer join #liqreno l with(nolock) on l.codprestamo=p.codprestamo
--	group by dbo.fdufechaaperiodo(p.desembolso)
--) a 
--left outer join #de d on d.periodo=a.periodo


--set @T2 = getdate()
--print 'T6 '+ cast( datediff(millisecond, @T1, @T2) as varchar(30))
--set @T1 = getdate()

update @tb set renovadopor=(renovadomonto/totalmonto)*100,reactivadopor=(reactivadomonto/totalmonto)*100,nuevopor=(nuevomonto/totalmonto)*100

select * from @tb

drop table #liqreno
drop table #Ptmos2
drop table #De

GO