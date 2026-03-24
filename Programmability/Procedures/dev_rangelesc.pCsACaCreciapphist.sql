SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dev_rangelesc].[pCsACaCreciapphist] @codoficina varchar(4),@fecha smalldatetime       
as      
set nocount on   

--declare @codoficina varchar(4)      
--set @codoficina=301 

--declare @fecha smalldatetime      
--select @fecha='20230621'
      
declare @fecini smalldatetime      
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'      
set @fecini=@fecini-1      


create table #ptmos (codprestamo varchar(25))      
insert into #ptmos      
select codprestamo --distinct      
from tcscartera with(nolock)      
where fecha=@fecini --@fecini    
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))      
and codoficina not in('97','230','231')     
and codoficina=@codoficina       
and cartera='ACTIVA'      
and nrodiasatraso>=0 and nrodiasatraso<=30--15      



select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor      
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor,c.codprestamo,c.saldocapital      
,c.fechadesembolso      
into #CAIni      
from tcscartera c with(nolock)      
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor      
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecini--@fecini-->huerfano      
where c.fecha=@fecini       
and codprestamo in(select codprestamo from #ptmos with(nolock))      
and c.codoficina=@codoficina   

select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor      
,count(c.codprestamo) nro,sum(c.saldocapital) monto      
into #INI      
from tcscartera c with(nolock)      
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor      
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano      
where c.fecha=@fecini     
and codprestamo in(select codprestamo from #ptmos)      
and c.codoficina=@codoficina      
group by case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end      
      

truncate table #ptmos    
  
insert into #ptmos      
select distinct codprestamo       
from tcscartera with(nolock)      
where fecha=@fecha     
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))      
and codoficina not in('97','230','231')     
and codoficina=@codoficina      
and cartera='ACTIVA'     
and nrodiasatraso>=0 and nrodiasatraso<=30--15--   

select distinct codprestamo       
into #ptmosVencidos      
from tcscartera with(nolock)      
where fecha=@fecha   
and codprestamo not in (select codprestamo from tCsCarteraAlta)      
and codoficina not in('97','230','231')    
and codoficina=@codoficina       
and cartera='ACTIVA'     
and nrodiasatraso>30--15      

 

