SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*CARTA PROMOTOR 20220802*/

CREATE procedure [dbo].[pCsCaFNCartaPromotor] 

as
set nocount on 

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecante smalldatetime
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  --fecha de termino del mes anterior

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes

declare @fecfin smalldatetime
select @fecfin = ultimodia from tclperiodo where dbo.fdufechaaperiodo(ultimodia)=dbo.fdufechaaperiodo(@fecha)

declare @diacorte int  -- dia de corte  que le corresponde en este periodo 
select @diacorte=day(@fecha)

---fechas para las REACTIVACIONES 
declare @feciniCosRe smalldatetime
set @feciniCosRe=dbo.fdufechaaperiodo(dateadd(month,-3,@fecha))+'01'
	 
declare @fecfinCosRe smalldatetime
set @fecfinCosRe=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes

declare @fecosecha smalldatetime --A PARTIR DE QUE FECHA QUIERES EVALUAR COSECHAS
set @fecosecha=dbo.fdufechaaperiodo(dateadd(month,-11,@fecha))+'01'



/*CARTERA*/--Saldo en cartera / vgte,cubetas e imor

declare @CarteraIni table (fecha smalldatetime,
							codoficina varchar(3),    
							codasesor varchar(15),    
							coordinador varchar(250),    
							saldoIni0a30 money,
							saldoIni31a89 money,
							saldoIni90m money,
							ptmsVgteIni int,
							imor16ini money,
							imor30ini money,
							imor90mini money
							,cubini1a7 money
							 ,cubini8a15 money
							 ,cubini16a30 money
							 ,cubini31m money
							 ,cubiniTotal money
							 ,ptmos1a7ini money
							 ,ptmos8a15ini money
							 ,ptmos16a30ini money
							 ,ptmos31ini money
							 ,ptmosTotalini money)    
insert into @CarteraIni    
select   c.fecha  
,c.codoficina     
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor    
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador    
,sum(case when c.nrodiasatraso<=30 then c.saldocapital else 0 end)saldoIni0a30
,sum(case when   c.nrodiasatraso>=31 and  c.nrodiasatraso<=89 then c.saldocapital else 0 end)saldoIni31a89
,sum(case when   c.nrodiasatraso>=90 then c.saldocapital else 0 end)saldoIni90m
,count(case when c.nrodiasatraso<=30 then c.codprestamo else null end)ptmsVgte0a30
--imor
,(sum(case when c.nrodiasatraso>=16 then d.saldocapital else 0 end)/sum(d.saldocapital))*100 Imor16Ini 
,(sum(case when c.nrodiasatraso>=30 and c.nrodiasatraso<=89 then d.saldocapital else 0 end)/sum(d.saldocapital))*100 Imor30ini
,(sum(case when c.nrodiasatraso>=90 then d.saldocapital else 0 end)/sum(d.saldocapital))*100 Imor90mini
--saldo 
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then d.saldocapital else 0 end)cubeta1a7
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then d.saldocapital else 0 end)cubeta8a15
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then d.saldocapital else 0 end)cubeta16a30
,sum(case when c.nrodiasatraso>=31 then d.saldocapital else 0 end)cubeta31m
,sum(case when c.nrodiasatraso>=1 then d.saldocapital else 0 end)cubetaTotal
--ptmos
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then 1 else 0 end)ptmos1a7
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then 1 else 0 end)ptmos8a15
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then 1 else 0 end)ptmos16a30
,sum(case when c.nrodiasatraso>=31 then 1 else 0 end)ptms31m
,sum(case when c.nrodiasatraso>=1 then 1 else 0 end)ptmosTotal
from tcscartera c with(nolock)    
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=c.fecha    
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor   
where c.fecha=@fecante  --> fecha consulta
and c.cartera='ACTIVA' and c.tiporeprog<>'REEST'and c.codoficina not in('97','230','231') 
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))    
group by  c.fecha,c.codoficina    
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end    
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end    


delete from @CarteraIni where coordinador='HUERFANO'    


declare @CarteraFin table (fecha smalldatetime,
							codoficina varchar(3),    
							codasesor varchar(15),    
							coordinador varchar(250),    
							saldoFin0a30 money,
							saldofin31a89 money,
							saldoFin90m money,
							ptmsVgtefin int,
							imor16fin money,
							imor30fin money,
							imor90mfin money
							,cubfin1a7 money
							 ,cubfin8a15 money
							 ,cubfin16a30 money
							 ,cubfin31m money
							 ,cubfinTotal money
							 ,ptmos1a7fin money
							 ,ptmos8a15fin money
							 ,ptmos16a30fin money
							 ,ptmos31fin money
							 ,ptmosTotalfin money)    
insert into @CarteraFin    
select   c.fecha  
,c.codoficina     
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor    
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador    
,sum(case when c.nrodiasatraso<=30 then c.saldocapital else 0 end)saldoFin0a30
,sum(case when   c.nrodiasatraso>=31 and  c.nrodiasatraso<=89 then c.saldocapital else 0 end)saldofin31a89
,sum(case when   c.nrodiasatraso>=90 then c.saldocapital else 0 end)saldoFin90m
,count(case when c.nrodiasatraso<=30 then c.codprestamo else null end)ptmsVgte0a30
--Imor
,(sum(case when c.nrodiasatraso>=16 then d.saldocapital else 0 end)/sum(d.saldocapital))*100 Imor16fin 
,(sum(case when c.nrodiasatraso>=30 and c.nrodiasatraso<=89 then d.saldocapital else 0 end)/sum(d.saldocapital))*100 Imor30fin
,(sum(case when c.nrodiasatraso>=90 then d.saldocapital else 0 end)/sum(d.saldocapital))*100 Imor90mfin
--saldo 
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then d.saldocapital else 0 end)cubeta1a7
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then d.saldocapital else 0 end)cubeta8a15
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then d.saldocapital else 0 end)cubeta16a30
,sum(case when c.nrodiasatraso>=31 then d.saldocapital else 0 end)cubeta31m
,sum(case when c.nrodiasatraso>=1 then d.saldocapital else 0 end)cubetaTotal
--ptmos
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then 1 else 0 end)ptmos1a7
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then 1 else 0 end)ptmos8a15
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then 1 else 0 end)ptmos16a30
,sum(case when c.nrodiasatraso>=31 then 1 else 0 end)ptms31m
,sum(case when c.nrodiasatraso>=1 then 1 else 0 end)ptmosTotal
from tcscartera c with(nolock)  
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=c.fecha    
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor   
where c.fecha=@fecha  --> fecha consulta
and c.cartera='ACTIVA' and c.tiporeprog<>'REEST'and c.codoficina not in('97','230','231') 
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))    
group by  c.fecha,c.codoficina    
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end    
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end    

delete from @CarteraFin where coordinador='HUERFANO'    

declare @creCartera table(fecha smalldatetime,codoficina varchar(3),codasesor varchar(15),coordinador varchar(250),
							saldoFin0a30 money,saldofin31a89 money,saldoFin90m money,
							ptmsVgtefin int,imor16fin money,imor30fin money,imor90mfin money
							,cubfin1a7 money,cubfin8a15 money,cubfin16a30 money,cubfin31m money,cubfinTotal money
							,ptmos1a7fin money,ptmos8a15fin money,ptmos16a30fin money,ptmos31fin money,ptmosTotalfin money
							,saldoIni0a30 money,saldoIni31a89 money,saldoIni90m money,
							ptmsVgteIni int,imor16ini money,imor30ini money,imor90mini money
							,cubini1a7 money,cubini8a15 money,cubini16a30 money,cubini31m money,cubiniTotal money
							,ptmos1a7ini money,ptmos8a15ini money,ptmos16a30ini money,ptmos31ini money,ptmosTotalini money   
							,creciSaldo0a30 money,creciSaldo31a89 money,creciSaldo90m money,creciPtmosVgtes int,
							detImor16 varchar(10),detImor30 varchar(10),detImor90 varchar(10)
							,Crecub1a7 money,Crecub8a15 money,crecub16a30 money,crecub31m money,crecub1m money
							,creptmos1a7 money,creptmos8a15 money,creptmos16a30 money,creptmos31m money,creptmos1m money)
insert into @creCartera							
select 
f.fecha,f.codoficina,f.codasesor,f.coordinador
,saldoFin0a30,saldofin31a89,saldoFin90m,ptmsVgtefin 
,imor16fin,imor30fin,imor90mfin 
,cubfin1a7,cubfin8a15,cubfin16a30,cubfin31m ,cubfinTotal 
,ptmos1a7fin ,ptmos8a15fin,ptmos16a30fin,ptmos31fin,ptmosTotalfin 
,saldoIni0a30,saldoIni31a89,saldoIni90m 
,ptmsVgteIni,imor16ini,imor30ini,imor90mini 
,cubini1a7,cubini8a15 ,cubini16a30,cubini31m ,cubiniTotal 
,ptmos1a7ini,ptmos8a15ini,ptmos16a30ini,ptmos31ini,ptmosTotalini 
,isnull(saldoFin0a30,0)-isnull(saldoIni0a30,0)creciSaldo0a30
,isnull(saldofin31a89,0)-isnull(saldoIni31a89,0)creciSaldo31a89
,isnull(saldofin90m,0)-isnull(saldoIni90m,0)ceciSaldo90m
,isnull(ptmsVgtefin,0)-isnull(ptmsVgteIni,0) creciPtmos
,case when isnull(imor16fin,0)>isnull(imor16ini,0) then 'SUBE'
      when isnull(imor16fin,0)=isnull(imor16ini,0) then 'IGUAL'
      when isnull(imor16fin,0)<isnull(imor16ini,0) then 'BAJA' else'' end detImor16
,case when isnull(imor30fin,0)>isnull(imor30ini,0) then 'SUBE'
      when isnull(imor30fin,0)=isnull(imor30ini,0)then 'IGUAL'
      when isnull(imor30fin,0)<isnull(imor30ini,0)then 'BAJA' else'' end detImor30 
,case when isnull(imor90mfin,0)>isnull(imor90mini,0) then 'SUBE'
      when isnull(imor90mfin,0)=isnull(imor90mini,0) then 'IGUAL'
      when isnull(imor90mfin,0)<isnull(imor90mini,0)then 'BAJA' else'' end detImor90  
,isnull(cubfin1a7,0)-isnull(cubini1a7,0) cub1a7
,isnull(cubfin8a15,0)-isnull(cubini8a15,0) cub8a15
,isnull(cubfin16a30,0)-isnull(cubini16a30,0) cub16a30
,isnull(cubfin31m,0)-isnull(cubini31m,0) cub31m
,isnull(cubfinTotal,0)-isnull(cubiniTotal,0) cubTotal
,isnull(ptmos1a7fin,0)-isnull(ptmos1a7ini,0) ptmos1a7
,isnull(ptmos8a15fin,0)-isnull(ptmos8a15ini,0) ptmos8a15
,isnull(ptmos16a30fin,0)-isnull(ptmos16a30ini,0) ptmos16a30
,isnull(ptmos31fin,0)-isnull(ptmos31ini,0)ptmos31m
,isnull(ptmosTotalfin,0)-isnull(ptmosTotalini,0) ptmosTotal
from @CarteraFin f
left outer join @carteraIni i on i.codasesor=f.codasesor and i.codoficina=f.codoficina
--inner join @carteraIni i on i.codasesor=f.codasesor and i.codoficina=f.codoficina


/*METAS DE CRECIMIENTO Y DE COLOCACION*/

declare @MeCrecimiento table(codasesor varchar(30), metacrecimiento money)
insert into @MeCrecimiento
select codigo,monto 
from tcscametas with(nolock)
where fecha=@fecfin 
and tipocodigo=2 and meta=1 --crecimiento

declare @MeColocacion table(codasesor varchar(30), montocolocacion money)
insert into @MeColocacion
select codigo, monto
from tcscametas with(nolock)
where fecha=@fecfin  
and tipocodigo=2 and meta=2 --colocacion

/*---parametros del alcance de crecimiento*/
  
declare @indiceAlcance decimal(5,2) 
if(day(@fecha)<=30)
begin
	 set @indiceAlcance = round(3.333333*@diacorte,0) 
end
else 
begin
	 set @indiceAlcance=100 
end
  

declare @estadoAlcance table (codoficina varchar(3),codasesor varchar(30),metacrecimiento money,porAlcance money,estadoAlcance varchar(8),metaColocacion money)
insert into @estadoAlcance
select max(codoficina),codasesor,sum(metacrecimiento)metacrecimiento --,sum(creciSaldo0a30)creciSaldo0a30
,case when sum(metacrecimiento)=0 then 0 else( sum(creciSaldo0a30)/sum(metacrecimiento)*100)end   porAlcance
,case when (case when sum(metacrecimiento)=0 then 0 else ( sum(creciSaldo0a30)/sum(metacrecimiento))*100 end)>=@indiceAlcance then 'OK' 
          when (case when sum(metacrecimiento)=0 then 0 else (sum(creciSaldo0a30)/sum(metacrecimiento))*100 end)>=@indiceAlcance*0.8 and (case when sum(metacrecimiento)=0 then 0 else (sum(creciSaldo0a30)/sum(metacrecimiento))*100 end)<@indiceAlcance then 'REGULAR'
		  else 'MAL' end estadoAlcance		  
