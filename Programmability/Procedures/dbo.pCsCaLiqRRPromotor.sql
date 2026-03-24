SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
   
CREATE procedure [dbo].[pCsCaLiqRRPromotor] @fecha smalldatetime, @fecini smalldatetime   
as       
set nocount on      
   
   
--declare @fecha smalldatetime    
--set @fecha='20220902'    
    
--declare @fecini smalldatetime    
  
    
--set @fecini='20220901'   
  
 declare @fecfin smalldatetime    
set @fecfin=@fecha    
    
create table #dias(codprestamo varchar(25),nrodiasatraso int)    
create table #ptmos (codprestamo varchar(25))    
    
insert into #ptmos    
select codprestamo from tcspadroncarteradet p with(nolock)     
where p.cancelacion>=@fecini and p.cancelacion<=@fecfin    
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)    
and p.codoficina not in('97','230','231','999')   
    
insert into #dias     
select codprestamo,max(nrodiasatraso) nrodiasatraso    
from tcscartera with(nolock)    
where codprestamo in (select codprestamo from #ptmos)    
group by codprestamo    
    
   
select o.codoficina,o.nomoficina sucursal  
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador    
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor    
--,p.codusuario  
--,cl.nombrecompleto cliente    
,p.codprestamo  
,p.secuenciacliente  
--,p.monto  
--,p.desembolso fechadesembolso  
--,ca.fechavencimiento  
,p.cancelacion  
,d.nrodiasatraso atrasomaximo    
,case when cr.nuevodesembolso is not null then    
 case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then 'Renovado' else 'Reactivado' end    
 else     
 'Sin Renovar'    
 end Estado    
--,cr.nuevomonto,cr.nuevodesembolso  
--,cr.codprestamo codprestamonuevo,cl.telefonomovil    
--,datepart(week,p.cancelacion) semana    
--,p.tiporeprog    
 --into #base  
from tcspadroncarteradet p with(nolock)    
left outer join tCsPadronCarteraSecuen s with(nolock) on s.codprestamo=p.codprestamo    
left outer join(    
       select x.codprestamo,x.codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso,secuenciacliente,y.secuenciaproductivo    
       ,y.secuenciaconsumo    
       from tcspadroncarteradet x    
       left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo    
       where x.desembolso>=@fecini and x.desembolso<=@fecha  
) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion    
    and cr.secuenciacliente=p.secuenciacliente+1    
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina    
--inner join tclzona z with(nolock) on o.zona=z.zona    
--inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario    
inner join tcspadronclientes co with(nolock) on co.codusuario=p.ultimoasesor    
--left outer join tcscartera ca with(nolock) on ca.fecha=p.fechacorte and ca.codprestamo=p.codprestamo    
left outer join #dias d on d.codprestamo=p.codprestamo    
left outer join tcsempleadosfecha e on e.codusuario=p.ultimoasesor and e.fecha=@fecfin-->huerfano    
where p.cancelacion>=@fecini and p.cancelacion<=@fecfin    
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)    
and p.codoficina not in('97','230','231','999')  
  
  
drop table #ptmos    
drop table #dias    
--delete from #base where coordinador='HUERFANO'    
  
--select --*   
--codoficina,sucursal,coordinador,codpromotor--,cancelacion,atrasomaximo,estado  
--,sum(case when estado='Renovado' then 1 else 0 end) Renovados  
--,count(*) liquidados  
--from #base with(nolock)  
--where atrasomaximo<=15  
--group by codoficina,sucursal,coordinador,codpromotor  
    
--drop table #base  
GO

GRANT EXECUTE ON [dbo].[pCsCaLiqRRPromotor] TO [mledesmav]
GO