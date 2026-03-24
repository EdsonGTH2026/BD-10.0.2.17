SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*Informacion para calculo de Bonos para Promotor - 20220716*/        
--Agrega cartera castigada 23.09.2022        
--Se modifica para mostrar todos los promotores activos con y sin cartera 10.11.2022        
--Actualizar nro de créditos renovados --> para ciclo 1,2,y 3 hasta 8 días de atraso  11.11.2022        
--Actualizar nro de créditos liquidados--> para ciclo 1,2,y 3 hasta 8 días de atraso  18.11.2022        
--Se actualiza el interes cobrado -- 27.02.2023  
        
       ----- VERSION 2023.01.03   
  
CREATE procedure [dbo].[pCsCaBonoPromotor]  @fecini smalldatetime,@fecha smalldatetime        
as        
set nocount on         
        
--declare @fecha smalldatetime        
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion---  '20221231'--    
        
--declare @fecini smalldatetime        
--set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes        
        
        
/*SE AGREGA NUEVA FECHA PARA LA CARTERA INICIAL*/        
declare @fecante smalldatetime        
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  --fecha de termino del mes anterior        
        
        
declare @fecfin smalldatetime        
select @fecfin = ultimodia from tclperiodo where dbo.fdufechaaperiodo(ultimodia)=dbo.fdufechaaperiodo(@fecha)        
        
        
--select @fecha        
--select @fecante        
        
/*CARTERA*/--Saldo en cartera / vgte,cubetas e imor        
        
declare @CarteraIni table (fecha smalldatetime,        
       --codoficina varchar(3),            
       codasesor varchar(15),            
       coordinador varchar(250),            
       saldoIni0a30 money,        
       saldoIni31m money,        
       ptmosVgteini int,        
       ptmosAtrasIni int,        
       PtmosVencidoIni int        
       )            
insert into @CarteraIni            
select   c.fecha          
--,c.codoficina             
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor            
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador            
,sum(case when c.nrodiasatraso<=30 then c.saldocapital else 0 end)saldoIni0a30        
,sum(case when   c.nrodiasatraso>=31 then c.saldocapital else 0 end)saldoIni31m        
,count (case  when c.nrodiasatraso <=30 then c.codprestamo end) 'VIGENTE 0-30'        
,count (case  when c.nrodiasatraso >=31 and c.nrodiasatraso <=89 then c.codprestamo end) 'ATRASADO 31-89'        
,count (case  when c.nrodiasatraso >=90  then c.codprestamo end)  'VENCIDO 90+'        
from tcscartera c with(nolock)            
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo          
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=c.fecha            
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor           
where c.fecha=@fecante--> fecha de corte del mes anterior        
and c.cartera='ACTIVA' and c.tiporeprog<>'REEST'and c.codoficina not in('97','230','231','999')         
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))      
--and e.codusuario='CBJ881122FH600' -------OJO           
group by  c.fecha--,c.codoficina            
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end            
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end            
        
        
delete from @CarteraIni where coordinador='HUERFANO'            
        
        
declare @CarteraFin table (fecha smalldatetime,        
       --codoficina varchar(3),            
       codasesor varchar(15),            
       coordinador varchar(250),            
       saldoFin0a30 money,               
       saldoFin31m money,        
       ptmosVgteFin int,        
       ptmosAtrasFin int,        
       PtmosVencidoFin int)            
insert into @CarteraFin            
select   c.fecha          
--,c.codoficina             
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor            
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador            
,sum(case when c.nrodiasatraso<=30 then c.saldocapital else 0 end)saldoFin0a30        
,sum(case when   c.nrodiasatraso>=31 then c.saldocapital else 0 end)saldoFin31m        
,count (case  when c.nrodiasatraso <=30 then c.codprestamo end) 'VIGENTE 0-30'        
,count (case  when c.nrodiasatraso >=31 and c.nrodiasatraso <=89 then c.codprestamo end) 'ATRASADO 31-89'        
,count (case  when c.nrodiasatraso >=90  then c.codprestamo end)  'VENCIDO 90+'        
        
