SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[pcsFNMGreporteDiarioV3]
    @fecha smalldatetime -- Parámetro para la fecha de corte
AS
BEGIN
    SET NOCOUNT ON;

	/*---calculo para el reporte diario:   buckets de EPRC X nroDiasAtraso   >>  FNMGConsolidado.dbo.tCaReporteDiarioEPRC ---*/  

	---- 2025.06.19   Agrego desgloces por numeros de días de atrasos.
	---- 2025.10.22   Este script ejecuta el EPRC de liquidados y castigados del fin de mes anterior si estos datos faltan
	---- 22.01.2026   Sil: Se ajusta para la nueva reserva IFRS9 (nuevo calculo de EPRC)   - 


 --   declare @fecha smalldatetime  ---LA FECHA DE CORTE                  
	--select @fecha=fechaconsolidacion from vcsfechaconsolidacion 

	--- inicio de mes
    DECLARE @fecini smalldatetime;
    SET @fecini = CAST(dbo.fdufechaaperiodo(@fecha) + '01' AS smalldatetime);
    
	--- fin de mes anterior
    DECLARE @fecante smalldatetime;
    SET @fecante = CAST(dbo.fdufechaaperiodo(@fecha) + '01' AS smalldatetime) - 1;


	-- Se ejecuta si falta el dato de EPRC y liquidados de fin de mes anterior
			IF NOT EXISTS (
					SELECT 1
					FROM FNMGConsolidado.dbo.tCaRepDiarioEPRC_LiqCast_FinMes WITH (NOLOCK)
					where fecha=@fecante 
				)
			BEGIN
			exec pcsFNMG_EPRC_LiqCast @fecante

			END



	--- define fecha de clasificación por buckets
    DECLARE @fecbucket smalldatetime;
	IF @fecha = DATEADD(DAY, -1,     DATEADD(MONTH, 1, @fecini)    )    -- ya es fin de mes? 
		begin
			set @fecbucket = @fecha    --'Es último día del mes actual';
			exec pcsFNMG_EPRC_LiqCast @fecha
		end
	ELSE
		set @fecbucket = @fecante   --'Es el ultimo día del mes anterior';





		----- Se unen las reservas  IFRS9 de Consumo y Productivo
CREATE TABLE #reserva (fecha smalldatetime,codprestamo varchar(25), Codproducto int, nrodiasatraso int,   eprc_total money)                 
  
	insert into #reserva
	select 
		rP.fecha,
		rP.codprestamo,
		rP.Codproducto,
		rP.Dias_Atraso_1,
		rP.reserva
	from tCsCaProReservaIFRS9 rP          ----------------- >> reserva  Productivo (170, 172)
	where --fecha='20260118'
	rP.fecha>=@fecante and  rP.fecha<=@fecha
	--and Dias_Atraso_1 <> PromedioDiasAtraso


	insert into #reserva
	select 	
		rC.fecha,
		rC.codprestamo,
		rC.Codproducto,
		rC.nrodiasatraso,
		rC.eprc_total
	from tCsCaConsReservaIFRS9 rC            ----------------- >> reserva  Consumo  (370)
	where --fecha='20260118'
	rC.fecha>=@fecante and  rC.fecha<=@fecha





------ Clasificacion por buckets (días de atraso) a una fecha especifica
select 
	r.fecha fecha,
	c.codprestamo,
	c.Cancelacion,
	c.PaseCastigado,
	r.nrodiasatraso
	--,CASE WHEN r.nrodiasatraso = 0 THEN '0'     ---0dm
	--	 WHEN r.nrodiasatraso >= 1 and r.nrodiasatraso <= 7 THEN '1_7' 
	--	 WHEN r.nrodiasatraso >= 8 and r.nrodiasatraso <= 15 THEN '8_15'
	--	 WHEN r.nrodiasatraso >= 16 and r.nrodiasatraso <= 21 THEN '16_21'
	--	 WHEN r.nrodiasatraso >= 22 and r.nrodiasatraso <= 30 THEN '22_30'
	--	 WHEN r.nrodiasatraso >= 31 and r.nrodiasatraso <= 60 THEN '31_60'
	--	 WHEN r.nrodiasatraso >= 61 and r.nrodiasatraso <= 90 THEN '61_90'
	--	 WHEN r.nrodiasatraso >= 91 and r.nrodiasatraso <= 120 THEN '91_120'
	--	 WHEN r.nrodiasatraso >= 121 and r.nrodiasatraso <= 150 THEN '121_150'
	--	 WHEN r.nrodiasatraso >= 151 and r.nrodiasatraso <= 180 THEN '151_180'	
	--	 WHEN r.nrodiasatraso >= 181 THEN '181+'   -- EPRC con días de atraso >= 181
	--	 ELSE '?' END AS bucket
