SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create procedure [rie_blozanob].[sp_Detc1]
 as begin
----DETERIORO C1

declare @fecha smalldatetime
set @fecha = CAST(GETDATE() - 1 AS DATE)
declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
declare @fecfin smalldatetime
set @fecfin=@fecha



--TIPO DE OPERACION 
CREATE TABLE #TX(FECHA SMALLDATETIME,CODPRESTAMO VARCHAR(30),TIPOOPERACION VARCHAR(30),INSTRUMENTO VARCHAR(30))
INSERT INTO #TX
SELECT FECHA,CODIGOCUENTA
,CASE WHEN CODSISTEMA='CA' AND TIPOTRANSACNIVEL3 = 102 AND TIPOTRANSACNIVEL2='OPR' THEN 'DESEMBOLSO OPR'
	  WHEN CODSISTEMA='CA' AND TIPOTRANSACNIVEL3 = 102 AND TIPOTRANSACNIVEL2='EFEC' THEN 'DESEMBOLSO EFECTIVO'
	  WHEN CODSISTEMA='CA' AND TIPOTRANSACNIVEL3 = 102 AND TIPOTRANSACNIVEL2 IN('SIST','TRANS','CHEQ') THEN 'DESEMBOLSO TRANSFERENCIA'
	  END TIPOOPERACIÓN
,CASE WHEN CODSISTEMA='CA' AND TIPOTRANSACNIVEL3 = 102 AND TIPOTRANSACNIVEL2='OPR' THEN 'OPR'
	  WHEN CODSISTEMA='CA' AND TIPOTRANSACNIVEL3 = 102 AND TIPOTRANSACNIVEL2='EFEC' THEN 'EFECTIVO'
      WHEN CODSISTEMA='CA' AND TIPOTRANSACNIVEL3 = 102 AND TIPOTRANSACNIVEL2 IN('SIST','TRANS','CHEQ') THEN 'TRANSFERENCIA'
	  END INSTRUMENTO
FROM TCSTRANSACCIONDIARIA  WITH(NOLOCK)
WHERE FECHA >='20240101' 
AND FECHA<=@fecha
AND CODSISTEMA='CA'
AND CODOFICINA<>'999'
AND TIPOTRANSACNIVEL3 IN(102)


create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo
   from tcspadroncarteradet with(nolock)
where desembolso>='20240101' -- A PARTIR DE QUE FECHA QUIERES EVALUAR COSECHAS
and codoficina not in('97','230','231','999') --and tiporeprog='RENOV' el codigo de oficina 98 se quita y se pone dependiendo de para que lo utilicemos, si es para reportes se deja y para analisis se quita
and codprestamo not in ('098-170-06-00-00006','098-170-06-01-00007')
and codprestamo not in (select codprestamo from tCsCarteraAlta)

 
select 
codusuario
,codoficina
,CodPrestamo
--,PaseCastigado_act
,PaseCastigado_ant
,PaseVencido_ant
,NroDiasAtraso
,@fecha fecha
,ciclo_act
,ciclo_ant
,cancelacion_act
,cancelacion_ant
,desembolso
,Incremento
,Rango_Movimientos
,Rango_garantia
,DATEADD(day, -((DATEPART(weekday, Desembolso) + @@DATEFIRST - 1) % 7), Desembolso) AS InicioSemana
 ,DATEADD(MONTH, DATEDIFF(MONTH, 0, desembolso), 0)  mes
,DATEADD(wk, DATEDIFF(wk, 0, desembolso), 6)  semana
,DATEADD(dd, DATEDIFF(dd, 0, desembolso), 0) dia
,ScoreF
,ScoreF_anterior
 ,Rango_score
,Rango_score2
,Rango_score2_Anterior
,Rango_score3
,Rango_score4
,Rango_score5
,rango_edad
,rango_edadDesemb
,rango_edadDesemb2
,rango_edadDesemb3
,edad
,fechanacimiento

