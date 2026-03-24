SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[pcsFNMGReporteDiario_eprcXciclos]
    @fecha smalldatetime -- Parámetro para la fecha de corte
AS
BEGIN
    SET NOCOUNT ON;

	
	/*---calculo para el reporte diario:   buckets de EPRC X ciclo   >>  FNMGConsolidado.dbo.tCaReporteDiarioEPRC_ciclos ---*/  

	--- 2025.06.19  -- Sil -- Agrego tabla de eprc por ciclos
	--- 2026.01.22   Sil: Se ajusta para la nueva reserva IFRS9 (nuevo calculo de EPRC)   - 


 --   declare @fecha smalldatetime  ---LA FECHA DE CORTE                  
	--select @fecha=fechaconsolidacion from vcsfechaconsolidacion 

    DECLARE @fecini smalldatetime;
    SET @fecini = CAST(dbo.fdufechaaperiodo(@fecha) + '01' AS smalldatetime);
    
    DECLARE @fecante smalldatetime;
    SET @fecante = CAST(dbo.fdufechaaperiodo(@fecha) + '01' AS smalldatetime) - 1;






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







------ Clasificacion por ciclos
select 
	r.fecha fecha,
	c.codprestamo,
	c.Cancelacion,
	c.PaseCastigado,
	r.nrodiasatraso
	,c.secuenciacliente
into #ciclos
from #reserva r with (nolock)                  
inner join tcspadroncarteradet c with(nolock) on c.codprestamo=r.codprestamo  and  r.fecha=@fecha  --- FECHA DE clasificacion por buckets                    
where --r.fecha in (@fecante)   and 
c.codoficina not in('999','97','230','231')                  
group by r.fecha,c.codprestamo, r.nrodiasatraso, c.Cancelacion,c.PaseCastigado,c.secuenciacliente



-----SALDO EPRC --- ptmos por ciclo  
-------------------------------------
------- ciclos liquidados

		--select @fecha fecha,r.codprestamo, isnull(r.eprc_total,0) EPRliquidado,
		--c.secuenciacliente AS ciclo
		----into #eprLiqui_ciclos
		--from tcspadroncarteradet c with(nolock)                  
		--inner join #reserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.Cancelacion-1  
		----inner join [10.0.2.14].finmas.dbo.tcaprestamos p with(nolock) on p.codprestamo=r.codprestamo
		--where (Cancelacion>= @fecini --> ptmos liquidados                   
		--and Cancelacion <= @fecha)                  
		--and c.codoficina not in('999','97','230','231')


select @fecha fecha,isnull(sum(r.eprc_total),0) EPRliquidado,
isnull(SUM(CASE WHEN c.secuenciacliente = 1 THEN r.eprc_total ELSE 0 END), 0) AS eprc_C1_liquidado,
isnull(SUM(CASE WHEN c.secuenciacliente >= 2 THEN r.eprc_total ELSE 0 END), 0) AS 'eprc_C2+_liquidado'
into #eprLiqui_ciclos
from tcspadroncarteradet c with(nolock)                  
inner join #reserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.Cancelacion-1  
--inner join [10.0.2.14].finmas.dbo.tcaprestamos p with(nolock) on p.codprestamo=r.codprestamo
where (Cancelacion>= @fecini --> ptmos liquidados                   
and Cancelacion <= @fecha)                  
and c.codoficina not in('999','97','230','231')  

--select * from #eprLiqui_ciclos


------- ciclos cancelados
select @fecha fecha,isnull(sum(r.eprc_total),0) EPRcastigo,
isnull(SUM(CASE WHEN c.secuenciacliente = 1 THEN r.eprc_total ELSE 0 END), 0) AS eprc_C1_castigo,
isnull(SUM(CASE WHEN c.secuenciacliente >= 2 THEN r.eprc_total ELSE 0 END), 0) AS 'eprc_C2+_castigo'
into #eprCastigado_ciclos
from tcspadroncarteradet c with(nolock)                  
inner join #reserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.PaseCastigado-1                  
where (PaseCastigado>=@fecini -->ptmos castigados en el periodo evaluado                  
and PaseCastigado<=@fecha )                  
and c.codoficina not in('999','97','230','231')      

--select * from #eprCastigado_ciclos


