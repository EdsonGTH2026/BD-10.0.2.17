SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSolicitudesDiaEstadoSuc] @region varchar(10), @codestado varchar(20)
as
set nocount on

Declare @Fecha 		SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

--oficinas en tabla temporal
create table #oficinas(CodOficina varchar(500) null, NomOficina varchar(100) null )

insert into #oficinas(CodOficina, NomOficina)
exec pCsCboOficinasyZonasVs2 @region, '', 0

--PRUEBAS COMENTAR
--declare @codestado varchar(20)
--set @codestado = '2'

--Arma la cadena de sucursales
--select * from #oficinas
declare @cadenaoficinas varchar(1000)
set @cadenaoficinas = ''
select @cadenaoficinas = @cadenaoficinas + ','+ isnull(rtrim(CodOficina),'') from #oficinas
--select @cadenaoficinas
--select codigo from dbo.fduTablaValores( @cadenaoficinas ) --comentar


--set @codoficina='15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'

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
	codproducto char(3) NOT NULL,
	Oficina varchar(50) null
)

insert into #sol
exec [10.0.2.14].finmas.dbo.pXaSolicitudesDiaEstado @codestado
--exec [10.0.2.14].finmas.dbo.pXaSolicitudesDiaOficinaReRe @codoficina
--select VALUE from dbo.fSplit(',','4,5,6,7,8,') 
--select top 100 * from [10.0.2.14].finmas.dbo.tcasolicitud 

--select 'sol', * from #sol  --comentar
--Borra las oficinas que no corresponden a la region
delete from #sol where codoficina not in (select codigo from dbo.fduTablaValores( @cadenaoficinas )) --Filtra las oficinas
--select 'sol', * from #sol  --comentar

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
	nuevomonto money,
	Oficina varchar(50) null
)
insert into #sol2 (estado,menor15,mayor15,monto,renovadonro,renovadomonto,reactivadonro,reactivadomonto, oficina)
select estadoactual,menor15,mayor15,montoaprobado,renovadonro,renovadomonto,reactivadonro,reactivadomonto, isnull(oficina,'')
from (
select 		case when s.estadoactual='Solicitado Preliminar' then 1
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
,s.estadoactual
,sum(s.Menor15) Menor15,sum(s.Mayor15) Mayor15,sum(s.montoaprobado) montoaprobado
,count(case when dbo.fdufechaaperiodo(s.fechadesembolso)=dbo.fdufechaaperiodo(l.cancelacion) then s.codsolicitud else null end) renovadonro
,sum(case when dbo.fdufechaaperiodo(s.fechadesembolso)=dbo.fdufechaaperiodo(l.cancelacion) then s.montoaprobado else 0 end) renovadomonto
,count(case when dbo.fdufechaaperiodo(s.fechadesembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then s.codsolicitud else null end) reactivadonro
,sum(case when dbo.fdufechaaperiodo(s.fechadesembolso)<>dbo.fdufechaaperiodo(l.cancelacion) then s.montoaprobado else 0 end) reactivadomonto
,isnull(s.Oficina,'') as Oficina
from #sol s
left outer join #liqreno l with(nolock) on l.codsolicitud=s.codsolicitud and l.codoficina=s.codoficina
--where p.codoficina in (select codigo from dbo.fduTablaValores( @cadenaoficinas )) --Filtra las oficinas
--group by s.estadoactual
group by s.Oficina, s.estadoactual
) a 
order by orden

insert into #sol2 (estado,menor15,mayor15,monto,renovadomonto,reactivadomonto,renovadonro,reactivadonro, oficina)
select 'Estado' estado
,sum(menor15) menor
,sum(mayor15) mayor
,sum(monto) monto
,sum(renovadomonto) renovadomonto,sum(reactivadomonto) reactivadomonto
,sum(renovadonro) renovadonro,sum(reactivadonro) reactivadonro,
'TOTAL'
from #sol2

update #sol2
set nuevomonto = monto - renovadomonto - reactivadomonto
,nuevonro = menor15 - renovadonro - reactivadonro

select * from #sol2

drop table #sol
drop table #sol2
drop table #liqreno
drop table #oficinas


GO