,TipoSucursal 
--,tipoCartera --HABILITAR PARA OBTENERLO POR TIPO DE CARTERA (HUERFANA, TRANSICIÓN Y ACTIVA)
--,promotor --HABILITAR PARA OBTENERLO POR PROMOTOR (HUERFANO Y ACTIVO)
,nomoficina --HABILITAR PARA OBTENERLO POR SUCURSAL--
,region   --  HABILITAR PARA OBTENERLO POR REGION--
,Division
,AntiguedadDesembolso
,AntiguedadActual
--,codprestamo-- HABILITAR POR PRESTAMO
--,codusuario
--,secuenciacliente
--,region
--,Antiguedad--HABILITAR POR ANTIGÜEDAD PROMOTOR
--,codproducto --HABILITAR POR PRODUCTO
,ciclo--HABILITAR POR CICLO
--,estadocalculado --HABILITAR PARA OBTENER POR ESTADO
,cosecha
,Garantia
,tasa
--,count(distinct codprestamo) nro
--SALDOS--
,CtaVigente8
,CtaVencida8
,CtaVigente16
,CtaVencida16
,CtaVigente30
,CtaVencida30
,CtaVigente90
,CtaVencida90 
,Rango_Monto
, Rango_Monto2
,montodesembolso montodesembolso
,montodesembolso_ant
--,sum(D0saldo) D0saldo
--,sum(D1a7saldo)D1a7saldo
--,sum(D8a15saldo) D8a15saldo
,D16a30saldo
,D0saldo+D1a7saldo D0a7salso
,D8a15saldo+D16a30saldo D8a30salso
,D0saldo+D1a7saldo+D8a15saldo D0a15salso
,D0saldo+D1a7saldo+D8a15saldo+D16a30saldo D0a30salso
--,sum(D16a30saldo) D15a30saldo
--,sum(D31a60saldo)D31a60saldo
--,sum(D61a89saldo) D61a89saldo
,D31a60saldo+D61a89saldo D31a89saldo
,D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo D7amassaldo
,D16a30saldo+D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo D16amassaldo
,D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo+Castigadosaldo Vencido
,D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo D90amassaldo
--,sum(D0saldo+D1a7saldo+D8a15saldo+D16a30saldo+D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241infsaldo) saldocapital
,Castigadosaldo Castigadosaldo
,Castigadonroptmo Castigadonroptmo
--,sum (interesvigente ) intvigente
--,sum( interesvencido ) intvencido
--CRÉDITOS--
--,count(distinct D0nroptmo)+count(distinct D1a7nroptmo)+count(distinct D8a15nroptmo)+count(distinct D16a30nroptmo) D0a30nroptmo
--,count(distinct D31a60nroptmo)+count(distinct D61a89nroptmo) D31a89nroptmo
--,count(distinct D90a120nroptmo)+count(distinct D121a150nroptmo)+count(distinct D151a180saldo)+count(distinct D181a210nroptmo) +count(distinct D211a240nroptmo)+count(distinct Dm241infnroptmo) D90amasnroptmo
--,count(distinct Castigadonroptmo) Castigadonroptmo
--,count(distinct codprestamo) nroptmo
--,generacion
--,producto
,TIPOOPERACION
,TIPO_FONDEO
,desembolso
,cancelacion
,tipoCredito
,TIPO_CREDITO
,Observacion  
,FechaUltVerificacion

,ActividadEconimica
,Estatus_Verificacion
,NuevosCierres
,NuevosCierres2
,NroCuotas
,NroCuotasPagadas
--,TasaIntCorriente
---------------------------------------------------------------------------------------
---DOMICILIO DEL ACREDITADO
,CÓDIGO_POSTAL_DEL_DOMICILIO-- DEL ACREDITADO	    
,COLONIA_DEL_DOMICILIO-- DEL ACREDITADO
,Municipio_Cliente
,Estado_Cliente
,Calificacion	
,pagomensualcred	
,capacidadpagoporc	
,capacidadpago	
,ingreso	
,gasto	
,calc_CapPago
,calc_CapPagoPorc

-------------------------------------------------------------------------------------

,Direccion
,nrodiasmax
,LatitudSuc
,LongitudSuc
,Asignacion_Promotor

--Primer promotor (Prom1)
,Prom1
,Ing_Prom1
,Nac_Prom1
,nameProm1
,salida_Prom1

--Promotor actual (PromAct)
,PromAct
,Ing_PromAct
,Nac_PromAct1
,namePromAct
,salida_PromAct