-------- para optimizar el left join, se crea una temporal de los datos de reserva a la fecha 
select fecha, r.codprestamo,nrodiasatraso, r.eprc_total ,c.codoficina
into #reserva_fecha
from #reserva r with (nolock) 
inner join tcspadroncarteradet c with(nolock) on c.codprestamo=r.codprestamo  and  r.fecha=@fecha 
where --r.fecha =@fecha --or  r.fecha =@fecante
c.codoficina not in('999','97','230','231') 

 --select * from #reserva_fecha


------- ciclos vigentes
select
	@fecha fecha,r.fecha fech,
	sum(r.eprc_total) eprc,
	isnull(SUM(CASE WHEN c.secuenciacliente = 1 THEN r.eprc_total ELSE 0 END), 0) AS eprc_C1,
	isnull(SUM(CASE WHEN c.secuenciacliente >= 2  THEN r.eprc_total ELSE 0 END), 0) AS 'eprc_C2+'
into #eprc_ciclos
from #reserva_fecha r with (nolock)                  
left join #ciclos c with(nolock) on c.codprestamo=r.codprestamo 
--where --p.ciclo=1 and
--r.fecha in (@fecha
--,@fecante
--)      
--and c.codoficina not in('999','97','230','231')                  
group by r.fecha

--select * from #eprc_ciclos




-----------------
------ Suma Final de Ciclos: 
select @fecha 'fechacorte'         

-----gasto epcr total                
--,sum(case when p.fech=@fecha then p.eprc else 0 end) - sum(case when p.fech=@fecante then p.eprc else 0 end) 
--+ l.EPRliquidado + c.EPRcastigo as GastoEPRC

------ gasto epcr C1

,(SUM(CASE WHEN p.fech = @fecha THEN p.eprc_C1 ELSE 0 END) + (l.eprc_C1_liquidado + c.eprc_C1_castigo))--+c.eprc_0_castigo --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN eprc_C1 ELSE 0 END)) GastoEPRC_C1

------ gasto epcr C2+

,(SUM(CASE WHEN p.fech = @fecha THEN p.[eprc_C2+] ELSE 0 END) + (l.[eprc_C2+_liquidado] + c.[eprc_C2+_castigo]))--+c.eprc_0_castigo --(c.EPRcastigo))
- (SUM(CASE WHEN p.fech = @fecante THEN p.[eprc_C2+] ELSE 0 END)) 'GastoEPRC_C2+'

into #pcsEpr_ciclos 
from #eprLiqui_ciclos l   WITH(NOLOCK)               
left outer join #eprCastigado_ciclos c WITH(NOLOCK)on l.fecha=c.fecha                  
left outer join #eprc_ciclos p WITH(NOLOCK)on p.fecha=l.fecha                  
group by c.eprc_C1_castigo,l.eprc_C1_liquidado, l.[eprc_C2+_liquidado], c.[eprc_C2+_castigo]  --,l.eprc_0_liquidado,c.eprc_0_castigo  


------ >>>>> Para insertar solo el EPRC:
delete  FNMGConsolidado.dbo.tCaReporteDiarioEPRC_ciclos where fecha=@fecha  --comentar para ejecutar ----Se comenta para modificar la tabla                         
insert into FNMGConsolidado.dbo.tCaReporteDiarioEPRC_ciclos   --comentar para ejecutar ----Se comenta para no insertar valores a la tabla                  
              
select @fecha fechacorte,dbo.fdufechaaperiodo(fechacorte) periodo                
,isnull(GastoEPRC_C1,0)+isnull([GastoEPRC_C2+],0) EPRC
,isnull(GastoEPRC_C1,0) EPRC_C1, isnull([GastoEPRC_C2+],0) 'EPRC_C2+'                 
     from #pcsEpr_ciclos with(nolock)   


drop table #ciclos
drop table #reserva_fecha
DROP TABLE #eprLiqui_ciclos  
DROP TABLE #eprCastigado_ciclos  
DROP TABLE #eprc_ciclos 
drop table #pcsEpr_ciclos 
drop table #reserva



--select * from FNMGConsolidado.dbo.tCaReporteDiarioEPRC_ciclos where fecha=@fecha
--order by fecha desc

--fecha	periodo	EPRC	EPRC_C1	EPRC_C2+
--2026-01-18 00:00:00	202601	15636448.9494	2851770.7875	12784678.1619
--2025-12-31 00:00:00	202512	28101961.6382	5554354.9299	22547606.7083
-- exec pcsFNMGReporteDiario_eprcXciclos '20251231'


END      
      
GO