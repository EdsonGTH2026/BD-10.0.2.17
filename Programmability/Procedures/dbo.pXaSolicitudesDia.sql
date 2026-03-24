SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--USE [FinamigoConsolidado]
--GO
--/****** Object:  StoredProcedure [dbo].[pCsSMSSolicitudes]    Script Date: 18/12/2017 04:36:01 pm ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
----pCsSMSSolicitudes
----drop procedure [pCsSMSSolicitudes]
--pXaSolicitudesDia
CREATE procedure [dbo].[pXaSolicitudesDia]
as
Declare @Fecha 		SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

SELECT p.codsolicitud,p.codoficina
,p.estado codestadoactual
,case when p.estado = 1 then 'Solicitado Preliminar'
		when p.estado in(2,21,22) then 'Solicitado'
		when p.estado = 3 then 'Credito'
		--when p.estado = 21 then 'Solicitado - Lider'
		when p.estado = 24 then 'Solicitado - Regional'
		when p.estado = 4 then 'Mesa de Control'
		--when p.estado = 22 then 'Solicitado - Lider'
		when p.estado = 5 then 'Aceptado - Lider'
		when p.estado = 11 then 'Cancelado'
		when p.estado = 23 then 'Solicitado - Regional'
		when p.estado = 31 then 'Credito'
		when p.estado = 6 then 'Fondeo'
		when p.estado = 7 then 'Entrega'
		when p.estado = 8 then 'Préstamo Entregado'
		when p.estado = 9 then 'Revisión de expediente'
		when p.estado = 10 then 'Expediente completo'
		when p.estado = 12 then 'Regional'
		when p.estado = 61 then 'Fondeo Progresemos'
		else 'No definido' end estadoactual
,case when datediff(day,p.fechahora,(@Fecha+1))<15 then 1 else 0 end Menor15
,case when datediff(day,p.fechahora,(@Fecha+1))>=15 then 1 else 0 end Mayor15
,s.montoaprobado
into #sol
FROM [10.0.2.14].finmas.dbo.tCaSolicitudProce p --with(nolock)
inner join [10.0.2.14].finmas.dbo.tcasolicitud s --with(nolock) 
on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina and s.codproducto=p.codproducto
where p.estado in (3,4,24,23,21,22,31,6,61,7,5,1,2)

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
select case when estadoactual='Solicitado' then 1
			when estadoactual='Solicitado Preliminar' then 2
			when estadoactual='Solicitado - regional' then 3
			when estadoactual='Credito' then 4
			when estadoactual='Mesa de Control' then 5
			when estadoactual='Aceptado - Lider' then 6
			when estadoactual='Fondeo' then 7
			when estadoactual='Fondeo progresemos' then 8
			when estadoactual='Entrega' then 9
			else 10 end orden
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