,sum(montocolocacion)montocolocacion
from (
	select 1 x,
	codasesor,codoficina,creciSaldo0a30,0 metacrecimiento,0 montocolocacion   
	from  @creCartera
	union   
	select 2 x,
	codasesor,''codoficina,0 creciSaldo0a30,metacrecimiento,0 montocolocacion
	from   @MeCrecimiento
	union   
	select 3 x,
	codasesor,''codoficina,0 creciSaldo0a30,0 metacrecimiento,montocolocacion
	from   @MeColocacion
	)a
group by codasesor

/*SE CAMBIA LA COBRANZA POR COBRANZA BAJO EL CAPITAL*/
---- Solicitado por Mercedes 20220802.
----EVALUACION COBRANZA PROGRAMADA (REPORTE DE PROMOTORES) --    

--declare @fec_programado smalldatetime    
--set @fec_programado= @fecha --> FECHA DE CONSULTA EN LA BASE DE DATOS    
--declare @fec_consulta smalldatetime    
--set @fec_consulta=dbo.fdufechaaperiodo(@fecha)+'01'--@fec_programado+1--+7 --> FECHA DE VENCIMIENTO A PARTIR DE LA CUAL SE QUIERE CONSULTAR, ACUMULA--    
    
--/*PARTE 1 MUESTRA CREDITOS*/    
--create table #ptmos (codprestamo varchar(25),codasesor varchar(15)    
--     ,codoficina varchar(4),nrodiasatraso int,ciclo int,codproducto varchar(3)    
--     ,modalidadplazo char(1),cuotas int, tiporeprog varchar(10))    
--insert into #ptmos    
--          select distinct c.codprestamo,c.codasesor,c.codoficina,c.nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo    
--          ,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end,c.tiporeprog    
--          from tcscartera c with(nolock)    
--          inner join tcspadroncarteradet p with(nolock) on p.codprestamo=c.codprestamo    
--          inner join tcscartera a with(nolock) on a.codprestamo=c.codprestamo and a.fecha=c.fechadesembolso    
--          where c.fecha=@fec_programado    
--          and c.nrodiasatraso<=30 
--          and c.cartera='ACTIVA' and c.codoficina not in('97','230','231') and c.tiporeprog<>'REEST'     
--          and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))    

--create table #ptmos_Liq (codprestamo varchar(25),codasesor varchar(15),codoficina varchar(4),nrodiasatraso int,ciclo int    
--      ,codproducto varchar(3),modalidadplazo char(1),cuotas int, tiporeprog varchar(10))    
--insert into #ptmos_Liq    
--select p.codprestamo,p.ultimoasesor,p.codoficina,0 nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo    
--,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end,p.tiporeprog    
--from tcspadroncarteradet p with(nolock)    
--inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo    
--inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso    
--where p.cancelacion>=@fec_consulta and cancelacion<=@fec_programado 
--and c.nrodiasatraso<=30 ------ANEXADO
--and p.tiporeprog<>'REEST'  
--and p.codoficina not in('230','231')  
--union    
--select p.codprestamo,p.ultimoasesor,p.codoficina,0 nrodiasatraso,p.secuenciacliente,c.codproducto,c.modalidadplazo    
--,case when c.nrocuotas-a.nrocuotas=0 then 0 else a.nrocuotas end,p.tiporeprog    
--from tcspadroncarteradet p with(nolock)    
--inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo    
--inner join tcscartera a with(nolock) on a.codprestamo=p.codprestamo and a.fecha=p.desembolso    
--where p.pasecastigado>=@fec_consulta and p.pasecastigado<=@fec_programado    
--and c.nrodiasatraso<=30   ------ANEXADO
--and p.tiporeprog<>'REEST'  
--and p.codoficina not in('230','231')  
    

--delete from #ptmos    
--where codprestamo in(select codprestamo from #ptmos_liq with(nolock))    
      
    
--/*PARTE 2 TABLA DE PAGOS*/    
----Para creditos vigentes    
--create table #Pogra1( codoficina varchar(4),      
--      codasesor varchar(15),      
--     codprestamo varchar(25),      
--     seccuota int,      
--     montodevengado money,      
--     montopagado money,      
--     fechavencimiento smalldatetime,      
--     fechapago smalldatetime,      
--     estadocuota varchar(20) )     
--insert into #Pogra1     
--select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado    
--,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota    
--from tcsplancuotas p with(nolock)    
--inner join #ptmos c on c.codprestamo=p.codprestamo and p.seccuota>c.cuotas    
--where p.fecha=@fec_programado and    
--p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos)    
--and p.fechavencimiento>=@fec_consulta and p.fechavencimiento<=@fec_programado    
--group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota    

----Para creditos liquidados / PAGOS PROGRAMADOS  
--create table #Pogra2( codoficina varchar(4),      
--      codasesor varchar(15),      
--     codprestamo varchar(25),      
--     seccuota int,      
--     montodevengado money,      
--     montopagado money,      
--     fechavencimiento smalldatetime,      
--     fechapago smalldatetime,      
--     estadocuota varchar(20))     
--insert into #Pogra2    
--select c.codoficina,c.codasesor,p.codprestamo,p.seccuota,sum(p.montodevengado) montodevengado,sum(p.montopagado) montopagado    
--,p.fechavencimiento,max(p.fechapagoconcepto) fechapago,p.estadocuota    
--from tcspadronplancuotas p with(nolock)    
--inner join #ptmos_Liq c on c.codprestamo=p.codprestamo and p.seccuota>c.cuotas    
--where p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos_Liq)    
--and p.fechavencimiento>=@fec_consulta and p.fechavencimiento<=@fec_programado    
--group by c.codoficina,c.codasesor,p.codprestamo,p.seccuota,p.fechavencimiento,p.estadocuota    
    
  
    
--/*PARTE 3 --CONSULTA FINAL */    
--declare @cobranza table ( codoficina varchar(4),codasesor varchar(15),Promotor varchar(250)    
--      ,Programado_S  money    
--      ,Pagado_S money    
--      ,progra_Cobrza5 money    
--      ,pag_Cobrza5 money    
--      ,progra_Cobrza3a4  money    
--      ,pag_Cobrza3a4  money    
--      ,progra_Cobrza2  money    
--      ,pag_Cobrza2  money    
--      ,progra_Cobrza1  money    
--      ,pag_Cobrza1  money    
--      ) 
--insert into @cobranza        
--select p.codoficina codoficina,p.codasesor  
--,pro.nombrecompleto Promotor    
-----VALORES DE COBRANZA TOTAL    
--,sum(p.montodevengado) Programado_S      
--,sum(p.montopagado) Pagado_S          
----COBRANZA  ANTI. Y ORGANICA x CICLOS    
--,sum(case when ca.ciclo>=5 then p.montodevengado else 0 end) progra_Cobrza5  --CICLO 5+    
--,sum(case when ca.ciclo>=5 then p.montopagado else 0 end) pag_Cobrza5         
--,sum(case when ca.ciclo>=3 and ca.ciclo<=4 then p.montodevengado else 0 end) progra_Cobrza3a4  --CICLO 3 a 4   
--,sum(case when ca.ciclo>=3 and ca.ciclo<=4 then p.montopagado else 0 end) pag_Cobrza3a4            
--,sum(case when ca.ciclo=2 then p.montodevengado else 0 end) progra_Cobrza2    --CICLO 2  
--,sum(case when ca.ciclo=2 then p.montopagado else 0 end) pag_Cobrza2          
--,sum(case when ca.ciclo=1 then p.montodevengado else 0 end) progra_Cobrza1   --CICLO 1    
--,sum(case when ca.ciclo=1 then p.montopagado else 0 end) pag_Cobrza1          
--from (    
--          select * from #Pogra1 with(nolock)    
--          union    
--          select * from #Pogra2 with(nolock)    
--)p    
--inner join (    
--          select * from #ptmos with(nolock)    
--          union    
--          select * from #ptmos_Liq with(nolock)    
--)ca on ca.codprestamo=p.codprestamo    
--inner join tcspadronclientes pro with(nolock) on p.codasesor=pro.codusuario  
--group by p.codoficina,p.codasesor,pro.nombrecompleto

    
    
--drop table #Pogra1    
--drop table #Pogra2    
--drop table #ptmos    
--drop table #ptmos_Liq    

--delete from @cobranza
--from @cobranza c 
--left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha
--where (case when (e.codpuesto<>66 or e.codusuario is null ) then 'HUERFANO' 
--			else Promotor end)='HUERFANO'  
						

/*COBRANZA PUNTUAL*/ 

create table #ptmosCP (codprestamo varchar(25),codoficina varchar(4),nrodiasatraso int,secuenciacliente int,codproducto char(3),codasesor varchar(15))--  
insert into #ptmosCP  
select c.codprestamo,c.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor  
from tcscartera c with(nolock)  
inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo  
where c.fecha=@fecha
and cartera='ACTIVA'  
insert into #ptmosCP  
select d.codprestamo,d.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor  
from tcspadroncarteradet d with(nolock)  
left outer join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fechacorte  
where d.cancelacion>=@fecini and d.cancelacion<=@fecha  

create table #CUO(  
          codoficina varchar(4),  
          codprestamo varchar(25),  
          seccuota int,  
          montodevengado money,  
          montopagado money,  
          fechavencimiento smalldatetime,  
          fechapago smalldatetime,  
          estadocuota varchar(20))  
insert into #CUO  
select p.codoficina,cu.codprestamo,cu.seccuota  
,sum(cu.montodevengado) montodevengado  
,sum(cu.montopagado) montopagado  
,cu.fechavencimiento  
,max(cu.fechapagoconcepto) fechapago  
,cu.estadocuota 
from tcspadronplancuotas cu with(nolock)  
inner join #ptmosCP p with(nolock) on p.codprestamo=cu.codprestamo  
where cu.codprestamo in(select codprestamo from #ptmosCP)  
and cu.numeroplan=0  
and cu.seccuota>0  
and cu.fechavencimiento>=@fecini and cu.fechavencimiento<=@fecha  
and cu.codconcepto = 'CAPI'  
group by cu.codprestamo,cu.seccuota  
,cu.fechavencimiento  
,cu.estadocuota  
,p.codoficina  
   
   
select @fecha fecha, z.Nombre region  
,o.nomoficina sucursal,o.codoficina codoficina , ca.codasesor 
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'  
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'  
            when ca.nrodiasatraso>=31 then '31+DM' else '' end atraso   
,case when ca.secuenciacliente>=5 then 'c.5+'  
         when ca.secuenciacliente>=3 then 'c.3-4'  
         when ca.secuenciacliente=2 then 'c.2'  
         else 'c.1' end rangoCiclo   
,sum(p.montodevengado) programado_s    
,sum(case when p.estadocuota='CANCELADO'and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) monto_anticipado  
, sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) monto_puntual 
, sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento then p.montopagado else 0 end) momto_atrasado  

into  #cobranzaP
from #CUO p with(nolock)  
inner join #ptmosCP ca with(nolock) on ca.codprestamo=p.codprestamo  
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina  
inner join tclzona z with(nolock) on z.zona=o.zona  
inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor  
where o.zona not in('ZSC','ZCO')  
group by p.fechavencimiento,z.Nombre  
,o.codoficina  
,o.nomoficina ,ca.codasesor 
,case when ca.secuenciacliente>=5 then 'c.5+'  
         when ca.secuenciacliente>=3 then 'c.3-4'  
         when ca.secuenciacliente=2 then 'c.2'  
         else 'c.1' end          
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'  
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'  
            when ca.nrodiasatraso>=31 then '31+DM' else '' end  
order by z.Nombre  


declare @pDiariaxPromotor table(codoficina varchar(4),codasesor varchar(30),puntualc1 money,puntualC2 money,puntualC3_4 money
						,puntualC5m money,PuntualTotal money
						,programadoTotal money
						,programadoC1 money
						,programadoC2 money
						,programadoC3_4 money
						,programadoC5m money
						,cobradoTotal money
						,cobradoC1 money
						,cobradoC2 money
						,cobradoC3a4 money
						,cobradoC5m money)
insert into @pDiariaxPromotor
select codoficina,codasesor
/*cobranza puntual*/
,sum(case when rangoCiclo='c.1' then (monto_puntual+monto_anticipado) else 0 end) puntualC1
,sum(case when rangoCiclo='c.2' then (monto_puntual+monto_anticipado) else 0 end) puntualC2
,sum(case when rangoCiclo in ('c.3-4') then (monto_puntual+monto_anticipado) else 0 end) puntualC3_4
,sum(case when rangoCiclo in ('c.5+') then (monto_puntual+monto_anticipado) else 0 end) puntualC5m
,sum(monto_puntual+monto_anticipado) puntualTotal
/*programada*/
,sum(programado_s) programadoTotal
,sum(case when rangoCiclo='c.1' then (programado_s) else 0 end) programadoC1
,sum(case when rangoCiclo='c.2' then (programado_s)  else 0 end) programadoC2
,sum(case when rangoCiclo in ('c.3-4') then (programado_s) else 0 end)  programadoC3_4
,sum(case when rangoCiclo in ('c.5+') then (programado_s) else 0 end)  programadoC5m
/*cobrada*/
,sum(monto_anticipado+monto_puntual+momto_atrasado) cobradoTotal
,sum(case when rangoCiclo='c.1' then (monto_anticipado+monto_puntual+momto_atrasado) else 0 end) cobradoC1
,sum(case when rangoCiclo='c.2' then (monto_anticipado+monto_puntual+momto_atrasado)  else 0 end) cobradoC2
,sum(case when rangoCiclo in ('c.3-4') then (monto_anticipado+monto_puntual+momto_atrasado) else 0 end)  cobradoC3a4
,sum(case when rangoCiclo in ('c.5+') then (monto_anticipado+monto_puntual+momto_atrasado) else 0 end)  cobradoC5m
from #cobranzaP with(nolock)
where atraso in ('0-7DM','8-30DM')--> 0 a 30 dm
group by codoficina,codasesor

  
declare @CobranzaPuntual table(fecha smalldatetime ,codoficina varchar(4),codasesor varchar(30)
								,CobranzaPuntalC1 money
								,CobranzaPuntualC2 money
								,CobranzaPuntualC3_4 money
								,CobranzaPuntualC5m money
								,CobranzaPuntalTotal money
								,CobranzaC1 money
								,CobranzaC2 money
								,CobranzaC3_4 money
								,CobranzaC5m money
								,CobranzaTotal money) 								