select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor      
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor,c.codprestamo,c.saldocapital      
,c.fechadesembolso      
into #CAFin      
from tcscartera c with(nolock)      
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor      
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha--@fecha-->huerfano      
where c.fecha=@fecha      
and c.codprestamo in(select codprestamo from #ptmos with(nolock))      
and c.codoficina=@codoficina      


select promotor      
,sum(case when tipo='CANCELADO' then nro else 0 end) nro_can      
,sum(case when tipo='CANCELADO' then monto else 0 end) monto_can      
,sum(case when tipo<>'CANCELADO' then nro else 0 end) nro_qui      
,sum(case when tipo<>'CANCELADO' then monto else 0 end) monto_qui      
into #CAN      
from (      
 select i.promotor      
 ,case when estadocalculado='CANCELADO' and cancelacion<=@fecha--@fecha       
    then 'CANCELADO'      
    else 'QUITADO' end TIPO      
 ,count(i.codprestamo) nro      
 --,sum(i.saldocapital) monto      
 ,sum(p.saldooriginal) monto --se cambia para saber el monto final del reasignado      
 --,sum(i.saldocapital-p.saldooriginal) monto --se cambia para saber el monto final del reasignado vs2      
 --,f.codprestamo codprestamo_fin,f.saldocapital      
 --,p.estadocalculado,p.cancelacion       
 from #CAini i with(nolock)      
 left outer join #CAfin f with(nolock) on i.promotor=f.promotor and i.codprestamo=f.codprestamo      
 inner join tcspadroncarteradet p with(nolock) on p.codprestamo=i.codprestamo      
 --left outer join tcscartera c with(nolock) on c.codprestamo=p.codprestamo and c.fecha=@fecha      
 where i.codprestamo not in(select codprestamo from #ptmosVencidos with(nolock)) and f.codprestamo is null       
 --and i.promotor='CASTILLO GUZMAN MARIA REYNALDA'      
 group by i.promotor,case when estadocalculado='CANCELADO' and cancelacion<=@fecha--@fecha       
    then 'CANCELADO'      
    else 'QUITADO' end      
) x      
group by promotor      


select promotor      
,sum(case when tipo='DESEMBOLSO' then nro else 0 end) nro_des      
,sum(case when tipo='DESEMBOLSO' then monto else 0 end) monto_des      
,sum(case when tipo<>'DESEMBOLSO' then nro else 0 end) nro_asi      
,sum(case when tipo<>'DESEMBOLSO' then monto else 0 end) monto_asi      
into #DEN      
from (      
 select f.promotor      
 ----SE AJUSTA PARA CONTEMPLAR MAS ESCENARIOS--    
 --,case when f.fechadesembolso>=@fecini and f.fechadesembolso<=@fecha then       
 --         case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else       
 --         'DESEMBOLSO' end      
 --                     else 'ASIGNADO' end TIPO      
,case when f.fechadesembolso>=@fecini and f.fechadesembolso<=@fecha then       
          case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else       
          'DESEMBOLSO' end      
     when f.fechadesembolso<@fecini then    
          case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' end     
     else 'ASIGNADO' end TIPO                                       
 ,count(f.codprestamo) nro,sum(f.saldocapital) monto      
 --,i.codprestamo,i.saldocapital,f.fechadesembolso      
 --,f.codprestamo codprestamo_fin,f.saldocapital       
 from #CAfin f left outer join #CAini i on i.promotor=f.promotor and i.codprestamo=f.codprestamo      
    inner join tcspadroncarteradet p with(nolock) on p.codprestamo=f.codprestamo      
 where i.codprestamo is null       
 --and f.promotor='CASTILLO GUZMAN MARIA REYNALDA'      
 group by f.promotor      
 --,case when f.fechadesembolso>=@fecini and f.fechadesembolso<=@fecha then       
 --         case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else       
 --         'DESEMBOLSO' end      
 --                     else 'ASIGNADO' end       
 ,case when f.fechadesembolso>=@fecini and f.fechadesembolso<=@fecha then       
          case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else       
          'DESEMBOLSO' end      
     when f.fechadesembolso<@fecini then    
          case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' end     
     else 'ASIGNADO' end    
) x      
group by promotor      


--------------------------------------------- #CUA
truncate table #ptmos      
insert into #ptmos      
select distinct codprestamo       
from tcscartera with(nolock)      
where fecha=@fecha     
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))      
and codoficina not in('97','230','231')     
and codoficina=@codoficina      
and cartera='ACTIVA'     
and nrodiasatraso>=0 and nrodiasatraso<=30--15--      
      
      
select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor      
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor      
,count(c.codprestamo) nro,sum(c.saldocapital) monto      
into #FIN      
from tcscartera c with(nolock)      
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor      
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano      
where c.fecha=@fecha     
and codprestamo in(select codprestamo from #ptmos)      
and c.codoficina=@codoficina      
group by case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end      
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end      
      

create table #cua(      
 codpromotor varchar(15),      
 promotor varchar(200),      
 ini_nro int default(0),      
 ini_monto money default(0),      
 fin_nro int default(0),      
 fin_monto money default(0)      
)      
insert #cua (codpromotor,promotor,ini_nro,ini_monto)      
select codpromotor,promotor, nro, monto      
from #INI with(nolock)      


update #cua       
set fin_nro=f.nro,fin_monto=f.monto      
from #FIN f with(nolock)      
inner join #cua i with(nolock) on i.promotor=f.promotor      

insert #cua (codpromotor,promotor,fin_nro,fin_monto)      
select codpromotor,promotor, nro, monto      
from #FIN      
where promotor not in(select promotor from #INI)   


             
   
select c.promotor,c.codpromotor,isnull(q.nro_qui,0) qui_nro_qui,isnull(q.monto_qui,0) qui_monto_qui,
isnull(a.nro_asi,0) asi_nro_asi,isnull(a.monto_asi,0) asi_monto_asi      
from #cua c with(nolock)      
left outer join #CAN q with(nolock) on q.promotor=c.promotor      
left outer join #DEN a with(nolock) on a.promotor=c.promotor 
WHERE c.codpromotor IS NOT NULL


drop table #ptmos      
drop table #CAIni      
drop table #CAFin           
drop table #CAN    
drop table #DEN  
drop table #INI      
drop table #FIN
drop table #ptmosVencidos  
drop table #cua
GO