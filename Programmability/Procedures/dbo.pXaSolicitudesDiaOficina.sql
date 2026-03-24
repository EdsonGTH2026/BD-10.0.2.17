SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSolicitudesDiaOficina] @codoficinas varchar(500)
as
Declare @Fecha 		SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

SELECT p.codsolicitud,p.codoficina
,p.estado codestadoactual
,case when p.estado = 1 then 'Solicitado Preliminar'
		when p.estado in(2,21,22) then 'Solicitado'
		when p.estado = 3 then 'Credito (VoBo)'
		--when p.estado = 21 then 'Solicitado - Lider'
		when p.estado = 24 then 'Solicitado - Regional'
		when p.estado = 4 then 'Mesa de Control'
		--when p.estado = 22 then 'Solicitado - Lider'
		when p.estado = 5 then 'Aceptado - Lider'
		when p.estado = 11 then 'Cancelado'
		when p.estado in(211,311) then 'Rechazado'
		when p.estado = 23 then 'Solicitado - Regional'
		when p.estado = 31 then 'Regional (VoBo)'
		when p.estado = 6 then 'Fondeo'
		when p.estado = 7 then 'Entrega'
		when p.estado = 8 then 'Préstamo Entregado'
		when p.estado = 9 then 'Revisión de expediente'
		when p.estado = 10 then 'Expediente completo'
		when p.estado = 12 then 'Regional'
		when p.estado = 61 then 'Fondeo Progresemos'
		when p.estado = 20 then 'Verificación Fisica'
		when p.estado in(28,281,282) then 'Evaluacion automatica'
		when p.estado in(25,26,27) then 'Gerente (VoBo)'
		else 'No definido' end estadoactual
,case when datediff(day,p.fechahora,(@Fecha+1))<15 then 1 else 0 end Menor15
,case when datediff(day,p.fechahora,(@Fecha+1))>=15 then 1 else 0 end Mayor15
,s.montoaprobado
into #sol
FROM [10.0.2.14].finmas.dbo.tCaSolicitudProce p --with(nolock)
inner join [10.0.2.14].finmas.dbo.tcasolicitud s --with(nolock) 
on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina and s.codproducto=p.codproducto
where p.estado in (3,4,24,23,21,22,31,6,61,7,5,1,2,20,28,281,282,25,26,27)
and p.codoficina in (select VALUE from dbo.fSplit(',',@codoficinas) )

create table #sol2(
	i int identity(1,1) not null,
	estado varchar(30),
	menor15 int,
	mayor15 int,
	monto money
)
insert into #sol2 (estado,menor15,mayor15,monto)
select estadoactual,menor15,mayor15,montoaprobado
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
,estadoactual,sum(Menor15) Menor15,sum(Mayor15) Mayor15,sum(montoaprobado) montoaprobado
from #sol
group by estadoactual
) a 
order by orden

insert into #sol2 (estado,menor15,mayor15,monto)
select 'Total' estado
,sum(menor15) menor
,sum(mayor15) mayor
,sum(monto) monto
from #sol2

select * from #sol2

drop table #sol
drop table #sol2
GO