insert into @CobranzaPuntual
select @fecha,codoficina,codasesor
/*recuperacion puntual*/
,sum(case when programadoC1=0 then 0 else (puntualC1)/(programadoC1) end)*100 recPuntualC1
,sum(case when programadoC2=0 then 0 else (puntualC2)/(programadoC2) end)*100 recPuntualC2
,sum(case when programadoC3_4=0 then 0 else (puntualC3_4)/(programadoC3_4) end)*100 recPuntualC3_4
,sum(case when programadoC5m=0 then 0 else (puntualC5m)/(programadoC5m) end)*100 recPuntualC5m
,sum(case when programadoTotal=0 then 0 else (puntualTotal)/(programadoTotal) end)*100 recPuntualTotal
/*recuperacion cobranza*/
,sum(case when programadoC1=0 then 0 else (cobradoC1)/(programadoC1) end)*100 recCobranzaC1
,sum(case when programadoC2=0 then 0 else (cobradoC2)/(programadoC2) end)*100 recCobranzaC2
,sum(case when programadoC3_4=0 then 0 else (cobradoC3a4)/(programadoC3_4) end)*100 recCobranzaC3a4
,sum(case when programadoC5m=0 then 0 else (cobradoC5m)/(programadoC5m) end)*100 recCobranzaC5m
,sum(case when programadoTotal=0 then 0 else (cobradoTotal)/(programadoTotal) end)*100 recCobranzaTotal
from  @pDiariaxPromotor
group by codoficina,codasesor

   
drop table #ptmosCP  
drop table #CUO  
drop table  #cobranzaP

/*DATOS DE TODA LA SECCION DE COBRANZA*/

select p.fecha,c.codoficina,c.codasesor
,sum(programadoTotal) coProgramado
,sum(programadoC5m) ProgramadoC5m
,sum(programadoC3_4) ProgramadoC3a4
,sum(programadoC2) ProgramadoC2
,sum(programadoC1) ProgramadoC1

,sum(cobradoTotal) coPagado
,sum(cobradoC5m) PagadoC5
,sum(cobradoC3a4) PagadoC3a4
,sum(cobradoC2) PagadoC2
,sum(cobradoC1) PagadoC1

/*recuperacion de cobranza*/
,round(sum(CobranzaC1),2) reCobranzaC1 
,round(sum(CobranzaC2),2)   reCobranzaC2
,round(sum(CobranzaC3_4),2) reCobranzaC3a4
,round(sum(CobranzaC5m),2)reCobranzaC5m
,round(sum(CobranzaTotal),2)reCobranzaTo

/*recuperacion puntual*/
,sum(CobranzaPuntalC1)rePuntalC1 ,sum(CobranzaPuntualC2)rePuntualC2 ,sum(CobranzaPuntualC3_4)rePuntualC3a4 
,sum(CobranzaPuntualC5m)rePuntualC5m ,sum(CobranzaPuntalTotal)rePuntalTo
into #CobranzaPrevio
from @pDiariaxPromotor c
left outer join @CobranzaPuntual p on p.codasesor=c.codasesor and p.codoficina=c.codoficina
group by p.fecha,c.codasesor,c.codoficina



delete from #CobranzaPrevio
from #CobranzaPrevio c 
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha
where (case when (e.codpuesto<>66 or e.codusuario is null ) then 'HUERFANO' 
			else codasesor end)='HUERFANO'  


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
						,codasesor varchar(15)
						,montoRenovAnt money
						,montoReactiva money
						,montoRenovacion money
						,montonuevo money
						,montoEntrega money
						,RenovPtmos int
						,RenovAntPtmos int
						,ReactivaPtmos  int
						,nuevosPtmos  int
						,totalPtmos int)
insert into @colocacionM
select p.codoficina, p.ultimoasesor
------------------------ colocacion Entrega --monto
,sum(case when p.TipoReprog='RENOV' then p.monto else 0 end )RenovAntEnt
,sum(case when p.TipoReprog='RENOV' then 0 ELSE
                case when l.cancelacion is NULL then 0 ELSE
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)
                               then 0 else p.monto end END end) ReacEntrega
,sum(case when p.TipoReprog='RENOV' then 0 ELSE
                case when l.cancelacion is NULL then 0 ELSE
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)
                               then p.monto  else 0 end END end) RenovEnt   
,sum(case when l.cancelacion is NULL  then p.monto else 0 end) nuevoEntrega
,sum(p.monto)montoEntrega
---------------------------#Créditos 
,sum(case when p.TipoReprog='RENOV' then 0 ELSE
                case when l.cancelacion is NULL then 0 ELSE
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)
                               then 1  else 0 end END end) RenovPtmos
,sum(case when p.TipoReprog='RENOV' then 1 else 0 end )RAnticipaPtmos
,sum(case when p.TipoReprog='RENOV' then 0 ELSE
                case when l.cancelacion is NULL then 0 ELSE
                case when month(l.cancelacion)=month(p.desembolso) and year(l.cancelacion)=year(p.desembolso)
                               then 0 else 1 end END end) ReactivaPtmos
,sum(case when l.cancelacion is NULL  then 1 else 0 end) nuevosPtmos
,count(p.codprestamo)totalPtmos
from tcspadroncarteradet p with(nolock)
left outer join @liqreno l on l.codprestamo=p.codprestamo
inner join tcscartera c with(nolock) on c.CodPrestamo=p.CodPrestamo and c.fecha=p.Desembolso
left outer join [10.0.2.14].finmas.dbo.tcasolicitudrenovacionanticipadaproce s ON s.CodSolicitud=c.CodSolicitud and s.CodOficina=c.CodOficina
where p.desembolso>=@fecini and p.desembolso<=@fecha
and p.codoficina<>'97'
group by p.codoficina, p.ultimoasesor

 
declare @ColocaPrevio table(codoficina varchar(30)
						,codasesor varchar(15)
						,montoRenovacion money
						,montoRenovAnt money
						,montoReactiva money
						,montonuevo money
						,montoEntrega money
						,RenovPtmos int
						,RenovAntPtmos int
						,ReactivaPtmos  int
						,nuevosPtmos  int
						,totalPtmos int
						,saldopromRenov money
						,saldopromRenovAnt money
						,saldopromReactiva money
						,saldopromNuevo money
						,saldopromTotal money
						,porRenov money
						,porRenovAnt money
						,porReactiva money
						,porNuevo money
						,porTotal money)
insert into @ColocaPrevio
select  
codoficina,codasesor
--Montos
,sum(montoRenovacion),sum(montoRenovAnt),sum(montoReactiva),sum(montonuevo),sum(montoEntrega) 
--nros ptmos
,sum(RenovPtmos),sum(RenovAntPtmos),sum(ReactivaPtmos),sum(nuevosPtmos),sum(totalPtmos) 
--saldo Promedio
,(case when isnull(sum(RenovPtmos),0)=0 then 0 else isnull(sum(montoRenovacion),0)/isnull(sum(RenovPtmos),0) end)saldopromRenov
,(case when isnull(sum(RenovAntPtmos),0)=0 then 0 else isnull(sum(montoRenovAnt),0)/isnull(sum(RenovAntPtmos),0) end)saldopromRenovAnt
,(case when isnull(sum(ReactivaPtmos),0)=0 then 0 else isnull(sum(montoReactiva),0)/isnull(sum(ReactivaPtmos),0) end)saldopromReactiva
,(case when isnull(sum(nuevosPtmos),0)=0 then 0 else isnull(sum(montonuevo),0)/isnull(sum(nuevosPtmos),0) end)saldopromNuevo
,(case when isnull(sum(totalPtmos),0)=0 then 0 else isnull(sum(montoEntrega),0)/isnull(sum(totalPtmos),0) end)saldopromTotal
---porcentaje 
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(montoRenovacion),0)/isnull(sum(montoEntrega),0)*100 end)porRenov
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(montoRenovAnt),0)/isnull(sum(montoEntrega),0)*100 end)porRenovAnt
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(montoReactiva),0)/isnull(sum(montoEntrega),0)*100 end)porReactiva
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(montonuevo),0)/isnull(sum(montoEntrega),0)*100 end)porNuevo
,(case when isnull(sum(montoEntrega),0)=0 then 0 else isnull(sum(montoEntrega),0)/isnull(sum(montoEntrega),0)*100 end)porTotal
from @colocacionM
group by codoficina,codasesor


delete from @ColocaPrevio
from @ColocaPrevio c 
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha
where (case when (e.codpuesto<>66 or e.codusuario is null ) then 'HUERFANO' 
			else codasesor end)='HUERFANO'  


declare  @liq table(codoficina varchar(4),coordinador varchar(500),codpromotor varchar(50),nro int,monto money)
insert into @liq
select codoficina,coordinador,codpromotor,count(codprestamo) nro,sum(monto)monto
--select top 10*
from tCsACaLIQUI_RR  with(nolock) 
where cancelacion>=@fecini and cancelacion<=@fecha
and atrasomaximo<=15
group by codoficina,coordinador,codpromotor

declare @Ren table(codoficina varchar(4),coordinador varchar(500),codpromotor varchar(50),nro int,monto money)
insert into @Ren
select codoficina,coordinador,codpromotor,count(codprestamo) nro,sum(nuevomonto)monto
from tCsACaLIQUI_RR   
where cancelacion>=@fecini and cancelacion<=@fecha
and estado='RENOVADO'
and atrasomaximo<=15
group by codoficina,coordinador,codpromotor


select l.codoficina,l.codpromotor codasesor
,sum(l.monto) montoLiqui
,sum(r.monto )MontoRenov
,sum(isnull(l.monto,0))-sum(isnull(r.monto,0)) montoSinRenov
,sum(isnull(l.nro,0)) ptmsLiqui
,sum(isnull(r.nro,0)) ptmosRenov
,sum(isnull(l.nro,0))-sum(isnull(r.nro,0)) ptmoSinRenovar
,sum(case when l.monto=0 then 0 else (r.monto)/(l.monto) *100 end )porRenovmonto
,sum(case when l.nro=0 then 0 else round((r.nro)/cast(l.nro as decimal)*100,2) end )porRenovptmos
,sum(case when l.nro=0 then 0 else (l.monto)/(l.nro) end) promLiquida
,sum(case when r.nro=0 then 0 else (r.monto)/(r.nro) end) promRenovacion
into #RenovaPrevio
from  @liq l  
left outer join @Ren r  on l.codpromotor=r.codpromotor
group by  l.codoficina,l.codpromotor



delete from #RenovaPrevio
from #RenovaPrevio c 
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha
where (case when (e.codpuesto<>66 or e.codusuario is null ) then 'HUERFANO' 
			else codasesor end)='HUERFANO'  



/*PARA EL UNIVERSO DE PTMOS*/

/*------------ANTICIPADAS */

declare @Anticipadas table(codoficina varchar(3),promotor varchar(250),codusuario varchar(20)
                           ,nroAnticipadas int
                           ,montoAnticipadas money )
insert into @Anticipadas
select a.codoficina,promotor,codusuario,count(a.codprestamo)nroAnticipada
,sum(montodisponibleRenovacion)anticipaMonto
from tcsaRenovaAnticipaPreCal a with(nolock)                    
inner join tcspadronclientes pro on pro.nombrecompleto=a.promotor  
group by a.codoficina,promotor,codusuario

-------- REACTIVACIONES 
------------------------------------------------ REACTIVACIONES 
declare @Reactivacion table  (codoficina varchar(40)
							,coordinador varchar(150)
							,codpromotor varchar(30)
							,nuevomonto money
							,nuevodesembolso int
							,codprestamonuevo varchar (30)) 
insert into @Reactivacion
select 
codoficina,coordinador,codpromotor,(nuevomonto)nuevomonto
,dbo.fdufechaaperiodo(nuevodesembolso) nuevodesembolso
,(codprestamonuevo)codprestamonuevo
from tCsACaLIQUI_RR t with(nolock) 
where cancelacion>=@feciniCosRe and cancelacion<@fecfinCosRe ---inicio de mes
and estado='Reactivado'
and  t.atrasomaximo<=30


declare @pCosecha table  (codoficina varchar(40)
							,coordinador varchar(150)
							,codpromotor varchar(30)
							,monto money
							,codprestamo varchar (30)) 
insert into @pCosecha							
select codoficina,coordinador,codpromotor,monto monto,codprestamo codprestamo
from tCsACaLIQUI_RR t with(nolock)                   
where cancelacion>=@feciniCosRe--cancelacion periodox3 meses anteriores
 and cancelacion<@fecfinCosRe  -- inicio de mes
and estado<>'Reactivado' and estado<>'Renovado'
and  t.atrasomaximo<=30 ---modificado 

declare @BaseReactivacion	 table (codoficina varchar(40)
							,coordinador varchar(150)
							,codpromotor varchar(30)
							--,nroNewPtmos int
							--,nroPtmos int
							--,porAlcance decimal(8,4)
							,montoPendte money
							,nroPendiente int)
