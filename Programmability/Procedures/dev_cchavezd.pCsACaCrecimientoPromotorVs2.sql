SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dev_cchavezd].[pCsACaCrecimientoPromotorVs2] @codoficina varchar(4)  
as  
set nocount on  
--begin tran
SET ANSI_WARNINGS OFF  
--declare @t1 datetime  
--declare @t2 datetime  
  
declare @fecha smalldatetime  
select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
declare @fecini smalldatetime  
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'  
set @fecini=@fecini-1  
  
--declare @codoficina varchar(4)  
--set @codoficina=330  
--select * from tcloficinas where nomoficina like '%penjamo%'  
  
--set @t1=getdate()  
  
declare @x_fec datetime  
set @x_fec=@fecini  
  
create table #ptmos (codprestamo varchar(25))  
insert into #ptmos  
select codprestamo --distinct  
from tcscartera with(nolock)  
where fecha=@x_fec--@fecini  
and cartera='ACTIVA' and codoficina not in('97','230','231')  
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
and codoficina=@codoficina  
and nrodiasatraso>=0 and nrodiasatraso<=30--15  
  
--set @t2=getdate()  
--print '1.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor  
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor,c.codprestamo,c.saldocapital  
,c.fechadesembolso  
into #CAIni  
from tcscartera c with(nolock)  
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@x_fec--@fecini-->huerfano  
where c.fecha=@x_fec--@fecini   
and c.codoficina=@codoficina  
and codprestamo in(select codprestamo from #ptmos with(nolock))  
--select * from #CAIni  
  
--set @t2=getdate()  
--print '2.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor  
,count(c.codprestamo) nro,sum(c.saldocapital) monto  
into #INI  
from tcscartera c with(nolock)  
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano  
where c.fecha=@fecini and c.codoficina=@codoficina  
and codprestamo in(select codprestamo from #ptmos)  
group by case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end  
  
--set @t2=getdate()  
--print '3.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
select --e.codusuario codpromotor,  
case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor  
,sum(case when c.nrodiasatraso>=16 then c.saldocapital else 0 end) / sum(isnull(c.saldocapital,0))*100 ini_mora16  
--,sum(case when c.nrodiasatraso>=16 then c.saldocapital else 0 end) / sum(isnull(c.saldocapital,0))*100 mora  
into #INI_Ven16  
from tcscartera c with(nolock)  
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@x_fec-->huerfano --'20191031'--  
where c.fecha=@x_fec --'20191031'--  
and c.codoficina=@codoficina--'3'--  
and cartera='ACTIVA'   
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by --e.codusuario,  
case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end  
  
--set @t2=getdate()  
--print '4.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
declare @y_fec datetime  
set @y_fec=@fecha  
  
select --e.codusuario codpromotor,  
case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor  
,sum(case when c.nrodiasatraso>=16 then c.saldocapital else 0 end) / sum(isnull(c.saldocapital,0))*100 fin_mora16  
--,sum(case when c.nrodiasatraso>=16 then c.saldocapital else 0 end) / sum(isnull(c.saldocapital,0))*100 mora  
into #FIN_Ven16  
from tcscartera c with(nolock)  
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@y_fec-->huerfano --'20191031'--  
where c.fecha=@y_fec --'20191031'--  
and c.codoficina=@codoficina--'3'--  
and cartera='ACTIVA'   
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by --e.codusuario,  
case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end  
  
--set @t2=getdate()  
--print '5.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
truncate table #ptmos  
insert into #ptmos  
select distinct codprestamo   
from tcscartera with(nolock)  
where fecha=@fecha  
and cartera='ACTIVA' and codoficina not in('97','230','231')  
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
and codoficina=@codoficina  
and nrodiasatraso>=0 and nrodiasatraso<=30--15--  
  
--set @t2=getdate()  
--print '6.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor  
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor,c.codprestamo,c.saldocapital  
,c.fechadesembolso  
into #CAFin  
from tcscartera c with(nolock)  
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@y_fec--@fecha-->huerfano  
where c.fecha=@y_fec--@fecha   
and c.codoficina=@codoficina  
and c.codprestamo in(select codprestamo from #ptmos with(nolock))  
  
--set @t2=getdate()  
--print '7.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
select case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor  
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor  
,count(c.codprestamo) nro,sum(c.saldocapital) monto  
into #FIN  
from tcscartera c with(nolock)  
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano  
where c.fecha=@fecha and c.codoficina=@codoficina  
and codprestamo in(select codprestamo from #ptmos)  
group by case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end  
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end  
  
--set @t2=getdate()  
--print '8.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
/*creditos que se mantuvieron*/  
--select i.codprestamo codprestamo_ini,i.saldocapital,f.codprestamo codprestamo_fin,f.saldocapital  
--from #CAini i  
--inner join #CAfin f on i.promotor=f.promotor and i.codprestamo=f.codprestamo  
--where i.promotor='CASTILLO GUZMAN MARIA REYNALDA'  
  
--select * from #CAini  
/* cartera vencida*/  
select distinct codprestamo   
into #ptmosVencidos  
from tcscartera with(nolock)  
where fecha=@fecha  
and cartera='ACTIVA' and codoficina not in('97','230','231')  
and codprestamo not in (select codprestamo from tCsCarteraAlta)  
and codoficina=@codoficina  
and nrodiasatraso>30--15  
  
--set @t2=getdate()  
--print '9.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
select promotor  
,sum(case when tipo='CANCELADO' then nro else 0 end) nro_can  
,sum(case when tipo='CANCELADO' then monto else 0 end) monto_can  
,sum(case when tipo<>'CANCELADO' then nro else 0 end) nro_qui  
,sum(case when tipo<>'CANCELADO' then monto else 0 end) monto_qui  
into #CAN  
from (  
 select i.promotor  
 ,case when estadocalculado='CANCELADO' and cancelacion<=@y_fec--@fecha   
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
 group by i.promotor,case when estadocalculado='CANCELADO' and cancelacion<=@y_fec--@fecha   
    then 'CANCELADO'  
    else 'QUITADO' end  
) x  
group by promotor  
  
--set @t2=getdate()  
--print '10.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
--select promotor  
--,sum(case when tipo='DESEMBOLSO' then nro else 0 end) nro_des  
--,sum(case when tipo='DESEMBOLSO' then monto else 0 end) monto_des  
--,sum(case when tipo<>'DESEMBOLSO' then nro else 0 end) nro_asi  
--,sum(case when tipo<>'DESEMBOLSO' then monto else 0 end) monto_asi  
--into #DEN  
--from (  
-- select f.promotor  
-- --,case when f.fechadesembolso>=@fecini and f.fechadesembolso<=@fecha then   
-- --         case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else   
-- --         'DESEMBOLSO' end  
-- --                     else 'ASIGNADO' end TIPO  
--,case when f.fechadesembolso>=@fecini and f.fechadesembolso<=@fecha then   
--          case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else   
--          'DESEMBOLSO' end  
--     when f.fechadesembolso<@fecini then
--          case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else   
--          'DESEMBOLSO' end 
--     else 'ASIGNADO' end TIPO                                   
-- ,count(f.codprestamo) nro,sum(f.saldocapital) monto  
-- --,i.codprestamo,i.saldocapital,f.fechadesembolso  
-- --,f.codprestamo codprestamo_fin,f.saldocapital   
-- from #CAfin f left outer join #CAini i on i.promotor=f.promotor and i.codprestamo=f.codprestamo  
--    inner join tcspadroncarteradet p with(nolock) on p.codprestamo=f.codprestamo  
-- where i.codprestamo is null   
-- --and f.promotor='CASTILLO GUZMAN MARIA REYNALDA'  
-- group by f.promotor  
-- ,case when f.fechadesembolso>=@fecini and f.fechadesembolso<=@fecha then   
--          case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else   
--          'DESEMBOLSO' end  
--                      else 'ASIGNADO' end   
  
--) x  
--group by promotor  

----SE AJUSTA PARA CONTEMPLAR MAS ESCENARIOS--2023.05.30  ZCCU

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
          case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else   
          'DESEMBOLSO' end 
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
          case when p.primerasesor<>p.UltimoAsesor then 'ASIGNADO' else   
          'DESEMBOLSO' end 
     else 'ASIGNADO' end
) x  
group by promotor  

  
--set @t2=getdate()  
--print '11.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
/*creditos en vencida que pasaron a vigente*/  
truncate table #ptmos  
insert into #ptmos  
select distinct codprestamo   
from tcscartera with(nolock)  
where fecha=@fecha  
and cartera='ACTIVA' and codoficina not in('97','230','231')  
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
and codoficina=@codoficina  
and nrodiasatraso>=0 and nrodiasatraso<=30--15--  
and codprestamo in(  
 select distinct codprestamo   
 from tcscartera with(nolock)  
 where fecha=@fecini  
 and cartera='ACTIVA' and codoficina not in('97','230','231')  
 and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
 and codoficina=@codoficina  
 and nrodiasatraso>30--15--  
)  
  
--set @t2=getdate()  
--print '12.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
select case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor  
,count(c.codprestamo) nro,sum(c.saldocapital) monto  
into #VEN  
from tcscartera c with(nolock)  
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano  
where c.fecha=@fecha and c.codoficina=@codoficina  
and codprestamo in(select codprestamo from #ptmos)  
group by case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end  
--select * from #VEN  
  
--set @t2=getdate()  
--print '13.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
/*CARTERA VENCIDA*/  
truncate table #ptmos  
insert into #ptmos  
select distinct codprestamo   
from tcscartera with(nolock)  
where fecha=@fecini  
and cartera='ACTIVA' and codoficina not in('97','230','231')  
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
and codoficina=@codoficina  
and nrodiasatraso>30--15--  
  
--set @t2=getdate()  
--print '14.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
select case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor  
,count(c.codprestamo) nro,sum(c.saldocapital) monto  
into #Vini  
from tcscartera c with(nolock)  
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecini-->huerfano  
where c.fecha=@fecini and c.codoficina=@codoficina  
and codprestamo in(select codprestamo from #ptmos)  
group by case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end  
  
--set @t2=getdate()  
--print '15.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
truncate table #ptmos  
insert into #ptmos  
select distinct codprestamo   
from tcscartera with(nolock)  
where fecha=@fecha  
and cartera='ACTIVA' and codoficina not in('97','230','231')  
and codprestamo not in (select codprestamo from tCsCarteraAlta)  
and codoficina=@codoficina  
and nrodiasatraso>30--15--  
  
--set @t2=getdate()  
--print '16.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
select case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end promotor  
,count(c.codprestamo) nro,sum(c.saldocapital) monto  
into #Vfin  
from tcscartera c with(nolock)  
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano  
where c.fecha=@fecha and c.codoficina=@codoficina  
and codprestamo in(select codprestamo from #ptmos)  
group by case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end  
  
--set @t2=getdate()  
--print '17.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
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
  
--set @t2=getdate()  
--print '18.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
--select f.promotor, f.nro,f.monto  
update #cua   
set fin_nro=f.nro,fin_monto=f.monto  
from #FIN f with(nolock)  
inner join #cua i with(nolock) on i.promotor=f.promotor  
  
--set @t2=getdate()  
--print '19.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
insert #cua (codpromotor,promotor,fin_nro,fin_monto)  
select codpromotor,promotor, nro, monto  
from #FIN  
where promotor not in(select promotor from #INI)  
  
--set @t2=getdate()  
--print '20.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
--select * from #INI  
--select * from #FIN  
--select * from #cua  
  
--select i.promotor,i.nro ini_nro,i.monto ini_monto,isnull(f.nro,0) fin_nro,isnull(f.monto,0) fin_monto  
--,isnull(q.nro_can,0) qui_nro_can,isnull(q.monto_can,0) qui_monto_can,isnull(q.nro_qui,0) qui_nro_qui,isnull(q.monto_qui,0) qui_monto_qui  
--,isnull(a.nro_des,0) asi_nro_des,isnull(a.monto_des,0) asi_monto_des,isnull(a.nro_asi,0) asi_nro_asi,isnull(a.monto_asi,0) asi_monto_asi  
--,(isnull(f.monto,0)-isnull(i.monto,0))+isnull(q.monto_qui,0)-isnull(a.monto_asi,0) crecimiento  
--from #INI i  
--left outer join #FIN f on f.promotor=i.promotor  
--left outer join #CAN q on q.promotor=i.promotor  
--left outer join #DEN a on a.promotor=i.promotor  
declare @sucursal varchar(200)  
declare @region varchar(200)  
  
select @sucursal=o.nomoficina,@region=z.nombre --region  
from tcloficinas o with(nolock)  
inner join tclzona z with(nolock) on z.zona=o.zona  
where o.codoficina=@codoficina  
  
--set @t2=getdate()  
--print '21.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
--delete from tCsACrecimientoPromotor where fecha=@fecha and codoficina=@codoficina  
----drop table tCsACrecimientoPromotor  
--insert into tCsACrecimientoPromotor  
select @fecha fecha,@codoficina codoficina,@sucursal sucursal,@region region,c.promotor,c.ini_nro,c.ini_monto,c.fin_nro,c.fin_monto  
,isnull(vi.nro,0) ini_venc_nro,isnull(vi.monto,0) ini_venc_monto  
,isnull(vf.nro,0) fin_venc_nro,isnull(vf.monto,0) fin_venc_monto  
,isnull(q.nro_can,0) qui_nro_can,isnull(q.monto_can,0) qui_monto_can,isnull(q.nro_qui,0) qui_nro_qui,isnull(q.monto_qui,0) qui_monto_qui  
,isnull(a.nro_des,0) asi_nro_des,isnull(a.monto_des,0) asi_monto_des,isnull(a.nro_asi,0) asi_nro_asi,isnull(a.monto_asi,0) asi_monto_asi  
,isnull(v.nro,0) ven_nro,isnull(v.monto,0) ven_monto  
,(isnull(c.fin_monto,0)-isnull(c.ini_monto,0))+isnull(q.monto_qui,0)-isnull(a.monto_asi,0) crecimiento  
  
/* debe seguir siendo a 31+ */  
,case when c.ini_monto+isnull(vi.monto,0)=0 then 0 else (isnull(vi.monto,0)/(c.ini_monto+isnull(vi.monto,0)))*100 end MoraIni  
,case when c.fin_monto+isnull(vf.monto,0)=0 then 0 else (isnull(vf.monto,0)/(c.fin_monto+isnull(vf.monto,0)))*100 end MoraFin  
,c.codpromotor  
,vi16.ini_mora16  
,vf16.fin_mora16  
--into tCsACrecimientoPromotor  
from #cua c with(nolock)  
left outer join #CAN q with(nolock) on q.promotor=c.promotor  
left outer join #DEN a with(nolock) on a.promotor=c.promotor  
left outer join #VEN v with(nolock) on v.promotor=c.promotor  
left outer join #Vini vi with(nolock) on vi.promotor=c.promotor  
left outer join #Vfin vf with(nolock) on vf.promotor=c.promotor  
left outer join #INI_ven16 vi16 with(nolock) on vi16.promotor=c.promotor  
left outer join #FIN_ven16 vf16 with(nolock) on vf16.promotor=c.promotor  
  
  
--set @t2=getdate()  
--print '22.- ' + cast(datediff(millisecond,@t1,@t2) as varchar(20))  
--set @t1=getdate()  
  
--select * from #INI_ven30  
--select * from #FIN_ven30  
  
drop table #ptmos  
drop table #CAIni  
drop table #CAFin  
drop table #INI  
drop table #FIN  
drop table #CAN  
drop table #DEN  
drop table #cua  
drop table #VEN  
drop table #Vini  
drop table #Vfin  
drop table #ptmosVencidos  
drop table #INI_ven16  
drop table #FIN_ven16  

--rollback tran
GO