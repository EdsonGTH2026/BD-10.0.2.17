SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--+++++++++++++++++++   CALCULO DE LAS RESERVAS CON LA NUEVA METODOLOGIA IFRS9   +++++++++++++++++++++++++++  
--ZCCU - 2025.11.01  
--SE CONSIDERA LA CARTERA COMERCIAL Y LA CARTERA ACTIVA.  
--IMPLEMENTACIÓN EN EL CIERRE DIARIO, GENERA LA TABLA:tCsCaProReservaIFRS9   
-- 20260305 zccu Se pone la PI  SP con 15 decimales.
CREATE PROCEDURE [dbo].[pCsCaProReservaIFRS9]   
AS    
SET NOCOUNT ON     
BEGIN   
  
 --VARIABLES   
 DECLARE @Fecha SMALLDATETIME  
 DECLARE @CodUsuario VARCHAR(30)  
  
  
 --SE INICIALIZAN LAS VARIABLES  
 SELECT @Fecha = fechaconsolidacion FROM vcsfechaconsolidacion WITH(NOLOCK)  
  
 --SE CALCULA LA CARTERA VIGENTE: UNICAMENTE DE CREDITOS COMERCIALES:   
 SELECT  C.FECHA,C.CodUsuario,C.CodPrestamo ,C.CodProducto  
   ,CASE  WHEN SUBSTRING (C.CodPrestamo,5,1)= 3 THEN 'CONSUMO'   
    WHEN CodProducto IN ('168','123') THEN 'VIVIENDA' ELSE 'COMERCIAL' END AS TIPO_CREDITO  
   ,cast(C.TasaIntCorriente as decimal (10,5))/100 as 'TasaIntCorriente'   
   ,C.FechaVencimiento   
   ,DATEDIFF(DAY ,FechaVencimiento ,@Fecha ) NroDiasRemanentes  
  ,CASE WHEN (DATEDIFF(DAY ,FechaVencimiento ,@Fecha ) /365.25) > 1 THEN (DATEDIFF(DAY ,FechaVencimiento ,@Fecha ) /365.25)ELSE 1 END AS PlazoRemanente  
 ,cast( (D.saldocapital + D.interesvigente + D.interesvencido + D.moratoriovigente + D.moratoriovencido)as decimal(30,15))  AS 'ExpoIncumplimiento_Saldo'--_CAPITAL&INTERES  
 INTO #CA  
 FROM tCsCartera C WITH(NOLOCK)  
 INNER JOIN tcscarteradet D WITH(NOLOCK) ON C.codprestamo = D.codprestamo and C.fecha = D.fecha  
 WHERE 1=1  
 AND C.Fecha = @Fecha  
 AND C.codoficina not in('97','230','231','999')  
 AND SUBSTRING (C.CodPrestamo,5,1) NOT IN ('3')  
 AND C.CodProducto NOT IN ('168','123')  
 AND C.codprestamo not in (SELECT codprestamo FROM tCsCarteraAlta WITH(NOLOCK))  
 AND C.CodPrestamo NOT IN (SELECT CUENTA FROM tCreditosExcluidos WITH(NOLOCK))  
 AND cartera='ACTIVA'   
  
 /*GARANTIA DEL CLIENTE / PRESTAMO */  
 CREATE TABLE #Ga(CodPrestamo CHAR(25),montogar MONEY)  
 INSERT INTO #Ga  
 SELECT codprestamo,sum(montogar) montogar  
 FROM (  
  SELECT codigo codprestamo,sum(g.garantia) montogar   
  FROM tCsDiaGarantias g WITH(NOLOCK)  
  INNER JOIN tcsahorros a WITH(NOLOCK) ON a.codcuenta=g.docpropiedad and a.fecha=g.fecha  
  WHERE g.fecha=@fecha  
  AND g.TipoGarantia IN ('GADPF', 'GARAH') --'-A-',  
  AND g.estado in('ACTIVO','MODIFICADO')--estado not in('LIBERADO','')   
  AND (a.saldocuenta - g.garantia)>= 0  
  AND len(g.codigo)>18  
  AND codigo in(SELECT codprestamo FROM #CA WITH(NOLOCK))  
  GROUP BY g.codigo  
  UNION  
  SELECT g.codigo codprestamo,sum(g.garantia) garantia  
  FROM tCsDiaGarantias g WITH(NOLOCK)  
  WHERE g.fecha = @fecha   
  AND g.estado = 'ACTIVO'  
  AND g.tipogarantia in ('EFECT')  
  AND len(g.codigo)> 18  
  AND codigo in (SELECT codprestamo FROM #CA WITH(NOLOCK))  
  GROUP BY  g.codigo  
  ) a  
 GROUP BY codprestamo  
  
 CREATE TABLE #PuntajeCrediticio(CodUsuario  VARCHAR(30)  
         , Sector  INT  
         ,Max_ATR  INT  
         ,PUNTAJE_MaxATR INT  
         ,Prom_Dias_Atraso INT  
         ,PUNTAJE_PromAtrasos INT  
         ,PUNTAJE_TOTAL INT  
         ,PERIODO_1 VARCHAR(30),DIAS_ATRASO_1 INT,ATR_1 INT  
         ,PERIODO_2 VARCHAR(30),DIAS_ATRASO_2 INT,ATR_2 INT  
         ,PERIODO_3 VARCHAR(30),DIAS_ATRASO_3 INT,ATR_3 INT  
         ,PERIODO_4 VARCHAR(30),DIAS_ATRASO_4 INT,ATR_4 INT)  
 insert into #PuntajeCrediticio  
 EXEC pCsCaPuntajeCrediticio_IFRS9 @fecha  
    
  
 ----********** ETAPA DEL CREDITO **************  
  
 ----Exposicion al incumplimiento: saldo insoluto + intereses  
 ---* Exposicion al incumplimineto Ajustado: se compara el saldo+ intereses VS la garantía  
  
 SELECT CA.FECHA,CA.CodUsuario,CA.CodPrestamo,CA.CodProducto,CA.TIPO_CREDITO  
 ,CA.ExpoIncumplimiento_Saldo  
 ,ISNULL(GA.montogar,0) montogar  
 ,CASE WHEN  ISNULL(GA.montogar,0)  <= 0 THEN 0  
    WHEN CA.ExpoIncumplimiento_Saldo - GA.montogar  <= 0 THEN 0   
    ELSE CA.ExpoIncumplimiento_Saldo - GA.montogar END ExpoIncumplimiento_Ajustado  
 ,[dbo].[fduCAAsignaEtapaCredito_IFRS9] (CA.CodPrestamo,CA.FECHA) 'ETAPA_Detalle'  
 INTO #EtapaCredito  
 FROM #CA CA WITH(NOLOCK)  
 LEFT OUTER JOIN #GA GA WITH(NOLOCK)ON CA.CodPrestamo = GA.CodPrestamo  
  
 ------ GENERA EL DETALLE DEL PUNTAJE CREDITICIO  
 SELECT E.CodPrestamo,E.CodUsuario  CodUsuario--,[DBO].[fduCASectorEconomicoCli_IFRS9] (CodUsuario) 'SECTOR'    
 ,E.ETAPA_Detalle  
 ,CAST(CASE WHEN PATINDEX('%Etapa:%',E.ETAPA_Detalle)> 0 then substring(E.ETAPA_Detalle,PATINDEX('%Etapa:%',E.ETAPA_Detalle)+6,PATINDEX('%_Fecha Etapa 3:%',E.ETAPA_Detalle)-(PATINDEX('%Etapa:%',E.ETAPA_Detalle)+6)) ELSE '' END AS INT) 'Etapa_credito'  
 ,CASE WHEN PATINDEX('%_Fecha Etapa 3:%',E.ETAPA_Detalle)> 0 then substring(E.ETAPA_Detalle,PATINDEX('%_Fecha Etapa 3:%',E.ETAPA_Detalle)+15,PATINDEX('%.%',E.ETAPA_Detalle)-(PATINDEX('%_Fecha Etapa 3:%',E.ETAPA_Detalle)+15)) ELSE '' END 'Fecha_Etapa3'  
 ,DP.Sector   
 ,DP.Max_ATR    
 ,DP.PUNTAJE_MaxATR   
 ,DP.Prom_Dias_Atraso   
 ,DP.PUNTAJE_PromAtrasos   
 ,DP.PUNTAJE_TOTAL   
 ,DP.PERIODO_1 ,DP.DIAS_ATRASO_1 ,DP.ATR_1   
 ,DP.PERIODO_2 ,DP.DIAS_ATRASO_2 ,DP.ATR_2   
 ,DP.PERIODO_3 ,DP.DIAS_ATRASO_3 ,DP.ATR_3   
 ,DP.PERIODO_4 ,DP.DIAS_ATRASO_4 ,DP.ATR_4   
 INTO #DetallePuntaje  
 FROM #EtapaCredito E WITH(NOLOCK)  
 LEFT OUTER JOIN #PuntajeCrediticio DP ON dp.CodUsuario = e.codUsuario   
  
  
 /* CALCULAR LA PROBABILIDAD DE INCUMPLIMIENTO*/  
  
 SELECT CodPrestamo,[DBO].[fduProbabilidadIncumplimiento_IFRS9] (SECTOR,PUNTAJE_TOTAL,ETAPA_CREDITO)'ProbaIncumplimiento'  
 INTO #ProbabilidadIncumplimiento  
 FROM #DetallePuntaje WITH(NOLOCK)  
 WHERE Codprestamo in (SELECT codprestamo FROM #CA WITH(NOLOCK))  
  
  
 /* CALCULAR LA SEVERIDAD DE LA PERDIDA*/  
  
 SELECT P.CODPRESTAMO,P.Etapa_credito,P.Fecha_Etapa3  
 --,CAST(CASE WHEN P.Fecha_Etapa3='NO APLICA' THEN '' ELSE P.Fecha_Etapa3  END AS SMALLDATETIME)  
 --, @Fecha -   
 ,CASE WHEN etapa_credito in (1,2) THEN 0   
  ELSE DATEDIFF(MONTH ,P.Fecha_Etapa3 ,@Fecha )END 'MesesEtapa3'  
  ,(CAST((s.valor)AS DECIMAL(20,15))/100) 'SeveridadPerdida'  --------se pone a 15 decimales
 ,S.*  
 INTO #SeveridadPerdida  
 FROM #DetallePuntaje P WITH(NOLOCK)  
 INNER JOIN tcIFRS9SeveridadPerdida S WITH(NOLOCK) ON S.ETAPA = P.Etapa_credito  
 WHERE   
 1=1  
 and CASE WHEN etapa_credito in (1,2) THEN 0   
  ELSE DATEDIFF(MONTH ,P.Fecha_Etapa3 ,@Fecha )END  <= RangoMaximo  
 AND  CASE WHEN etapa_credito in (1,2) THEN 0   
  ELSE DATEDIFF(MONTH ,P.Fecha_Etapa3 ,@Fecha )END  >= RangoMinimo  
  
  
 /* CALCULAR LA SEVERIDAD DE LA PERDIDA AJUSTADA por Garantias*/  
  
 SELECT P.Codprestamo,P.SeveridadPerdida--,E.expoIncumplimiento_saldo, E.expoIncumplimiento_Ajustado  
 ,CAST(CASE WHEN montoGar = 0 THEN 0 ELSE P.SeveridadPerdida* ( E.expoIncumplimiento_Ajustado/E.expoIncumplimiento_saldo )END AS DECIMAL(20,15)) SeveridadPerdida_Ajustado  
 INTO #SeveridadPerdidaAjustado  
 FROM #SeveridadPerdida p  WITH(NOLOCK)   
 LEFT OUTER JOIN #EtapaCredito E WITH(NOLOCK) ON E.Codprestamo=p.codprestamo  
 WHERE P.CODPRESTAMO IN (SELECT CodPrestamo FROM  #CA  WITH(NOLOCK))  
  
  
 Delete from tCsCaProReservaIFRS9 where fecha=@Fecha  
 Insert into tCsCaProReservaIFRS9(  
 Fecha,CodUsuario,CodPrestamo,CodProducto,TipoCredito,TasaIntCorriente,FechaVencimiento,montoGarantia,SectorEconomico,  
 EtapaCredito,IngresoTerceraEtapa,MesesTerceraEtapa,NroDiasRemanentes,PlazoRemanente,Periodo_1,Dias_Atraso_1,ATR_1,  
 Periodo_2,Dias_Atraso_2,ATR_2,Periodo_3,Dias_Atraso_3,ATR_3,Periodo_4,Dias_Atraso_4,ATR_4,Max_ATR,PuntajeMaxATR,  
 PromedioDiasAtraso,PuntajePromedioAtrasos,PuntajeTotal,ProIncumplimiento,ExpoIncumplimiento_Saldo,  
 ExpoIncumplimiento_Ajustado,ExpoIncumplimiento_Total,SeveridadPerdida,SeveridadPerdida_Ajustado,SeveridadPerdida_Total,  
 Reserva,ReservaCompleta,TCartera)   
 SELECT   
 CA.FECHA   
 ,CA.CodUsuario   
 ,CA.CodPrestamo   
 ,CA.CodProducto   
 ,CA.TIPO_CREDITO   
 ,CA.TasaIntCorriente   
 ,CA.FechaVencimiento   
 ,E.montogar   
 ,DP.SECTOR AS 'SECTOR_Economico'   
 ,DP.Etapa_credito   
 ,DP.Fecha_Etapa3   
 ,SP.MesesEtapa3   
 ,CASE WHEN DP.Etapa_credito = 2 THEN CA.NroDiasRemanentes ELSE 0 END NroDiasRemanentes  
 ,CASE WHEN DP.Etapa_credito = 2 THEN CA.PlazoRemanente ELSE 0 END PlazoRemanente  
 ,CASE WHEN DP.PERIODO_1 ='19000101' THEN '' ELSE DP.PERIODO_1 END AS PERIODO_1   
 ,DP.DIAS_ATRASO_1   
 ,DP.ATR_1   
 ,CASE WHEN DP.PERIODO_2 ='19000101' THEN '' ELSE DP.PERIODO_2 END AS PERIODO_2   
 ,DP.DIAS_ATRASO_2   
 ,DP.ATR_2   
 ,CASE WHEN DP.PERIODO_3 ='19000101' THEN '' ELSE DP.PERIODO_3 END AS PERIODO_3   
 ,DP.DIAS_ATRASO_3   
 ,DP.ATR_3   
 ,CASE WHEN DP.PERIODO_4 ='19000101' THEN '' ELSE DP.PERIODO_4 END AS PERIODO_4   
 ,DP.DIAS_ATRASO_4   
 ,DP.ATR_4   
 ,DP.Max_ATR   
 ,DP.PUNTAJE_MaxATR   
 ,DP.PROM_DIAS_ATRASO   
 ,DP.PUNTAJE_PromAtrasos   
 ,DP.PUNTAJE_TOTAL   
 --,E.DetallePuntajeCrediticio   
 ,PIN.ProbaIncumplimiento   
 ,CA.ExpoIncumplimiento_Saldo  
 ,E.ExpoIncumplimiento_Ajustado   
 ,CASE WHEN E.montogar=0 THEN CA.ExpoIncumplimiento_Saldo ELSE E.ExpoIncumplimiento_Ajustado  END'ExpoIncumplimiento_Total'  
 ,SP.SeveridadPerdida   
 ,SPA.SeveridadPerdida_Ajustado   
 ,CASE WHEN E.montogar=0 THEN SP.SeveridadPerdida ELSE SPA.SeveridadPerdida_Ajustado  END 'SeveridadPerdida_Total'  
 ,CASE WHEN E.MONTOGAR <= 0 THEN PIN.ProbaIncumplimiento*SP.SeveridadPerdida*CA.ExpoIncumplimiento_Saldo   
          ELSE  PIN.ProbaIncumplimiento * E.ExpoIncumplimiento_Saldo * SPA.SeveridadPerdida_Ajustado END 'RESERVA'  
               
 ,(CASE WHEN DP.Etapa_credito IN(2) THEN (CASE WHEN E.MONTOGAR <= 0 THEN PIN.ProbaIncumplimiento*SP.SeveridadPerdida*CA.ExpoIncumplimiento_Saldo   
             ELSE  PIN.ProbaIncumplimiento * E.ExpoIncumplimiento_Saldo * SPA.SeveridadPerdida_Ajustado END)     
    ELSE 0 END) *(1- POWER(((1-PIN.ProbaIncumplimiento)/(1+CA.TasaIntCorriente)), PlazoRemanente ))/(CA.TasaIntCorriente + PIN.ProbaIncumplimiento) 'ReservaCompleta'  
    ,'Cartera - Activa'  
 FROM #CA CA WITH(NOLOCK)  
 LEFT OUTER JOIN #EtapaCredito E WITH(NOLOCK)ON E.CODPRESTAMO = CA.CODPRESTAMO  
 LEFT OUTER JOIN #DetallePuntaje DP WITH(NOLOCK)ON DP.CODPRESTAMO = CA.CODPRESTAMO  
 LEFT OUTER JOIN #ProbabilidadIncumplimiento PIN WITH(NOLOCK)ON PIN.CODPRESTAMO = CA.CODPRESTAMO  
 LEFT OUTER JOIN #SeveridadPerdida SP WITH(NOLOCK)ON SP.CODPRESTAMO = CA.CODPRESTAMO  
 LEFT OUTER JOIN  #SeveridadPerdidaAjustado SPA WITH(NOLOCK)ON SPA.CODPRESTAMO = CA.CODPRESTAMO  
  
 DROP TABLE #EtapaCredito  
 DROP TABLE #Ga  
 DROP TABLE #CA  
 DROP TABLE #DetallePuntaje  
 DROP TABLE #ProbabilidadIncumplimiento  
 DROP TABLE #SeveridadPerdida  
 DROP TABLE #SeveridadPerdidaAjustado  
 drop table #PuntajeCrediticio  
END;
GO