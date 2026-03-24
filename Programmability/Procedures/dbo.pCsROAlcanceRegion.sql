SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE Procedure [dbo].[pCsROAlcanceRegion] ---@fecha smalldatetime        
as        
BEGIN    
-- 14.01.2026    Sil ----  Se ajusta para unificar Expansion 1 y 2    


set nocount on      
declare @fecha smalldatetime    
set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)    
    
declare @fecante smalldatetime    
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1    
  
declare @fecini smalldatetime    
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes    
    
   
    
--declare @MeCrecimiento table(codigo varchar(3),metaColocacion money)    
--insert into @MeCrecimiento    
--select codigo,monto     
--from tcscametas m with(nolock)    
--where dbo.fdufechaaperiodo(m.fecha)=dbo.fdufechaaperiodo(@fecha) --fecha fin de mes actual    
--and tipocodigo=1 and meta=2     
    
declare @Region table(fecha smalldatetime, region varchar(30),zona varchar(4)--,nomoficina varchar(30),codoficina varchar(4)    
        ,saldo0a30ini money,saldo31a89ini money,saldo90ini money,saldoCapIni money    
        ,saldo0a30Fin money,saldo31a89fin money,saldo90fin money,saldoCapfinal money    
        ,capitalProgramado money,capitalPagado money    
        ,MontoRenov money,montoLiqui money    
        ,ptmosRenov money,ptmsLiqui money    
        ,ptmosVigIni money,ptmosVigFin money    
        --,porcolocacion money  
        ,montoentrega money    
        ,mes0a3 int,mes3a6 int,mes6a9 int    
        ,mes9a12 int,mes12 int,totsucursal int    
        ,TotaPtmos int,nuevosptmos int  
        ,cartVencidaIni money,cartVencidaFin money,varCapVencido money)    
insert into @Region    
select    
 c.fecha,region,o.zona--,c.nomoficina,codoficina  
  ,sum(saldo0a30ini),sum(saldo31a89ini),sum(saldo90ini),sum(saldoCapIni)    
   ,sum(saldo0a30Fin),sum(saldo31a89fin),sum(saldo90fin),sum(saldoCapfinal)    
   ,sum(capitalProgramado),sum(capitalPagado),sum(MontoRenov),sum(montoLiqui)  
   ,sum(ptmosRenov),sum(ptmsLiqui),sum(ptmosVigIni),sum(ptmosVigFin)    
   --,sum()porcolocacion  
   ,sum(montoentrega),sum(mes0a3),sum(mes3a6),sum(mes6a9),sum(mes9a12),sum(mes12),sum(totsucursal)    
   ,sum(TotaPtmos),sum(nuevosptmos),sum(cartVencidaIni),sum(cartVencidaFin),sum(varCapVencido)  
--select *                 
FROM [FNMGConsolidado].[dbo].[tCaReporteKPI] c  with(nolock)  
--where fecha='20230109'    
inner join tcloficinas o on o.nomoficina=c.nomoficina and tipo<>'cerrada'    
where c.fecha=@fecha and region<>'pro exito'    
group by  c.fecha,region ,zona   
  

--select * from @Region 
-- PRESTAMOS POR CICLO  
         
select o.zona zona    
,sum(case when c.fecha=@fecante and (pd.secuenciacliente>=1 and pd.secuenciacliente<=3)  then 1 else 0  end)  'PtmosIniC1a3'  
,sum(case when c.fecha=@fecante and (pd.secuenciacliente>=4 and pd.secuenciacliente<=10) then 1 else 0  end)  'PtmosIniC4a10'  
,sum(case when c.fecha=@fecante and pd.secuenciacliente >= 11 then 1 else 0  end)  'PtmosIniC11'  
,sum(case when c.fecha=@fecha and (pd.secuenciacliente>=1 and pd.secuenciacliente<=3) then 1 else 0  end)  'PtmosFinC1a3'  
,sum(case when c.fecha=@fecha and (pd.secuenciacliente>=4 and pd.secuenciacliente<=10) then 1 else 0  end)  'PtmosFinC4a10'  
,sum(case when c.fecha=@fecha and pd.secuenciacliente >= 11 then 1 else  0 end)'PtmosFinC11'  
into #ptmosxCiclo             
FROM tCsCartera c  with(nolock)      
left outer join tcspadroncarteradet pd  with(nolock) on  c.codprestamo=pd.codprestamo and c.codusuario=pd.codusuario      
left outer join tcscarteradet cd with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha   
inner join tcloficinas o on o.codoficina=c.codoficina  
--inner join tclzona z on z.zona=o.zona     
where  
C.fecha in(@fecante,@fecha)   
and pd.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))     
and c.codoficina not in('97','230','231','999')         
and cartera='ACTIVA' and nrodiasatraso<=30 
group by o.zona     
      
 -----------BAJAS DE PROMOTORES   
    