insert into @BaseReactivacion							
select a.codoficina,a.coordinador,a.codpromotor
--,sum(nuevomonto) nuevomonto,sum(monto)monto,
--,sum(codprestamonuevo)nroNewPtmos
--,sum(codprestamo)nroPtmos
--,case when sum(codprestamo)=0 then 0 else sum(codprestamonuevo)/cast(isnull(sum(codprestamo),0) as decimal(8,4)) end *100 porAlcance
,isnull(sum(monto),0)-isnull(sum(nuevomonto),0)montoPendte
,isnull(sum(codprestamo),0)- isnull(sum(codprestamonuevo),0) nroPendiente
from (
	select 1x,
	 codoficina,coordinador,codpromotor,sum(nuevomonto)nuevomonto,count(codprestamonuevo)codprestamonuevo
	 ,0 monto,0 codprestamo
     from @Reactivacion
     where nuevodesembolso>=dbo.fdufechaaperiodo(@fecha)  --Periodo mes actual--'202201'
   group by codoficina,coordinador,codpromotor
	union
	select 2x,
	codoficina,coordinador,codpromotor,0 nuevomonto,0 condprestamonuevo
	,sum(monto)monto,count(codprestamo)codprestamo
	from @pCosecha 
	group by codoficina,coordinador,codpromotor
)a	
group by codoficina,coordinador,codpromotor


select r.codoficina codoficina,r.codpromotor codasesor
,montoAnticipadas montoAnticipaU,nroAnticipadas ptmosAnticipaU
,montoPendte montoReactivacionU
,nroPendiente ptmosReactivacionU
into #UniversoPrevio
from @Anticipadas a
left outer join @BaseReactivacion r on a.codoficina=r.codoficina and r.codpromotor=a.codusuario


delete from #UniversoPrevio
from #UniversoPrevio c 
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha
where (case when (e.codpuesto<>66 or e.codusuario is null ) then 'HUERFANO' 
			else codasesor end)='HUERFANO'  

------------------- DETERIORO
	declare @ptmos table(codprestamo varchar(20))
	insert into @ptmos
	select distinct codprestamo
	from tcspadroncarteradet pd with(nolock)
	where pd.desembolso>=@fecosecha -- A PARTIR DE QUE FECHA COSECHAS SE EVALUA
	and pd.desembolso<=@fecha       -- fecha corte
	and pd.codoficina not in('97','230','231','98') 
	and codprestamo not in (select codprestamo from tCsCarteraAlta)
	
declare @cos table (ID int IDENTITY(1,1),cosecha varchar(6))
insert into @cos(cosecha) 
select DISTINCT dbo.fdufechaaperiodo(pd.desembolso)cosecha
FROM tcspadroncarteradet pd with(nolock)
where pd.codprestamo in(select codprestamo from @ptmos)
order by dbo.fdufechaaperiodo(pd.desembolso)


/*--- Mostrar un periodo de  12 cosechas */

declare @deterioro table (codoficina varchar(3),codasesor varchar(30)
						,montodesembolso money
						,recuperado money
						,cosecha varchar(6)
						,D0saldo money
						,D0a15saldo money
						,D16saldo money
						,Castigadosaldo money)
insert into @deterioro					
select a.codoficina,a.ultimoasesor
	,sum(montodesembolso) montodesembolso
	,sum(montodesembolso)-sum(D0saldo)-sum(Castigadosaldo) recuperado
	,cosecha cosecha
	,sum(D0saldo)D0saldo
	,sum(D0a15saldo)D0a15saldo
	,sum(D16saldo)D16saldo
	,sum(Castigadosaldo)Castigadosaldo
	from (
	  SELECT 
	 o.codoficina ,pd.ultimoasesor
	 ,isnull(cd.saldocapital,0) saldocapital
	  ,pd.monto montodesembolso
	  ,dbo.fdufechaaperiodo(pd.Desembolso) cosecha  
	,case when c.cartera= 'CASTIGADA' then   cd.saldocapital   else 0 end Castigadosaldo
	,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=16 then  cd.saldocapital  else 0 end else 0 end D16saldo
    ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=15  then  cd.saldocapital  else 0 end else 0 end D0a15saldo
	 ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 then cd.saldocapital  else 0 end else 0 end D0saldo
	  FROM tcspadroncarteradet pd with(nolock)
	  left outer join tcscarteradet cd with(nolock) on cd.fecha=@fecha and cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario
	  left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha
	  inner join tcloficinas o with(nolock) on o.codoficina=pd.codoficina
	  where pd.codprestamo in(select codprestamo from @ptmos) 
	) a 
	  group by a.codoficina,a.ultimoasesor,cosecha
	  order by codoficina,cosecha
	  
declare @idCosecha1 varchar(6)
select @idCosecha1 =  cosecha from @cos  where id=1
declare @idCosecha2 varchar(6)
select @idCosecha2 =  cosecha from @cos  where id=2
declare @idCosecha3 varchar(6)
select @idCosecha3 =  cosecha from @cos  where id=3
declare @idCosecha4 varchar(6)
select @idCosecha4 =  cosecha from @cos  where id=4
declare @idCosecha5 varchar(6)
select @idCosecha5 =  cosecha from @cos  where id=5
declare @idCosecha6 varchar(6)
select @idCosecha6 =  cosecha from @cos  where id=6
declare @idCosecha7 varchar(6)
select @idCosecha7 =  cosecha from @cos  where id=7
declare @idCosecha8 varchar(6)
select @idCosecha8 =  cosecha from @cos  where id=8
declare @idCosecha9 varchar(6)
select @idCosecha9 =  cosecha from @cos  where id=9
declare @idCosecha10 varchar(6)
select @idCosecha10 =  cosecha from @cos  where id=10
declare @idCosecha11 varchar(6)
select @idCosecha11 =  cosecha from @cos  where id=11
declare @idCosecha12 varchar(6)
select @idCosecha12 =  cosecha from @cos  where id=12

declare @det table (codoficina varchar(3),codasesor varchar(30)
,colocacionC1 money,porRecuperaC1 money,Deterioro0a15C1 money,Deterioro16C1 money
,colocacionC2 money,porRecuperaC2 money,Deterioro0a15C2 money,Deterioro16C2 money
,colocacionC3 money,porRecuperaC3 money,Deterioro0a15C3 money,Deterioro16C3 money
,colocacionC4 money,porRecuperaC4 money,Deterioro0a15C4 money,Deterioro16C4 money
,colocacionC5 money,porRecuperaC5 money,Deterioro0a15C5 money,Deterioro16C5 money
,colocacionC6 money,porRecuperaC6 money,Deterioro0a15C6 money,Deterioro16C6 money
,colocacionC7 money,porRecuperaC7 money,Deterioro0a15C7 money,Deterioro16C7 money
,colocacionC8 money,porRecuperaC8 money,Deterioro0a15C8 money,Deterioro16C8 money
,colocacionC9 money,porRecuperaC9 money,Deterioro0a15C9 money,Deterioro16C9 money
,colocacionC10 money,porRecuperaC10 money,Deterioro0a15C10 money,Deterioro16C10 money
,colocacionC11 money,porRecuperaC11 money,Deterioro0a15C11 money,Deterioro16C11 money
,colocacionC12 money,porRecuperaC12 money,Deterioro0a15C12 money,Deterioro16C12	 money
) 
insert into @det
select 
      d.codoficina ,d.codasesor
      --,@idCosecha1 cosecha1
	  ,sum(case when c.id=1 then montodesembolso else 0 end )colocacionC1 
	  ,case when sum(case when c.id=1 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=1 then recuperado else 0 end )
	  /sum(case when c.id=1 then montodesembolso else 0 end )*100 end porRecuperaC1
      ,case when sum(case when c.id=1 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=1 then(D0a15saldo) else 0 end)/sum(case when c.id=1 then montodesembolso else 0 end)*100 end Deterioro0a15C1
      ,case when sum(case when c.id=1 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=1 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=1 then montodesembolso else 0 end)*100 end Deterioro16C1
	  --,@idCosecha2 cosecha2
	  ,sum(case when c.id=2 then montodesembolso else 0 end )colocacionC2
	   ,case when sum(case when c.id=2 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=2 then recuperado else 0 end )
	  /sum(case when c.id=2 then montodesembolso else 0 end )*100 end porRecuperaC2
      ,case when sum(case when c.id=2 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=2 then(D0a15saldo) else 0 end)/sum(case when c.id=2 then montodesembolso else 0 end)*100 end Deterioro0a15C2
      ,case when sum(case when c.id=2 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=2 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=2 then montodesembolso else 0 end)*100 end Deterioro16C2
	  --,@idCosecha3 cosecha3
	  ,sum(case when c.id=3 then montodesembolso else 0 end )colocacionC3 
	  ,case when sum(case when c.id=3 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=3 then recuperado else 0 end )
	  /sum(case when c.id=3 then montodesembolso else 0 end )*100 end porRecuperaC3
      ,case when sum(case when c.id=3 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=3 then(D0a15saldo) else 0 end)/sum(case when c.id=3 then montodesembolso else 0 end)*100 end Deterioro0a15C3
      ,case when sum(case when c.id=3 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=3 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=3 then montodesembolso else 0 end)*100 end Deterioro16C3
	  --,@idCosecha4 cosecha4
	  ,sum(case when c.id=4 then montodesembolso else 0 end )colocacionC4 
	  ,case when sum(case when c.id=4 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=4 then recuperado else 0 end )
	  /sum(case when c.id=4 then montodesembolso else 0 end )*100 end porRecuperaC4
      ,case when sum(case when c.id=4 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=4 then(D0a15saldo) else 0 end)/sum(case when c.id=4 then montodesembolso else 0 end)*100 end Deterioro0a15C4
      ,case when sum(case when c.id=4 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=4 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=4 then montodesembolso else 0 end)*100 end Deterioro16C4
	  --,@idCosecha5 cosecha5
	  ,sum(case when c.id=5 then montodesembolso else 0 end )colocacionC5 
	  ,case when sum(case when c.id=5 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=5 then recuperado else 0 end )
	  /sum(case when c.id=5 then montodesembolso else 0 end )*100 end porRecuperaC5
      ,case when sum(case when c.id=5 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=5 then(D0a15saldo) else 0 end)/sum(case when c.id=5 then montodesembolso else 0 end)*100 end Deterioro0a15C5
      ,case when sum(case when c.id=5 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=5 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=5 then montodesembolso else 0 end)*100 end Deterioro16C5
	  --,@idCosecha6 cosecha6
	  ,sum(case when c.id=6 then montodesembolso else 0 end )colocacionC6 
	  ,case when sum(case when c.id=6 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=6 then recuperado else 0 end )
	  /sum(case when c.id=6 then montodesembolso else 0 end )*100 end porRecuperaC6
      ,case when sum(case when c.id=6 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=6 then(D0a15saldo) else 0 end)/sum(case when c.id=6 then montodesembolso else 0 end)*100 end Deterioro0a15C6
      ,case when sum(case when c.id=6 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=6 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=6 then montodesembolso else 0 end)*100 end Deterioro16C6
	  --,@idCosecha7 cosecha7
	  ,sum(case when c.id=7 then montodesembolso else 0 end )colocacionC7 
	  ,case when sum(case when c.id=7 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=7 then recuperado else 0 end )
	  /sum(case when c.id=7 then montodesembolso else 0 end )*100 end porRecuperaC7
      ,case when sum(case when c.id=7 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=7 then(D0a15saldo) else 0 end)/sum(case when c.id=7 then montodesembolso else 0 end)*100 end Deterioro0a15C7
      ,case when sum(case when c.id=7 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=7 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=7 then montodesembolso else 0 end)*100 end Deterioro16C7
	  --,@idCosecha8 cosecha8
	  ,sum(case when c.id=8 then montodesembolso else 0 end )colocacionC8 
	  ,case when sum(case when c.id=8 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=8 then recuperado else 0 end )
	  /sum(case when c.id=8 then montodesembolso else 0 end )*100 end porRecuperaC8
      ,case when sum(case when c.id=8 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=8 then(D0a15saldo) else 0 end)/sum(case when c.id=8 then montodesembolso else 0 end)*100 end Deterioro0a15C8
      ,case when sum(case when c.id=8 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=8 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=8 then montodesembolso else 0 end)*100 end Deterioro16C8
	  --,@idCosecha9 cosecha9
	  ,sum(case when c.id=9 then montodesembolso else 0 end )colocacionC9 
	  ,case when sum(case when c.id=9 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=9 then recuperado else 0 end )
	  /sum(case when c.id=9 then montodesembolso else 0 end )*100 end porRecuperaC9
      ,case when sum(case when c.id=9 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=9 then(D0a15saldo) else 0 end)/sum(case when c.id=9 then montodesembolso else 0 end)*100 end Deterioro0a15C9
      ,case when sum(case when c.id=9 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=9 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=9 then montodesembolso else 0 end)*100 end Deterioro16C9
	  --,@idCosecha10 cosecha10
	  ,sum(case when c.id=10 then montodesembolso else 0 end )colocacionC10
	  ,case when sum(case when c.id=10 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=10 then recuperado else 0 end )
	  /sum(case when c.id=10 then montodesembolso else 0 end )*100 end porRecuperaC10
      ,case when sum(case when c.id=10 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=10 then(D0a15saldo)else 0 end)/sum(case when c.id=10 then montodesembolso else 0 end)*100 end Deterioro0a15C10
      ,case when sum(case when c.id=10 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=10 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=10 then montodesembolso else 0 end)*100 end Deterioro16C10
	  --,@idCosecha11 cosecha11
	  ,sum(case when c.id=11 then montodesembolso else 0 end )colocacionC11
	  ,case when sum(case when c.id=11 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=11 then recuperado else 0 end )
	  /sum(case when c.id=11 then montodesembolso else 0 end )*100 end porRecuperaC11
      ,case when sum(case when c.id=11 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=11 then(D0a15saldo) else 0 end)/sum(case when c.id=11 then montodesembolso else 0 end)*100 end Deterioro0a15C11
      ,case when sum(case when c.id=11 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=11 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=11 then montodesembolso else 0 end)*100 end Deterioro16C11
	  --,@idCosecha12 cosecha12
	  ,sum(case when c.id=12 then montodesembolso else 0 end )colocacionC12 
	  ,case when sum(case when c.id=12 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=12 then recuperado else 0 end )
	  /sum(case when c.id=12 then montodesembolso else 0 end )*100 end porRecuperaC12
      ,case when sum(case when c.id=12 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=12 then(D0a15saldo)else 0 end)/sum(case when c.id=12 then montodesembolso else 0 end)*100 end Deterioro0a15C12
      ,case when sum(case when c.id=12 then montodesembolso else 0 end )=0 then 0 else 
      sum(case when c.id=12 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=12 then montodesembolso else 0 end)*100 end Deterioro16C12
 	  FROM @cos c 
 	  left outer join @deterioro d on d.cosecha=c.cosecha
      group by d.codoficina,d.codasesor