from tcscartera c with(nolock)          
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo          
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=c.fecha            
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor           
where c.fecha=@fecha  --> fecha consulta        
and c.cartera='ACTIVA' and c.tiporeprog<>'REEST'and c.codoficina not in('97','230','231','999')         
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))     
--and e.codusuario='CBJ881122FH600' -------OJO           
group by  c.fecha--,c.codoficina            
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end            
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end            
        
delete from @CarteraFin where coordinador='HUERFANO'          
        
        
declare @creCartera table(fecha smalldatetime--,codoficina varchar(3)    
  ,codasesor varchar(15),coordinador varchar(250),        
       saldoFin0a30 money ,saldoFin31m money,        
       saldoIni0a30 money,saldoIni31m money        
       ,ptmosVgteini int ,ptmosAtrasini int ,PtmosVencidoini int        
       ,ptmosVgteFin int,ptmosAtrasFin int ,PtmosVencidoFin int )        
               
insert into @creCartera               
select         
f.fecha--,f.codoficina    
,f.codasesor,f.coordinador        
,saldoFin0a30,saldoFin31m         
,saldoIni0a30,saldoIni31m        
,ptmosVgteini,ptmosAtrasini,PtmosVencidoini         
,ptmosVgteFin,ptmosAtrasFin,PtmosVencidoFin         
from @CarteraFin f        
left outer join @carteraIni i on i.codasesor=f.codasesor-- and i.codoficina=f.codoficina        
        
--------------------------------------------------CARTERA CASTIGADA        
create table #ptmosCast (codprestamo varchar(25))        
insert into #ptmosCast        
select c.codprestamo        
from tcscartera c with(nolock)        
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina        
where c.cartera='ACTIVA' and c.codoficina not in('97','230','231','999','98')        
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))        
and o.tipo<>'Cerrada'         
and c.fecha=@fecha        
group by c.fecha,c.codprestamo        
        
insert into #ptmosCast        
select codprestamo        
from tcspadroncarteradet with(nolock)        
where pasecastigado>=@fecini and pasecastigado<=@fecha        
        
        
        
declare @Castigada table (fecha smalldatetime,        
       codoficina varchar(3),            
       codasesor varchar(15),            
       coordinador varchar(250),            
       SaldoCastigado money)            
insert into @Castigada          
select fecha,codoficina,codasesor,promotor        
--,sum(saldocapital) capital_total        
,sum(SaldoCastigado) SaldoCastigado        
from (        
  SELECT         
  case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cl.nombrecompleto end promotor        
  ,cd.codoficina,c.Fecha--, c.cartera tipo        
  ,c.codasesor,c.CodPrestamo,case when c.Estado='CASTIGADO' then (cd.saldocapital) else 0 end SaldoCastigado        
  --,cd.saldocapital        
  FROM tCsCartera c with(nolock)        
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo        
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina        
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor        
  left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano        
  where c.fecha=@fecha and c.codprestamo in(select codprestamo from #ptmosCast)        
) a        
group by fecha,codoficina,codasesor,promotor        
        
drop table #ptmosCast        
        
        
delete from @Castigada where coordinador='HUERFANO'          
        
--select * from @Castigada        
        
        
/*METAS DE COLOCACION*/        
        
declare @MeColocacion table(codasesor varchar(30), Metacolocacion money)        
insert into @MeColocacion        
select codigo, monto        
from tcscametas with(nolock)        
where fecha=@fecfin          
and tipocodigo=2 and meta=2 --colocacion        
--and codigo='CBJ881122FH600' -------OJO           
    
        
/*SECCION DE COLOCACION POR PROMOTOR*/        
        
/* COLOCACIÓN OK ---*/        
declare @liqreno table(codprestamo varchar(30)        
      ,desembolso smalldatetime        
      ,codusuario varchar(15)        
      ,cancelacion smalldatetime)        
insert into @liqreno        
select p.codprestamo,p.desembolso,p.codusuario,max(a.cancelacion) cancelacion        
from tcspadroncarteradet p with(nolock)        
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.desembolso        
where p.desembolso>=@fecini -----fecha de inicio de mes        
and p.desembolso<=@fecha -----fecha de consulta        
and p.codoficina not in ('97','999')      
--and p.codusuario='CBJ881122FH600' -------OJO           
group by p.codprestamo,p.desembolso,p.codusuario        
having max(a.cancelacion) is not null        
        
declare @colocacionM table(--codoficina varchar(30)        
      codasesor varchar(15)        
      ,montoColocacion money        
      ,totalPtmos int)        
insert into @colocacionM        
select --p.codoficina,     
p.ultimoasesor        
,sum(p.monto)montoEntrega        
,count(p.codprestamo)totalPtmos        
from tcspadroncarteradet p with(nolock)        
left outer join @liqreno l on l.codprestamo=p.codprestamo        
inner join tcscartera c with(nolock) on c.CodPrestamo=p.CodPrestamo and c.fecha=p.Desembolso        
left outer join [10.0.2.14].finmas.dbo.tcasolicitudrenovacionanticipadaproce s ON s.CodSolicitud=c.CodSolicitud and s.CodOficina=c.CodOficina        
where p.desembolso>=@fecini and p.desembolso<=@fecha        
and p.codoficina not in ('97','999')     
--and p.ULTIMOASESOR='CBJ881122FH600' -------OJO           
group by --p.codoficina,     
p.ultimoasesor        
        
--select *        
--into tCsACaLIQUI_RR_20220713        
--from tCsACaLIQUI_RR        
        
        
        
/*Prestamos Liquidados y Renovados*/        
        
create table #baseLiqui (codoficina varchar(5)        
      ,sucursal varchar(50)        
      ,coordinador  varchar(500)        
      ,codpromotor  varchar(50)        
      ,codprestamo varchar(35)        
      ,secuenciacliente int        
      ,cancelacion  smalldatetime        
      ,atrasomaximo  int        
      ,Estado  varchar(30))         
        