,rangoAntiguedad
,rango_AntiguedadDesemb
,rango_AntiguedadDesemb2
,R_AntigDesemAnio
--,Asignacion_Promotor
,TipoC
from (
  SELECT pd.secuenciacliente,c.Fecha,pd.codusuario codusuario,pd.codoficina, pd.CodPrestamo CodPrestamo, pd.EstadoCalculado estadocalculado, pd.CodProducto,ct.tasaIntcorriente tasa
  ,cd.saldocapital, pd.monto montodesembolso, pd.desembolso desembolso , t.cancelacion cancelacion ,c.NroDiasAtraso NroDiasAtraso
  ,dbo.fdufechaaperiodo(pd.Desembolso) cosecha  ,o.nomoficina , pd.SecuenciaCliente ciclo_act , pd1.SecuenciaCliente ciclo_ant
  ,z.nombre region,cd.interesvigente, cd.interesvencido, cd.interesctaorden, cd.moratoriovigente, cd.moratoriovencido, cd.moratorioctaorden,TX.FECHA  'FECHA_DESEMBOLSO',
TX.TIPOOPERACION,TX.INSTRUMENTO  'TIPO_FONDEO' ,pd1.cancelacion cancelacion_ant ,pd.cancelacion cancelacion_act , pd.PaseCastigado PaseCastigado_act
,pd1.PaseCastigado PaseCastigado_ant ,pd1.PaseVencido PaseVencido_ant, pd1.monto montodesembolso_ant, r.MontoGarLiq Garantia, u.Latitud Latitud, u.Longitud Longitud
,o.Direccion Direccion
 
,case 
	when (pd.Monto/pd1.monto)-1 = 0  then 'sin cambio 0%'
	when (pd.Monto/pd1.monto)-1 > 0 and (pd.Monto/pd1.monto)-1  <= 0.1 then 'incremento 1-10%'
	when (pd.Monto/pd1.monto)-1 > 0.1 and (pd.Monto/pd1.monto)-1  <= 0.2 then 'incremento 11-20%'
	when (pd.Monto/pd1.monto)-1 > 0.2 and (pd.Monto/pd1.monto)-1  <= 0.3 then 'incremento 21-30%'
	when (pd.Monto/pd1.monto)-1 > 0.3 and (pd.Monto/pd1.monto)-1  <= 0.6 then 'incremento 31-60%'
	when (pd.Monto/pd1.monto)-1 > 0.6 and (pd.Monto/pd1.monto)-1  < 1 then 'incremento 61-99%'
	when (pd.Monto/pd1.monto)-1 >= 1  then 'incremento 100%'
	when (pd.Monto/pd1.monto)-1 < 0 and (pd.Monto/pd1.monto)-1  >= -0.1 then 'disminucion 1-10%'
	when (pd.Monto/pd1.monto)-1 < -0.1 and (pd.Monto/pd1.monto)-1  >= -0.2 then 'disminucion 11-20%'
	when (pd.Monto/pd1.monto)-1 < -0.2 and (pd.Monto/pd1.monto)-1  >= -0.3 then 'disminucion 21-30%'
	when (pd.Monto/pd1.monto)-1 < -0.3 and (pd.Monto/pd1.monto)-1  >= -0.6 then 'disminucion 31-60%'
	when (pd.Monto/pd1.monto)-1 < -0.6 and (pd.Monto/pd1.monto)-1  > -1 then 'disminucion 61-99%'
	when (pd.Monto/pd1.monto)-1 <= -1  then 'disminucion 100%'
	when pd1.monto IS NULL then 'nuevo'
	else '?' end Rango_Movimientos

,case 
	when (pd.Monto/pd1.monto)-1 = 0  then 'se mantuvo %'
	when (pd.Monto/pd1.monto)-1 > 0  then 'incremento %'
	when (pd.Monto/pd1.monto)-1 < 0  then 'disminucion%'
	when pd1.monto IS NULL then 'nuevo'
	else '?' end Incremento



 ,case
	when r.MontoGarLiq/pd.Monto >= 0  and r.MontoGarLiq/pd.Monto <= .05   then 'garantia 0-5%'
	when r.MontoGarLiq/pd.Monto > .05 and r.MontoGarLiq/pd.Monto < .1   then 'garantia 6-9%'
	when r.MontoGarLiq/pd.Monto >= .1  then 'garantia 10+%'
	else '?' end Rango_garantia
  
,case when pd.Monto >=7500 then 'b.7.5k+' 
      when pd.Monto < 7500 then 'a.-7.5k'
      else 'na' end Rango_Monto
      
,case when pd.Monto > 6000 then '6k+' 
	  
      else 'hasta 6k' end Rango_Monto2

,case when e.valorscore is null then e.score_valor 
 else e.valorscore end ScoreF
,case when e1.valorscore is null then e1.score_valor 
 else e1.valorscore end ScoreF_anterior
         
,case when e.score_valor = 0 then 'a.score 0'
	when e.score_valor >=350 and e.score_valor <400 then 'b.350-399'
      when e.score_valor >=400 and e.score_valor <451 then 'c.400-450'
      when e.score_valor >=451 and e.score_valor <500 then 'd.451-499'
      when e.score_valor >=500 and e.score_valor <551 then 'e.500-550'
      when e.score_valor >=551 and e.score_valor <600 then 'f.551-599'
      when e.score_valor >=600 and e.score_valor <651 then 'g.600-650'
      when e.score_valor >=651 and e.score_valor <700 then 'h.651-699'
      when e.score_valor >=700 and e.score_valor <751 then 'i.700-750'
      when e.score_valor >=751 and e.score_valor <800 then 'j.751-799'
      when e.score_valor >=800 then 'k.800+'
      else '?' end Rango_score

,case when e.valorscore is null and e.score_valor is null then 'SinScore'
	 when e.valorscore is null and e.score_valor = 0 then 'a.score 0'
	 when e.valorscore is null  and e.score_valor>0  and e.score_valor <400 then 'b.1-399'
     when e.valorscore is null and e.score_valor >=400 and e.score_valor <451 then 'c.400-450'
      when e.valorscore is null and e.score_valor >=451 and e.score_valor <500 then 'd.451-499'
      when e.valorscore is null and e.score_valor >=500 and e.score_valor <551 then 'e.500-550'
      when e.valorscore is null and e.score_valor >=551 and e.score_valor <600 then 'f.551-599'
      when e.valorscore is null and e.score_valor >=600 and e.score_valor <651 then 'g.600-650'
      when e.valorscore is null and e.score_valor >=651 and e.score_valor <700 then 'h.651-699'
      when e.valorscore is null and e.score_valor >=700 and e.score_valor <751 then 'i.700-750'
      when e.valorscore is null and e.score_valor >=751 and e.score_valor <800 then 'j.751-799'
      when e.valorscore is null and e.score_valor >=800 then 'k.800+'
	  when e.valorscore is not null and e.valorscore = 0 then 'a.score 0'
when e.valorscore is not null and e.valorscore>0 and e.valorscore <400 then 'b.1-399'
when e.valorscore is not null and e.valorscore >=400 and e.valorscore <451 then 'c.400-450'
when e.valorscore is not null and e.valorscore >=451 and e.valorscore <500 then 'd.451-499'
when e.valorscore is not null and e.valorscore >=500 and e.valorscore <551 then 'e.500-550'
when e.valorscore is not null and e.valorscore >=551 and e.valorscore <600 then 'f.551-599'
when e.valorscore is not null and e.valorscore >=600 and e.valorscore <651 then 'g.600-650'
when e.valorscore is not null and e.valorscore >=651 and e.valorscore <700 then 'h.651-699'
when e.valorscore is not null and e.valorscore >=700 and e.valorscore <751 then 'i.700-750'
when e.valorscore is not null and e.valorscore >=751 and e.valorscore <800 then 'j.751-799'
when e.valorscore is not null and e.valorscore >=800 then 'k.800+'	  
      else 'na' end Rango_score2

,case when e1.valorscore is null and e1.score_valor is null then 'SinScore'
	 when e1.valorscore is null and e1.score_valor = 0 then 'a.score 0'
	 when e1.valorscore is null  and e1.score_valor>0  and e1.score_valor <400 then 'b.1-399'
     when e1.valorscore is null and e1.score_valor >=400 and e1.score_valor <451 then 'c.400-450'
      when e1.valorscore is null and e1.score_valor >=451 and e1.score_valor <500 then 'd.451-499'
      when e1.valorscore is null and e1.score_valor >=500 and e1.score_valor <551 then 'e.500-550'
      when e1.valorscore is null and e1.score_valor >=551 and e1.score_valor <600 then 'f.551-599'
      when e1.valorscore is null and e1.score_valor >=600 and e1.score_valor <651 then 'g.600-650'
      when e1.valorscore is null and e1.score_valor >=651 and e1.score_valor <700 then 'h.651-699'
      when e1.valorscore is null and e1.score_valor >=700 and e1.score_valor <751 then 'i.700-750'
      when e1.valorscore is null and e1.score_valor >=751 and e1.score_valor <800 then 'j.751-799'
      when e1.valorscore is null and e1.score_valor >=800 then 'k.800+'
	  when e1.valorscore is not null and e1.valorscore = 0 then 'a.score 0'
when e1.valorscore is not null and e1.valorscore>0 and e1.valorscore <400 then 'b.1-399'
when e1.valorscore is not null and e1.valorscore >=400 and e1.valorscore <451 then 'c.400-450'
when e1.valorscore is not null and e1.valorscore >=451 and e1.valorscore <500 then 'd.451-499'
when e1.valorscore is not null and e1.valorscore >=500 and e1.valorscore <551 then 'e.500-550'
when e1.valorscore is not null and e1.valorscore >=551 and e1.valorscore <600 then 'f.551-599'
when e1.valorscore is not null and e1.valorscore >=600 and e1.valorscore <651 then 'g.600-650'
when e1.valorscore is not null and e1.valorscore >=651 and e1.valorscore <700 then 'h.651-699'
when e1.valorscore is not null and e1.valorscore >=700 and e1.valorscore <751 then 'i.700-750'
when e1.valorscore is not null and e1.valorscore >=751 and e1.valorscore <800 then 'j.751-799'
when e1.valorscore is not null and e1.valorscore >=800 then 'k.800+'	  
      else 'na' end Rango_score2_Anterior

,case 
	when e.valorscore is null and e.score_valor is null then 'a.SinScore'
	when e.valorscore is null and e.score_valor >=0 and e.score_valor <600 then 'b.0-599'
    when e.valorscore is null and e.score_valor >=600 then 'c.600+'
	when e.valorscore is not null and e.valorscore >=0 and e.valorscore <600 then 'b.0-599'
	when e.valorscore is not null and e.valorscore >=600 then 'c.600+'	  
	else 'na' end Rango_score3

,case 
	when e.valorscore is null and e.score_valor is null then 'a.SinScore'
	when e.valorscore is null and e.score_valor >=0 and e.score_valor <500 then 'b.0-499'
	when e.valorscore is null and e.score_valor >=500 and e.score_valor <600 then 'C.500-599'
    when e.valorscore is null and e.score_valor >=600 then 'c.600+'
	when e.valorscore is not null and e.valorscore >=0 and e.valorscore <500 then 'b.0-499'
	when e.valorscore is not null and e.valorscore >=500 and e.valorscore <600 then 'C.500-599'
	when e.valorscore is not null and e.valorscore >=600 then 'c.600+'	  
	else 'na' end Rango_score4

,case 
	when e.valorscore is null and e.score_valor is null then 'a.SinScore'
	when e.valorscore is null and e.score_valor = 0 then 'b.score 0'
	when e.valorscore is null and e.score_valor >0 and e.score_valor <500 then 'c.1-499'
	when e.valorscore is null and e.score_valor >=500 and e.score_valor <550 then 'd.500-549'
	when e.valorscore is null and e.score_valor >=550 and e.score_valor <600 then 'e.550-599'
    when e.valorscore is null and e.score_valor >=600 then 'f.600+'
	when e.valorscore is not null and e.valorscore = 0 then 'b.score 0'
	when e.valorscore is not null and e.valorscore >0 and e.valorscore <500 then 'c.1-499'
	when e.valorscore is not null and e.valorscore >=500 and e.valorscore <550 then 'd.500-549'
	when e.valorscore is not null and e.valorscore >=550 and e.valorscore <600 then 'e.550-599'
	when e.valorscore is not null and e.valorscore >=600 then 'f.600+'	  
	else 'na' end Rango_score5
,case when datediff(year,pc.fechanacimiento,@fecfin)<= 24 then 'a.18-24'
       when datediff(year,pc.fechanacimiento,@fecfin)<= 39 then 'b.25-39'
   when datediff(year,pc.fechanacimiento,@fecfin)<= 49 then 'c.40-49'
   when datediff(year,pc.fechanacimiento,@fecfin)<=59  then 'd.50-59'
   when datediff(year,pc.fechanacimiento,@fecfin)>= 60 then 'e.60+'
   when pc.fechanacimiento is null then 'f.null'
   else 'na' end rango_edad
,case when datediff(year,pc.fechanacimiento,pd.desembolso)<= 39 then 'a.-40'
       when datediff(year,pc.fechanacimiento,pd.desembolso)> 39 then 'b.40+'
   when pc.fechanacimiento is null then 'e.null'
   else 'na' end rango_edadDesemb
,case when datediff(year,pc.fechanacimiento,pd.desembolso)<= 24 then 'a.18-24'
       when datediff(year,pc.fechanacimiento,pd.desembolso)<= 39 then 'b.25-39'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 49 then 'c.40-49'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<=59  then 'd.50-59'
   when datediff(year,pc.fechanacimiento,pd.desembolso)>= 60 then 'e.60+'
   when pc.fechanacimiento is null then 'f.null'
   else 'na' end rango_edadDesemb2
,case when datediff(year,pc.fechanacimiento,pd.desembolso)<= 20 then 'a.18-20'
       when datediff(year,pc.fechanacimiento,pd.desembolso)<= 25 then 'b.21-25'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 30 then 'c.26-30'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<=35  then 'd.31-35'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 40 then 'e.36-40'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 45 then 'f.41-45'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 50 then 'g.46-50'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 55 then 'h.51-55'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 60 then 'i.56-60'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 65 then 'j.61-65'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 70 then 'k.66-70'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 75 then 'l.71-75'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 80 then 'm.76-80'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 85 then 'n.81-85'
   when datediff(year,pc.fechanacimiento,pd.desembolso)<= 90 then 'o.86-90'
   when datediff(year,pc.fechanacimiento,pd.desembolso)> 90 then 'p.91+'
   when pc.fechanacimiento is null then 'z.null'
   else 'na' end rango_edadDesemb3
,datediff(year,pc.fechanacimiento,pd.desembolso) edad
,pc.fechanacimiento


,case when pd.SecuenciaCliente>=15 then 'f.ciclo 15+'  
      when pd.SecuenciaCliente>=10 then 'e.ciclo 10-15'
      when pd.SecuenciaCliente>=5 then 'd.ciclo 5-9'
      when pd.SecuenciaCliente>=3 then 'c.ciclo 3-4'
      when pd.SecuenciaCliente=2 then 'b.ciclo 2'
      else 'a.ciclo 1' end  ciclo
  
,case when z.nombre in  ('Bajio', 'Jalisco') then 'Division_Bajio'
	when z.nombre in('Centro','Estado','Costa Chica','Costa Grande') then 'Division_Centro'
	when z.nombre in ('Sur progreso','Sur tizimin') then 'Division_Sur'	  
	when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Division_Veracruz'
	when z.nombre in ('Zona Corporativo') then 'Corporativo'
	else 'NA' end Division



  ,(datediff(day,emp.Ingreso,pd.desembolso )/30) AntiguedadDesembolso
  ,(datediff(day,emp.Ingreso,@fecha )/30) AntiguedadActual
  --,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else 'ACTIVO' end promotor
 
  --,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO'
--when (pd.ultimoasesor<>pd.primerasesor) then 'TRANSICION'
--else  'ACTIVO' end tipoCartera  

,case when pd.CodProducto='370' then 'CONSUMO'
         when pd.CodProducto='168' then 'VIVIENDA'
         when pd.Monto >=500000 then 'EMPRESARIAL'
      when pd.Monto >=30000 then 'PYME 30K-150K'
         when pd.CodProducto='172' then 'PYME 30K-150K'
         when pd.CodProducto='170' then 'PRODUCTIVO'
         else 'Revisar' end Producto
     
--,case when pd.TipoReprog = 'RENOV' then 'Renovacion Anticipada' 
--when pd.SecuenciaCliente =1 then 'Nuevo'
--	 --when t.cancelacion = pd.desembolso then 'Renovacion Organica' 
--      when DATEDIFF(dd,t.cancelacion,pd.desembolso) >= 90 then 'Reactivado 90+' 
--      --when t.cancelacion is null and pd.SecuenciaCliente > 1  and DATEDIFF(dd,t.cancelacion,pd.desembolso) >= 90 then 'Reactivado 90+'
--       when DATEDIFF(dd,t.cancelacion,pd.desembolso) < 90 then 'Reactivado 90-' 
--      --when t.cancelacion is null and pd.SecuenciaCliente > 1  and DATEDIFF(dd,t.cancelacion,pd.desembolso) < 90 then 'Reactivado 90-'
--      else t.estado end tipoCredito

,case when pd.TipoReprog = 'RENOV' then 'Anticipado' 
when pd.SecuenciaCliente =1 then 'Nuevo'
      when DATEDIFF(MM,t.cancelacion,pd.desembolso) >= 1 then 'Reactivado' 
      when t.cancelacion is null and pd.SecuenciaCliente > 1 then 'Reactivado'
      else t.estado end tipoCredito 
,CASE WHEN o.EsVirtual = 0 THEN 'Fisica'
			WHEN o.EsVirtual = 1 THEN 'Virual'
			ELSE '?' End TipoSucursal 
      
,case when pd.TipoReprog = 'RENOV' then 'Renovacion Anticipada' 
	  when pd1.SecuenciaCliente is null then 'Nuevo'
	  when pd1.cancelacion = pd.desembolso AND pd.TipoReprog <> 'RENOV' then 'Renovacion Organica'
      when DATEDIFF(dd,pd1.cancelacion,pd.desembolso) >= 90 then 'Reactivado 90+' 
      when DATEDIFF(dd,pd1.cancelacion,pd.desembolso) < 90 then 'Reactivado 90-' 
      when pd1.cancelacion is null and pd1.PaseCastigado is not null then 'Castigado-Reactivado'
      else t.estado end TIPO_CREDITO       
      
  /*   Total    */
,case when c.nrodiasatraso<=7 then 1 else 0 end CtaVigente8
,case when c.nrodiasatraso>7 then 1 else 0 end CtaVencida8
,case when c.nrodiasatraso<=15 then 1 else 0 end CtaVigente16
,case when c.nrodiasatraso>15 then 1 else 0 end CtaVencida16
,case when c.nrodiasatraso<=30 then 1 else 0 end CtaVigente30
,case when c.nrodiasatraso>30 then 1 else 0 end CtaVencida30
,case when c.nrodiasatraso<=90 then 1 else 0 end CtaVigente90
,case when c.nrodiasatraso>90 then 1 else 0 end CtaVencida90 
--,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso<=30 then 1 else 0 end else null end CtaVigente30


,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.codprestamo else null end else null end D0nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso=0 then cd.saldocapital else 0 end else 0 end D0saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.codprestamo else null end else null end D1a7nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>0 and c.NroDiasAtraso<=7 then cd.saldocapital else 0 end else 0 end D1a7saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.codprestamo else null end else null end D8a15nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<=15 then cd.saldocapital else 0 end else 0 end D8a15saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.codprestamo else null end else null end  D16a30nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end D16a30saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.codprestamo else null end else null end  D31a60nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<=60 then cd.saldocapital else 0 end else 0 end D31a60saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.codprestamo else null end else null end D61a89nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<=89 then cd.saldocapital else 0 end else 0 end D61a89saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.codprestamo else null end else null end D90a120nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=90 and c.NroDiasAtraso<=120 then cd.saldocapital else 0 end else 0 end D90a120saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then cd.codprestamo else null end else null end D121a150nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=121 and c.NroDiasAtraso<=150 then cd.saldocapital else 0 end else 0 end D121a150saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then cd.codprestamo else null end else null end D151a180nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=151 and c.NroDiasAtraso<=180 then cd.saldocapital else 0 end else 0 end D151a180saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then cd.codprestamo else null end else null end D181a210nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=181 and c.NroDiasAtraso<=210 then cd.saldocapital else 0 end else 0 end D181a210saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then cd.codprestamo else null end else null end D211a240nroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=211 and c.NroDiasAtraso<=240 then cd.saldocapital else 0 end else 0 end D211a240saldo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.codprestamo else null end else null end Dm241infnroptmo
,case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=241 then cd.saldocapital else 0 end else 0 end Dm241infsaldo
,case when c.cartera='CASTIGADA' then cd.codprestamo else null end Castigadonroptmo
,case when c.cartera='CASTIGADA' then cd.saldocapital else 0 end Castigadosaldo

--,case when pd.CodProducto='170' then 'PRODUCTIVO'when pd.Codproducto='168' then 'VIVIENDA' when pd.Codproducto='172'then 'PYME' when pd.monto>=500000 then 'EMPRESARIAL' when pd.monto>=30000 then 'PYME' else 'CONSUMO' end producto
 
  /*   Verificacion   */
  
,v.Observacion Observacion  
,v.FechaUltVerificacion FechaUltVerificacion
, v.ActividadEconimica ActividadEconimica
 
,case
	when v.FechaUltVerificacion = '19000101'then 'sin verificacion'
	when v.FechaUltVerificacion <> '19000101' then 'con verificacion'
	else 'sin verificacion' end Estatus_Verificacion

,case 
	--when c.codoficina in ('330','474','484','485','480','468','483','489','471','456') then 'cerradas'
	when pd.codoficina in ('130','330','474','18','484','212','412','485','456','163','363','480','468','26','483','489','138','338','452','471') then 'cerradas'
else 'abiertas' end NuevosCierres
,case 
	--when c.codoficina in ('330','474','484','485','480','468','483','489','471','456') then 'cerradas'
	when o.nomoficina in ('Chetumal',	'Emiliano Zapata',	'LERMA',	'AUTLAN',	'TIERRA COLORADA',	'Tecamac',	'Chetumal',	'Emiliano Zapata',	'PALENQUE',	'Coatepec',	'Tierra Blanca',	'UMAN',	'UMÁN') then 'cerradas'
else 'abiertas' end NuevosCierres2

----------------------------------------------------------------------------------------------------------
  ---DOMICILIO CLIENTE
    ,replace(substring(upper(isnull(cl.DireccionDirFamPri,cl.DireccionDirNegPri)),1,100),',','') CALLE_DEL_DOMICILIO-- DEL ACREDITADO--17
,case when cl.NumExtFam is null or rtrim(ltrim(cl.NumExtFam))=''
	  then (case when cl.NumExtNeg is null or ltrim(rtrim(cl.NumExtNeg))='' or ltrim(rtrim(cl.NumExtNeg))='sn'
				 then 'S/N' else replace(replace(replace(replace(replace(replace(cl.NumExtNeg,' ',''),'*',''),'-',''),'.',''),'_',''),',',' ')end)
	  when rtrim(ltrim(cl.NumExtFam))='sn' or rtrim(ltrim(cl.NumExtFam))='SINNUMERO' then 'S/N'
	  else                       replace(replace(replace(replace(replace(replace(cl.NumExtFam,' ',''),'*',''),'-',''),'.',''),'_',''),',',' ') end + ' ' +
case when cl.NumIntFam is null or rtrim(ltrim(cl.NumIntFam))=''
	  then (case when cl.NumIntNeg is null or ltrim(rtrim(cl.NumIntNeg))='' or ltrim(rtrim(cl.NumIntNeg))='sn'
				 then '' else    replace(replace(replace(replace(replace(replace(cl.NumIntNeg,' ',''),'*',''),'-',''),'.',''),'_',''),',',' ') end)
	  when rtrim(ltrim(cl.NumIntFam))='sn' or rtrim(ltrim(cl.NumIntFam))='SINNUMERO' then ''
	  else                       replace(replace(replace(replace(replace(replace(cl.NumIntFam,' ',''),'*',''),'-',''),'.',''),'_',''),',',' ') end	  
	   NÚMERO_EXTERIOR_DEL_DOMICILIO_DEL_ACREDITADO--18
,case when isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1)='' or isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1)='0'
		then ''
		else isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1) end CÓDIGO_POSTAL_DEL_DOMICILIO-- DEL ACREDITADO	    
