SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----exec pCsCaIncOrgP1 '20201007'  
create procedure [dbo].[pCsCaIncOrgP1x_vs2] @fecha smalldatetime  
as  
set nocount on  
--declare @fecha smalldatetime  
--set @fecha='20211130'  
  
create table #sal( 
 codoficina varchar(3),  
 codasesor varchar(15),  
 coordinador varchar(250),  
 saldocapital money,
 --FechaIngreso smalldatetime, 
 --mes int, 
-- montodesembolso money   // campo no requerido en la nueva actualizacion
)  
  
insert into #sal  
select   
c.codoficina   
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor  
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador  
,sum(c.saldocapital) saldocapital 
--,FechaIngreso
--,DATEDIFF(MONTH,co.FechaIngreso,getdate()) mes
--,sum(c.montodesembolso) montodesembolso   // campo no requerido en la nueva actualizacion
--select *,e.*
from tcscartera c with(nolock)  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=c.fecha  
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor 
--where  c.codasesor = 'LCR010114FH300' and c.fecha='20211130' 
where c.fecha=@fecha--'20201007'  
and c.cartera='ACTIVA'  
/*and c.nrodiasatraso>=0*/ and c.nrodiasatraso<=30   -- de (0-30 dias de retraso)
and c.tiporeprog<>'REEST'  
and c.codoficina not in('230','231')  
group by  c.fecha,c.codoficina  
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end  
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end  
--,FechaIngreso
----------------------- 'LCR010114FH300' es coodinador HUERFANO

--select * 
--from #sal with(nolock) 
--where  codasesor = 'LCR010114FH300'

delete from #sal where coordinador='HUERFANO'  
--1,175,265.02  
--1,121,225.07 --> 1,494,600.00  