into #bucket
from #reserva r with (nolock)                  
inner join tcspadroncarteradet c with(nolock) on c.codprestamo=r.codprestamo  and  r.fecha= @fecbucket     --@fecante  --- FECHA DE clasificacion por buckets                    
where --r.fecha in (@fecante)   and 
c.codoficina not in('999','97','230','231')                  
group by r.fecha,c.codprestamo, r.nrodiasatraso, c.Cancelacion,c.PaseCastigado




/*CALCULO DE EPRC */                  
                  
-----SALDO EPRC --- ptmos LIQUIDADOS 
select c.fechaCorte, c.codprestamo,  c.Cancelacion, c.Desembolso , b.nrodiasatraso
into #bucket_liq
from tcspadroncarteradet c with(nolock)
left join #bucket b with (nolock) on c.codprestamo=b.codprestamo
where (c.Cancelacion>= @fecini --> ptmos liquidados                   
and c.Cancelacion <= @fecha)   and
--Desembolso >@fecante and
c.codoficina not in('999','97','230','231') 
	

----declare @eprLiqui table(fecha smalldatetime,EPRliquidado money)      
--CREATE TABLE #eprLiqui (fecha smalldatetime,EPRliquidado money, eprc_0_119_liquidado money, eprc_120_liquidado money)                 
--insert into #eprLiqui                  
select @fecha fecha,isnull(sum(r.eprc_total),0) EPRliquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso = 0 THEN r.eprc_total ELSE 0 END), 0) AS eprc_0_liquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 1 and c.nrodiasatraso <= 7 THEN r.eprc_total ELSE 0 END), 0) AS eprc_1_7_liquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 8 and c.nrodiasatraso <= 15 THEN r.eprc_total ELSE 0 END), 0) AS eprc_8_15_liquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 16 and c.nrodiasatraso <= 21 THEN r.eprc_total ELSE 0 END), 0) AS eprc_16_21_liquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 22 and c.nrodiasatraso <= 30 THEN r.eprc_total ELSE 0 END), 0) AS eprc_22_30_liquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 31 and c.nrodiasatraso <= 60 THEN r.eprc_total ELSE 0 END), 0) AS eprc_31_60_liquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 61 and c.nrodiasatraso <= 90 THEN r.eprc_total ELSE 0 END), 0) AS eprc_61_90_liquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 91 and c.nrodiasatraso <= 120 THEN r.eprc_total ELSE 0 END), 0) AS eprc_91_120_liquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 121 and c.nrodiasatraso <= 150 THEN r.eprc_total ELSE 0 END), 0) AS eprc_121_150_liquidado,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 151 and c.nrodiasatraso <= 180 THEN r.eprc_total ELSE 0 END), 0) AS eprc_151_180_liquidado,
--isnull(SUM(CASE WHEN r.nrodiasatraso <= 119 THEN r.eprc_total ELSE 0 END), 0) AS eprc_0_119_liquidado, -- EPRC con días de atraso <= 119
isnull(SUM(CASE WHEN c.nrodiasatraso >= 181 THEN r.eprc_total ELSE 0 END), 0) AS eprc_181_liquidado   -- EPRC con días de atraso >= 181
,isnull(SUM(CASE WHEN c.nrodiasatraso IS NULL THEN r.eprc_total ELSE 0 END), 0) AS eprc_new_liquidado
into #eprLiqui
from #bucket_liq c with(nolock)                  
inner join #reserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.Cancelacion-1                  
--where (Cancelacion>= @fecini --> ptmos liquidados                   
--and Cancelacion <= @fecha)                  
--and c.codoficina not in('999','97','230','231')                  

--select * from #eprLiqui 


--SET @T2=GETDATE()            
--PRINT '1 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()         