insert into #baseLiqui         
exec pCsCaLiqRRPromotor @fecha,@fecini        
        
/*Para ciclos 1,2 y 3 se toman hasta 8 dias de atraso, c4+ hasta 15 dias a. -- cambio solicitado por Laura*/        
        
declare  @liq table(codoficina varchar(4),coordinador varchar(500),codpromotor varchar(50),nro int)        
insert into @liq        
select codoficina,coordinador,codpromotor--,count(codprestamo) nro--,sum(monto)monto        
,sum(case when secuenciaCliente<=3 and atrasomaximo<=8 then 1          
   when secuenciaCliente>3 and atrasomaximo<=15 then 1        
   else 0 end) nro        
from #baseLiqui  --with(nolock)         
where cancelacion>=@fecini and cancelacion<=@fecha        
and atrasomaximo<=15     
--and CODPROMOTOR='CBJ881122FH600' -------OJO           
group by codoficina,coordinador,codpromotor        
        
        
/*Para ciclos 1,2 y 3 se toman hasta 8 dias de atraso, c4+ hasta 15 dias a. -- cambio solicitado por Laura*/        
        
declare @Ren table(codoficina varchar(4),coordinador varchar(500),codpromotor varchar(50),nro int)        
insert into @Ren        
select codoficina,coordinador,codpromotor--,count(codprestamo) nro        
,sum(case when secuenciaCliente<=3 and atrasomaximo<=8 then 1          
   when secuenciaCliente>3 and atrasomaximo<=15 then 1        
   else 0 end) nro        
from #baseLiqui           
where cancelacion>=@fecini and cancelacion<=@fecha        
and estado='RENOVADO'        
and atrasomaximo<=15       
--and CODPROMOTOR='CBJ881122FH600' -------OJO           
     
group by codoficina,coordinador,codpromotor        
        
        
        
drop table #baseLiqui         
        
        
declare @RenovaPrevio table(    
--codoficina varchar(4),    
codasesor varchar(20),ptmosLiqui int,ptmosRenov int    
)        
insert into @RenovaPrevio        
select --l.codoficina,    
l.codpromotor codasesor        
,sum(isnull(l.nro,0)) ptmsLiqui        
,sum(isnull(r.nro,0)) ptmosRenov        
from  @liq l          
left outer join @Ren r  on l.codpromotor=r.codpromotor        
group by  --l.codoficina,    
l.codpromotor        
        
        
/*COBRANZA PUNTUAL */        
----Del primer dia del mes a la fecha de consulta        
        