,u.descubigeo COLONIA_DEL_DOMICILIO-- DEL ACREDITADO
,mu.descubigeo Municipio_Cliente
,es.descubigeo Estado_Cliente
--,c.TasaIntCorriente
 ,e.Calificacion,	e.pagomensualcred,	e.capacidadpagoporc,	e.capacidadpago,	e.ingreso,	e.gasto	
 
, case 
	when  e.pagomensualcred is null or e.ingreso is null or 	e.gasto	is null then 'null'
	when ((e.ingreso-e.gasto-e.pagomensualcred)/e.ingreso)>=.30 then 'a.ALTA'
	when ((e.ingreso-e.gasto-e.pagomensualcred)/e.ingreso)>=.10 then 'b.MEDIA'
	when ((e.ingreso-e.gasto-e.pagomensualcred)/e.ingreso)>0 then 'c.BAJA'
	when ((e.ingreso-e.gasto-e.pagomensualcred)/e.ingreso)<=0 then 'd.NULA'
	else 'revisar' end calc_CapPago

,((e.ingreso-e.gasto-e.pagomensualcred)/e.ingreso)calc_CapPagoPorc

,pd.nroCuotas NroCuotas
,ct.NroCuotasPagadas
,c.nrodiasmax 
,oc.latitud LatitudSuc, oc.longitud longitudSuc