--create table #Puno( ----------  // campo no requerido en la nueva actualizacion
-- codoficina varchar(3),  
-- codasesor varchar(15),  
-- coordinador varchar(250),  
-- saldocapital money,  
-- --desembolso money,  
-- --PorDeuDese money  
--)  
--insert into #Puno  
--select *  
--from (  
-- select codoficina,codasesor,coordinador,sum(saldocapital) saldocapital--, sum(montodesembolso) desembolso  
---- ,(case when sum(montodesembolso)=0 then 0 else (sum(saldocapital)/sum(montodesembolso))*100 end) PorDeuDese  
-- from #sal with(nolock)  
-- group by codoficina,codasesor,coordinador  
--) a  
  
  
select codoficina,codasesor,coordinador,saldocapital,categoria--,FechaIngreso 
--,FechaIngreso,mes
--,desembolso,pordeudese 
,case when categoria='TRAINEE' then(Case when saldocapital>=40000 AND saldocapital<100000 then 500 
									when saldocapital>=100000 AND saldocapital<150000 then 750 
									when saldocapital>=150000 AND saldocapital<200000 then 750
									when saldocapital>=200000 AND saldocapital<250000 then 1000
									when saldocapital>=250000 AND saldocapital<300000 then 1000  
									when saldocapital>=300000 AND saldocapital<350000 then 1150
									when saldocapital>=350000 AND saldocapital<400000 then 1350
									when saldocapital>=400000 AND saldocapital<450000 then 1500 
									when saldocapital>=450000 AND saldocapital<500000 then 1700
									when saldocapital>=500000 AND saldocapital<550000 then 1900 
									else 0 end)  
  when categoria='JUNIOR' then (Case when saldocapital>=550000 AND saldocapital<600000 then 2100 
									when saldocapital>=600000 AND saldocapital<650000 then 2300
									when saldocapital>=650000 AND saldocapital<700000 then 2450
									when saldocapital>=700000 AND saldocapital<750000 then 2650
									when saldocapital>=750000 AND saldocapital<800000 then 2850 
									when saldocapital>=800000 AND saldocapital<850000 then 3050
									when saldocapital>=850000 AND saldocapital<900000 then 3250
									when saldocapital>=900000 AND saldocapital<950000 then 3400 
									when saldocapital>=950000 AND saldocapital<1000000 then 3600
									when saldocapital>=1000000 AND saldocapital<1050000 then 3800
									else 0 end)   
  when categoria='SENIOR' then(Case when saldocapital>=1050000 AND saldocapital<1100000 then 4000 
									when saldocapital>=1100000 AND saldocapital<1150000 then 4200
									when saldocapital>=1150000 AND saldocapital<1200000 then 4350
									when saldocapital>=1200000 AND saldocapital<1250000 then 4550
									when saldocapital>=1250000 AND saldocapital<1300000 then 4750 
									when saldocapital>=1300000 AND saldocapital<1350000 then 4950
									when saldocapital>=1350000 AND saldocapital<1400000 then 5150
									when saldocapital>=1400000 AND saldocapital<1450000 then 5300 
									when saldocapital>=1450000 AND saldocapital<1500000 then 5500 
									else 0 end)
  when categoria='MASTER 1.5'then (Case when saldocapital>=1500000 AND saldocapital<1600000 then 5900 
									when saldocapital>=1600000 AND saldocapital<1650000 then 6100
									when saldocapital>=1650000 AND saldocapital<1700000 then 6250
									when saldocapital>=1700000 AND saldocapital<1750000 then 6450
									when saldocapital>=1750000 AND saldocapital<1800000 then 6650 
									when saldocapital>=1800000 AND saldocapital<1850000 then 6850
									when saldocapital>=1850000 AND saldocapital<1900000 then 7050
									when saldocapital>=1900000 AND saldocapital<1950000 then 7200 
									when saldocapital>=1950000 AND saldocapital<2000000 then 7400 
									when saldocapital>=2000000 AND saldocapital<2050000 then 7600 
									else 0 end)  
  when categoria='MASTER 2.0' then (Case when saldocapital>=2050000 AND saldocapital<2100000 then 7800 
									when saldocapital>=2100000 AND saldocapital<2150000 then 8000
									when saldocapital>=2150000 AND saldocapital<2200000 then 8150
									when saldocapital>=2200000 AND saldocapital<2250000 then 8350
									when saldocapital>=2250000 AND saldocapital<2300000 then 8550 
									when saldocapital>=2300000 AND saldocapital<2350000 then 8750
									when saldocapital>=2350000 AND saldocapital<2400000 then 8950
									when saldocapital>=2400000 AND saldocapital<2450000 then 9100 
									when saldocapital>=2450000 AND saldocapital<2500000 then 9300 
									when saldocapital>=2500000 AND saldocapital<2550000 then 9500 
									else 0 end)
  when categoria='MASTER 2.5' then (Case when saldocapital>=2550000 AND saldocapital<2600000 then 9700 
									when saldocapital>=2600000 AND saldocapital<2650000 then 9900
									when saldocapital>=2650000 AND saldocapital<2700000 then 10050
									when saldocapital>=2700000 AND saldocapital<2750000 then 10250
									when saldocapital>=2750000 AND saldocapital<2800000 then 10450 
									when saldocapital>=2800000 AND saldocapital<2850000 then 10650
									when saldocapital>=2850000 AND saldocapital<2900000 then 10850
									when saldocapital>=2900000 AND saldocapital<3000000 then 11000 					
									when saldocapital>=3000000 then 11400 
									else 0 end)  
  else 0 end BonoObjetivo  
from (  
 select codoficina,codasesor,coordinador,saldocapital--,FechaIngreso,mes--,desembolso,pordeudese  
 ,case when saldocapital>=40000 AND saldocapital<550000 then 'TRAINEE'  
   when saldocapital>=550000 AND saldocapital<1050000 then 'JUNIOR '  
   when saldocapital>=1050000 AND saldocapital<1500000 then 'SENIOR'  
   when saldocapital>=1500000 AND saldocapital<2050000 then 'MASTER 1.5'  
   when saldocapital>=2050000 AND saldocapital<2550000 then 'MASTER 2.0'  
   when saldocapital>=2550000 then 'MASTER 2.5'  
   else 'TRAINEE' end Categoria  
   
 from #sal  
 --where codasesor='STE890117FM100'  
) a  
  
drop table #sal  


--tcspadronplancuotas
GO