------ buckets de castigados
----- Esto es necesario para considerar castigados que fueron desembolsados el mismo mes, si ocurren estos casos
select c.fechaCorte, c.codprestamo,  c.PaseCastigado, c.Desembolso , b.nrodiasatraso
into #bucket_cast
from tcspadroncarteradet c with(nolock)
left join #bucket b with (nolock) on c.codprestamo=b.codprestamo
where (c.PaseCastigado>=@fecini -->ptmos castigados en el periodo evaluado                  
and c.PaseCastigado<=@fecha ) 
and c.codoficina not in('999','97','230','231') 


         


                  
-----SALDO EPRC ---- ptmos CASTIGADOS                  
----declare @eprCastigado table (fecha smalldatetime,EPRcastigo money)    
--CREATE TABLE #eprCastigado (fecha smalldatetime,EPRcastigo money, eprc_0_119_castigo money, eprc_120_castigo money)               
--insert into #eprCastigado                  
select @fecha fecha,isnull(sum(r.eprc_total),0) EPRcastigo
,isnull(SUM(CASE WHEN c.nrodiasatraso = 0 THEN r.eprc_total ELSE 0 END), 0) AS eprc_0_castigo,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 1 and c.nrodiasatraso <= 7 THEN r.eprc_total ELSE 0 END), 0) AS eprc_1_7_castigo,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 8 and c.nrodiasatraso <= 15 THEN r.eprc_total ELSE 0 END), 0) AS eprc_8_15_castigo,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 16 and c.nrodiasatraso <= 21 THEN r.eprc_total ELSE 0 END), 0) AS eprc_16_21_castigo,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 22 and c.nrodiasatraso <= 30 THEN r.eprc_total ELSE 0 END), 0) AS eprc_22_30_castigo,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 31 and c.nrodiasatraso <= 60 THEN r.eprc_total ELSE 0 END), 0) AS eprc_31_60_castigo,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 61 and c.nrodiasatraso <= 90 THEN r.eprc_total ELSE 0 END), 0) AS eprc_61_90_castigo,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 91 and c.nrodiasatraso <= 120 THEN r.eprc_total ELSE 0 END), 0) AS eprc_91_120_castigo,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 121 and c.nrodiasatraso <= 150 THEN r.eprc_total ELSE 0 END), 0) AS eprc_121_150_castigo,
isnull(SUM(CASE WHEN c.nrodiasatraso >= 151 and c.nrodiasatraso <= 180 THEN r.eprc_total ELSE 0 END), 0) AS eprc_151_180_castigo,
--isnull(SUM(CASE WHEN r.nrodiasatraso <= 119 THEN r.eprc_total ELSE 0 END), 0) AS eprc_0_119_castigo, -- EPRC con días de atraso <= 119
isnull(SUM(CASE WHEN c.nrodiasatraso >= 181 THEN r.eprc_total ELSE 0 END), 0) AS eprc_181_castigo   -- EPRC con días de atraso >= 181
,isnull(SUM(CASE WHEN c.nrodiasatraso IS NULL THEN r.eprc_total ELSE 0 END), 0) AS eprc_new_castigado
into #eprCastigado
from #bucket_cast c with(nolock)                  
inner join #reserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.PaseCastigado-1                  
--where (PaseCastigado>=@fecini -->ptmos castigados en el periodo evaluado                  
--and PaseCastigado<=@fecha )                  
--and c.codoficina not in('999','97','230','231')                  

--select * from #eprCastigado

      
--SET @T2=GETDATE()            
--PRINT '2 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   

-------- para optimizar el left join, se crea una temporal de los datos de reserva a la fecha 
select fecha, r.codprestamo,nrodiasatraso, r.eprc_total ,c.codoficina
into #reserva_fecha
from #reserva r with (nolock) 
inner join tcspadroncarteradet c with(nolock) on c.codprestamo=r.codprestamo  and  r.fecha=@fecha 
where --r.fecha =@fecha --or  r.fecha =@fecante
c.codoficina not in('999','97','230','231') 

 --select * from #reserva_fecha
-- select top 3 * from tcspadroncarteradet
                 