create table #cobranzaP (        
   fecha smalldatetime,region varchar(15)         
   ,sucursal varchar(30),codoficina varchar(4),promotor varchar(200),atraso varchar (10),programado_s money         
   ,monto_anticipado money         
   ,monto_puntual money,monto_atrasado money)        
insert into  #cobranzaP        
exec pCsCACobranzaPuntualcartas @fecha,@fecini        
        
--create table #cobranzaP (        
--   fecha smalldatetime,fechavencimiento smalldatetime,region varchar(15)         
--   ,sucursal varchar(30),atraso varchar (10),rangoCiclo varchar(10)        
--   ,saldo money,condonado money,programado_n int,programado_s money         
--   ,anticipado int,puntual int ,atrasado int,monto_anticipado money         
--   ,monto_puntual money,monto_atrasado money,creditosPagados int         
--   ,capitalPagado money,pagado_por money,sinpago_n int        
--   ,sinpago_s money,sinpago_por money,pagoparcial_n int        
--   ,pagoparcial_s money,parcial_por money,total_n int        
--   ,total_s money,total_por money,orden int,promotor varchar(200))        
--insert into  #cobranzaP        
--exec pCsCACobranzaPuntual @fecha,@fecini        
        
declare @cop table(fecha smalldatetime--,sucursal varchar(30)    
  ,promotor varchar(200)        
        ,programado_s money        
        ,monto_anticipado money        
        ,monto_puntual money        
        ,monto_atrasado money        
        ,PagoPuntual money        
        ,PagoAcumulado money)        
insert into @cop        
select fecha--,sucursal    
,promotor        
,sum(programado_s) Programado_S        
,sum(monto_anticipado)monto_anticipado        
,sum(monto_puntual)monto_puntual        
,sum(monto_atrasado) monto_atrasado        
,case when sum(programado_s)=0  then 0 else sum(monto_puntual+monto_anticipado)/sum(programado_s)end *100 PagoPuntual        
,case when sum(programado_s)=0  then 0 else sum(monto_anticipado+monto_puntual+monto_atrasado)/sum(programado_s)end *100 PagoAcumulado        
from #cobranzaP with(nolock)        
where atraso in ('0-7DM','8-30DM')        
group by fecha--,sucursal    
,promotor        
        
drop table #cobranzaP        
        
/*INTERES  COBRADO del periodo a evaluar*/         
        
--create table  #Co (        
--          fecha smalldatetime,        
--          codprestamo varchar(25),        
--          codusuario varchar(15),        
--          interes money,        
--          dias int,fehaCa smalldatetime)        
--insert into #Co        
--select d.fecha, codigocuenta,d.codusuario,montointerestran interes,nrodiasatraso dias,c.fecha        
--from tcstransacciondiaria d with(nolock)        
--left outer  join tcscartera c with(nolock) on (c.fecha+1)=d.fecha and c.codprestamo=d.codigocuenta         
--where d.fecha>=@fecini and d.fecha<=@fecha        
--and d.codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0        
--and d.codoficina not in('97','231','230','999')        
----and c.nrodiasatraso <= 30     
----and D.CODUSUARIO='CBJ881122FH600' -------OJO           
       
        
        
