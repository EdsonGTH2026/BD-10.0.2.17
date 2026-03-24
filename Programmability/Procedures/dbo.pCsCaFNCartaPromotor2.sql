SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*CARTA PROMOTOR VS 4  13.09.2022 */ 
--Actualizar las renovaciones --> para ciclo 1,2,y 3 hasta 8 días de atraso  11.11.2022
--Actualizar los créditos liquidados --> para ciclo 1,2,y 3 hasta 8 días de atraso  18.11.2022

CREATE procedure [dbo].[pCsCaFNCartaPromotor2]  
as
set nocount on 

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes

declare @fecante smalldatetime
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  --fecha de CORTE del mes anterior


declare @fecfin smalldatetime
select @fecfin = ultimodia from tclperiodo where dbo.fdufechaaperiodo(ultimodia)=dbo.fdufechaaperiodo(@fecha)

declare @diacorte int  -- dia de corte  que le corresponde en este periodo 
select @diacorte=day(fechacorte)  from tCsACaIncentivosCortes where dbo.fdufechaaperiodo(fecha)=dbo.fdufechaaperiodo(@fecha)

declare @porcentaje money
declare @eva money

---Determina que porcentaje del bono se muestra
if(day(@fecha)<=isnull(@diacorte,15)) 
begin
	set @eva=0.5
	set @porcentaje=0.4
    
end
else 
begin
	set @eva=1            --- para la meta de colocacion
	set @porcentaje=0.6
end

--select @eva
--select @porcentaje
----------------------------------------

/*CARTERA INICIAL Saldo en cartera vgte*/ 

declare @CarteraIni table (fecha smalldatetime,
							codoficina varchar(3),    
							codasesor varchar(15),    
							coordinador varchar(250),    
							saldoIni0a30 money,
							saldoIni31m money) 
  
insert into @CarteraIni    
select   c.fecha  
,c.codoficina     
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor    
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador    
,sum(case when c.nrodiasatraso<=30 then c.saldocapital else 0 end)saldoIni0a30
,sum(case when   c.nrodiasatraso>=31 then c.saldocapital else 0 end)saldoIni31m
from tcscartera c with(nolock)    
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=c.fecha    
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor   
where c.fecha=@fecante--> fecha de corte del mes anterior
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and c.codoficina not in('97','230','231','999') 
and c.cartera='ACTIVA' 
and c.tiporeprog<>'REEST'
group by  c.fecha,c.codoficina    
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end    
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end    

delete from @CarteraIni where coordinador='HUERFANO' 

/*CARTERA FINAL */ 

declare @CarteraFin table (fecha smalldatetime,
							codoficina varchar(3),    
							codasesor varchar(15),    
							coordinador varchar(250),    
							saldo31mFin money)    
insert into @CarteraFin    
select   c.fecha  
,c.codoficina     
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codasesor    
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador    
,sum(case when   c.nrodiasatraso>=31 then c.saldocapital else 0 end)
from tcscartera c with(nolock)  
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo  
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=c.fecha    
inner join tcspadronclientes co with(nolock) on co.codusuario=c.codasesor   
where c.fecha=@fecha  --> fecha consulta
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and c.codoficina not in('97','230','231','999')
and c.cartera='ACTIVA' 
and c.tiporeprog<>'REEST'
group by  c.fecha,c.codoficina    
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end    
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end    

delete from @CarteraFin where coordinador='HUERFANO'  

--/*INTERES  COBRADO AL PERIODO A EVALUAR*/ 

--create table  #Coa (
--          fecha smalldatetime,
--          codprestamo varchar(25),
--          codusuario varchar(15),
--          interes money,
--          dias int,fehaCa smalldatetime)
--insert into #Coa
--select d.fecha, codigocuenta,d.codusuario,montointerestran interes,nrodiasatraso dias,c.fecha
--from tcstransacciondiaria d with(nolock)
--left outer  join tcscartera c with(nolock) on (c.fecha+1)=d.fecha and c.codprestamo=d.codigocuenta 
--where  d.fecha>=@fecini and d.fecha<=@fecha
--and d.codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
--and d.codoficina not in('97','231','230','999')

--select fecha,codprestamo,codusuario,interes ,case when dias is null then 0 else dias end dias
--into #co2a        
--from #coa
--where isnull(dias,0) <= 30
 
