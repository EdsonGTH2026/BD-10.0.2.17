SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*Informacion para calculo de Bonos para  Sucursal*/    
--Agrega cartera castigada 23.09.2022    
--Actualizar las renovaciones --> para ciclo 1,2,y 3 hasta 8 días de atraso  11.11.2022  
--Actualizar los créditos liquidados --> para ciclo 1,2,y 3 hasta 8 días de atraso  18.11.2022  
  
  
CREATE procedure [dbo].[pCsCaBonoGerente]  @fecini smalldatetime,@fecha smalldatetime    
as    
set nocount on     
    
--declare @fecha smalldatetime    
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion  --'20221102'--  
    
--declare @fecini smalldatetime    
--set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes    
    
declare @fecante smalldatetime    
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  --fecha de termino del mes anterior    
    
declare @fecfin smalldatetime    
select @fecfin = ultimodia from tclperiodo where dbo.fdufechaaperiodo(ultimodia)=dbo.fdufechaaperiodo(@fecha)    
    
    
/*CARTERA*/--Saldo en cartera     
    
declare @CarteraIni table (fecha smalldatetime,    
       codoficina varchar(3),           
       saldoIni0a30 money,    
       saldoIni31m money,    
       ptmosVgteini int,    
       ptmosAtrasIni int,    
       PtmosVencidoIni int)        
insert into @CarteraIni        
select   c.fecha      
,c.codoficina         
,sum(case when c.nrodiasatraso<=30 then c.saldocapital else 0 end)saldoIni0a30    
,sum(case when   c.nrodiasatraso>=31 then c.saldocapital else 0 end)saldoIni31m    
,count (case  when c.nrodiasatraso <=30 then c.codprestamo end) 'VIGENTE 0-30'    
,count (case  when c.nrodiasatraso >=31 and c.nrodiasatraso <=89 then c.codprestamo end) 'ATRASADO 31-89'    
,count (case  when c.nrodiasatraso >=90  then c.codprestamo end)  'VENCIDO 90+'    
    
from tcscartera c with(nolock)        
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo      
--left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=c.fecha        
--inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor       
inner join tcloficinas o on o.codoficina=c.codoficina    
where c.fecha=@fecante                                               --> fecha de corte del mes anterior    
and c.codoficina not in('97','231','230','999')  and o.tipo<>'Cerrada'    
and cartera='ACTIVA' and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))      
group by c.fecha,c.codoficina         
    
    
declare @CarteraFin table (fecha smalldatetime,    
       codoficina varchar(3),        
       nomoficina varchar(50),       
       saldoFin0a30 money,    
           
       saldoFin31m money,    
       ptmosVgteFin int,    
       ptmosAtrasFin int,    
       PtmosVencidoFin int)        
insert into @CarteraFin        
select   c.fecha      
,c.codoficina ,o.nomoficina        
,sum(case when c.nrodiasatraso<=30 then c.saldocapital else 0 end)saldofin0a30    
,sum(case when   c.nrodiasatraso>=31 then c.saldocapital else 0 end)saldofin31m    
,count (case  when c.nrodiasatraso <=30 then c.codprestamo end) 'VIGENTE 0-30'    
,count (case  when c.nrodiasatraso >=31 and c.nrodiasatraso <=89 then c.codprestamo end) 'ATRASADO 31-89'    
,count (case  when c.nrodiasatraso >=90  then c.codprestamo end)  'VENCIDO 90+'    
    
from tcscartera c with(nolock)        
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo      
--left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=c.fecha        
--inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor      
inner join tcloficinas o on o.codoficina=c.codoficina    
 where c.fecha=@fecha --> fecha consulta    
and c.codoficina not in('97','231','230','999')  and o.tipo<>'Cerrada'    
and cartera='ACTIVA' and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))      
group by c.fecha,c.codoficina ,o.nomoficina       
    
    
declare @creCartera table(fecha smalldatetime,codoficina varchar(3),nomoficina varchar(50)    
       ,saldoFin0a30 money ,saldoFin31m money,    
       saldoIni0a30 money,saldoIni31m money    
       ,ptmosVgteini int ,ptmosAtrasini int ,PtmosVencidoini int    
       ,ptmosVgteFin int,ptmosAtrasFin int ,PtmosVencidoFin int)    
           