--select fecha,codprestamo,codusuario,interes ,case when dias is null then 0 else dias end dias        
--into #co2                
--from #co        
--where isnull(dias,0) <= 30        
         
        
--declare @Ca table(codprestamo varchar(25),Codoficina varchar(4),codpromotor varchar(25))        
--insert into @Ca      select p.codprestamo, p.CodOficina, p.ultimoasesor        
--from tcspadroncarteradet p with(nolock)        
--where p.codprestamo in(select distinct codprestamo from #Co)      
----and P.ULTIMOASESOR='CBJ881122FH600' -------OJO           
      
        
----declare @Dias table(codprestamo varchar(25),diasatraso int)        
----insert into @Dias        
----select c.codprestamo, c.NroDiasAtraso        
----from tcscartera c with(nolock)        
----where c.fecha=@fecha and c.codprestamo in(select distinct codprestamo from #Co)        
        
--declare @inteCobrado table(fecha smalldatetime        
--       --,codoficina varchar(3)        
--       ,Codasesor varchar(25)        
--       ,interesCobrado money)         
--insert into @inteCobrado        
--select @fecha fecha--,c.codoficina    
--,c.codpromotor,sum(interes) interes        
--from #Co2 t        
--inner join @Ca c on t.codprestamo=c.codprestamo        
----inner join @Dias d on d.codprestamo=c.codprestamo        
--inner join tcloficinas j with(nolock) on j.codoficina=c.codoficina       
--group by         
----c.codoficina,    
--c.codpromotor        
              
--drop table #Co        
--drop table #co2
   
------------------------------- AJUSTE EN INTERES COBRADO 27.02.2023 CCU  

/*INTERESES COBRADOS POR PROMOTOR*/
  
create table  #ptmosPagos(  
          fecha smalldatetime,  
          codprestamo varchar(25),  
          interes money
          )  
insert into #ptmosPagos  
select  d.fecha,codigocuenta,montointerestran
from tcstransacciondiaria d with(nolock)  
where  d.fecha>=@fecini and d.fecha<=@fecha  
and d.codsistema='CA' 
and tipotransacnivel3 in(104,105) 
and extornado=0  

 
create table  #IntCo( fecha smalldatetime,  
					  codprestamo varchar(25),  
					  interes money,
					  nrodias int,
					  codoficina varchar(4),
					  codAsesor varchar(25)
					) 
insert into #IntCo
select  p.fecha,p.codprestamo,p.interes
,c.nrodiasatraso dias,c.codoficina,codAsesor
from #ptmosPagos p with(nolock)  
inner join tcscartera c with(nolock) on (c.fecha+1)=p.fecha and c.codprestamo=p.codprestamo   
where isnull(c.nrodiasatraso,0)<=30 and c.codoficina not in('97','231','230','999') 
--where c.codoficina  in('307') 

insert into #IntCo
select  p.fecha,p.codprestamo,p.interes,0 dias,pd.codoficina,isnull(ultimoAsesor,primerAsesor)
from #ptmosPagos p with(nolock)  
inner join tcspadroncarteradet pd with(nolock)on p.fecha=pd.desembolso and p.codprestamo=pd.codprestamo 

declare @inteCobrado table(fecha smalldatetime    
						  -- ,codoficina varchar(5)    
						   ,Codasesor varchar(25)    
						   ,interesCobrado money)     
insert into @inteCobrado  
select @fecha,
--c.codoficina,
codasesor,sum(interes)interes
from #IntCo c 
--inner join tcloficinas o on o.codoficina=c.codoficina
where isnull(nrodias,0)<=30  
group by codasesor 

drop table #ptmosPagos
drop table #IntCo

        
------------------ANTIGUEDAD DE PROMOTORES ACTIVOS        
--Antiguedad  por meses no por dias, solicitado por Mercedes          
declare @Antiquedad table(fecha smalldatetime,codoficina varchar(4),codusuario varchar(30),coordinador varchar(250),mes int,rango varchar(10), ingreso smalldatetime)        
insert into @Antiquedad        
select b1.fecha,co.Codoficina,b1.codusuario        
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador            
,(datediff(month,e.Ingreso,b1.fecha)) mesesantiguedad         
, case        
when (datediff(month,e.Ingreso,b1.fecha)) >= 12 then '12+m'        
when (datediff(month,e.Ingreso,b1.fecha)) >= 9 then '9-12m'        
when (datediff(month,e.Ingreso,b1.fecha)) >= 6 then '6-9m'        
when (datediff(month,e.Ingreso,b1.fecha)) >= 3 then '3-6m'        
else '0-3m' end rangoAntiguedad        
,e.ingreso ingreso        
from tCsempleadosfecha as b1 with(nolock)        
inner join tCsempleados as e with(nolock) on b1.codusuario=e.codusuario        
inner join tcspadronclientes co with(nolock) on co.codusuario=e.codusuario           
where b1.CodPuesto=66 and b1.Fecha=@fecha --'20221231'--    
and e.estado=1          
and b1.Codoficina <>'501'        
--and E.codusuario='CBJ881122FH600' -------OJO           
       
        
delete from @Antiquedad where coordinador='HUERFANO'          
        
        
        
