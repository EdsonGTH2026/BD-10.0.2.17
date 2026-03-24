SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[pcsFNMGReporteDiarioV2]
    @fecha smalldatetime -- Parámetro para la fecha de corte
AS
BEGIN
    SET NOCOUNT ON;

 --   declare @fecha smalldatetime  ---LA FECHA DE CORTE                  
	--select @fecha=fechaconsolidacion from vcsfechaconsolidacion 

    DECLARE @fecini smalldatetime;
    SET @fecini = CAST(dbo.fdufechaaperiodo(@fecha) + '01' AS smalldatetime);
    
    DECLARE @fecante smalldatetime;
    SET @fecante = CAST(dbo.fdufechaaperiodo(@fecha) + '01' AS smalldatetime) - 1;


/*CALCULO DE EPRC */                  
                  
---SALDO EPRC --- ptmos LIQUIDADOS                  
--declare @eprLiqui table(fecha smalldatetime,EPRliquidado money)      
CREATE TABLE #eprLiqui (fecha smalldatetime,EPRliquidado money, eprc_0_119_liquidado money, eprc_120_liquidado money)                 
insert into #eprLiqui                  
select @fecha fecha,isnull(sum(r.eprc_total),0) EPRliquidado,
isnull(SUM(CASE WHEN r.nrodiasatraso <= 119 THEN r.eprc_total ELSE 0 END), 0) AS eprc_0_119_liquidado, -- EPRC con días de atraso <= 119
isnull(SUM(CASE WHEN r.nrodiasatraso >= 120 THEN r.eprc_total ELSE 0 END), 0) AS eprc_120_liquidado   -- EPRC con días de atraso >= 120
from tcspadroncarteradet c with(nolock)                  
inner join tCsCarteraReserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.Cancelacion-1                  
where (Cancelacion>= @fecini --> ptmos liquidados                   
and Cancelacion <= @fecha)                  
and c.codoficina not in('999','97','230','231')                  

--select * from #eprLiqui 


--SET @T2=GETDATE()            
--PRINT '1 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()         

                  
---SALDO EPRC ---- ptmos CASTIGADOS                  
--declare @eprCastigado table (fecha smalldatetime,EPRcastigo money)    
CREATE TABLE #eprCastigado (fecha smalldatetime,EPRcastigo money, eprc_0_119_castigo money, eprc_120_castigo money)               
insert into #eprCastigado                  
select @fecha id,isnull(sum(r.eprc_total),0) EPRcastigo,
isnull(SUM(CASE WHEN r.nrodiasatraso <= 119 THEN r.eprc_total ELSE 0 END), 0) AS eprc_0_119_castigo, -- EPRC con días de atraso <= 119
isnull(SUM(CASE WHEN r.nrodiasatraso >= 120 THEN r.eprc_total ELSE 0 END), 0) AS eprc_120_castigo
from tcspadroncarteradet c with(nolock)                  
inner join tCsCarteraReserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.PaseCastigado-1                  
where (PaseCastigado>=@fecini -->ptmos castigados en el periodo evaluado                  
and PaseCastigado<=@fecha )                  
and c.codoficina not in('999','97','230','231')                  



--select * from #eprCastigado      
--SET @T2=GETDATE()            
--PRINT '2 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()   
                 
---EPRC al dia de consulta y al inicio del mes---                  
--declare @eprc table (fecha smalldatetime,fech smalldatetime,eprc money)    
CREATE TABLE #eprc  (fecha smalldatetime,fech smalldatetime,eprc money, eprc_0_119 money, eprc_120 money)                 
insert into #eprc                  
select 
	@fecha fecha,r.fecha fech,
	sum(r.eprc_total) eprc,
	sum(case when r.nrodiasatraso <= 119 then r.eprc_total else 0 end) as eprc_0_119,
	sum(case when r.nrodiasatraso >= 120 then r.eprc_total else 0 end) as eprc_120
from tCsCarteraReserva r with (nolock)                  
inner join tcscartera c with(nolock) on c.codprestamo=r.codprestamo and r.fecha=c.fecha                  
--where (r.fecha = @fecha --- FECHA DE CONSULTA                  
--or r.fecha=@fecante )-- fecha fin de mes anterior         
where r.fecha in (@fecha,@fecante)      
and c.codoficina not in('999','97','230','231')                  
group by r.fecha    

--select * from #eprc
  
--SET @T2=GETDATE()            
--PRINT '3 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))            
--SET @T1=GETDATE()                   
                  
--declare @pcsEpr table  (fechacorte smalldatetime--,saldoEPRCFin money,saldoEPRCini money ,EPRCliqui money, EPRCcastigado money                  
--       ,GastoEPRC money)                     
--insert into @pcsEpr                      
CREATE TABLE #pcsEpr (fechacorte smalldatetime, GastoEPRC money, GastoEPRC_0_119 money, GastoEPRC_120 money)
                     
insert into #pcsEpr                      
select @fecha fecha         

-----gasto epcr total                
,sum(case when p.fech=@fecha then p.eprc else 0 end) - sum(case when p.fech=@fecante then p.eprc else 0 end) 
+ l.EPRliquidado + c.EPRcastigo as GastoEPRC,


------ gasto epcr 119

(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_0_119 ELSE 0 END) + (l.EPRliquidado)) --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.eprc_0_119 ELSE 0 END)) GastoEPRC_0_119,


------ gasto epcr 120+
(SUM(CASE WHEN p.fech=@fecha THEN p.eprc_120 ELSE 0 END) + (c.EPRcastigo))--+ (l.EPRliquidado) + (c.EPRcastigo))
- (SUM(CASE WHEN p.fech=@fecante THEN p.eprc_120 ELSE 0 END)) as GastoEPRC_120


from #eprLiqui l   WITH(NOLOCK)               
left outer join #eprCastigado c WITH(NOLOCK)on l.fecha=c.fecha                  
left outer join #eprc p WITH(NOLOCK)on p.fecha=l.fecha                  
group by c.EPRcastigo,l.EPRliquidado                  
  
	
------select * from #pcsEpr



-------- >>>>> Para insertar solo el EPRC:
delete  FNMGConsolidado.dbo.tCaReporteDiarioEPRC where fecha=@fecha  --comentar para ejecutar ----Se comenta para modificar la tabla                         
insert into FNMGConsolidado.dbo.tCaReporteDiarioEPRC   --comentar para ejecutar ----Se comenta para no insertar valores a la tabla                  
              
select @fecha fechacorte,dbo.fdufechaaperiodo(fechacorte) periodo                
,isnull(gastoEPRC,0) EPRC,isnull(GastoEPRC_0_119,0) EPRC_0_119, isnull(GastoEPRC_120,0) EPRC_120  
, NULL EPRC_new
,NULL EPRC_0, NULL EPRC_1_7  
, NULL EPRC_8_15, NULL EPRC_16_21, NULL EPRC_22_30
, NULL EPRC_31_60, NULL EPRC_61_90, NULL EPRC_91_120
, NULL EPRC_121_150, NULL EPRC_151_180
     from #pcsEpr with(nolock)   

DROP TABLE #eprLiqui  
DROP TABLE #eprCastigado  
DROP TABLE #eprc 
drop table #pcsEpr 
               
               
--select * from FNMGConsolidado.dbo.tCaReporteDiarioEPRC




END      
      
GO