insert into @creCartera           
select     
f.fecha,f.codoficina,f.nomoficina      
,saldoFin0a30,saldoFin31m     
,saldoIni0a30,saldoIni31m     
,ptmosVgteini,ptmosAtrasini,PtmosVencidoini     
,ptmosVgteFin,ptmosAtrasFin,PtmosVencidoFin     
    
from @CarteraFin f    
left outer join @carteraIni i on  i.codoficina=f.codoficina    
    
    
    
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
       --codasesor varchar(15),        
       --coordinador varchar(250),        
       SaldoCastigado money)        
insert into @Castigada      
select fecha,codoficina--,codasesor,promotor    
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
group by fecha,codoficina--,codasesor,promotor    
    
drop table #ptmosCast    
    
    
--select * from @Castigada    
    
    
/*METAS DE COLOCACION*/    
    
declare @MeColocacion table(codoficina varchar(4), Metacolocacion money)    
insert into @MeColocacion    
select codigo, monto    
from tcscametas with(nolock)    
where fecha=@fecfin      
and tipocodigo=1 and meta=2 --colocacion    
    
    
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
and p.codoficina<>'97'     
group by p.codprestamo,p.desembolso,p.codusuario    
having max(a.cancelacion) is not null    
    
declare @colocacionM table(codoficina varchar(30)    
      --,codasesor varchar(15)    
      ,montoColocacion money    
      ,totalPtmos int)    
insert into @colocacionM    
select p.codoficina--, p.ultimoasesor    
,sum(p.monto)montoEntrega    
,count(p.codprestamo)totalPtmos    
from tcspadroncarteradet p with(nolock)    
left outer join @liqreno l on l.codprestamo=p.codprestamo    
inner join tcscartera c with(nolock) on c.CodPrestamo=p.CodPrestamo and c.fecha=p.Desembolso    
left outer join [10.0.2.14].finmas.dbo.tcasolicitudrenovacionanticipadaproce s ON s.CodSolicitud=c.CodSolicitud and s.CodOficina=c.CodOficina    
where p.desembolso>=@fecini and p.desembolso<=@fecha    
and p.codoficina<>'97'    
group by p.codoficina--, p.ultimoasesor    
    
    
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
  
declare  @liq table(codoficina varchar(4),nro int)    
insert into @liq   
select codoficina--,count(codprestamo) nro  
,sum(case when secuenciaCliente<=3 and atrasomaximo<=8 then 1    
   when secuenciaCliente>3 and atrasomaximo<=15 then 1  
   else 0 end) nro  
from #baseLiqui  with(nolock)   
where cancelacion>=@fecini and cancelacion<=@fecha  
and atrasomaximo<=15  
group by codoficina  
  
  
  
/*Para ciclos 1,2 y 3 se toman hasta 8 dias de atraso, c4+ hasta 15 dias a. -- cambio solicitado por Laura*/  
   
declare @Ren table(codoficina varchar(4),nro int)    
insert into @Ren   
select codoficina  
--,count(codprestamo) nro -- se cambia  
,sum(case when secuenciaCliente<=3 and atrasomaximo<=8 then 1    
   when secuenciaCliente>3 and atrasomaximo<=15 then 1  
   else 0 end) nro  
from #baseLiqui     
where cancelacion>=@fecini and cancelacion<=@fecha  
and estado='RENOVADO'  
and atrasomaximo<=15  
group by codoficina  
  
drop table #baseLiqui  
   
    
declare @RenovaPrevio table(codoficina varchar(4),ptmosLiqui int,ptmosRenov int)    
insert into @RenovaPrevio    
select l.codoficina--,l.codpromotor codasesor    
,sum(isnull(l.nro,0)) ptmsLiqui    
,sum(isnull(r.nro,0)) ptmosRenov    
from  @liq l      
left outer join @Ren r  on l.codoficina=r.codoficina    
group by  l.codoficina--,l.codpromotor    
    
    
/*COBRANZA PUNTUAL */    
    
