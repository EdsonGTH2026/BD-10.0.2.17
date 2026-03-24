SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pCsCaIncOrgP1 '20201007'
CREATE procedure [dbo].[pCsCaIncOrgP1] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20201007'

set nocount on

create table #sal(
	codoficina varchar(3),
	codasesor varchar(15),
	coordinador varchar(250),
	saldocapital money,
	montodesembolso money
)

insert into #sal
select 
c.codoficina
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador
,sum(c.saldocapital) saldocapital
,sum(c.montodesembolso) montodesembolso
from tcscartera c with(nolock)
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=c.fecha
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor
where c.fecha=@fecha--'20201007'
and c.cartera='ACTIVA'
and c.nrodiasatraso<=30
and c.tiporeprog<>'REEST'
--and c.codasesor='DLR890221F0221'
and c.codoficina not in('230','231')
group by c.codoficina
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end

delete from #sal where coordinador='HUERFANO'
--1,175,265.02
--1,121,225.07 --> 1,494,600.00
create table #P1(
	codoficina varchar(3),
	codasesor varchar(15),
	coordinador varchar(250),
	saldocapital money,
	desembolso money,
	PorDeuDese money
)
insert into #P1
select *
from (
	select codoficina,codasesor,coordinador,sum(saldocapital) saldocapital, sum(montodesembolso) desembolso
	,(case when sum(montodesembolso)=0 then 0 else (sum(saldocapital)/sum(montodesembolso))*100 end) PorDeuDese
	from #sal with(nolock)
	group by codoficina,codasesor,coordinador
) a

select codoficina,codasesor,coordinador,saldocapital,desembolso,pordeudese,categoria
,case	when categoria='MASTER' and PorDeuDese>=75 then 8.5
		when categoria='MASTER' and PorDeuDese>=65 and PorDeuDese<75 then 8
		when categoria='SENIOR' and PorDeuDese>=75 then 8.5
		when categoria='SENIOR' and PorDeuDese>=65 and PorDeuDese<75 then 8
		when categoria='JUNIOR' and PorDeuDese>=75 then 7.5
		when categoria='JUNIOR' and PorDeuDese>=65 and PorDeuDese<75 then 7
		when categoria='EN DESARROLLO' and PorDeuDese>=75 then 5.5
		when categoria='EN DESARROLLO' and PorDeuDese>=65 and PorDeuDese<75 then 5
		when categoria='PRINCIPIANTE' then 4.5
		else 4.5 end PorBono		
from (
	select codoficina,codasesor,coordinador,saldocapital,desembolso,pordeudese
	,case	when saldocapital<400000 then 'PRINCIPIANTE'
			when saldocapital>=400000 AND saldocapital<750000 then 'EN DESARROLLO'
			when saldocapital>=750000 AND saldocapital<1000000 then 'JUNIOR'
			when saldocapital>=1000000 AND saldocapital<1500000 then 'SENIOR'
			when saldocapital>=1500000 then 'MASTER'
			else 'NO DEFINIDO' end Categoria
	from #P1
) a

drop table #sal
drop table #P1
GO