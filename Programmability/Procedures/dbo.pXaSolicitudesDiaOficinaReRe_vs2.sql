SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSolicitudesDiaOficinaReRe_vs2] @codoficina varchar(1000)
as
Declare @Fecha 		SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion
--declare @codoficina varchar(1000)
--set @codoficina='15,21,3,301,302,303,304,307,308,309,310,311,315,318,320,321,322,323,324,325,326,327,33,330,332,333,334,335,336,337,339,341,342,344,37,4,41,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,5,6,8,25,28'

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
	codproducto char(3) NOT NULL,
	tiporeprog char(5)
)
insert into #sol
--exec [10.0.2.14].finmas.dbo.pXaSolicitudesDiaOficinaReRe @codoficina
exec [10.0.2.14].finmas.dbo.pXaSolicitudesDiaOficinaReRe_vs2 @codoficina
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
--and p.codproducto = (case when a.codproducto ='370' then '370' else '170' end)
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
	anticipadonro int,
	anticipadomonto money,
	reactivadonro int,
	reactivadomonto money,
	nuevonro int,
	nuevomonto money
)
insert into #sol2 (estado,menor15,mayor15,monto,renovadonro,renovadomonto,anticipadonro,anticipadomonto,reactivadonro,reactivadomonto)
select estadoactual,menor15,mayor15,montoaprobado,renovadonro,renovadomonto,anticipadonro,anticipadomonto,reactivadonro,reactivadomonto
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

,count(case when dbo.fdufechaaperiodo(s.fechadesembolso)=dbo.fdufechaaperiodo(l.cancelacion) or s.tiporeprog='RENOV' then 
			--s.codsolicitud
			case when s.tiporeprog='SINRE' then s.codsolicitud else null end
		else null end) renovadonro
,  sum(case when dbo.fdufechaaperiodo(s.fechadesembolso)=dbo.fdufechaaperiodo(l.cancelacion) or s.tiporeprog='RENOV' then 
			--s.montoaprobado
			case when s.tiporeprog='SINRE' then s.montoaprobado else 0 end
		else 0 end) renovadomonto

,count(case when dbo.fdufechaaperiodo(s.fechadesembolso)=dbo.fdufechaaperiodo(l.cancelacion) or s.tiporeprog='RENOV' then
			--s.codsolicitud
			case when s.tiporeprog='RENOV' then s.codsolicitud else null end
		else null end) anticipadonro
,sum(case when dbo.fdufechaaperiodo(s.fechadesembolso)=dbo.fdufechaaperiodo(l.cancelacion) or s.tiporeprog='RENOV' then
			--s.montoaprobado
			case when s.tiporeprog='RENOV' then s.montoaprobado else 0 end
		else 0 end) anticipadomonto

,count(case when dbo.fdufechaaperiodo(s.fechadesembolso)<>dbo.fdufechaaperiodo(l.cancelacion) and s.tiporeprog<>'RENOV' then s.codsolicitud else null end) reactivadonro
,sum(case when dbo.fdufechaaperiodo(s.fechadesembolso)<>dbo.fdufechaaperiodo(l.cancelacion) and s.tiporeprog<>'RENOV' then s.montoaprobado else 0 end) reactivadomonto
from #sol s
left outer join #liqreno l with(nolock) on l.codsolicitud=s.codsolicitud and l.codoficina=s.codoficina
group by s.estadoactual
) a 
order by orden

insert into #sol2 (estado,menor15,mayor15,monto,renovadomonto,reactivadomonto,renovadonro,reactivadonro,anticipadomonto,anticipadonro)
select 'Total' estado
,sum(menor15) menor
,sum(mayor15) mayor
,sum(monto) monto
,sum(renovadomonto) renovadomonto,sum(reactivadomonto) reactivadomonto
,sum(renovadonro) renovadonro,sum(reactivadonro) reactivadonro
,sum(anticipadomonto) anticipadomonto
,sum(anticipadonro) anticipadonro
from #sol2

update #sol2
set nuevomonto = monto - renovadomonto - reactivadomonto - anticipadomonto
,nuevonro = mayor15+menor15 - renovadonro - reactivadonro - anticipadonro

update #sol2
set menor15= mayor15+ menor15

select * from #sol2

drop table #sol
drop table #sol2
drop table #liqreno
GO