--Del primer dia del mes a la fecha de consulta    
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
      
create table #cobranzaP( fecha smalldatetime,region varchar(15)   
        ,sucursal varchar(30)  
        ,codoficina varchar(4)  
        ,promotor varchar(200)  
        ,atraso varchar (10)  
        ,programado_s money   
        ,monto_anticipado money   
        ,monto_puntual money  
        ,monto_atrasado money)  
insert into  #cobranzaP  
exec pCsCACobranzaPuntualcartas @fecha,@fecini  
    
declare @cop table(fecha smalldatetime,sucursal varchar(30)    
        ,programado_s money    
        ,monto_anticipado money    
        ,monto_puntual money    
        ,monto_atrasado money    
        ,PagoPuntual money    
        ,PagoAcumulado money)    
insert into @cop    
select fecha,sucursal    
,sum(c.programado_s) Programado_S    
,sum(c.monto_anticipado)monto_anticipado    
,sum(c.monto_puntual)monto_puntual    
,sum(c.monto_atrasado) monto_atrasado    
,case when sum(c.programado_s)=0  then 0 else sum(c.monto_puntual+c.monto_anticipado)/sum(c.programado_s)end *100 PagoPuntual    
,case when sum(c.programado_s)=0  then 0 else sum(c.monto_anticipado+c.monto_puntual+c.monto_atrasado)/sum(c.programado_s)end *100 PagoAcumulado    
from #cobranzaP c with(nolock)  
where atraso in ('0-7DM','8-30DM')    
group by fecha,sucursal    
    
drop table #cobranzaP    
    
/*INTERES  COBRADO del periodo a evaluar*/     
create table  #Co (    
          fecha smalldatetime,    
          codprestamo varchar(25),    
          codusuario varchar(15),    
          interes money,    
          dias int,fehaCa smalldatetime)    
insert into #Co    
select d.fecha, codigocuenta,d.codusuario,montointerestran interes,nrodiasatraso dias,c.fecha    
from tcstransacciondiaria d with(nolock)    
left outer  join tcscartera c with(nolock) on (c.fecha+1)=d.fecha and c.codprestamo=d.codigocuenta     
where d.fecha>=@fecini and d.fecha<=@fecha    
and d.codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0    
and d.codoficina not in('97','231','230','999')    
    
    
select fecha,codprestamo,codusuario,interes ,case when dias is null then 0 else dias end dias    
into #co2            
from #co    
where isnull(dias,0) <= 30    
     