delete from @det
from @det c 
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha
where (case when (e.codpuesto<>66 or e.codusuario is null ) then 'HUERFANO' 
			else codasesor end)='HUERFANO'  



------------------ANTIGUEDAD DE PROMOTORES ACTIVOS

--Ingresos de meses anteriores
declare @Antiquedad table(fecha smalldatetime,codoficina varchar(4),codusuario varchar(30),mes int)
insert into @Antiquedad
select b1.fecha, b1.Codoficina,b1.codusuario
,(datediff(day,e.Ingreso,b1.fecha)/30) mesesantiguedad
from tCsempleadosfecha as b1 with(nolock)
inner join tCsempleados as e with(nolock) on b1.codusuario=e.codusuario
where b1.CodPuesto=66 and b1.Fecha=@fecha 


Select @fecha fecha,@diacorte diaCorte
	,max(codoficina)codoficina
	,codasesor,max(coordinador)coordinador
	,sum(mes) mes
	,sum(saldoIni0a30)saldoIni0a30,sum(saldoIni31a89)saldoIni31a89,sum(saldoIni90m)saldoIni90m
	,(sum(saldoIni0a30)+sum(saldoIni31a89)+sum(saldoIni90m))SaldoIniTo
	,sum(ptmsVgteIni)ptmsVgteIni,sum(ptmsVgtefin)ptmsVgtefin
	,sum(imor16ini)imor16ini,sum(imor30ini)imor30ini,sum(imor90mini)imor90mini
	,sum(cubini1a7)cubini1a7,sum(cubini8a15)cubini8a15,sum(cubini16a30)cubini16a30,sum(cubini31m)cubini31m,sum(cubiniTotal)cubiniTotal
	,sum(ptmos1a7ini)ptmos1a7ini,sum(ptmos8a15ini)ptmos8a15ini,sum(ptmos16a30ini)ptmos16a30ini,sum(ptmos31ini)ptmos31ini,sum(ptmosTotalini)ptmosTotalini 
	,sum(saldoFin0a30)saldoFin0a30,sum(saldofin31a89)saldofin31a89,sum(saldoFin90m)saldoFin90m
	,(sum(saldoFin0a30)+sum(saldofin31a89)+sum(saldoFin90m))saldoFinTo
	,sum(imor16fin)imor16fin,sum(imor30fin)imor30fin,sum(imor90mfin)imor90mfin
	,sum(cubfin1a7)cubfin1a7,sum(cubfin8a15)cubfin8a15,sum(cubfin16a30)cubfin16a30,sum(cubfin31m)cubfin31m,sum(cubfinTotal)cubfinTotal
	,sum(ptmos1a7fin)ptmos1a7fin,sum(ptmos8a15fin)ptmos8a15fin,sum(ptmos16a30fin)ptmos16a30fin,sum(ptmos31fin)ptmos31fin,sum(ptmosTotalfin)ptmosTotalfin	
	,sum(creciSaldo0a30)creciSaldo0a30,sum(creciSaldo31a89)creciSaldo31a89,sum(creciSaldo90m)creciSaldo90m,sum(creciPtmosVgtes)creciPtmosVgtes
	,max(detImor16)detImor16,max(detImor30)detImor30,max(detImor90)detImor90,sum(Crecub1a7)Crecub1a7,sum(Crecub8a15)Crecub8a15,sum(crecub16a30)crecub16a30
	,sum(crecub31m)crecub31m,sum(crecub1m)crecub1m,sum(creptmos1a7)creptmos1a7,sum(creptmos8a15)creptmos8a15,sum(creptmos16a30)creptmos16a30,sum(creptmos31m)creptmos31m,sum(creptmos1m)creptmos1m
	,sum(coProgramado)coProgramado,sum(ProgramadoC5m)ProgramadoC5m,sum(ProgramadoC3a4)ProgramadoC3a4,sum(ProgramadoC2)ProgramadoC2,sum(ProgramadoC1)ProgramadoC1
	,sum(coPagado)coPagado,sum(PagadoC5)PagadoC5,sum(PagadoC3a4)PagadoC3a4,sum(PagadoC2)PagadoC2,sum(PagadoC1)PagadoC1
	,sum(reCobranzaC1)reCobranzaC1,sum(reCobranzaC2)reCobranzaC2,sum(reCobranzaC3a4)reCobranzaC3a4,sum(reCobranzaC5m)reCobranzaC5m,sum(reCobranzaTo)reCobranzaTo
	,sum(rePuntalC1)rePuntalC1,sum(rePuntualC2)rePuntualC2,sum(rePuntualC3a4)rePuntualC3a4,sum(rePuntualC5m)rePuntualC5m,sum(rePuntalTo)rePuntalTo	
	,sum(montoRenovacion)montoRenovacion,sum(montoRenovAnt)montoRenovAnt,sum(montoReactiva)montoReactiva,sum(montonuevo)montonuevo,sum(montoEntrega)montoEntrega
	,sum(RenovPtmos)RenovPtmos,sum(RenovAntPtmos)RenovAntPtmos,sum(ReactivaPtmos)ReactivaPtmos,sum(nuevosPtmos)nuevosPtmos,sum(totalPtmos)totalPtmos	
	,sum(saldopromRenov)saldopromRenov,sum(saldopromRenovAnt)saldopromRenovAnt,sum(saldopromReactiva)saldopromReactiva,sum(saldopromNuevo)saldopromNuevo,sum(saldopromTotal)saldopromTotal
	,sum(porRenov)porRenov,sum(porRenovAnt)porRenovAnt,sum(porReactiva)porReactiva,sum(porNuevo)porNuevo,sum(porTotal)porTotal	
	,sum(montoLiqui)montoLiqui,sum(MontoRenov)MontoRenov,sum(montoSinRenov)montoSinRenov,sum(ptmsLiqui)ptmsLiqui,sum(ptmosRenov)ptmosRenov,sum(ptmoSinRenovar)ptmoSinRenovar
	,sum(porRenovmonto)porRenovmonto,sum(porRenovptmos)porRenovptmos,sum(promLiquida)promLiquida,sum(promRenovacion)promRenovacion
	,sum(montoAnticipaU)montoAnticipaU,sum(ptmosAnticipaU)ptmosAnticipaU,sum(montoReactivacionU)montoReactivacionU,sum(ptmosReactivacionU)ptmosReactivacionU
    ,sum(montoSinRenov)montosinRenovU,sum(ptmoSinRenovar)ptmoSinRenovarU
    ,sum(montoAnticipaU+montoSinRenov+montoReactivacionU)montoTotalU
    ,sum(ptmosAnticipaU+ptmosReactivacionU+ptmoSinRenovar)ptmosTotalU
    --- metas 
    ,sum(metacrecimiento)metacrecimiento,sum(porAlcance)porAlcance,max(estadoAlcance)estadoAlcance,sum(metaColocacion)metaColocacion
    ,case when sum(metaColocacion)=0 then 0 else (sum(montoEntrega)/sum(metaColocacion))*100 end porColocacion

	--Deterioro sum()
	,@idCosecha1 cosecha1,sum(colocacionC1)colocacionC1,sum(porRecuperaC1)porRecuperaC1,sum(Deterioro0a15C1)Deterioro0a15C1,sum(Deterioro16C1)Deterioro16C1
	,@idCosecha2 cosecha2,sum(colocacionC2)colocacionC2,sum(porRecuperaC2)porRecuperaC2,sum(Deterioro0a15C2)Deterioro0a15C2,sum(Deterioro16C2)Deterioro16C2
	,@idCosecha3 cosecha3,sum(colocacionC3)colocacionC3,sum(porRecuperaC3)porRecuperaC3,sum(Deterioro0a15C3)Deterioro0a15C3,sum(Deterioro16C3)Deterioro16C3
	,@idCosecha4 cosecha4,sum(colocacionC4)colocacionC4,sum(porRecuperaC4)porRecuperaC4,sum(Deterioro0a15C4)Deterioro0a15C4,sum(Deterioro16C4)Deterioro16C4
	,@idCosecha5 cosecha5,sum(colocacionC5)colocacionC5,sum(porRecuperaC5)porRecuperaC5,sum(Deterioro0a15C5)Deterioro0a15C5,sum(Deterioro16C5)Deterioro16C5
	,@idCosecha6 cosecha6,sum(colocacionC6)colocacionC6,sum(porRecuperaC6)porRecuperaC6,sum(Deterioro0a15C6)Deterioro0a15C6,sum(Deterioro16C6)Deterioro16C6
	,@idCosecha7 cosecha7,sum(colocacionC7)colocacionC7,sum(porRecuperaC7)porRecuperaC7,sum(Deterioro0a15C7)Deterioro0a15C7,sum(Deterioro16C7)Deterioro16C7
	,@idCosecha8 cosecha8,sum(colocacionC8)colocacionC8,sum(porRecuperaC8)porRecuperaC8,sum(Deterioro0a15C8)Deterioro0a15C8,sum(Deterioro16C8)Deterioro16C8
	,@idCosecha9 cosecha9,sum(colocacionC9)colocacionC9,sum(porRecuperaC9)porRecuperaC9,sum(Deterioro0a15C9)Deterioro0a15C9,sum(Deterioro16C9)Deterioro16C9
	,@idCosecha10 cosecha10,sum(colocacionC10)colocacionC10,sum(porRecuperaC10)porRecuperaC10,sum(Deterioro0a15C10)Deterioro0a15C10,sum(Deterioro16C10)Deterioro16C10
	,@idCosecha11 cosecha11,sum(colocacionC11)colocacionC11,sum(porRecuperaC11)porRecuperaC11,sum(Deterioro0a15C11)Deterioro0a15C11,sum(Deterioro16C11)Deterioro16C11
	,@idCosecha12 cosecha12,sum(colocacionC12)colocacionC12,sum(porRecuperaC12)porRecuperaC12,sum(Deterioro0a15C12)Deterioro0a15C12,sum(Deterioro16C12)Deterioro16C12	