/*CONSULTA FINAl*/        
select distinct @fecini fechaInicio,@fecha fechaConsulta,z.nombre Region,o.nomoficina sucursal,a.coordinador Promotor        
--select @fecini fechaInicio,c.fecha fechaConsulta,z.nombre Region,o.nomoficina sucursal,c.coordinador Promotor        
,ingreso FechaIngreso,mes Antiguedad,rango RangoAntiguedad        
,isnull (interesCobrado,0)  InteresCobradoVgte        
,isnull (saldoIni0a30,0) CartVtge0a30_Ini,isnull (saldoIni31m,0) CartVencida31m_Ini        
,isnull (saldoFin0a30,0) CartVtge0a30_Fin,isnull (saldoFin31m,0) CartVencida31m_Fin        
,isnull(saldocastigado,0)saldocastigado        
,isnull (Metacolocacion,0)Metacolocacion,isnull (MontoColocacion,0)MontoColocacion,isnull(totalPtmos,0) CreditosColocados        
,isnull (pagopuntual,0) pagopuntual        
,isnull (pagoacumulado,0) pagoacumulado        
,isnull(programado_s,0) Programado_S        
,isnull(monto_anticipado,0)monto_anticipado        
,isnull(monto_puntual,0)monto_puntual        
,isnull(monto_atrasado,0) monto_atrasado        
,isnull (ptmosLiqui,0) ptmosLiquidados,isnull (ptmosRenov,0) ptmosRenovados        
,isnull(ptmosVgteini,0)ptmosVgteIni,isnull(ptmosAtrasini,0)ptmosAtrasadoIni,isnull(PtmosVencidoini,0)PtmosVencidoIni         
,isnull(ptmosVgteFin,0)ptmosVgteFin,isnull(ptmosAtrasFin,0)ptmosAtrasadoFin,isnull(PtmosVencidoFin,0)PtmosVencidoFin         
,isnull(ptmosVgteFin,0)-isnull(ptmosVgteini,0) creciPtmosVgtes        
,isnull(ptmosAtrasFin,0)-isnull(ptmosAtrasini,0) creciPtmosAtraso        
,isnull(PtmosVencidoFin,0)-isnull(PtmosVencidoini,0) creciPtmosVencido        
--,a.codusuario        
---se cambia de orden y relacion para traer siempre todos los promotores  activos -- anteriormente era, los promotores con saldo en cartera        
from @Antiquedad a         
left outer join  @creCartera  c on a.codusuario=c.codasesor --and a.codoficina=c.codoficina      
left outer join  @MeColocacion mc on mc.codasesor=a.codusuario     
left outer join @colocacionM co on co.codasesor=a.codusuario --and a.codoficina=co.codoficina         
left outer join  @RenovaPrevio r on a.codusuario=r.codasesor --and a.codoficina=r.codoficina      
left outer join @inteCobrado i on i.codasesor=a.codusuario --and c.codoficina=i.codoficina         
--left outer join @Antiquedad a on a.codusuario=c.codasesor        
left outer join tcloficinas o on o.codoficina=a.codoficina       
Left outer join @cop cop on cop.promotor=a.coordinador --and cop.sucursal=o.nomoficina    
left outer join tclzona z on z.zona=o.zona        
left outer join @castigada cas on cas.codasesor=a.codusuario --and a.codoficina=cas.codoficina         
        
--from @creCartera  c        
--left outer join  @MeColocacion mc on mc.codasesor=c.codasesor        
--left outer join @colocacionM co on co.codasesor=c.codasesor        
--left outer join  @RenovaPrevio r on c.codasesor=r.codasesor        
--Left outer join @cop cop on cop.promotor=c.coordinador        
----Left outer join @copu copu on copu.promotor=c.coordinador        
--left outer join @inteCobrado i on i.codasesor=c.codasesor        
--right outer join @Antiquedad a on a.codusuario=c.codasesor        
--left outer join tcloficinas o on o.codoficina=c.codoficina        
--left outer join tclzona z on z.zona=o.zona        
--left outer join @castigada cas on cas.codasesor=c.codasesor and c.codoficina=cas.codoficina 
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoPromotor] TO [marista]
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoPromotor] TO [mchavezs2]
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoPromotor] TO [ope_lvegav]
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoPromotor] TO [ope_dalvarador]
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoPromotor] TO [mledesmav]
GO