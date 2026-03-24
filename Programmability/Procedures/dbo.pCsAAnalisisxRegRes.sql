SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--DROP PROC pCsAAnalisisxRegF
--EXEC pCsAAnalisisxRegF '20140312',''
 CREATE PROCEDURE [dbo].[pCsAAnalisisxRegRes]
                ( @Fecha      SMALLDATETIME ,
                  @CodOficina VARCHAR(300)  )
 AS
--  DECLARE @Fecha SMALLDATETIME
--    SET @Fecha = '20140313'
    
DECLARE @FechaIni SMALLDATETIME    
DECLARE @Periodo1 VARCHAR(6)      
DECLARE @FechaSig SMALLDATETIME    


    SET @Periodo1 = dbo.fduFechaATexto(@Fecha, 'AAAAMM')      
    SET @FechaIni = DateAdd(Day,1,DateAdd(Day, -1, Cast(@Periodo1 + '01' As SmallDateTime)))    
    print @FechaIni

set @FechaSig = @FechaIni
-- Crea tablas temporales
CREATE TABLE #CarteraVig( Zona CHAR(5), Nombre VARCHAR(50), SaldoCarteraVigente NUMERIC(16,2))
CREATE TABLE #EstimRec( Zona CHAR(5), Nombre VARCHAR(50), MontoCuota NUMERIC(16,2))
CREATE TABLE #PagosDia( Zona CHAR(5), Nombre VARCHAR(50), TotalPagosDia NUMERIC(16,2))
CREATE TABLE #DesemCancel( Zona CHAR(5), Nombre VARCHAR(50), DesembolsoCancelados NUMERIC(16,2))
CREATE TABLE #Desembolsos( Zona CHAR(5), Nombre VARCHAR(50), TotalMontoDesembolso NUMERIC(16,2))
CREATE TABLE #Resumen(Fecha SMALLDATETIME, Nombre VARCHAR(80), SaldoCarteraVigente NUMERIC(16,2), 
		MontoCuota NUMERIC(16,2), TotalPagosDia NUMERIC(16,2), DesembolsoCancelados NUMERIC(16,2), TotalMontoDesembolso NUMERIC(16,2))
    
WHILE @FechaSig <= @Fecha
   BEGIN



    
--1. Saldo de Cartera Vigente 
--*** CREATE TABLE #CarteraVig(Zona CHAR(5), Nombre VARCHAR(50), SaldoCarteraVigente NUMERIC(16,2))
INSERT INTO #CarteraVig
SELECT o.Zona, z.Nombre,
       sum(cd.saldocapital +cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) SaldoCarteraVigente
  FROM tCsCartera c WITH(NOLOCK)  
 INNER JOIN tCsCarteraDet cd WITH(NOLOCK) ON c.fecha = cd.fecha AND c.codprestamo=cd.codprestamo  
 INNER JOIN tClOficinas    o WITH(NOLOCK) ON cd.CodOficina = o.CodOficina
  LEFT OUTER JOIN tClZona  z WITH(NOLOCK) ON o.Zona        = z.Zona
 WHERE c.cartera IN ('ACTIVA')  
   AND c.Fecha = @FechaSig		-- @Fecha
   AND o.Tipo <> 'cerrada'
 GROUP BY o.Zona, z.Nombre

--2. Estimación de Recuperación (Pagos)- Son los pagos que se tienen programados para el día siguiente, durante el mes por día. solo para créditos vigentes? Sí, Para todos los créditos? Es decir que este programado su 2do pago o posteriores. Así es
--*** CREATE TABLE #EstimRec(Zona CHAR(5), Nombre VARCHAR(50), MontoCuota NUMERIC(16,2))
INSERT INTO #EstimRec
SELECT Zona, Nombre, --CuotasVenc.FechaVencimiento, 
       CuotasVenc.CAPI+CuotasVenc.INTE+CuotasVenc.INPE MontoCuota 
  FROM (Select Zona, Nombre,--Fecha, CodPrestamo, FechaVencimiento, 
               SUM(CAPI) AS CAPI, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(INVE) AS INVE 
		 From (select o.Zona, z.Nombre,--Fecha, FechaVencimiento, CodPrestamo,  
	  			      case CodConcepto when 'capi' then MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) else 0 end as CAPI, 
					  case CodConcepto when 'inte' then MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) else 0 end as INTE, 
				      case CodConcepto when 'inpe' then MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) else 0 end as INPE, 
					  case CodConcepto when 'inve' then MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) else 0 end as INVE
				 from tCsPadronPlanCuotas p WITH(NOLOCK) 
			    inner join tCsCartera     c WITH(NOLOCK) ON p.codprestamo = c.codprestamo and c.cartera IN ('ACTIVA') and p.FechaVencimiento = c.Fecha 
			    inner join tClOficinas    o WITH(NOLOCK) ON p.CodOficina = o.CodOficina
			     left outer join tClZona  z WITH(NOLOCK) ON o.Zona       = z.Zona
			    where EstadoCuota <> 'cancelado'
			      and p.FechaVencimiento >= @FechaIni and p.FechaVencimiento <= @FechaSig		--@Fecha
                  and o.Tipo <> 'cerrada'
			  ) A 
		 Group By Zona, Nombre --Fecha, FechaVencimiento, CodPrestamo
      ) CuotasVenc

