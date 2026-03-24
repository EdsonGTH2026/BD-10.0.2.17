SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSolicitudesDiaOficinaReRe] @codoficina varchar(1000)
as
Declare @Fecha 		SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion
--declare @codoficina varchar(1000)
--set @codoficina='15,21,3,301,302,303,304,307,308,309,310,311,315,318,320,321,322,323,324,325,326,327,33,330,332,333,334,335,336,337,339,341,342,344,37,4,41,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,5,6,8,25,28'

--declare @columnNames varchar(8000)
--select @columnNames = COALESCE( @columnNames  + ',', '') + codoficina
--from tcloficinas with(nolock)
--where tipo<>'Cerrada'
--and (codoficina<100 or codoficina>=300)
--and codoficina not in(97,99,98)
--select @columnNames

--SELECT p.codsolicitud,p.codoficina
--,p.estado codestadoactual
--,case when p.estado = 1 then 'Solicitado Preliminar'
--		when p.estado in(2,21,22) then 'Solicitado'
--		when p.estado = 3 then 'Credito'
--		--when p.estado = 21 then 'Solicitado - Lider'
--		when p.estado = 24 then 'Solicitado - Regional'
--		when p.estado = 4 then 'Mesa de Control'
--		--when p.estado = 22 then 'Solicitado - Lider'
--		when p.estado = 5 then 'Aceptado - Lider'
--		when p.estado = 11 then 'Cancelado'
--		when p.estado = 23 then 'Solicitado - Regional'
--		when p.estado = 31 then 'Credito'
--		when p.estado = 6 then 'Fondeo'
--		when p.estado = 7 then 'Entrega'
--		when p.estado = 8 then 'Préstamo Entregado'
--		when p.estado = 9 then 'Revisión de expediente'
--		when p.estado = 10 then 'Expediente completo'
--		when p.estado = 12 then 'Regional'
--		when p.estado = 61 then 'Fondeo Progresemos'
--		else 'No definido' end estadoactual
--,case when datediff(day,p.fechahora,(@Fecha+1))<15 then 1 else 0 end Menor15
--,case when datediff(day,p.fechahora,(@Fecha+1))>=15 then 1 else 0 end Mayor15
--,s.montoaprobado
--,s.codusuario,s.fechadesembolso,s.codproducto
--into #sol
--FROM [10.0.2.14].finmas.dbo.tCaSolicitudProce p --with(nolock)
--inner join [10.0.2.14].finmas.dbo.tcasolicitud s --with(nolock) 
--on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina and s.codproducto=p.codproducto
--where p.estado in (3,4,24,23,21,22,31,6,61,7,5,1,2)
--and p.codoficina in (select VALUE from dbo.fSplit(',',@codoficina) )

create table #sol (
	codsolicitud varchar(15) NOT NULL,
	codoficina varchar(4) NOT NULL,
	codestadoactual int NULL,
	estadoactual varchar(30) NOT NULL,
	Menor15 int NOT NULL,
	Mayor15 int NOT NULL,
	montoaprobado money NULL,
	codusuario varchar(20) NOT NULL,
	fechadesembolso smalldatetime NULL,
	codproducto char(3) NOT NULL
)
insert into #sol
exec [10.0.2.14].finmas.dbo.pXaSolicitudesDiaOficinaReRe @codoficina
--select VALUE from dbo.fSplit(',','4,5,6,7,8,') 
--select top 100 * from [10.0.2.14].finmas.dbo.tcasolicitud 
update #sol
set codusuario=cl.codusuario
from #sol p with(nolock)
inner join tcspadronclientes cl with(nolock) on p.codusuario=cl.codorigen

create table #liqreno(codsolicitud varchar(25) not null,codoficina varchar(4),desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)
insert into #liqreno
select p.codsolicitud,p.codoficina,p.fechadesembolso,p.codusuario,max(a.cancelacion) cancelacion
from #sol p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.fechadesembolso
and p.codproducto = (case when a.codproducto ='370' then '370' else '170' end)
group by p.codsolicitud,p.codoficina,p.fechadesembolso,p.codusuario
having max(a.cancelacion) is not null

create table #sol2(
	i int identity(1,1) not null,
	estado varchar(30),
	menor15 int,
	mayor15 int,
	monto money,
	renovadonro int,
	renovadomonto money,
	reactivadonro int,
	reactivadomonto money,
	nuevonro int,
	nuevomonto money
)
insert into #sol2 (estado,menor15,mayor15,monto,renovadonro,renovadomonto,reactivadonro,reactivadomonto)
select estadoactual,menor15,mayor15,montoaprobado,renovadonro,renovadomonto,reactivadonro,reactivadomonto
from (
select 
		case when s.estadoactual='Solicitado Preliminar' then 1
			when s.estadoactual='Solicitado' then 2
			when s.estadoactual='Solicitado - Regional' then 3
			when s.estadoactual='Verificación Fisica' then 4
			when s.estadoactual='Evaluacion automatica' then 5
			when s.estadoactual='Gerente (VoBo)' then 6
			when s.estadoactual='Regional (VoBo)' then 7
			when s.estadoactual='Credito (VoBo)' then 8
			when s.estadoactual='Mesa de Control' then 9
			when s.estadoactual='Aceptado - Lider' then 10
			when s.estadoactual='Fondeo' then 11
			when s.estadoactual='Fondeo Progresemos' then 12
			when s.estadoactual='Entrega' then 13
			when s.estadoactual='Préstamo Entregado' then 14
			when s.estadoactual='Cancelado' then 15
			when s.estadoactual='Rechazado' then 16		
			else 20 end orden
,s.estadoactual,sum(s.Menor15) Menor15,sum(s.Mayor15) Mayor15,sum(s.montoaprobado) montoaprobado
,count(case when dbo.fdufechaaperiodo(s.fechadesembolso)=dbo.fdufechaaperiodo(l.cancelacion) then s.codsolicitud else null end) renovadonro
,sum(case when dbo.fdufechaaperiodo(s.fechadesembolso)=dbo.fdufechaaperiodo(l.cancelacion) then s.montoaprobado else 0 end) renovadomonto
,count(case when dbo.fdufechaaperiodo(s.fechadesembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then s.codsolicitud else null end) reactivadonro
,sum(case when dbo.fdufechaaperiodo(s.fechadesembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then s.montoaprobado else 0 end) reactivadomonto
from #sol s
left outer join #liqreno l with(nolock) on l.codsolicitud=s.codsolicitud and l.codoficina=s.codoficina
group by s.estadoactual
) a 
order by orden

insert into #sol2 (estado,menor15,mayor15,monto,renovadomonto,reactivadomonto,renovadonro,reactivadonro)
select 'Total' estado
,sum(menor15) menor
,sum(mayor15) mayor
,sum(monto) monto
,sum(renovadomonto) renovadomonto,sum(reactivadomonto) reactivadomonto
,sum(renovadonro) renovadonro,sum(reactivadonro) reactivadonro
from #sol2

update #sol2
set nuevomonto = monto - renovadomonto - reactivadomonto
,nuevonro = mayor15+menor15 - renovadonro - reactivadonro

update #sol2
set menor15= mayor15+ menor15

select * from #sol2

drop table #sol
drop table #sol2
drop table #liqreno
GO