declare @Ca table(codprestamo varchar(25),Codoficina varchar(4),codpromotor varchar(25))    
insert into @Ca    
select p.codprestamo, p.CodOficina, p.ultimoasesor    
from tcspadroncarteradet p with(nolock)    
where p.codprestamo in(select distinct codprestamo from #Co)    
    
    
declare @inteCobrado table(fecha smalldatetime    
       ,codoficina varchar(3)    
       --,Codasesor varchar(25)    
       ,interesCobrado money)     
insert into @inteCobrado    
select @fecha fecha,c.codoficina--,c.codpromotor    
,sum(interes) interes    
from #co2 t    
inner join @Ca c on t.codprestamo=c.codprestamo    
--inner join @Dias d on d.codprestamo=c.codprestamo    
inner join tcloficinas j with(nolock) on j.codoficina=c.codoficina    
group by     
c.codoficina--,c.codpromotor    
          
    
drop table #co      
drop table #co2     
    
    
          
    
    
-------------------- informacion de Gerente Sucursal    
    
declare @Gerentes table(fecha smalldatetime,nomoficina varchar(30),ingreso smalldatetime,gerente varchar(200))    
insert into @Gerentes select b1.Fecha,o.NomOficina, e.Ingreso,b2.NombreCompleto   
from tCsempleadosfecha as b1 with(nolock)   
inner join tCsempleados as e with(nolock) on b1.codusuario=e.codusuario   
inner join tCsPadronClientes as b2 with(nolock) on b1.CodUsuario=b2.CodUsuario   
inner join tcloficinas o on o.codoficina=b1.codoficina   
where b1.CodPuesto=41 and b1.Fecha=@fecha--'20221018'--   
and b2.NombreCompleto not in (  
'CORDERO AGUILAR JOSE MANUEL'  
,'SOLABAC CAMPOS VIRGINIA'  
,'RAMIREZ RAYAS DIEGO RODOLFO'  
,'DE JESUS TORRES XOCHITL'  
,'CARRASCO BASTIDA ISABEL SARINA'   
,'OCAMPO VILLEGAS VICTOR MANUEL'  
,'SALAZAR GAY ROBERTO CARLOS')   
order by o.NomOficina    
    
    
declare @Antiguedad table(fecha smalldatetime  
       ,nomoficina varchar(30)  
       ,ingreso smalldatetime  
       ,gerente varchar(200)  
       ,mesAntiguedad int  
       ,rangoAntiguedad varchar(10))    
insert into @Antiguedad   
select fecha ,nomoficina,ingreso ,gerente   
,(datediff(day,Ingreso,@fecha)/30) mesesantiguedad   
, case                             
  when (datediff(day,Ingreso,@fecha)/30) >= 12 then '12+m'                   
  when (datediff(day,Ingreso,@fecha)/30) >= 9 then '9-12m'                   
  when (datediff(day,Ingreso,@fecha)/30) >= 6 then '6-9m'                   
  when (datediff(day,Ingreso,@fecha)/30) >= 3 then '3-6m'                   
  else '0-3m' end rangoAntiguedad    
from  @Gerentes    
    
    
/*CONSULTA FINAL¨*/    
select @fecini fechaInicio,c.fecha fechaConsulta,z.nombre Region,o.nomoficina sucursal    
,case when o.EsVirtual=1 then 'VIRTUAL' else 'FISICA' end tipoSucursal    
,isnull(gerente,'--')  gerente    
,ISNULL( CONVERT( VARCHAR, Ingreso, 121 ) , '--' )   Ingreso    
,isnull(mesAntiguedad,0)  mesAntiguedad     
,isnull(rangoAntiguedad,'--') rangoAntiguedad     
,isnull (interesCobrado,0)  InteresCobradoVgte    
,isnull (saldoIni0a30,0) CartVtge0a30_Ini,isnull (saldoIni31m,0) CartVencida31m_Ini    
,isnull (saldoFin0a30,0) CartVtge0a30_Fin,isnull (saldoFin31m,0) CartVencida31m_Fin    
,isnull(saldocastigado,0)saldocastigado---- se agrega 23.09.2022    
,isnull (Metacolocacion,0)Metacolocacion    
,isnull (MontoColocacion,0)MontoColocacion,isnull(totalPtmos,0) CreditosColocados    
,isnull (pagoPuntual,0) pagoPuntual,isnull (pagoAcumulado,0) pagoAcumulado    
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
from @creCartera  c    
left outer join  @MeColocacion mc on mc.codoficina=c.codoficina    
left outer join @colocacionM co on co.codoficina=c.codoficina    
left outer join  @RenovaPrevio r on c.codoficina=r.codoficina    
Left outer join @cop cop on cop.sucursal=c.nomoficina    
left outer join @inteCobrado i on i.codoficina=c.codoficina    
left outer join @Antiguedad a on a.nomoficina=c.nomoficina    
left outer join tcloficinas o on o.codoficina=c.codoficina    
left outer join tclzona z on z.zona=o.zona    
left outer join @castigada cas on  c.codoficina=cas.codoficina      
where z.zona not in ('ZCO','ZPE')    
order by region,sucursal,tiposucursal  
    
--drop table #Co
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoGerente] TO [marista]
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoGerente] TO [mchavezs2]
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoGerente] TO [ope_lvegav]
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoGerente] TO [ope_dalvarador]
GO

GRANT EXECUTE ON [dbo].[pCsCaBonoGerente] TO [mledesmav]
GO