--declare @Caa table(codprestamo varchar(25),Codoficina varchar(4),codpromotor varchar(25))
--insert into @Caa
--select p.codprestamo, p.CodOficina, p.ultimoasesor
--from tcspadroncarteradet p with(nolock)
--where p.codprestamo in(select distinct codprestamo from #Coa)


--declare @inteCobrados table(fecha smalldatetime
--							,codoficina varchar(3)
--							,Codasesor varchar(25)
--							,interesCobrado money) 
--insert into @inteCobrados
--select @fecha fecha,c.codoficina,c.codpromotor,sum(interes) interes
--from #Co2a t
--inner join @Caa c on t.codprestamo=c.codprestamo
--inner join tcloficinas j with(nolock) on j.codoficina=c.codoficina
--group by 
--c.codoficina,c.codpromotor
						
--drop table #Coa
--drop table #co2a	

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
where   c.codoficina not in('97','231','230','999') and
isnull(c.nrodiasatraso,0)<=30
--where c.codoficina  in('307') 

insert into #IntCo
select  p.fecha,p.codprestamo,p.interes,0 dias,pd.codoficina,isnull(ultimoAsesor,primerAsesor)
from #ptmosPagos p with(nolock)  
inner join tcspadroncarteradet pd with(nolock)on p.fecha=pd.desembolso and p.codprestamo=pd.codprestamo 

declare @inteCobradoS table(fecha smalldatetime    
						   ,codoficina varchar(5)    
						   ,Codasesor varchar(25)    
						   ,interesCobrado money)     
insert into @inteCobradoS  
select @fecha,
c.codoficina,
codasesor,sum(interes)interes
from #IntCo c 
inner join tcloficinas o on o.codoficina=c.codoficina
where isnull(nrodias,0)<=30  
group by c.codoficina,codasesor 

drop table #ptmosPagos
drop table #IntCo


--TABLA DE NIVEL DE PROMOTOR Y BONO 
declare @nivelpromotor table(codasesor varchar(15),  
                            codoficina varchar(3),  
							saldoIni0a30 money,
							--saldointerescobrado money,
							nivel varchar(20),
							BonoMes money)
insert into @nivelpromotor 							
select f.codasesor
      ,f.codoficina
      ,sum(i.saldoIni0a30)
      --,t.interesCobrado
      ,case when isnull(i.saldoIni0a30,0)>=0 and isnull(i.saldoIni0a30,0)<=500000 then 'Trainee'
            when i.saldoIni0a30>500000 and i.saldoIni0a30<=1000000 then 'Junior'
            when i.saldoIni0a30>1000000 and i.saldoIni0a30<=1500000 then 'Senior'
            else 'Master' end 
      ,case when isnull(i.saldoIni0a30,0)>=0 and isnull(i.saldoIni0a30,0)<=250000 then 2500
            when i.saldoIni0a30>250000  and i.saldoIni0a30<=500000 then 3000
            when i.saldoIni0a30>500000 and i.saldoIni0a30<=750000 then 4500
            when i.saldoIni0a30>750000 and i.saldoIni0a30<=1000000 then 7000
            when i.saldoIni0a30>1000000 and i.saldoIni0a30<=1250000 then 9000
            when i.saldoIni0a30>1250000 and i.saldoIni0a30<=1500000 then 11000
            else isnull(t.interesCobrado,0)*0.08 end 
from @CarteraFin f
left outer join @carteraIni i on i.codasesor=f.codasesor and i.codoficina=f.codoficina
left outer join @inteCobrados t on f.codasesor=t.codasesor and f.codoficina=t.codoficina
group by f.codasesor,f.codoficina
,case when isnull(i.saldoIni0a30,0)>=0 and isnull(i.saldoIni0a30,0)<=500000 then 'Trainee'
            when i.saldoIni0a30>500000 and i.saldoIni0a30<=1000000 then 'Junior'
            when i.saldoIni0a30>1000000 and i.saldoIni0a30<=1500000 then 'Senior'
            else 'Master' end 
,case when isnull(i.saldoIni0a30,0)>=0 and isnull(i.saldoIni0a30,0)<=250000 then 2500
            when i.saldoIni0a30>250000  and i.saldoIni0a30<=500000 then 3000
            when i.saldoIni0a30>500000 and i.saldoIni0a30<=750000 then 4500
            when i.saldoIni0a30>750000 and i.saldoIni0a30<=1000000 then 7000
            when i.saldoIni0a30>1000000 and i.saldoIni0a30<=1250000 then 9000
            when i.saldoIni0a30>1250000 and i.saldoIni0a30<=1500000 then 11000
            else isnull(t.interesCobrado,0)*0.08 end 



/*Seccion de COLOCACIÓN*/---------------------------
--meta de colocación
declare @MeColocacion table(codasesor varchar(30), Metacolocacion money)
insert into @MeColocacion
select codigo,monto*(@eva) ---solo se debe ver la mitad de la meta
from tcscametas with(nolock)
where fecha=@fecfin  
and tipocodigo=2 and meta=2 --colocacion


/*capital colocado por promotor*/

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


declare @montoEntrega table(codoficina varchar(30)
						,codasesor varchar(15)
						,montoColocacion money)
						--,totalPtmos int
insert into @montoEntrega
select p.codoficina, p.ultimoasesor
,sum(p.monto)montoEntrega
--,count(p.codprestamo)totalPtmos
from tcspadroncarteradet p with(nolock)
left outer join @liqreno l on l.codprestamo=p.codprestamo
inner join tcscartera c with(nolock) on c.CodPrestamo=p.CodPrestamo and c.fecha=p.Desembolso
left outer join [10.0.2.14].finmas.dbo.tcasolicitudrenovacionanticipadaproce s ON s.CodSolicitud=c.CodSolicitud and s.CodOficina=c.CodOficina
where p.desembolso>=@fecini and p.desembolso<=@fecha
and p.codoficina<>'97'
group by p.codoficina, p.ultimoasesor


--declare @colocado table(codoficina varchar(30)
--						,codasesor varchar(15)
--						,montoColocacion money
--						,metacolocacion money
--						,AlcanceColocacion money)
----insert into @colocado
--select codoficina,c.codasesor,c.montocolocacion,metacolocacion
--,case when metacolocacion=0 then 0 else (montocolocacion/metacolocacion)*100 end   AlcanceColocacion
--from @montoEntrega c  
--left outer join @MeColocacion mc on mc.codasesor=c.codasesor



/*Seccion de COBRANZA  */----------------------

--Del primer dia del mes a la fecha de consulta
create table #cobranzaP (
			fecha smalldatetime,fechavencimiento smalldatetime,region varchar(15)	
			,sucursal varchar(30),atraso varchar (10),rangoCiclo varchar(10)
			,saldo money,condonado money,programado_n int,programado_s money	
			,anticipado	int,puntual int	,atrasado int,monto_anticipado money	
			,monto_puntual money,monto_atrasado	money,creditosPagados int	
			,capitalPagado	money,pagado_por money,sinpago_n int
			,sinpago_s	money,sinpago_por money,pagoparcial_n int
			,pagoparcial_s	money,parcial_por money,total_n int
			,total_s money,total_por money,orden int,promotor varchar(200))