into #base
from (
	select 3 x,
	codoficina,codasesor,coordinador
	,saldoIni0a30,saldoIni31a89,saldoIni90m,ptmsVgteIni,imor16ini,imor30ini,imor90mini
	,cubini1a7,cubini8a15,cubini16a30,cubini31m,cubiniTotal,ptmos1a7ini,ptmos8a15ini,ptmos16a30ini,ptmos31ini,ptmosTotalini 
	,saldoFin0a30,saldofin31a89,saldoFin90m,ptmsVgtefin,imor16fin,imor30fin,imor90mfin
	,cubfin1a7,cubfin8a15,cubfin16a30,cubfin31m,cubfinTotal,ptmos1a7fin,ptmos8a15fin,ptmos16a30fin,ptmos31fin,ptmosTotalfin
	,creciSaldo0a30,creciSaldo31a89,creciSaldo90m,creciPtmosVgtes,detImor16,detImor30,detImor90,Crecub1a7,Crecub8a15,crecub16a30
	,crecub31m,crecub1m,creptmos1a7,creptmos8a15,creptmos16a30,creptmos31m,creptmos1m
	,0 coProgramado,0 ProgramadoC5m,0 ProgramadoC3a4,0 ProgramadoC2,0 ProgramadoC1,0 coPagado,0 PagadoC5,0 PagadoC3a4,0 PagadoC2,0 PagadoC1
	,0 reCobranzaC1,0 reCobranzaC2,0 reCobranzaC3a4,0 reCobranzaC5m,0 reCobranzaTo,0 rePuntalC1,0 rePuntualC2,0 rePuntualC3a4,0 rePuntualC5m,0 rePuntalTo
	,0 montoRenovacion,0 montoRenovAnt,0 montoReactiva,0 montonuevo,0 montoEntrega,0 RenovPtmos,0 RenovAntPtmos,0 ReactivaPtmos,0 nuevosPtmos,0 totalPtmos
	,0 saldopromRenov,0 saldopromRenovAnt,0 saldopromReactiva,0 saldopromNuevo,0 saldopromTotal,0 porRenov,0 porRenovAnt,0 porReactiva,0 porNuevo,0 porTotal
	,0 montoLiqui,0 MontoRenov,0 montoSinRenov,0 ptmsLiqui,0 ptmosRenov,0 ptmoSinRenovar,0 porRenovmonto,0 porRenovptmos,0 promLiquida,0 promRenovacion
	,0 montoAnticipaU,0 ptmosAnticipaU,0 montoReactivacionU,0 ptmosReactivacionU
	,0 colocacionC1,0 porRecuperaC1,0 Deterioro0a15C1,0 Deterioro16C1,0 colocacionC2,0 porRecuperaC2,0 Deterioro0a15C2,0 Deterioro16C2
	,0 colocacionC3,0 porRecuperaC3,0 Deterioro0a15C3,0 Deterioro16C3,0 colocacionC4 ,0 porRecuperaC4 ,0 Deterioro0a15C4 ,0 Deterioro16C4 
	,0 colocacionC5 ,0 porRecuperaC5 ,0 Deterioro0a15C5 ,0 Deterioro16C5 ,0 colocacionC6 ,0 porRecuperaC6 ,0 Deterioro0a15C6 ,0 Deterioro16C6 
	,0 colocacionC7 ,0 porRecuperaC7 ,0 Deterioro0a15C7 ,0 Deterioro16C7 ,0 colocacionC8 ,0 porRecuperaC8 ,0 Deterioro0a15C8 ,0 Deterioro16C8 
	,0 colocacionC9 ,0 porRecuperaC9 ,0 Deterioro0a15C9 ,0 Deterioro16C9 ,0 colocacionC10 ,0 porRecuperaC10 ,0 Deterioro0a15C10 ,0 Deterioro16C10 
	,0 colocacionC11 ,0 porRecuperaC11 ,0 Deterioro0a15C11 ,0 Deterioro16C11 ,0 colocacionC12 ,0 porRecuperaC12 ,0 Deterioro0a15C12 ,0 Deterioro16C12
	,0 metacrecimiento,0 porAlcance,'' estadoAlcance,0 metaColocacion
	,0 mes
	from @creCartera
	union
	select 4 x,
	codoficina,codasesor,''coordinador
	,0 saldoIni0a30,0 saldoIni31a89,0 saldoIni90m,0 ptmsVgteIni,0 imor16ini,0 imor30ini,0 imor90mini
	,0 cubini1a7,0 cubini8a15,0 cubini16a30,0 cubini31m,0 cubiniTotal,0 ptmos1a7ini,0 ptmos8a15ini,0 ptmos16a30ini,0 ptmos31ini,0 ptmosTotalini 
    ,0 saldoFin0a30,0 saldofin31a89,0 saldoFin90m,0 ptmsVgtefin,0 imor16fin,0 imor30fin,0 imor90mfin
	,0 cubfin1a7,0 cubfin8a15,0 cubfin16a30,0 cubfin31m,0 cubfinTotal,0 ptmos1a7fin,0 ptmos8a15fin,0 ptmos16a30fin,0 ptmos31fin,0 ptmosTotalfin
	,0 creciSaldo0a30,0 creciSaldo31a89,0 creciSaldo90m,0 creciPtmosVgtes,''detImor16,''detImor30,''detImor90,0 Crecub1a7,0 Crecub8a15,0 crecub16a30
	,0 crecub31m,0 crecub1m,0 creptmos1a7,0 creptmos8a15,0 creptmos16a30,0 creptmos31m,0 creptmos1m
	,coProgramado,ProgramadoC5m,ProgramadoC3a4,ProgramadoC2,ProgramadoC1,coPagado,PagadoC5,PagadoC3a4,PagadoC2,PagadoC1
	,reCobranzaC1,reCobranzaC2,reCobranzaC3a4,reCobranzaC5m,reCobranzaTo,rePuntalC1,rePuntualC2,rePuntualC3a4,rePuntualC5m,rePuntalTo
	,0 montoRenovacion,0 montoRenovAnt,0 montoReactiva,0 montonuevo,0 montoEntrega,0 RenovPtmos,0 RenovAntPtmos,0 ReactivaPtmos,0 nuevosPtmos,0 totalPtmos
	,0 saldopromRenov,0 saldopromRenovAnt,0 saldopromReactiva,0 saldopromNuevo,0 saldopromTotal,0 porRenov,0 porRenovAnt,0 porReactiva,0 porNuevo,0 porTotal
	,0 montoLiqui,0 MontoRenov,0 montoSinRenov,0 ptmsLiqui,0 ptmosRenov,0 ptmoSinRenovar,0 porRenovmonto,0 porRenovptmos,0 promLiquida,0 promRenovacion
	,0 montoAnticipaU,0 ptmosAnticipaU,0 montoReactivacionU,0 ptmosReactivacionU
	,0 colocacionC1,0 porRecuperaC1,0 Deterioro0a15C1,0 Deterioro16C1,0 colocacionC2,0 porRecuperaC2,0 Deterioro0a15C2,0 Deterioro16C2
	,0 colocacionC3,0 porRecuperaC3,0 Deterioro0a15C3,0 Deterioro16C3,0 colocacionC4 ,0 porRecuperaC4 ,0 Deterioro0a15C4 ,0 Deterioro16C4 
	,0 colocacionC5 ,0 porRecuperaC5,0 Deterioro0a15C5 ,0 Deterioro16C5 ,0 colocacionC6 ,0 porRecuperaC6 ,0 Deterioro0a15C6 ,0 Deterioro16C6 
	,0 colocacionC7 ,0 porRecuperaC7,0 Deterioro0a15C7 ,0 Deterioro16C7 ,0 colocacionC8 ,0 porRecuperaC8 ,0 Deterioro0a15C8 ,0 Deterioro16C8 
	,0 colocacionC9 ,0 porRecuperaC9,0 Deterioro0a15C9 ,0 Deterioro16C9 ,0 colocacionC10 ,0 porRecuperaC10 ,0 Deterioro0a15C10 ,0 Deterioro16C10 
	,0 colocacionC11 ,0 porRecuperaC11,0 Deterioro0a15C11 ,0 Deterioro16C11 ,0 colocacionC12 ,0 porRecuperaC12 ,0 Deterioro0a15C12 ,0 Deterioro16C12
	,0 metacrecimiento,0 porAlcance,'' estadoAlcance,0 metaColocacion
	,0 mes

	from #CobranzaPrevio
	union
	select 5 x,
	codoficina,codasesor,''coordinador
	,0 saldoIni0a30,0 saldoIni31a89,0 saldoIni90m,0 ptmsVgteIni,0 imor16ini,0 imor30ini,0 imor90mini
	,0 cubini1a7,0 cubini8a15,0 cubini16a30,0 cubini31m,0 cubiniTotal,0 ptmos1a7ini,0 ptmos8a15ini,0 ptmos16a30ini,0 ptmos31ini,0 ptmosTotalini 
    ,0 saldoFin0a30,0 saldofin31a89,0 saldoFin90m,0 ptmsVgtefin,0 imor16fin,0 imor30fin,0 imor90mfin
	,0 cubfin1a7,0 cubfin8a15,0 cubfin16a30,0 cubfin31m,0 cubfinTotal,0 ptmos1a7fin,0 ptmos8a15fin,0 ptmos16a30fin,0 ptmos31fin,0 ptmosTotalfin
	,0 creciSaldo0a30,0 creciSaldo31a89,0 creciSaldo90m,0 creciPtmosVgtes,''detImor16,''detImor30,''detImor90,0 Crecub1a7,0 Crecub8a15,0 crecub16a30
	,0 crecub31m,0 crecub1m,0 creptmos1a7,0 creptmos8a15,0 creptmos16a30,0 creptmos31m,0 creptmos1m
	,0 coProgramado,0 ProgramadoC5m,0 ProgramadoC3a4,0 ProgramadoC2,0 ProgramadoC1,0 coPagado,0 PagadoC5,0 PagadoC3a4,0 PagadoC2,0 PagadoC1
	,0 reCobranzaC1,0 reCobranzaC2,0 reCobranzaC3a4,0 reCobranzaC5m,0 reCobranzaTo,0 rePuntalC1,0 rePuntualC2,0 rePuntualC3a4,0 rePuntualC5m,0 rePuntalTo
	,montoRenovacion,montoRenovAnt,montoReactiva,montonuevo,montoEntrega,RenovPtmos,RenovAntPtmos,ReactivaPtmos,nuevosPtmos,totalPtmos
	,saldopromRenov,saldopromRenovAnt,saldopromReactiva,saldopromNuevo,saldopromTotal,porRenov,porRenovAnt,porReactiva,porNuevo,porTotal
	,0 montoLiqui,0 MontoRenov,0 montoSinRenov,0 ptmsLiqui,0 ptmosRenov,0 ptmoSinRenovar,0 porRenovmonto,0 porRenovptmos,0 promLiquida,0 promRenovacion
	,0 montoAnticipaU,0 ptmosAnticipaU,0 montoReactivacionU,0 ptmosReactivacionU
	,0 colocacionC1,0 porRecuperaC1,0 Deterioro0a15C1,0 Deterioro16C1,0 colocacionC2,0 porRecuperaC2,0 Deterioro0a15C2,0 Deterioro16C2
	,0 colocacionC3,0 porRecuperaC3,0 Deterioro0a15C3,0 Deterioro16C3,0 colocacionC4 ,0 porRecuperaC4 ,0 Deterioro0a15C4 ,0 Deterioro16C4 
	,0 colocacionC5 ,0 porRecuperaC5 ,0 Deterioro0a15C5 ,0 Deterioro16C5 ,0 colocacionC6 ,0 porRecuperaC6 ,0 Deterioro0a15C6 ,0 Deterioro16C6 
	,0 colocacionC7 ,0 porRecuperaC7 ,0 Deterioro0a15C7 ,0 Deterioro16C7 ,0 colocacionC8 ,0 porRecuperaC8 ,0 Deterioro0a15C8 ,0 Deterioro16C8 
	,0 colocacionC9 ,0 porRecuperaC9 ,0 Deterioro0a15C9 ,0 Deterioro16C9 ,0 colocacionC10 ,0 porRecuperaC10 ,0 Deterioro0a15C10 ,0 Deterioro16C10 
	,0 colocacionC11 ,0 porRecuperaC11 ,0 Deterioro0a15C11 ,0 Deterioro16C11 ,0 colocacionC12 ,0 porRecuperaC12 ,0 Deterioro0a15C12 ,0 Deterioro16C12
	,0 metacrecimiento,0 porAlcance,'' estadoAlcance,0 metaColocacion
	,0 mes
	from @ColocaPrevio
	union
	select 6 x,
	codoficina,codasesor,''coordinador
	,0 saldoIni0a30,0 saldoIni31a89,0 saldoIni90m,0 ptmsVgteIni,0 imor16ini,0 imor30ini,0 imor90mini
	,0 cubini1a7,0 cubini8a15,0 cubini16a30,0 cubini31m,0 cubiniTotal,0 ptmos1a7ini,0 ptmos8a15ini,0 ptmos16a30ini,0 ptmos31ini,0 ptmosTotalini 
    ,0 saldoFin0a30,0 saldofin31a89,0 saldoFin90m,0 ptmsVgtefin,0 imor16fin,0 imor30fin,0 imor90mfin
	,0 cubfin1a7,0 cubfin8a15,0 cubfin16a30,0 cubfin31m,0 cubfinTotal,0 ptmos1a7fin,0 ptmos8a15fin,0 ptmos16a30fin,0 ptmos31fin,0 ptmosTotalfin
	,0 creciSaldo0a30,0 creciSaldo31a89,0 creciSaldo90m,0 creciPtmosVgtes,''detImor16,''detImor30,''detImor90,0 Crecub1a7,0 Crecub8a15,0 crecub16a30
	,0 crecub31m,0 crecub1m,0 creptmos1a7,0 creptmos8a15,0 creptmos16a30,0 creptmos31m,0 creptmos1m
	,0 coProgramado,0 ProgramadoC5m,0 ProgramadoC3a4,0 ProgramadoC2,0 ProgramadoC1,0 coPagado,0 PagadoC5,0 PagadoC3a4,0 PagadoC2,0 PagadoC1
	,0 reCobranzaC1,0 reCobranzaC2,0 reCobranzaC3a4,0 reCobranzaC5m,0 reCobranzaTo,0 rePuntalC1,0 rePuntualC2,0 rePuntualC3a4,0 rePuntualC5m,0 rePuntalTo
	,0 montoRenovacion,0 montoRenovAnt,0 montoReactiva,0 montonuevo,0 montoEntrega,0 RenovPtmos,0 RenovAntPtmos,0 ReactivaPtmos,0 nuevosPtmos,0 totalPtmos
	,0 saldopromRenov,0 saldopromRenovAnt,0 saldopromReactiva,0 saldopromNuevo,0 saldopromTotal,0 porRenov,0 porRenovAnt,0 porReactiva,0 porNuevo,0 porTotal
	,montoLiqui,MontoRenov,montoSinRenov,ptmsLiqui,ptmosRenov,ptmoSinRenovar,porRenovmonto,porRenovptmos,promLiquida,promRenovacion
	,0 montoAnticipaU,0 ptmosAnticipaU,0 montoReactivacionU,0 ptmosReactivacionU
	,0 colocacionC1,0 porRecuperaC1,0 Deterioro0a15C1,0 Deterioro16C1,0 colocacionC2,0 porRecuperaC2,0 Deterioro0a15C2,0 Deterioro16C2
	,0 colocacionC3,0 porRecuperaC3,0 Deterioro0a15C3,0 Deterioro16C3,0 colocacionC4 ,0 porRecuperaC4 ,0 Deterioro0a15C4 ,0 Deterioro16C4 
	,0 colocacionC5 ,0 porRecuperaC5 ,0 Deterioro0a15C5 ,0 Deterioro16C5 ,0 colocacionC6 ,0 porRecuperaC6 ,0 Deterioro0a15C6 ,0 Deterioro16C6 
	,0 colocacionC7 ,0 porRecuperaC7 ,0 Deterioro0a15C7 ,0 Deterioro16C7 ,0 colocacionC8 ,0 porRecuperaC8 ,0 Deterioro0a15C8 ,0 Deterioro16C8 
	,0 colocacionC9 ,0 porRecuperaC9 ,0 Deterioro0a15C9 ,0 Deterioro16C9 ,0 colocacionC10 ,0 porRecuperaC10 ,0 Deterioro0a15C10 ,0 Deterioro16C10 
	,0 colocacionC11 ,0 porRecuperaC11 ,0 Deterioro0a15C11 ,0 Deterioro16C11 ,0 colocacionC12 ,0 porRecuperaC12 ,0 Deterioro0a15C12 ,0 Deterioro16C12
	,0 metacrecimiento,0 porAlcance,'' estadoAlcance,0 metaColocacion
	,0 mes
	from #RenovaPrevio
	union
	select 7 x,
	codoficina,codasesor,''coordinador
	,0 saldoIni0a30,0 saldoIni31a89,0 saldoIni90m,0 ptmsVgteIni,0 imor16ini,0 imor30ini,0 imor90mini
	,0 cubini1a7,0 cubini8a15,0 cubini16a30,0 cubini31m,0 cubiniTotal,0 ptmos1a7ini,0 ptmos8a15ini,0 ptmos16a30ini,0 ptmos31ini,0 ptmosTotalini 
    ,0 saldoFin0a30,0 saldofin31a89,0 saldoFin90m,0 ptmsVgtefin,0 imor16fin,0 imor30fin,0 imor90mfin
	,0 cubfin1a7,0 cubfin8a15,0 cubfin16a30,0 cubfin31m,0 cubfinTotal,0 ptmos1a7fin,0 ptmos8a15fin,0 ptmos16a30fin,0 ptmos31fin,0 ptmosTotalfin
	,0 creciSaldo0a30,0 creciSaldo31a89,0 creciSaldo90m,0 creciPtmosVgtes,''detImor16,''detImor30,''detImor90,0 Crecub1a7,0 Crecub8a15,0 crecub16a30
	,0 crecub31m,0 crecub1m,0 creptmos1a7,0 creptmos8a15,0 creptmos16a30,0 creptmos31m,0 creptmos1m
	,0 coProgramado,0 ProgramadoC5m,0 ProgramadoC3a4,0 ProgramadoC2,0 ProgramadoC1,0 coPagado,0 PagadoC5,0 PagadoC3a4,0 PagadoC2,0 PagadoC1
	,0 reCobranzaC1,0 reCobranzaC2,0 reCobranzaC3a4,0 reCobranzaC5m,0 reCobranzaTo,0 rePuntalC1,0 rePuntualC2,0 rePuntualC3a4,0 rePuntualC5m,0 rePuntalTo
	,0 montoRenovacion,0 montoRenovAnt,0 montoReactiva,0 montonuevo,0 montoEntrega,0 RenovPtmos,0 RenovAntPtmos,0 ReactivaPtmos,0 nuevosPtmos,0 totalPtmos
	,0 saldopromRenov,0 saldopromRenovAnt,0 saldopromReactiva,0 saldopromNuevo,0 saldopromTotal,0 porRenov,0 porRenovAnt,0 porReactiva,0 porNuevo,0 porTotal
	,0 montoLiqui,0 MontoRenov,0 montoSinRenov,0 ptmsLiqui,0 ptmosRenov,0 ptmoSinRenovar,0 porRenovmonto,0 porRenovptmos,0 promLiquida,0 promRenovacion
	, montoAnticipaU,ptmosAnticipaU,montoReactivacionU,ptmosReactivacionU
	,0 colocacionC1,0 porRecuperaC1,0 Deterioro0a15C1,0 Deterioro16C1,0 colocacionC2,0 porRecuperaC2,0 Deterioro0a15C2,0 Deterioro16C2
	,0 colocacionC3,0 porRecuperaC3,0 Deterioro0a15C3,0 Deterioro16C3,0 colocacionC4 ,0 porRecuperaC4 ,0 Deterioro0a15C4 ,0 Deterioro16C4 
	,0 colocacionC5 ,0 porRecuperaC5 ,0 Deterioro0a15C5 ,0 Deterioro16C5 ,0 colocacionC6 ,0 porRecuperaC6 ,0 Deterioro0a15C6 ,0 Deterioro16C6 
	,0 colocacionC7 ,0 porRecuperaC7 ,0 Deterioro0a15C7 ,0 Deterioro16C7 ,0 colocacionC8 ,0 porRecuperaC8 ,0 Deterioro0a15C8 ,0 Deterioro16C8 
	,0 colocacionC9 ,0 porRecuperaC9 ,0 Deterioro0a15C9 ,0 Deterioro16C9 ,0 colocacionC10 ,0 porRecuperaC10 ,0 Deterioro0a15C10 ,0 Deterioro16C10 
	,0 colocacionC11 ,0 porRecuperaC11 ,0 Deterioro0a15C11 ,0 Deterioro16C11 ,0 colocacionC12 ,0 porRecuperaC12 ,0 Deterioro0a15C12 ,0 Deterioro16C12
	,0 metacrecimiento,0 porAlcance,'' estadoAlcance,0 metaColocacion
	,0 mes
	from #UniversoPrevio
	union
	select 8 x,
	codoficina,codasesor,''coordinador
	,0 saldoIni0a30,0 saldoIni31a89,0 saldoIni90m,0 ptmsVgteIni,0 imor16ini,0 imor30ini,0 imor90mini
	,0 cubini1a7,0 cubini8a15,0 cubini16a30,0 cubini31m,0 cubiniTotal,0 ptmos1a7ini,0 ptmos8a15ini,0 ptmos16a30ini,0 ptmos31ini,0 ptmosTotalini 
    ,0 saldoFin0a30,0 saldofin31a89,0 saldoFin90m,0 ptmsVgtefin,0 imor16fin,0 imor30fin,0 imor90mfin
	,0 cubfin1a7,0 cubfin8a15,0 cubfin16a30,0 cubfin31m,0 cubfinTotal,0 ptmos1a7fin,0 ptmos8a15fin,0 ptmos16a30fin,0 ptmos31fin,0 ptmosTotalfin
	,0 creciSaldo0a30,0 creciSaldo31a89,0 creciSaldo90m,0 creciPtmosVgtes,''detImor16,''detImor30,''detImor90,0 Crecub1a7,0 Crecub8a15,0 crecub16a30
	,0 crecub31m,0 crecub1m,0 creptmos1a7,0 creptmos8a15,0 creptmos16a30,0 creptmos31m,0 creptmos1m
	,0 coProgramado,0 ProgramadoC5m,0 ProgramadoC3a4,0 ProgramadoC2,0 ProgramadoC1,0 coPagado,0 PagadoC5,0 PagadoC3a4,0 PagadoC2,0 PagadoC1
	,0 reCobranzaC1,0 reCobranzaC2,0 reCobranzaC3a4,0 reCobranzaC5m,0 reCobranzaTo,0 rePuntalC1,0 rePuntualC2,0 rePuntualC3a4,0 rePuntualC5m,0 rePuntalTo
	,0 montoRenovacion,0 montoRenovAnt,0 montoReactiva,0 montonuevo,0 montoEntrega,0 RenovPtmos,0 RenovAntPtmos,0 ReactivaPtmos,0 nuevosPtmos,0 totalPtmos
	,0 saldopromRenov,0 saldopromRenovAnt,0 saldopromReactiva,0 saldopromNuevo,0 saldopromTotal,0 porRenov,0 porRenovAnt,0 porReactiva,0 porNuevo,0 porTotal
	,0 montoLiqui,0 MontoRenov,0 montoSinRenov,0 ptmsLiqui,0 ptmosRenov,0 ptmoSinRenovar,0 porRenovmonto,0 porRenovptmos,0 promLiquida,0 promRenovacion
	,0 montoAnticipaU,0 ptmosAnticipaU,0 montoReactivacionU,0 ptmosReactivacionU
	,colocacionC1,porRecuperaC1,Deterioro0a15C1,Deterioro16C1,colocacionC2,porRecuperaC2,Deterioro0a15C2,Deterioro16C2
	,colocacionC3,porRecuperaC3,Deterioro0a15C3,Deterioro16C3,colocacionC4 ,porRecuperaC4 ,Deterioro0a15C4 ,Deterioro16C4 
	,colocacionC5 ,porRecuperaC5 ,Deterioro0a15C5 ,Deterioro16C5 ,colocacionC6 ,porRecuperaC6 ,Deterioro0a15C6 ,Deterioro16C6 
	,colocacionC7 ,porRecuperaC7 ,Deterioro0a15C7 ,Deterioro16C7 ,colocacionC8 ,porRecuperaC8 ,Deterioro0a15C8 ,Deterioro16C8 
	,colocacionC9 ,porRecuperaC9 ,Deterioro0a15C9 ,Deterioro16C9 ,colocacionC10 ,porRecuperaC10 ,Deterioro0a15C10 ,Deterioro16C10 
	,colocacionC11 ,porRecuperaC11 ,Deterioro0a15C11 ,Deterioro16C11 ,colocacionC12 ,porRecuperaC12 ,Deterioro0a15C12 ,Deterioro16C12
	,0 metacrecimiento,0 porAlcance,'' estadoAlcance,0 metaColocacion
	,0 mes
	from @det
	union
	select 8 x,
	''codoficina,codasesor,''coordinador
	,0 saldoIni0a30,0 saldoIni31a89,0 saldoIni90m,0 ptmsVgteIni,0 imor16ini,0 imor30ini,0 imor90mini
	,0 cubini1a7,0 cubini8a15,0 cubini16a30,0 cubini31m,0 cubiniTotal,0 ptmos1a7ini,0 ptmos8a15ini,0 ptmos16a30ini,0 ptmos31ini,0 ptmosTotalini 
    ,0 saldoFin0a30,0 saldofin31a89,0 saldoFin90m,0 ptmsVgtefin,0 imor16fin,0 imor30fin,0 imor90mfin
	,0 cubfin1a7,0 cubfin8a15,0 cubfin16a30,0 cubfin31m,0 cubfinTotal,0 ptmos1a7fin,0 ptmos8a15fin,0 ptmos16a30fin,0 ptmos31fin,0 ptmosTotalfin
	,0 creciSaldo0a30,0 creciSaldo31a89,0 creciSaldo90m,0 creciPtmosVgtes,''detImor16,''detImor30,''detImor90,0 Crecub1a7,0 Crecub8a15,0 crecub16a30
	,0 crecub31m,0 crecub1m,0 creptmos1a7,0 creptmos8a15,0 creptmos16a30,0 creptmos31m,0 creptmos1m
	,0 coProgramado,0 ProgramadoC5m,0 ProgramadoC3a4,0 ProgramadoC2,0 ProgramadoC1,0 coPagado,0 PagadoC5,0 PagadoC3a4,0 PagadoC2,0 PagadoC1
	,0 reCobranzaC1,0 reCobranzaC2,0 reCobranzaC3a4,0 reCobranzaC5m,0 reCobranzaTo,0 rePuntalC1,0 rePuntualC2,0 rePuntualC3a4,0 rePuntualC5m,0 rePuntalTo
	,0 montoRenovacion,0 montoRenovAnt,0 montoReactiva,0 montonuevo,0 montoEntrega,0 RenovPtmos,0 RenovAntPtmos,0 ReactivaPtmos,0 nuevosPtmos,0 totalPtmos
	,0 saldopromRenov,0 saldopromRenovAnt,0 saldopromReactiva,0 saldopromNuevo,0 saldopromTotal,0 porRenov,0 porRenovAnt,0 porReactiva,0 porNuevo,0 porTotal
	,0 montoLiqui,0 MontoRenov,0 montoSinRenov,0 ptmsLiqui,0 ptmosRenov,0 ptmoSinRenovar,0 porRenovmonto,0 porRenovptmos,0 promLiquida,0 promRenovacion
	,0 montoAnticipaU,0 ptmosAnticipaU,0 montoReactivacionU,0 ptmosReactivacionU
	,0 colocacionC1,0 porRecuperaC1,0 Deterioro0a15C1,0 Deterioro16C1,0 colocacionC2,0 porRecuperaC2,0 Deterioro0a15C2,0 Deterioro16C2
	,0 colocacionC3,0 porRecuperaC3,0 Deterioro0a15C3,0 Deterioro16C3,0 colocacionC4 ,0 porRecuperaC4 ,0 Deterioro0a15C4 ,0 Deterioro16C4 
	,0 colocacionC5 ,0 porRecuperaC5 ,0 Deterioro0a15C5 ,0 Deterioro16C5 ,0 colocacionC6 ,0 porRecuperaC6 ,0 Deterioro0a15C6 ,0 Deterioro16C6 
	,0 colocacionC7 ,0 porRecuperaC7 ,0 Deterioro0a15C7 ,0 Deterioro16C7 ,0 colocacionC8 ,0 porRecuperaC8 ,0 Deterioro0a15C8 ,0 Deterioro16C8 
	,0 colocacionC9 ,0 porRecuperaC9 ,0 Deterioro0a15C9 ,0 Deterioro16C9 ,0 colocacionC10 ,0 porRecuperaC10 ,0 Deterioro0a15C10 ,0 Deterioro16C10 
	,0 colocacionC11 ,0 porRecuperaC11 ,0 Deterioro0a15C11 ,0 Deterioro16C11 ,0 colocacionC12 ,0 porRecuperaC12 ,0 Deterioro0a15C12 ,0 Deterioro16C12
	,metacrecimiento,porAlcance,estadoAlcance,metaColocacion
	,0 mes
	from @estadoAlcance 	
	union
	select 9 x,
	codoficina,codusuario codasesor,''coordinador
	,0 saldoIni0a30,0 saldoIni31a89,0 saldoIni90m,0 ptmsVgteIni,0 imor16ini,0 imor30ini,0 imor90mini
	,0 cubini1a7,0 cubini8a15,0 cubini16a30,0 cubini31m,0 cubiniTotal,0 ptmos1a7ini,0 ptmos8a15ini,0 ptmos16a30ini,0 ptmos31ini,0 ptmosTotalini 
    ,0 saldoFin0a30,0 saldofin31a89,0 saldoFin90m,0 ptmsVgtefin,0 imor16fin,0 imor30fin,0 imor90mfin
	,0 cubfin1a7,0 cubfin8a15,0 cubfin16a30,0 cubfin31m,0 cubfinTotal,0 ptmos1a7fin,0 ptmos8a15fin,0 ptmos16a30fin,0 ptmos31fin,0 ptmosTotalfin
	,0 creciSaldo0a30,0 creciSaldo31a89,0 creciSaldo90m,0 creciPtmosVgtes,''detImor16,''detImor30,''detImor90,0 Crecub1a7,0 Crecub8a15,0 crecub16a30
	,0 crecub31m,0 crecub1m,0 creptmos1a7,0 creptmos8a15,0 creptmos16a30,0 creptmos31m,0 creptmos1m
	,0 coProgramado,0 ProgramadoC5m,0 ProgramadoC3a4,0 ProgramadoC2,0 ProgramadoC1,0 coPagado,0 PagadoC5,0 PagadoC3a4,0 PagadoC2,0 PagadoC1
	,0 reCobranzaC1,0 reCobranzaC2,0 reCobranzaC3a4,0 reCobranzaC5m,0 reCobranzaTo,0 rePuntalC1,0 rePuntualC2,0 rePuntualC3a4,0 rePuntualC5m,0 rePuntalTo
	,0 montoRenovacion,0 montoRenovAnt,0 montoReactiva,0 montonuevo,0 montoEntrega,0 RenovPtmos,0 RenovAntPtmos,0 ReactivaPtmos,0 nuevosPtmos,0 totalPtmos
	,0 saldopromRenov,0 saldopromRenovAnt,0 saldopromReactiva,0 saldopromNuevo,0 saldopromTotal,0 porRenov,0 porRenovAnt,0 porReactiva,0 porNuevo,0 porTotal
	,0 montoLiqui,0 MontoRenov,0 montoSinRenov,0 ptmsLiqui,0 ptmosRenov,0 ptmoSinRenovar,0 porRenovmonto,0 porRenovptmos,0 promLiquida,0 promRenovacion
	,0 montoAnticipaU,0 ptmosAnticipaU,0 montoReactivacionU,0 ptmosReactivacionU
	,0 colocacionC1,0 porRecuperaC1,0 Deterioro0a15C1,0 Deterioro16C1,0 colocacionC2,0 porRecuperaC2,0 Deterioro0a15C2,0 Deterioro16C2
	,0 colocacionC3,0 porRecuperaC3,0 Deterioro0a15C3,0 Deterioro16C3,0 colocacionC4 ,0 porRecuperaC4 ,0 Deterioro0a15C4 ,0 Deterioro16C4 
	,0 colocacionC5 ,0 porRecuperaC5 ,0 Deterioro0a15C5 ,0 Deterioro16C5 ,0 colocacionC6 ,0 porRecuperaC6 ,0 Deterioro0a15C6 ,0 Deterioro16C6 
	,0 colocacionC7 ,0 porRecuperaC7 ,0 Deterioro0a15C7 ,0 Deterioro16C7 ,0 colocacionC8 ,0 porRecuperaC8 ,0 Deterioro0a15C8 ,0 Deterioro16C8 
	,0 colocacionC9 ,0 porRecuperaC9 ,0 Deterioro0a15C9 ,0 Deterioro16C9 ,0 colocacionC10 ,0 porRecuperaC10 ,0 Deterioro0a15C10 ,0 Deterioro16C10 
	,0 colocacionC11 ,0 porRecuperaC11 ,0 Deterioro0a15C11 ,0 Deterioro16C11 ,0 colocacionC12 ,0 porRecuperaC12 ,0 Deterioro0a15C12 ,0 Deterioro16C12
	,0 metacrecimiento,0 porAlcance,'' estadoAlcance,0 metaColocacion
	,mes
	from  @Antiquedad
)a
group by codasesor