---BAJAS EN EL PERIODO ---    
select --e.codoficina,o.nomoficina nomoficina    
o.zona  
,sum(case when (datediff(day,e.Ingreso, e.Salida)/30)>=0 and (datediff(day,e.Ingreso, e.Salida)/30)<3 then 1 else 0 end) mes0a3B    
,sum(case when (datediff(day,e.Ingreso, e.Salida)/30)>=3 and (datediff(day,e.Ingreso, e.Salida)/30)<6 then 1 else 0 end) mes3a6B    
,sum(case when (datediff(day,e.Ingreso, e.Salida)/30)>=6 then 1 else 0 end) mes6B    
,count(*)totSucursalB    
into #bajaPromo    
from tCsempleados e with (nolock)    
left outer join tcloficinas o on o.codoficina=e.codoficina     
where salida >=@fecini and salida <=@fecha     
and e.CodPuesto ='66'    
--and o.codoficina=@codoficina    
group by o.zona  
-- o.nomoficina, e.codoficina    
     

    
DELETE FNMGCONSOLIDADO.DBO.TmpROAlcanceRegion   
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROAlcanceRegion   
    
-------------CONSULTA (CASI) FINAL   (Expansiones 1 y 2 se unifican, y luego se inserta el Total)
select    
c.fecha , region    
,sum(saldo0a30ini) carteraVgte_inicial    
,case when sum(saldoCapIni)=0 then 0 else (sum(saldo31a89ini)+sum(saldo90ini))/sum(saldoCapIni)end *100 imor31_inicial    
,sum(saldo0a30Fin) carteraVgteActual    
,case when sum(saldoCapfinal) =0 then 0 else isnull((sum(saldo31a89fin)+sum(saldo90fin))/sum(saldoCapfinal),0)end *100 imor31_Actual    
,0 MetaCrecimiento -- se cambia por la meta de colocacion    
,isnull(sum(saldo0a30Fin),0)-isnull(sum(saldo0a30ini),0)CRECIMIENTO    
--,case when sum(metaColocacion)=0 then 0 else isnull(sum(montoentrega)/sum(metaColocacion),0)end *100 AlcanceCrecimiento   
,0  AlcanceCrecimiento  
,case when sum(capitalProgramado)=0 then 0 else ISNULL(sum(capitalPagado)/sum(capitalProgramado),0)end *100 alcanceCobranza_por    
,case when sum(montoLiqui)=0 then 0 else ISNULL(sum(MontoRenov)/sum(montoLiqui),0)end *100 permanencia_s    
,case when sum(ptmsLiqui)=0 then 0 else ISNULL(sum(ptmosRenov)/cast(sum(ptmsLiqui)as decimal),0)end *100 permanencia_n    
,sum(ptmosVigIni)ptmosVigIni,sum(ptmosVigFin)ptmosVigFin    
,0 metacliente  -- se quita     
,sum(montoentrega)montocolocado    
,sum(mes0a3+mes3a6) mes0a6     
,sum(mes6a9+mes9a12+mes12) mes6m    
,sum(totsucursal)totsucursal    
,sum(TotaPtmos)ColocadoPtmos    
,sum(nuevosptmos) ptmosNuevoColoca   
,sum(cartVencidaIni)cartVencidaIni  
,sum(cartVencidaFin)cartVencidaFin  
,sum(varCapVencido)varCapVencido   
,case when sum(varCapVencido)=0 then 0 else sum(varCapVencido)/sum(saldo0a30ini)*100 end PorVencidaCaInicial  
  
