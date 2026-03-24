SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSolicitudesDiaEstadoSucvs2] @region varchar(2000), @codestado varchar(20)  
as  
set nocount on  
  
Declare @Fecha   SmallDateTime  
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion  
  
--declare @region varchar(2000)  
--declare @codestado varchar(20)  
--set @region='302,102,303,103,315,115,341,141,342,142,474,274' 
--set @codestado='1'  
  
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
exec [10.0.2.14].finmas.dbo.pXaSolicitudesDiaEstadovs2 @codestado,@region  
  
--delete from #sol where codoficina not in (select codigo from dbo.fduTablaValores(@region)) --Filtra las oficinas  
  
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
 reactivadonro int,  
 reactivadomonto money,  
 nuevonro int,  
 nuevomonto money,  
 Oficina varchar(50) null  
)  
insert into #sol2 (estado,menor15,mayor15,monto,renovadonro,renovadomonto,reactivadonro,reactivadomonto, oficina)  
select estadoactual,menor15,mayor15,montoaprobado,renovadonro,renovadomonto,reactivadonro,reactivadomonto, isnull(oficina,'')  
from (  
select   case when s.estadoactual='Solicitado Preliminar' then 1  
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
,isnull(sum(menor15),0) menor  
,isnull(sum(mayor15),0) mayor  
,isnull(sum(monto),0) monto  
,isnull(sum(renovadomonto),0) renovadomonto
,isnull(sum(reactivadomonto),0) reactivadomonto  
,isnull(sum(renovadonro),0) renovadonro
,isnull(sum(reactivadonro),0) reactivadonro,  
'TOTAL'  
from #sol2  
  
update #sol2  
set nuevomonto = monto - renovadomonto - reactivadomonto  
,nuevonro = menor15 - renovadonro - reactivadonro  
  
select * from #sol2  
  
drop table #sol  
drop table #sol2  
drop table #liqreno  
--drop table #oficinas  
  
GO