-----EPRC al dia de consulta y al inicio del mes---                  
----declare @eprc table (fecha smalldatetime,fech smalldatetime,eprc money)    
--CREATE TABLE #eprc  (fecha smalldatetime,fech smalldatetime,eprc money, eprc_0_119 money, eprc_120 money)                 
--insert into #eprc                  
select 
	@fecha fecha,r.fecha fech,
	sum(r.eprc_total) eprc,
	isnull(SUM(CASE WHEN c.nrodiasatraso = 0 THEN r.eprc_total ELSE 0 END), 0) AS eprc_0,
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 1 and c.nrodiasatraso <= 7 THEN r.eprc_total ELSE 0 END), 0) AS eprc_1_7,
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 8 and c.nrodiasatraso <= 15 THEN r.eprc_total ELSE 0 END), 0) AS eprc_8_15,
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 16 and c.nrodiasatraso <= 21 THEN r.eprc_total ELSE 0 END), 0) AS eprc_16_21,
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 22 and c.nrodiasatraso <= 30 THEN r.eprc_total ELSE 0 END), 0) AS eprc_22_30,
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 31 and c.nrodiasatraso <= 60 THEN r.eprc_total ELSE 0 END), 0) AS eprc_31_60,
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 61 and c.nrodiasatraso <= 90 THEN r.eprc_total ELSE 0 END), 0) AS eprc_61_90,
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 91 and c.nrodiasatraso <= 120 THEN r.eprc_total ELSE 0 END), 0) AS eprc_91_120,
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 121 and c.nrodiasatraso <= 150 THEN r.eprc_total ELSE 0 END), 0) AS eprc_121_150,
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 151 and c.nrodiasatraso <= 180 THEN r.eprc_total ELSE 0 END), 0) AS eprc_151_180,
	isnull(SUM(CASE WHEN r.nrodiasatraso <= 119 THEN r.eprc_total ELSE 0 END), 0) AS eprc_0_119, -- EPRC con días de atraso <= 119
	isnull(SUM(CASE WHEN c.nrodiasatraso >= 181 THEN r.eprc_total ELSE 0 END), 0) AS eprc_181   -- EPRC con días de atraso >= 181
	,isnull(SUM(CASE WHEN c.nrodiasatraso IS NULL THEN r.eprc_total ELSE 0 END), 0) AS eprc_new
	--sum(case when r.nrodiasatraso <= 119 then r.eprc_total else 0 end) as eprc_0_119,
	--sum(case when r.nrodiasatraso >= 120 then r.eprc_total else 0 end) as eprc_120
into #eprc
from #reserva_fecha r with (nolock)                  
left join #bucket c with(nolock) on c.codprestamo=r.codprestamo --and r.fecha=c.fecha                  
--where (r.fecha = @fecha --- FECHA DE CONSULTA                  
--or r.fecha=@fecante )-- fecha fin de mes anterior         
where r.fecha in (@fecha,@fecante)      
--and c.codoficina not in('999','97','230','231')                  
group by r.fecha    

--select * from #eprc



----SET @T2=GETDATE()            
----PRINT '3 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
----SET @T1=GETDATE()                   
                  
----declare @pcsEpr table  (fechacorte smalldatetime--,saldoEPRCFin money,saldoEPRCini money ,EPRCliqui money, EPRCcastigado money                  
----       ,GastoEPRC money)                     
----insert into @pcsEpr                      
--CREATE TABLE #pcsEpr (fechacorte smalldatetime, GastoEPRC money, GastoEPRC_0_119 money, GastoEPRC_120 money)
                     
--insert into #pcsEpr                      
       
select @fecha 'fecha'  
-----gasto epcr total                
,sum(case when p.fech=@fecha then p.eprc else 0 end) - sum(case when p.fech=@fecante then p.eprc else 0 end) 
+ l.EPRliquidado + c.EPRcastigo as GastoEPRC,

sum(case when p.fech=@fecha then p.eprc else 0 end) EPRC_fecha,

 - sum(case when p.fech=@fecante then p.eprc else 0 end) 
 as EPRC_fechacante,

  c.EPRcastigo as EPRC_cast,

 l.EPRliquidado  as EPRC_liqui,

------ gasto epcr 0

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_0 ELSE 0 END) + (l.eprliquidado))--+c.eprc_0_castigo --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_0 ELSE 0 END)) GastoEPRC_0,