,sum(PtmosIniC1a3) 'PtmosIniC1a3'  
,sum(PtmosIniC4a10)  'PtmosIniC4a10'  
,sum(PtmosIniC11)  'PtmosIniC11+'  
  
,sum(PtmosFinC1a3)  'PtmosFinC1a3'  
,sum(PtmosFinC4a10)  'PtmosFinC4a10'  
,sum(PtmosFinC11)'PtmosFinC11+'  
  
,sum(PtmosFinC1a3)-sum(PtmosIniC1a3)'crePtmsC1a3'  
,sum(PtmosFinC4a10)-sum(PtmosIniC4a10) 'crePtmsC4a10'  
,sum(PtmosFinC11)-sum(PtmosIniC11) 'crePtmsC11+'  
  
  
,sum(isnull(mes0a3B,0)) mes0a3B    
,sum(isnull(mes3a6B,0)) mes3a6B    
,sum(isnull(mes6B,0)) mes6B  
--INTO FNMGCONSOLIDADO.DBO.TmpROAlcanceRegion     
FROM @region c    
inner join #ptmosxCiclo o on o.zona=c.zona    
left outer join  #bajaPromo b on b.zona=c.zona   
where c.zona not like 'ZE%'
group by c.fecha,region    
--union 



INSERT INTO FNMGCONSOLIDADO.DBO.TmpROAlcanceRegion     --- Se agrega la unificacion de Expansion 1 y 2
select    
 c.fecha,'Expansion' as region    
,sum(saldo0a30ini) carteraVgte_inicial    
,case when sum(saldoCapIni)=0 then 0 else (sum(saldo31a89ini)+sum(saldo90ini))/sum(saldoCapIni)end *100 imor31_inicial    
,sum(saldo0a30Fin) carteraVgteActual    
,case when sum(saldoCapfinal) =0 then 0 else isnull((sum(saldo31a89fin)+sum(saldo90fin))/sum(saldoCapfinal),0)end *100 imor31_Actual    
,0 MetaCrecimiento -- se cambia por la meta de colocacion    
    
,isnull(sum(saldo0a30Fin),0)-isnull(sum(saldo0a30ini),0)CRECIMIENTO    
--,case when sum(metaColocacion)=0 then 0 else isnull(sum(montoentrega)/sum(metaColocacion),0)end *100 AlcanceCrecimiento    
,0  AlcanceCrecimiento  
,case when sum(capitalProgramado)=0 then 0 else ISNULL(sum(capitalPagado)/sum(capitalProgramado),0)end *100 alcanceCobranza_por    
,case when sum(montoLiqui)=0 then 0 else ISNULL(sum(MontoRenov)/sum(montoLiqui),0)end *100 permanencia_s    
,case when sum(ptmsLiqui)=0 then 0 else ISNULL(sum(ptmosRenov)/cast(sum(ptmsLiqui)as decimal),0)end *100 permanencia_n    
,sum(ptmosVigIni)ptmosVigIni,sum(ptmosVigFin)ptmosVigFin    
 ,0 metacliente    
,sum(montoentrega)montocolocado    
,sum(mes0a3+mes3a6) mes0a6     
,sum(mes6a9+mes9a12+mes12)    
,sum(totsucursal)totsucursal    
,sum(TotaPtmos)ColocadoPtmos    
,sum(nuevosptmos) ptmosNuevoColoca    
,sum(cartVencidaIni)cartVencidaIni  
,sum(cartVencidaFin)cartVencidaFin  
,sum(varCapVencido)varCapVencido   
,case when sum(varCapVencido)=0 then 0 else sum(varCapVencido)/sum(saldo0a30ini)*100 end PorVencidaCaInicial  
,sum(PtmosIniC1a3) 'PtmosIniC1a3'  
,sum(PtmosIniC4a10)  'PtmosIniC4a10'  
,sum(PtmosIniC11)  'PtmosIniC11+'  
  
,sum(PtmosFinC1a3)  'PtmosFinC1a3'  
,sum(PtmosFinC4a10)  'PtmosFinC4a10'  
,sum(PtmosFinC11)'PtmosFinC11+'  
  
,sum(PtmosFinC1a3)-sum(PtmosIniC1a3)'crePtmsC1a3'  
,sum(PtmosFinC4a10)-sum(PtmosIniC4a10) 'crePtmsC4a10'  
,sum(PtmosFinC11)-sum(PtmosIniC11) 'crePtmsC11+'  
  