--3. Recuperación Ejecutada - Son todos los pagos recibidos en el día, solo para créditos vigentes? Sí Para todos los créditos? Es decir que este programado su 2do pago o posteriores. Solo lo recuperado real
--***  CREATE TABLE #PagosDia(Zona CHAR(5), Nombre VARCHAR(50), TotalPagosDia NUMERIC(16,2))
 INSERT INTO #PagosDia
 SELECT o.zona, z.Nombre, sum(MontoTotalTran) TotalPagosDia
   FROM tCsTransaccionDiaria t WITH(NOLOCK) 
  INNER JOIN tCsCartera    c WITH(NOLOCK) ON c.codprestamo = t.codigocuenta  and c.fecha = t.fecha 
  INNER JOIN tClOficinas   o WITH(NOLOCK) ON t.CodOficina  = o.CodOficina
   LEFT OUTER JOIN tClZona z WITH(NOLOCK) ON o.Zona        = z.Zona
  WHERE t.Fecha  = @FechaSig		--@Fecha
    AND (t.descripciontran NOT LIKE 'CONDONACIONES%'  AND t.descripciontran NOT LIKE 'desembolso%')
    AND t.codsistema = 'CA' 
    AND o.Tipo <> 'cerrada'
  GROUP BY o.zona, z.Nombre
  
--4.Estimación de Desembolso - En esta parte tengo la pregunta de en base a que requieres la estimación?  Es en base a los cancelados? Con cuantos días de atraso al cancelar su crédito?. En la proyección por Asesor ( Renovaciones, tanto de las canceladas en el mes como en el histórico posible de clientes inactivos. +Meta mensual de la sucursal)
--drop table #DesemCancel
--*** CREATE TABLE #DesemCancel(Zona CHAR(5), Nombre VARCHAR(50), DesembolsoCancelados NUMERIC(16,2))
INSERT INTO #DesemCancel
SELECT o.zona, z.Nombre, SUM(Monto) DesembolsoCancelados
  FROM tCsPadronCarteraDet cd WITH(NOLOCK) 
 INNER JOIN tClOficinas     o WITH(NOLOCK) ON cd.CodOficina = o.CodOficina
  LEFT OUTER JOIN tClZona   z WITH(NOLOCK) ON o.Zona        = z.Zona
 WHERE EstadoCalculado = 'cancelado' 
   AND Cancelacion >= @FechaIni AND Cancelacion <= @FechaSig		--@Fecha
   AND o.Tipo <> 'cerrada'
 GROUP BY o.zona, z.Nombre

--5.Desembolso Ejecutado - Desembolsos de día. Sí
--*** CREATE TABLE #Desembolsos(Zona CHAR(5), Nombre VARCHAR(50), TotalMontoDesembolso NUMERIC(16,2))
INSERT INTO #Desembolsos
 SELECT o.zona, z.Nombre, sum(cd.MontoDesembolso) TotalMontoDesembolso
   FROM tCsCartera c  WITH(NOLOCK) 
  INNER JOIN tCsCarteraDet cd WITH(NOLOCK) ON c.fecha = cd.fecha AND c.codprestamo = cd.codprestamo  
  INNER JOIN tClOficinas    o WITH(NOLOCK) ON cd.CodOficina = o.CodOficina
   LEFT OUTER JOIN tClZona  z WITH(NOLOCK) ON o.Zona        = z.Zona
  WHERE c.Fecha >= @FechaIni AND c.Fecha <= @FechaSig		--@Fecha
    AND c.FechaDesembolso = @FechaSig		-- @Fecha
    AND o.Tipo <> 'cerrada'
  GROUP BY o.zona, z.Nombre


INSERT INTO #Resumen
SELECT Cast(@FechaSig As SmallDateTime) Fecha, ca.zona+' '+ca.Nombre Region, 
       isnull(ca.SaldoCarteraVigente,0)  CarteraVigente,
       isnull(er.MontoCuota,0)           EstimacionRecuperacion,
       isnull(pa.TotalPagosDia,0)        RecuperacionEjecutada,
       isnull(dc.DesembolsoCancelados,0) EstimacionDesembolso,
       isnull(de.TotalMontoDesembolso,0) DesembolsoEjecutado
  FROM #CarteraVig ca 
  LEFT OUTER JOIN #DesemCancel dc ON dc.Zona = ca.Zona
  LEFT OUTER JOIN #Desembolsos de ON de.Zona = ca.Zona
  LEFT OUTER JOIN #PagosDia    pa ON pa.Zona = ca.Zona
  LEFT OUTER JOIN #EstimRec    er ON er.Zona = ca.Zona
 GROUP BY ca.zona, ca.Nombre, SaldoCarteraVigente, MontoCuota, TotalPagosDia, DesembolsoCancelados, TotalMontoDesembolso
 ORDER BY ca.zona 

delete from #CarteraVig
delete  from  #DesemCancel  
delete  from  #Desembolsos
delete  from  #PagosDia
delete  from  #EstimRec


	set @fechaSig = DATEADD(dd, 1, @FechaSig) 
END

select * from #Resumen  order by fecha

 
 --select * from tcloficinas where zona = 'Z01' AND tipo <> 'cerrada' order by convert(integer,codoficina)
--/*
drop table #CarteraVig
drop table #DesemCancel  
drop table #Desembolsos
drop table #PagosDia
drop table #EstimRec
drop table #Resumen
--*/

GO