---------
--------
----------------------------------------PROMOTORES
 ,case when emp.salida is null then 'mismo promotor'
 when emp.salida is not null and pd.primerasesor= pd.UltimoAsesor then 'no reasignado'
  when emp.salida is not null and pd.primerasesor<> pd.UltimoAsesor then 'reasignado'
  else 'revisar' end Asignacion_Promotor

--Primer promotor (Prom1)
,pd.PrimerAsesor Prom1
,emp.Ingreso Ing_Prom1
,emp.Nacimiento Nac_Prom1
,coalesce(emp.paterno ,'') + ' ' + coalesce(emp.materno ,'') + ' ' + coalesce(emp.nombres,'') nameProm1
,emp.salida salida_Prom1

--Promotor actual (PromAct)
,pd.UltimoAsesor PromAct
,emp2.Ingreso Ing_PromAct
,emp2.Nacimiento Nac_PromAct1

,coalesce(emp2.paterno ,'') + ' ' + coalesce(emp2.materno ,'') + ' ' + coalesce(emp2.nombres,'') namePromAct
,emp2.salida salida_PromAct


,case when datediff(month,emp.ingreso,@fecha)>6 then '6-9meses'
       when datediff(month,emp.ingreso,@fecha)> 3 then '3-6meses'
     else '0-3meses'  END rangoAntiguedad	