------ gasto epcr 1 a 7

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_1_7 ELSE 0 END)) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_1_7 ELSE 0 END)) GastoEPRC_1_7,

------ gasto epcr 8 a 15

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_8_15 ELSE 0 END)) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_8_15 ELSE 0 END)) GastoEPRC_8_15,

------ gasto epcr 16 a 21

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_16_21 ELSE 0 END)) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_16_21 ELSE 0 END)) GastoEPRC_16_21,

------ gasto epcr 22 a 30

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_22_30 ELSE 0 END)) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_22_30 ELSE 0 END)) GastoEPRC_22_30,

------ gasto epcr 31 a 60

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_31_60 ELSE 0 END)) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_31_60 ELSE 0 END)) GastoEPRC_31_60,

------ gasto epcr 61 a 90

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_61_90 ELSE 0 END)) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_61_90 ELSE 0 END)) GastoEPRC_61_90,

------ gasto epcr 91 a 120

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_91_120 ELSE 0 END)) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_91_120 ELSE 0 END)) GastoEPRC_91_120,

------ gasto epcr 121 a 150

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_121_150 ELSE 0 END) ) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_121_150 ELSE 0 END)) GastoEPRC_121_150,

------ gasto epcr 151 a 180

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_151_180 ELSE 0 END)) + (c.EPRcastigo) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_151_180 ELSE 0 END)) GastoEPRC_151_180,

---- nuevos creditos desde el cierre del mes

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_new ELSE 0 END)) --+ (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_new ELSE 0 END)) GastoEPRC_new


------ gasto epcr 119

,(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_0_119 ELSE 0 END) + (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_0_119 ELSE 0 END)) GastoEPRC_0_119


-------- gasto epcr 120+
--(SUM(CASE WHEN p.fech=@fecha THEN p.eprc_120 ELSE 0 END) + (c.EPRcastigo))--+ (l.EPRliquidado) + (c.EPRcastigo))
--- (SUM(CASE WHEN p.fech=@fecante THEN p.eprc_120 ELSE 0 END)) as GastoEPRC_120

into #pcsEpr
from #eprLiqui l   WITH(NOLOCK)               
left outer join #eprCastigado c WITH(NOLOCK)on l.fecha=c.fecha                  
left outer join #eprc p WITH(NOLOCK)on p.fecha=l.fecha                  
group by c.EPRcastigo,l.EPRliquidado,l.eprc_0_liquidado,c.eprc_0_castigo                  
  
	
--select * from #pcsEpr



-------- >>>>> Para insertar solo el EPRC:
delete  FNMGConsolidado.dbo.tCaReporteDiarioEPRC where fecha=@fecha  --comentar para ejecutar ----Se comenta para modificar la tabla                         
insert into FNMGConsolidado.dbo.tCaReporteDiarioEPRC   --comentar para ejecutar ----Se comenta para no insertar valores a la tabla                  
              
select @fecha fechacorte,dbo.fdufechaaperiodo(fecha) periodo                
,isnull(gastoEPRC,0) EPRC
,Null EPRC_0_119
,Null EPRC_120
, isnull(GastoEPRC_new,0) EPRC_new
,isnull(GastoEPRC_0,0) EPRC_0, isnull(GastoEPRC_1_7,0) EPRC_1_7  
, isnull(GastoEPRC_8_15,0) EPRC_8_15, isnull(GastoEPRC_16_21,0) EPRC_16_21, isnull(GastoEPRC_22_30,0) EPRC_22_30
, isnull(GastoEPRC_31_60,0) EPRC_31_60, isnull(GastoEPRC_61_90,0) EPRC_61_90, isnull(GastoEPRC_91_120,0) EPRC_91_120
, isnull(GastoEPRC_121_150,0) EPRC_121_150, isnull(GastoEPRC_151_180,0) EPRC_151_180

     from #pcsEpr with(nolock)   


--select * from FNMGConsolidado.dbo.tCaReporteDiarioEPRC order by fecha desc

drop table #bucket_liq
drop table #bucket_cast
drop table #bucket
drop table #reserva_fecha
DROP TABLE #eprLiqui  
DROP TABLE #eprCastigado  
DROP TABLE #eprc 
drop table #pcsEpr 
drop table #reserva



---exec pcsFNMGreporteDiarioV3 '20251231'
          

		


END      
      
GO