delete from #base
from #base c 
left outer join tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha
where (case when (e.codpuesto<>66 or e.codusuario is null ) then 'HUERFANO' 
			else codasesor end)='HUERFANO'  

delete from #base where coordinador is null  or coordinador=''

drop table #UniversoPrevio
drop table #RenovaPrevio
drop table #CobranzaPrevio

delete  FNMGConsolidado.dbo.tCaCartaPromotor  where fecha=@fecha
insert into FNMGConsolidado.dbo.tCaCartaPromotor	

---------------  CONSULTA FINAL ------------

Select  ca.fecha, diaCorte,z.nombre,nomoficina nomoficina
	,(ca.codoficina)codoficina,codasesor,coordinador,mes
	,(saldoIni0a30)saldoIni0a30,(saldoIni31a89)saldoIni31a89,(saldoIni90m)saldoIni90m,SaldoIniTo
	,(saldoFin0a30)saldoFin0a30,(saldofin31a89)saldofin31a89,(saldoFin90m)saldoFin90m,saldoFinTo
	,(creciSaldo0a30)creciSaldo0a30,(creciSaldo31a89)creciSaldo31a89,(creciSaldo90m)creciSaldo90m
	,((creciSaldo0a30)+(creciSaldo31a89)+(creciSaldo90m))  CreciSaldoTo
	,(imor16ini)imor16ini,(imor30ini)imor30ini,(imor90mini)imor90mini
	,(imor16fin)imor16fin,(imor30fin)imor30fin,(imor90mfin)imor90mfin
	,(detImor16)detImor16,(detImor30)detImor30,(detImor90)detImor90
	,(ptmsVgteIni)ptmsVgteIni,(ptmsVgtefin)ptmsVgtefin,(creciPtmosVgtes)creciPtmosVgtes
   --- metas 
    ,(metacrecimiento)metacrecimiento,(porAlcance)porAlcance,(estadoAlcance)estadoAlcance,(metaColocacion)metaColocacion
    ,porColocacion porColocacion
	,(coProgramado)coProgramado,(ProgramadoC5m)ProgramadoC5m,(ProgramadoC3a4)ProgramadoC3a4,(ProgramadoC2)ProgramadoC2,(ProgramadoC1)ProgramadoC1
	,(coPagado)coPagado,(PagadoC5)PagadoC5,(PagadoC3a4)PagadoC3a4,(PagadoC2)PagadoC2,(PagadoC1)PagadoC1
	,(reCobranzaC1)reCobranzaC1,(reCobranzaC2)reCobranzaC2,(reCobranzaC3a4)reCobranzaC3a4,(reCobranzaC5m)reCobranzaC5m,(reCobranzaTo)reCobranzaTo
	,(rePuntalC1)rePuntalC1,(rePuntualC2)rePuntualC2,(rePuntualC3a4)rePuntualC3a4,(rePuntualC5m)rePuntualC5m,(rePuntalTo)rePuntalTo	
	,(montoRenovacion)montoRenovacion,(montoRenovAnt)montoRenovAnt,(montoReactiva)montoReactiva,(montonuevo)montonuevo,(montoEntrega)montoEntrega
	,(RenovPtmos)RenovPtmos,(RenovAntPtmos)RenovAntPtmos,(ReactivaPtmos)ReactivaPtmos,(nuevosPtmos)nuevosPtmos,(totalPtmos)totalPtmos	
	,(saldopromRenov)saldopromRenov,(saldopromRenovAnt)saldopromRenovAnt,(saldopromReactiva)saldopromReactiva,(saldopromNuevo)saldopromNuevo,(saldopromTotal)saldopromTotal
	,(porRenov)porRenov,(porRenovAnt)porRenovAnt,(porReactiva)porReactiva,(porNuevo)porNuevo,(porTotal)porTotal	
	,(montoAnticipaU)montoAnticipaU,(ptmosAnticipaU)ptmosAnticipaU,(montoReactivacionU)montoReactivacionU,(ptmosReactivacionU)ptmosReactivacionU
    ,(montoSinRenov)montosinRenovU,(ptmoSinRenovar)ptmoSinRenovarU,(montoTotalU)montoTotalU,(ptmosTotalU)ptmosTotalU
	,(montoLiqui)montoLiqui,(MontoRenov)MontoRenov,(montoSinRenov)montoSinRenov,(ptmsLiqui)ptmsLiqui,(ptmosRenov)ptmosRenov,(ptmoSinRenovar)ptmoSinRenovar
	,(porRenovmonto)porRenovmonto,(porRenovptmos)porRenovptmos,(promLiquida)promLiquida,(promRenovacion)promRenovacion
	,(cubini1a7)cubini1a7,(cubini8a15)cubini8a15,(cubini16a30)cubini16a30,(cubini31m)cubini31m,(cubiniTotal)cubiniTotal
	,(ptmos1a7ini)ptmos1a7ini,(ptmos8a15ini)ptmos8a15ini,(ptmos16a30ini)ptmos16a30ini,(ptmos31ini)ptmos31ini,(ptmosTotalini)ptmosTotalini 
	,(cubfin1a7)cubfin1a7,(cubfin8a15)cubfin8a15,(cubfin16a30)cubfin16a30,(cubfin31m)cubfin31m,(cubfinTotal)cubfinTotal
	,(ptmos1a7fin)ptmos1a7fin,(ptmos8a15fin)ptmos8a15fin,(ptmos16a30fin)ptmos16a30fin,(ptmos31fin)ptmos31fin,(ptmosTotalfin)ptmosTotalfin	
	,(Crecub1a7)Crecub1a7,(Crecub8a15)Crecub8a15,(crecub16a30)crecub16a30,(crecub31m)crecub31m,(crecub1m)crecub1m
	,(creptmos1a7)creptmos1a7,(creptmos8a15)creptmos8a15,(creptmos16a30)creptmos16a30,(creptmos31m)creptmos31m,(creptmos1m)creptmos1m
	--Deterioro ()
	, cosecha1,(colocacionC1)colocacionC1,(porRecuperaC1)porRecuperaC1,(Deterioro0a15C1)Deterioro0a15C1,(Deterioro16C1)Deterioro16C1
	, cosecha2,(colocacionC2)colocacionC2,(porRecuperaC2)porRecuperaC2,(Deterioro0a15C2)Deterioro0a15C2,(Deterioro16C2)Deterioro16C2
	, cosecha3,(colocacionC3)colocacionC3,(porRecuperaC3)porRecuperaC3,(Deterioro0a15C3)Deterioro0a15C3,(Deterioro16C3)Deterioro16C3
	, cosecha4,(colocacionC4)colocacionC4,(porRecuperaC4)porRecuperaC4,(Deterioro0a15C4)Deterioro0a15C4,(Deterioro16C4)Deterioro16C4
	, cosecha5,(colocacionC5)colocacionC5,(porRecuperaC5)porRecuperaC5,(Deterioro0a15C5)Deterioro0a15C5,(Deterioro16C5)Deterioro16C5
	, cosecha6,(colocacionC6)colocacionC6,(porRecuperaC6)porRecuperaC6,(Deterioro0a15C6)Deterioro0a15C6,(Deterioro16C6)Deterioro16C6
	, cosecha7,(colocacionC7)colocacionC7,(porRecuperaC7)porRecuperaC7,(Deterioro0a15C7)Deterioro0a15C7,(Deterioro16C7)Deterioro16C7
	, cosecha8,(colocacionC8)colocacionC8,(porRecuperaC8)porRecuperaC8,(Deterioro0a15C8)Deterioro0a15C8,(Deterioro16C8)Deterioro16C8
	, cosecha9,(colocacionC9)colocacionC9,(porRecuperaC9)porRecuperaC9,(Deterioro0a15C9)Deterioro0a15C9,(Deterioro16C9)Deterioro16C9
	, cosecha10,(colocacionC10)colocacionC10,(porRecuperaC10)porRecuperaC10,(Deterioro0a15C10)Deterioro0a15C10,(Deterioro16C10)Deterioro16C10
	, cosecha11,(colocacionC11)colocacionC11,(porRecuperaC11)porRecuperaC11,(Deterioro0a15C11)Deterioro0a15C11,(Deterioro16C11)Deterioro16C11
	, cosecha12,(colocacionC12)colocacionC12,(porRecuperaC12)porRecuperaC12,(Deterioro0a15C12)Deterioro0a15C12,(Deterioro16C12)Deterioro16C12

from #base ca with(nolock)
--left outer join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor  
left outer join tcloficinas o on o.codoficina=ca.codoficina
left outer join tclzona z on z.zona=o.zona


drop table #base
GO