,case
    when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 6 then 'c.+6m'
    when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 3 then 'b.+3-6m'
	when (datediff(day,emp.Ingreso,pd.desembolso )/30) <= 3 then 'a.0-3m'
    else 'z.revisar' end rango_AntiguedadDesemb
,case
    when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 6 then 'b.+6m'
    when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 3 then 'b.+3-6m'
    else 'a.0-6m' end rango_AntiguedadDesemb2
--,case 
--	when pd.PrimerAsesor=pd.UltimoAsesor then 'Promotor inicial'
--	else 'CréditoReasignado' end Asignacion_Promotor

,case
---2024
    when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 6 and year(pd.desembolso)=2024 then 'c.2024_+6m'
    when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 3 and year(pd.desembolso)=2024 then 'b.2024_3-6m'
	when (datediff(day,emp.Ingreso,pd.desembolso )/30) <= 3 and year(pd.desembolso)=2024 then 'a.2024_0-3m'
--2025
	when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 6 and year(pd.desembolso)=2025 then 'c.2025_+6m'
    when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 3 and year(pd.desembolso)=2025 then 'b.2025_3-6m'
	when (datediff(day,emp.Ingreso,pd.desembolso )/30) <= 3 and year(pd.desembolso)=2025 then 'a.2025_0-3m'