insert into  #cobranzaP
exec pCsCACobranzaPuntual @fecha,@fecini



/*Cobranza Putual y acumulada*/----------------------
declare @cop table(fecha smalldatetime,sucursal varchar(30),promotor varchar(200)
								,programado_s money
								,monto_anticipado money
								,monto_puntual money
								,monto_atrasado money)
								--,PagoPuntual money
								--,PagoAcumulado money
insert into @cop
select fecha,sucursal,promotor
,sum(programado_s) Programado_S
,sum(monto_anticipado)monto_anticipado
,sum(monto_puntual)monto_puntual
,sum(monto_atrasado) monto_atrasado
--,case when sum(programado_s)=0  then 0 else sum(monto_puntual+monto_anticipado)/sum(programado_s)end *100 PagoPuntual
--,case when sum(programado_s)=0  then 0 else sum(monto_anticipado+monto_puntual+monto_atrasado)/sum(programado_s)end *100 PagoAcumulado
from #cobranzaP with(nolock)
where atraso in ('0-7DM','8-30DM')
group by fecha,sucursal,promotor

drop table #cobranzaP


--select *
--into tCsACaLIQUI_RR_20220912
--from tCsACaLIQUI_RR

/*Seccion de Permanencia -- Liquidados y Renovados*/----------------------
--declare @fecha smalldatetime
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

--declare @fecini smalldatetime
--set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes

declare  @liq table(codoficina varchar(4),coordinador varchar(500),codpromotor varchar(50),nro int)
insert into @liq
--select p.codoficina codoficina,p.ultimoasesor  codpromotor,count(p.codprestamo) nro--,p.codprestamo, nrodiasatraso
--from tcspadroncarteradet p with(nolock)    
--inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo    
--where p.cancelacion>=@fecini and cancelacion<=@fecha
--and nrodiasatraso<=15
----and ultimoasesor='CHL750923M'
--group by p.codoficina ,p.ultimoasesor

