SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/****** Object:  StoredProcedure [dbo].[pcsFNMG_EPRC_LiqCast]    Script Date: 17/06/2025 09:42:06 am ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO



CREATE PROCEDURE [dbo].[pcsFNMG_EPRC_LiqCast]
    @fecha smalldatetime -- Parámetro para la fecha de corte
AS
BEGIN
    SET NOCOUNT ON;

		/*---calculo para el reporte diario:   guarda el [EPRC liquidado y castigado del fin de mes], para calculos del Gasto o Delta del EPRC   >>  FNMGConsolidado.dbo.tCaRepDiarioEPRC_LiqCast_FinMes ---*/  

	--- 2025.06.19  -- Sil --  datos de EPRC liquidados y castigados a fin de mes, son necesarios para 
	--- 2026.01.22   Sil: Se ajusta para la nueva reserva IFRS9 (nuevo calculo de EPRC)   



	--declare @fecha smalldatetime  ---LA FECHA DE CORTE                  
	--select @fecha='20260131'--fechaconsolidacion from vcsfechaconsolidacion 

    DECLARE @fecini smalldatetime;
    SET @fecini = CAST(dbo.fdufechaaperiodo(@fecha) + '01' AS smalldatetime);
    
    DECLARE @fecante smalldatetime;
    SET @fecante = CAST(dbo.fdufechaaperiodo(@fecha) + '01' AS smalldatetime) - 1;






----- Se unen las reservas  IFRS9 de Consumo y Productivo
CREATE TABLE #reserva (fecha smalldatetime,codprestamo varchar(25), Codproducto int, nrodiasatraso int,   eprc_total money,   garantia money)                 
  
	insert into #reserva
	select 
		rP.fecha,
		rP.codprestamo,
		rP.Codproducto,
		rP.Dias_Atraso_1,
		rP.reserva,
		rP.montoGarantia
	from tCsCaProReservaIFRS9 rP   with(nolock)         ----------------- >> reserva  Productivo (170, 172)
	where --fecha='20260118'
	rP.fecha>=@fecante and  rP.fecha<=@fecha
	--and Dias_Atraso_1 <> PromedioDiasAtraso


	insert into #reserva
	select 	
		rC.fecha,
		rC.codprestamo,
		rC.Codproducto,
		rC.nrodiasatraso,
		rC.eprc_total,
		rC.MontoGarLiq
	from tCsCaConsReservaIFRS9 rC   with(nolock)          ----------------- >> reserva  Consumo  (370)
	where --fecha='20260118'
	rC.fecha>=@fecante and  rC.fecha<=@fecha





--	select  montoGarantia, * from tCsCaProReservaIFRS9 with(nolock) where codprestamo='321-170-06-09-22238' order by fecha desc
--	select top 5 MontoGarLiq, * from tCsCaConsReservaIFRS9 with(nolock) where codprestamo='321-170-06-09-22238'



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
----- ajuste al 03.02.2026    Sil         --- el EPRC castigado se sustituye por   Saldo insoluto despues del castigo =  Saldo insoluto previo castigo - Garantia

		--select @fecha fecha, r.codprestamo, isnull(r.eprc_total,0) EPRcastigo, d.saldocapital, d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido saldo_insoluto
		--,isnull(r.garantia,0) garantias
		----isnull(SUM(CASE WHEN c.secuenciacliente = 1 THEN r.eprc_total ELSE 0 END), 0) AS eprc_C1_castigo,
		----isnull(SUM(CASE WHEN c.secuenciacliente >= 2 THEN r.eprc_total ELSE 0 END), 0) AS 'eprc_C2+_castigo'
		----into #eprCastigado_ciclos
		--from tcspadroncarteradet c with(nolock)                  
		--inner join #reserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.PaseCastigado-1 
		--inner join tCsCarteradet d with(nolock) on c.codprestamo=d.codprestamo and d.fecha=c.PaseCastigado-1
		--where (PaseCastigado>=@fecini -->ptmos castigados en el periodo evaluado                  
		--and PaseCastigado<=@fecha )                  
		--and c.codoficina not in('999','97','230','231')     



		--		select  d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido,  d.saldocapital , d.interesvigente,d.interesvencido,d.moratoriovigente,d.moratoriovencido, *  
		--		from	tCsCarteradet d with(nolock)
		--where codprestamo='498-170-06-06-00080'
		--order by fecha desc



select @fecha fecha,
--isnull(sum(r.eprc_total),0) EPRcastigo,
--isnull(SUM(CASE WHEN c.secuenciacliente = 1 THEN r.eprc_total ELSE 0 END), 0) AS eprc_C1_castigo,
--isnull(SUM(CASE WHEN c.secuenciacliente >= 2 THEN r.eprc_total ELSE 0 END), 0) AS 'eprc_C2+_castigo'
isnull(sum(d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido),0) EPRcastigo,
isnull(SUM(CASE WHEN c.secuenciacliente = 1 THEN d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido ELSE 0 END), 0) AS eprc_C1_castigo,
isnull(SUM(CASE WHEN c.secuenciacliente >= 2 THEN d.saldocapital + d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido ELSE 0 END), 0) AS 'eprc_C2+_castigo'
into #eprCastigado_ciclos
from tcspadroncarteradet c with(nolock)                  
inner join #reserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.PaseCastigado-1      
inner join tCsCarteradet d with(nolock) on c.codprestamo=d.codprestamo and d.fecha=c.PaseCastigado-1
where (PaseCastigado>=@fecini -->ptmos castigados en el periodo evaluado                  
and PaseCastigado<=@fecha )                  
and c.codoficina not in('999','97','230','231')      