--2026
	when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 6 and year(pd.desembolso)=2026 then 'c.2026_+6m'
    when (datediff(day,emp.Ingreso,pd.desembolso )/30) > 3 and year(pd.desembolso)=2026 then 'b.2026_3-6m'
	when (datediff(day,emp.Ingreso,pd.desembolso )/30) <= 3 and year(pd.desembolso)=2026 then 'a.2026_0-3m'
 else 'z.revisar' end R_AntigDesemAnio
 --tipo
,case 
	when pd.SecuenciaCliente= 1 and pd.monto<20000 then 'a.c1-'
	when pd.SecuenciaCliente= 1 and pd.monto>=20000 then 'b.c1+'
	when pd.SecuenciaCliente<> 1 and pd1.TipoReprog='RENOV' THEN 'c.renovAnticip'
	when pd.SecuenciaCliente<> 1 and pd1.TipoReprog<>'RENOV' and DATEDIFF(day,pd1.cancelacion,pd.desembolso)<=30 THEN 'd.renovOrgan'
	when pd.SecuenciaCliente<> 1 and pd1.TipoReprog<>'RENOV' and DATEDIFF(day,pd1.cancelacion,pd.desembolso)>30 THEN 'e.Reactivacion'
	else 'revisar' end TipoC

  FROM tcspadroncarteradet pd with(nolock)
  left outer join tcspadroncarteradet pd1  with (nolock) on pd.codusuario = pd1.codusuario and pd1.SecuenciaCliente = pd.SecuenciaCliente-1
  left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e with (nolock) on pd.codprestamo=e.codprestamo
  left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e1 with (nolock) on pd1.codprestamo=e1.codprestamo
  left outer join tCsACaLIQUI_RR t on t.codprestamonuevo = pd.CodPrestamo 
  left outer join tcscarteradet cd with(nolock) on cd.fecha=@fecha and cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario
  left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha
  inner join tcloficinas o with(nolock) on o.codoficina=pd.codoficina
  left outer join tCsCartera ct with(nolock) on pd.codprestamo=ct.codprestamo and ct.fecha=pd.fechacorte
  inner join tclzona z on z.zona=o.zona

  left outer join tcsempleados emp with(nolock) on pd.primerasesor=emp.codusuario  --Promotor coloca
  left outer join tCsEmpleados emp2 on emp2.codusuario=pd.UltimoAsesor --- promotor actual


  --left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha
  left outer join tCsPadronClientes pc with(nolock) on pd.CodUsuario=pc.Codusuario
  left outer join tcscarterareserva r with(nolock) on  pd.codprestamo=r.codprestamo and pd.desembolso=r.fecha
  INNER JOIN #TX TX WITH(NOLOCK) ON pd.codprestamo=TX.CODPRESTAMO
  LEFT OUTER JOIN [FNMGConsolidado].[dbo].[tCaDesembVerificacionFisica] v with(nolock) ON pd.codprestamo=v.codprestamo 
  --LEFT OUTER JOIN tclubigeo u with(nolock) on u.codubigeo=o.codubigeo
   -----
  ---DOMICILIO CLIENTE
  left outer join tcspadronclientes cl with(nolock) on cl.codusuario=pd.codusuario
  left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
  left outer join tclubigeo mu with(nolock) on mu.codubigeotipo='MUNI' and mu.codarbolconta=substring(u.codarbolconta,1,19)
  left outer join tclubigeo es with(nolock) on es.codubigeotipo='ESTA' and es.codarbolconta=substring(u.codarbolconta,1,13)
 
 ----Sucursal
 left outer join tclLocalizaOficina oc on oc.codoficina= o.codoficina
  ------
  where pd.codprestamo in(select codprestamo from #ptmos) and pd.codoficina not in('97','230','231','999')
  and pd.CodPrestamo not in ('435-170-06-00-04873','339-170-06-06-15512','434-170-06-02-05128 ','435-170-06-05-05506','310-170-06-00-09621','431-170-06-00-05911','307-170-06-05-19145')
and pd.SecuenciaCliente=1) a

 
drop table #ptmos
DROP TABLE #TX

end
GO

GRANT EXECUTE ON [rie_blozanob].[sp_Detc1] TO [rie_jalvarezc]
GO