,sum(isnull(mes0a3B,0)) mes0a3B    
,sum(isnull(mes3a6B,0)) mes3a6B    
,sum(isnull(mes6B,0)) mes6B 
FROM @region c 
inner join #ptmosxCiclo o on o.zona=c.zona    
left outer join  #bajaPromo b on b.zona=c.zona  
where c.zona like 'ZE%'
group by c.fecha    
 

INSERT INTO FNMGCONSOLIDADO.DBO.TmpROAlcanceRegion   ---- Se agrega el Total
select    
 c.fecha,'TOTAL' as region    
,sum(saldo0a30ini) carteraVgte_inicial    
,case when sum(saldoCapIni)=0 then 0 else (sum(saldo31a89ini)+sum(saldo90ini))/sum(saldoCapIni)end *100 imor31_inicial    
,sum(saldo0a30Fin) carteraVgteActual    
,case when sum(saldoCapfinal) =0 then 0 else isnull((sum(saldo31a89fin)+sum(saldo90fin))/sum(saldoCapfinal),0)end *100 imor31_Actual    
,0 MetaCrecimiento -- se cambia por la meta de colocacion    
    
,isnull(sum(saldo0a30Fin),0)-isnull(sum(saldo0a30ini),0)CRECIMIENTO    
--,case when sum(metaColocacion)=0 then 0 else isnull(sum(montoentrega)/sum(metaColocacion),0)end *100 AlcanceCrecimiento    
,0  AlcanceCrecimiento  
,case when sum(capitalProgramado)=0 then 0 else ISNULL(sum(capitalPagado)/sum(capitalProgramado),0)end *100 alcanceCobranza_por    
,case when sum(montoLiqui)=0 then 0 else ISNULL(sum(MontoRenov)/sum(montoLiqui),0)end *100 permanencia_s    
,case when sum(ptmsLiqui)=0 then 0 else ISNULL(sum(ptmosRenov)/cast(sum(ptmsLiqui)as decimal),0)end *100 permanencia_n    
,sum(ptmosVigIni)ptmosVigIni,sum(ptmosVigFin)ptmosVigFin    
 ,0 metacliente    
,sum(montoentrega)montocolocado    
,sum(mes0a3+mes3a6) mes0a6     
,sum(mes6a9+mes9a12+mes12)    
,sum(totsucursal)totsucursal    
,sum(TotaPtmos)ColocadoPtmos    
,sum(nuevosptmos) ptmosNuevoColoca    
,sum(cartVencidaIni)cartVencidaIni  
,sum(cartVencidaFin)cartVencidaFin  
,sum(varCapVencido)varCapVencido   
,case when sum(varCapVencido)=0 then 0 else sum(varCapVencido)/sum(saldo0a30ini)*100 end PorVencidaCaInicial  
,sum(PtmosIniC1a3) 'PtmosIniC1a3'  
,sum(PtmosIniC4a10)  'PtmosIniC4a10'  
,sum(PtmosIniC11)  'PtmosIniC11+'  
  
,sum(PtmosFinC1a3)  'PtmosFinC1a3'  
,sum(PtmosFinC4a10)  'PtmosFinC4a10'  
,sum(PtmosFinC11)'PtmosFinC11+'  
  
,sum(PtmosFinC1a3)-sum(PtmosIniC1a3)'crePtmsC1a3'  
,sum(PtmosFinC4a10)-sum(PtmosIniC4a10) 'crePtmsC4a10'  
,sum(PtmosFinC11)-sum(PtmosIniC11) 'crePtmsC11+'  
  
,sum(isnull(mes0a3B,0)) mes0a3B    
,sum(isnull(mes3a6B,0)) mes3a6B    
,sum(isnull(mes6B,0)) mes6B 
FROM @region c 
inner join #ptmosxCiclo o on o.zona=c.zona    
left outer join  #bajaPromo b on b.zona=c.zona    
group by c.fecha    

drop table #ptmosxCiclo  
drop table #bajaPromo  


--SELECT * FROM FNMGCONSOLIDADO.DBO.TmpROAlcanceRegion
END  
GO