--select * from #eprCastigado_ciclos

-------Temporal, los castigados puede que fueran cargados días despues a Alemania
------select fecha, EPRcastigo, eprc_C1_castigo, [eprc_C2+_castigo] from #eprCastigado_ciclos
----update  #eprCastigado_ciclos
----set EPRcastigo = 0, eprc_C1_castigo = 0, [eprc_C2+_castigo]=0
----where fecha='20250731'

--select * from #eprCastigado_ciclos

-------- para optimizar el left join, se crea una temporal de los datos de reserva a la fecha 
--------select fecha, r.codprestamo,nrodiasatraso, r.eprc_total ,c.codoficina
--------into #reserva_fecha
--------from #reserva r with (nolock) 
--------inner join tcspadroncarteradet c with(nolock) on c.codprestamo=r.codprestamo  and  r.fecha=@fecha 
--------where --r.fecha =@fecha --or  r.fecha =@fecante
--------c.codoficina not in('999','97','230','231') 

-------- --select * from #reserva_fecha


--------------- ciclos vigentes
--------select
--------	@fecha fecha,r.fecha fech,
--------	sum(r.eprc_total) eprc,
--------	isnull(SUM(CASE WHEN c.secuenciacliente = 1 THEN r.eprc_total ELSE 0 END), 0) AS eprc_C1,
--------	isnull(SUM(CASE WHEN c.secuenciacliente >= 2  THEN r.eprc_total ELSE 0 END), 0) AS 'eprc_C2+'
--------into #eprc_ciclos
--------from #reserva_fecha r with (nolock)                  
--------left join #ciclos c with(nolock) on c.codprestamo=r.codprestamo 
----------where --p.ciclo=1 and
----------r.fecha in (@fecha
----------,@fecante
----------)      
----------and c.codoficina not in('999','97','230','231')                  
--------group by r.fecha

--------select * from #eprc_ciclos




-----------------
------ Suma Final de Ciclos: 


-------- >>>>> Para insertar solo el EPRC:
delete  FNMGConsolidado.dbo.tCaRepDiarioEPRC_LiqCast_FinMes where fecha=@fecha  --comentar para ejecutar ----Se comenta para modificar la tabla                         
insert into FNMGConsolidado.dbo.tCaRepDiarioEPRC_LiqCast_FinMes   --comentar para ejecutar ----Se comenta para no insertar valores a la tabla                  
select @fecha 'fechacorte'         

-----gasto epcr total                
--,sum(case when p.fech=@fecha then p.eprc else 0 end) - sum(case when p.fech=@fecante then p.eprc else 0 end) 
--+ l.EPRliquidado + c.EPRcastigo as GastoEPRC

, isnull(l.EPRliquidado,0) EPRCLiquidado
, isnull(c.EPRcastigo,0)   EPRCCastigado
------ gasto epcr C1

,isnull(l.eprc_C1_liquidado,0) + isnull(c.eprc_C1_castigo,0)  'EPRC_C1_LiqCast'

------ gasto epcr C2+

,isnull(l.[eprc_C2+_liquidado],0) + isnull(c.[eprc_C2+_castigo],0)  'EPRC_C2+_LiqCast'

--into #pcsEpr_ciclos 
from #eprLiqui_ciclos l   WITH(NOLOCK)               
left outer join #eprCastigado_ciclos c WITH(NOLOCK)on l.fecha=c.fecha                  
--left outer join #eprc_ciclos p WITH(NOLOCK)on p.fecha=l.fecha                  
group by c.eprc_C1_castigo,l.eprc_C1_liquidado, l.[eprc_C2+_liquidado], c.[eprc_C2+_castigo],l.EPRliquidado,c.EPRcastigo  --,l.eprc_0_liquidado,c.eprc_0_castigo  






drop table #ciclos
----drop table #reserva_fecha
DROP TABLE #eprLiqui_ciclos  
DROP TABLE #eprCastigado_ciclos  
----DROP TABLE #eprc_ciclos 
DROP TABLE #reserva



--	declare @fecha smalldatetime  ---LA FECHA DE CORTE                  
--	select @fecha=fechaconsolidacion from vcsfechaconsolidacion 

--    DECLARE @fecante smalldatetime;
--    SET @fecante = CAST(dbo.fdufechaaperiodo(@fecha) + '01' AS smalldatetime) - 1;

--select * from FNMGConsolidado.dbo.tCaRepDiarioEPRC_LiqCast_FinMes
--where fecha=@fecha --@fecante

--select 7214089.8416- 4165672.04

------EPRC anterior:
----fecha	EPRCLiquidado	EPRCCastigado	EPRC_C1_LiqCast	EPRC_C2+_LiqCast
----2026-01-31 00:00:00	794066.0058	4866961.9375	1176945.6757	4484082.2676


--exec pcsFNMG_EPRC_LiqCast '20260131'

END      
      
GO