select codoficina,coordinador,codpromotor--,count(codprestamo) nro--,sum(monto)monto
,sum(case when secuenciaCliente<=3 and atrasomaximo<=8 then 1  
			when secuenciaCliente>3 and atrasomaximo<=15 then 1
			else 0 end) nro
from tCsACaLIQUI_RR  with(nolock) 
where cancelacion>=@fecini and cancelacion<=@fecha
and atrasomaximo<=15
group by codoficina,coordinador,codpromotor


/*Para ciclos 1,2 y 3 se toman hasta 8 dias de atraso, c4+ hasta 15 dias a. -- cambio solicitado por Laura*/
declare @Ren table(codoficina varchar(4),coordinador varchar(500),codpromotor varchar(50),nro int)
insert into @Ren
select codoficina,coordinador,codpromotor
---,count(codprestamo) nro
,sum(case when secuenciaCliente<=3 and atrasomaximo<=8 then 1  
			when secuenciaCliente>3 and atrasomaximo<=15 then 1
			else 0 end) nro
--select top 10*
from tCsACaLIQUI_RR   
where cancelacion>=@fecini and cancelacion<=@fecha
and estado='RENOVADO'
and atrasomaximo<=15
group by codoficina,coordinador,codpromotor


declare @Permanencia table(codoficina varchar(4),codasesor varchar(20),ptmosLiqui int,ptmosRenov int,AlcanceRenovados money)
insert into @Permanencia
select l.codoficina,l.codpromotor codasesor
,sum(isnull(l.nro,0)) ptmsLiqui
,sum(isnull(r.nro,0)) ptmosRenov
,case when sum(l.nro)=0 then 0 else sum(r.nro)/cast(sum(l.nro)as decimal)*100 end   
from  @liq l  
left outer join @Ren r  on l.codpromotor=r.codpromotor
group by  l.codoficina,l.codpromotor




------------------ANTIGUEDAD DE PROMOTORES ACTIVOS
--Antiguedad  por meses no por dias, solicitado por Mercedes  
declare @Antiquedad table(fecha smalldatetime
							,codoficina varchar(4)
							,codusuario varchar(30)
							,mes int)
insert into @Antiquedad
select b1.fecha, e.Codoficina,e.codusuario
,(datediff(month,e.Ingreso,b1.fecha))mesesantiguedad 
from tCsempleadosfecha as b1 with(nolock)
inner join tCsempleados as e with(nolock) on b1.codusuario=e.codusuario
where e.CodPuesto=66 and b1.Fecha=@fecha 






/*Consulta Final*/

select c.fecha,z.nombre Region ,c.codoficina,o.nomoficina,c.codasesor,c.coordinador NombrePromotor
,sum(mes) meses
,sum(i.saldoini0a30) saldoIni0a30
,case when isnull(sum(i.saldoini0a30),0)=0 then 'Trainee' else nivel end nivel
,case when isnull(sum(i.saldoini0a30),0)=0 then 2500 else sum(BonoMes) end  BonoTotalMes
,case when isnull(sum(i.saldoini0a30),0)=0 then 2500*(@porcentaje) else @porcentaje*sum(BonoMes)end  BonoPeriodo
,sum(montocolocacion)montoColocacion,sum(metacolocacion)metacolocacion
,case when sum(metacolocacion)=0 then 0 else (sum(montocolocacion)/sum(metacolocacion))*100 end   AlcanceColocacion

--,metacolocacion ,montoColocacion,sum(AlcanceColocacion)AlcanceColocacion 
,sum(programado_s)programado_s
,sum(monto_anticipado)monto_anticipado
,sum(monto_puntual)monto_puntual 
,case when sum(programado_s)=0 then 0 else sum(monto_puntual + monto_anticipado)/sum(programado_s)*100 end   AlcancePuntual
,sum(monto_atrasado)monto_atrasado
,case when sum(programado_s)=0 then 0 else sum(monto_puntual + monto_anticipado + monto_atrasado)/sum(programado_s)*100 end   AlcanceAcumulado
--paso a vencida
,sum(i.saldoini0a30)caVgteInicial
,sum(i.saldoIni31m)caVencidaInicial
,sum(c.saldo31mFin)caVencidaFinal
,case when isnull(sum(i.saldoini0a30),0)=0 then 0 else sum(saldo31mFin-saldoIni31m)/sum(i.saldoini0a30)*100 end   AlcancePasoVencida
--permanencia
,sum(ptmosRenov)ptmosRenov
,sum(ptmosLiqui)ptmosLiqui
,sum(AlcanceRenovados)AlcanceRenovados
into #base
from @CarteraFin c
left outer join @CarteraIni i on i.codasesor=c.codasesor and c.codoficina=i.codoficina
left outer join @nivelpromotor p on p.codasesor=c.codasesor and c.codoficina=p.codoficina
--left outer join @colocado co on co.codasesor=c.codasesor
left outer join @cop cob on cob.promotor=c.coordinador --and c.codoficina=cob.codoficina
left outer join @Permanencia pe on pe.codasesor=c.codasesor
left outer join tcloficinas o with(nolock)  on o.codoficina=c.codoficina
left outer join tclzona z with(nolock) on z.zona=o.zona	
left outer join @Antiquedad a on a.codusuario=c.codasesor
left outer join @montoEntrega me on me.codasesor=c.codasesor 
left outer join @MeColocacion mc on mc.codasesor=c.codasesor
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha    
Where e.CodPuesto=66
and not (c.codoficina ='446' and c.codasesor='JTD910814FM300') 
group by
c.fecha,z.nombre,c.codoficina,o.nomoficina,c.codasesor,c.coordinador,nivel 
order by
o.nomoficina


delete  FNMGConsolidado.dbo.tCaCartaPromotor2  where fecha=@fecha
insert into FNMGConsolidado.dbo.tCaCartaPromotor2	

-------------  CONSULTA FINAL ------------

select fecha,Region,codoficina, nomoficina, codasesor,NombrePromotor,
isnull(meses,0) meses,
--isnull(saldoIni0a30,0) saldoIni0a30,
isnull(nivel,0) nivel,
isnull(BonoTotalMes,0) BonoTotalMes,
@porcentaje PorcBonoPeriodo,
isnull(BonoPeriodo,0) BonoPeriodo,
isnull(metacolocacion,0) metacolocacion,
isnull(montoColocacion,0) montoColocacion,
isnull(AlcanceColocacion,0) AlcanceColocacion,
--CobranzaPuntual
'90' MetaPuntual,  -- porcentaje de meta fija
isnull(programado_s,0) capProgramado,
isnull(monto_anticipado,0) capAnticipado,
isnull(monto_puntual,0) monto_puntual,
isnull(AlcancePuntual,0) AlcancePuntual,
--CobranzaAcumulada
'95' MetaAcumulada, -- porcentaje de meta fija
--isnull(programado_s,0) capProgramado,
--isnull(monto_anticipado,0) capAnticipado,
--isnull(monto_puntual,0) monto_puntual,
isnull(monto_atrasado,0) monto_atrasado,
isnull(AlcanceAcumulado,0) AlcanceAcumulado,
isnull(caVgteInicial,0) caVgteInicial,
isnull(caVencidaInicial,0) caVencidaInicial31m,
isnull(caVencidaFinal,0) caVencidaFinal31m,
isnull(AlcancePasoVencida,0) AlcancePasoVencida,

'85' MetaPermanencia, -- porcentaje de meta fija
isnull(ptmosRenov,0) ptmosRenov,
isnull(ptmosLiqui,0) ptmosLiqui,
isnull(AlcanceRenovados,0) AlcanceRenovados
--- descripcion
,case when isnull(saldoIni0a30,0)>=0 and isnull(saldoIni0a30,0)<=250000 then '$0 - $250,000'
when saldoIni0a30>250000  and saldoIni0a30<=500000 then '$250,001 - $500,000'
when saldoIni0a30>500000 and saldoIni0a30<=750000 then '$500,001 - $750,000'
when saldoIni0a30>750000 and saldoIni0a30<=1000000 then '$750,001 - $1,000,000'
when saldoIni0a30>1000000 and saldoIni0a30<=1250000 then '$1,000,001 - $1,250,000'
when saldoIni0a30>1250000 and saldoIni0a30<=1500000 then '$1,250,001 - $1,500,000'
 else 'Mayor a $1,500,001' end descripcion
--into FNMGConsolidado.dbo.tCaCartaPromotor2		
from #base with(nolock)



drop table #base
GO