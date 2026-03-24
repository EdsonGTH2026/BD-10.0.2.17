SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO









 
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++             
++ Genera Informacion para calculo de Bonos para Promotor - 20220716  ZCCU          
++--Agrega cartera castigada 23.09.2022  ZCCU                  
++--Se modifica para mostrar todos los promotores activos con y sin cartera 10.11.2022 -ZCCU                   
++--Actualizar nro de créditos renovados --> para ciclo 1,2,y 3 hasta 8 días de atraso  11.11.2022  ZCCU                  
++--Actualizar nro de créditos liquidados--> para ciclo 1,2,y 3 hasta 8 días de atraso  18.11.2022   ZCCU                 
++--Se actualiza el interes cobrado -- 27.02.2023    ZCCU          
++                
++--- /*CARTA PROMOTOR VS 5 APP  05.2023 */            
++--Se agrega Categoria, Valor Bono Objetivo, Asignacion y quita de cartera 05.2023            
++--Optimiza tiempos de consulta + nuevos campos 06.2023 ZCCU        
++--Formato de porcentajes a columnas finales 31.07.2023 JRAC      
++--PORCE_BONO_GANADO y SALDO_BONO_GANADO, ajustar el valor mínimo a 0   31.07.2023 JRAC      
      
++-- 08.08.2023 ZCCU       
++--MONTO_RENOV y PTMOS_RENOV:considerar solamente renovacion Organica (sin renovacion anticipada) 08.08.2023 ZCCU      
++--PORCE_BONO_COBRANZA Disminuir el %, de 40%, a 20%,                                                    
++--PORCE_BONO_GANADO: sumar tambien el PORCE_BONO_IMOR                                                   
++--BONO_ESTIMADO_CALCULADO:el calculo de la categoria master, INT_COBRADO_TOTAL*8%                          
++--PORCE_PENALIZACION: si PORCE_PASO_VENCIDA >= 1.5%, 20%, si PORCE_PASO_VENCIDA >= 1%, 10%, si no 0%,       
++--PTMOS_CRECIMIENTO_META: en caso de no tener meta, poner 12 08.08.2023 ZCCU      
++--SALDO_CRECIMIENTO_META: en caso de no tener meta, poner 80,000  08.08.2023 ZCCU      
++-- Nueva Columna: DIFF_CARTERA_VENCIDA -->Incremento de cartera vencida, cartera vencida final menos cartera vencida inicial       
++-- Nueva Columna: IMOR_7 IMOR_15 IMOR_30                          
++-- Nueva Columna: MONTO_RENOV_ANTIC Y PTMOS_RENOV_ANTIC           
++-- Nueva Columna: PORCE_BONO_IMOR Si el IMOR_7 es menor o igual al 10%, 20%, si no, 0%   08.08.2023 ZCCU      
  
++-- Ajuste en el calculo de Quitas y asignaciones de Cartera JRAC  
++-- Se optimiza sp 2023.10.17 zccu     
 

 ++-- 10.04.2024 Sil
 ++-- PORCE_BONO_IMOR:	Poner siempre 0%
 ++-- PORCE_PENALIZACION: Si PORCE_PASO_VENCIDA >= 2%, 30%, SI PORCE_PASO_VENCIDA >= 1%, 20%, si no 0%,
 ++-- PORCE_BONO_CRECIMIENTO:	Modificar el %, si cumple con el crecimiento, 50%, si no, 0%
 ++-- PORCE_BONO_COBRANZA:	Modificar el %, si cumple con el 93.6% de PAGO_ACUMULADO, 50%, si no, 0%
 ++-- PORCE_BONO_GANADO:	Sumar PORCE_BONO_CRECIMIENTO + PORCE_BONO_COBRANZA + PORCE_PENALIZACION.  --->  Se resta?   -(PORCE_PENALIZACION)
 ++-- SALDO_BONO_GANADO: Se replica el cambio de PORCE_BONO_GANADO
 ++-- DIFF_CARTERA_VENCIDA:	CART_VENCIDA_FIN + SALDOCASTIGADO - CART_VENCIDA_INI
 ++-- CART_VENCIDA_FIN	Se le debe de sumar el saldo castigado


++-- Nueva Columna:  SaldoCastigado	Identificar las cuentas castigadas en lo que va del mes actual y tomar su saldo de capital a inicio de mes,
++-- Nueva Columna:  Ptmos Liquidados	Ptmos liquidados en lo que va del mes actual
++-- Nueva Columna:  Ptmos Renovados	Ptmos liquidados en lo que va del mes actual ya renovados,
++-- Nueva Columna:  Saldo Liquidado	Saldo de capital de los ptmos liquidados en lo que va del mes actual
++-- Nueva Columna:  Saldo Renovado	Nuevo monto desembolso de los ptmos liquidados en lo que va del mes actual ya renovados,



++-- 16.08.2024 Sil
++-- Nueva Columna -->  Cartera07: el saldo capital de las cuentas que se encuentran entre 0 y 7 días de atraso

++-- 14.01.2025 Sil
 ++-- CART_VENCIDA_FIN	Ya no se suma el saldo castigado por solicitud de Mauricio

++-- 07.02.2025 Sil
 ++-- FechaIngresoPromotor	Se agrega nueva columna por solicitud de Mauricio, la fecha en la que un empleado inicio como promotor en tcsempleadosFecha


 ++-- 20.03.2025 Sil
 ++-- Saldo_Castigado. Sólo se toman en cuenta los castigados al final de mes.


  ++-- 07.12.2025 Sil
 ++-- En la consulta final, se filtran (quitan) algunos codusuarios con saldos en ceros. Los pidio Inteligencia de Negocios.
 ++--    Se crearon dos codusuarios para estos promotores para moverlos de sucursal en lo que se iba cerrando su cartera del codasesor incial


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  */          
--exec pCsCaFNCartaPromotor3_APP           
          
CREATE PROCEDURE  [dbo].[pCsCaFNCartaPromotor3_APP]               
AS              
SET NOCOUNT ON    

                                        
--+++++++++++++++++++++++++++++ DECLARAR VARIABLES +++++++++++++++++++++++++++++++++++--          
DECLARE @FECHA SMALLDATETIME,          
         @FECINI SMALLDATETIME,          
         @FECANTE SMALLDATETIME,  
		 @FECCASTIGO SMALLDATETIME,
         @FECFIN SMALLDATETIME,            
         @DIACORTE INT ,          
         @EVA INT,          
         @FECEVAL SMALLDATETIME          
--SET @FECHA = '20250131'          
SELECT @FECHA=FECHACONSOLIDACION FROM VCSFECHACONSOLIDACION          
SET @FECINI = DBO.FDUFECHAAPERIODO(@FECHA)+'01' ---- FECHA DE INICIO DE MES           
SET @FECANTE = CAST(DBO.FDUFECHAAPERIODO(@FECHA)+'01' AS SMALLDATETIME)-1  --FECHA DE TERMINO DEL MES ANTERIOR   
SELECT @FECFIN = ULTIMODIA FROM TCLPERIODO WHERE DBO.FDUFECHAAPERIODO(ULTIMODIA)=DBO.FDUFECHAAPERIODO(@FECHA)                 
SELECT @DIACORTE = DAY(FECHACORTE) FROM TCSACAINCENTIVOSCORTES WHERE DBO.FDUFECHAAPERIODO(FECHA)=DBO.FDUFECHAAPERIODO(@FECHA)  
SET @FECCASTIGO = CAST(DBO.FDUFECHAAPERIODO(@FECFIN)+'28'  AS SMALLDATETIME)+1     ---se cuenta el saldo castigado a partir del 29 del mes 
--SELECT @FECHA          
--SELECT * FROM  TCSACAINCENTIVOSCORTES          
 --     SELECT @FECCASTIGO AS Valor_FecCastigo;
      
-------DEFINIR INICIO DE CADA EVALUACIÓN DEL MES             
IF(DAY(@FECHA)<=ISNULL(@DIACORTE,15))           
  BEGIN          
 SET @EVA=1          
 SET @FECEVAL=CAST(DBO.FDUFECHAAPERIODO(@FECHA)+'01' AS SMALLDATETIME)          
  END          
ELSE           
  BEGIN          
 SET @EVA=2          
 SET @FECEVAL=CAST(DBO.FDUFECHAAPERIODO(@FECHA)+ CAST(ISNULL(@DIACORTE+1,16)AS VARCHAR) AS SMALLDATETIME)          
  END          
          
          
--SELECT @EVA          
--SELECT @FECEVAL          
          
-------------------------VARIABLES DE TIEMPO----------          
--DECLARE @T1 DATETIME          
--DECLARE @T2 DATETIME          
--SET @T1=GETDATE()          
          
          
                    
--+++++++++++++++++++++++++++++/*CARTERA INICIAL */--SALDOS EN CARTERA +++++++++++++++++++++++++++++++++++++                   
                    
DECLARE @CARTERAINI TABLE (FECHA SMALLDATETIME,                    
         CODASESOR VARCHAR(15),                        
         SALDOINI0A30 MONEY,                    
         SALDOINI31M MONEY,                    
         PTMOSVGTEINI INT,                     
         PTMOSVENCIDOINI INT,          
         SALDOVIGTEINIC1 MONEY,          
         PTMOSVIGTEINIC1 INT,          
         SALDOVIGTEINIC2 MONEY,          
         PTMOSVIGTEINIC2 INT,          
         SALDOVIGTEINIC3 MONEY,          
         PTMOSVIGTEINIC3 INT,          
         SALDOVIGTEINIC410 MONEY,          
         PTMOSVIGTEINIC410 INT,          
         SALDOVIGTEINIC11 MONEY,          
         PTMOSVIGTEINIC11 INT)                        
INSERT INTO @CARTERAINI                        
SELECT   C.FECHA                      
,C.CODASESOR  CODASESOR                 
,SUM(CASE WHEN C.NRODIASATRASO<=30 THEN C.SALDOCAPITAL ELSE 0 END)SALDOINI0A30                    
,SUM(CASE WHEN   C.NRODIASATRASO>=31 THEN C.SALDOCAPITAL ELSE 0 END)SALDOINI31M                    
,COUNT(CASE WHEN C.NRODIASATRASO<=30 THEN C.CODPRESTAMO END) 'VIGENTE 0-30'                         
,COUNT(CASE WHEN C.NRODIASATRASO>=31 THEN C.CODPRESTAMO END)  'VENCIDO'       
,SUM(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE=1 THEN C.SALDOCAPITAL ELSE 0 END) CARTERAINICIALC1                    
,COUNT(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE=1 THEN C.CODPRESTAMO END) CREDITOSINICIALESC1           
,SUM(CASE WHEN C.NRODIASATRASO <=30 AND D.SECUENCIACLIENTE=2 THEN C.SALDOCAPITAL ELSE 0 END) CARTERAINICIALC2                   
,COUNT(CASE WHEN C.NRODIASATRASO <=30 AND D.SECUENCIACLIENTE=2 THEN C.CODPRESTAMO END) CREDITOSINICIALESC2          
,SUM(CASE WHEN C.NRODIASATRASO <=30 AND D.SECUENCIACLIENTE=3 THEN C.SALDOCAPITAL ELSE 0 END) CARTERAINICIALC3                    
,COUNT(CASE WHEN C.NRODIASATRASO <=30 AND D.SECUENCIACLIENTE=3 THEN C.CODPRESTAMO END) CREDITOSINICIALESC3          
,SUM(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE>=4 AND D.SECUENCIACLIENTE<=10 THEN C.SALDOCAPITAL ELSE 0 END) 'CARTERAINICIALC4-10'                  
,COUNT(CASE WHEN C.NRODIASATRASO <=30 AND D.SECUENCIACLIENTE>=4 AND D.SECUENCIACLIENTE<=10 THEN C.CODPRESTAMO END) 'CREDITOSINICIALESC4-10'          
,SUM(CASE WHEN C.NRODIASATRASO <=30 AND D.SECUENCIACLIENTE>=11 THEN C.SALDOCAPITAL ELSE 0 END) 'CARTERAINICIALC11+'                  
,COUNT(CASE WHEN C.NRODIASATRASO <=30 AND D.SECUENCIACLIENTE>=11 THEN C.CODPRESTAMO END) 'CREDITOSINICIALESC11+'          
FROM TCSCARTERA C WITH(NOLOCK)                        
INNER JOIN TCSCARTERADET D WITH(NOLOCK) ON C.FECHA=D.FECHA AND C.CODPRESTAMO=D.CODPRESTAMO                      
WHERE C.FECHA=@FECANTE--> FECHA DE CORTE DEL MES ANTERIOR           
AND C.CODPRESTAMO NOT IN (SELECT CODPRESTAMO FROM TCSCARTERAALTA WITH(NOLOCK))                  
AND C.CODOFICINA NOT IN('97','230','231','999')                     
AND C.CARTERA='ACTIVA'           
AND C.TIPOREPROG<>'REEST'                   
GROUP BY  C.FECHA,C.CODASESOR                      
          
                    
--SET @T2=GETDATE()          
--PRINT '1 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
                    
--+++++++++++++++++++++++++++++/*CARTERA FINAL */--SALDOS EN CARTERA +++++++++++++++++++++++++++++++++++++                   
                   
DECLARE @CARTERAFIN TABLE (FECHA SMALLDATETIME,                    
         CODASESOR VARCHAR(15),   
		 SALDOFIN0A7 MONEY,                      --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
         SALDOFIN0A30 MONEY,                           
         SALDOFIN31M MONEY,                    
         PTMOSVGTEFIN INT,                              
         PTMOSVENCIDOFIN INT,          
         SALDOVIGTEFINC1 MONEY,          
         PTMOSVIGTEFINC1 INT,          
         SALDOVIGTEFINC2 MONEY,          
         PTMOSVIGTEFINC2 INT,          
         SALDOVIGTEFINC3 MONEY,          
         PTMOSVIGTEFINC3 INT,          
         SALDOVIGTEFINC410 MONEY,          
         PTMOSVIGTEFINC410 INT,          
         SALDOVIGTEFINC11 MONEY,          
         PTMOSVIGTEFINC11 INT,          
         SALDORIESGO MONEY,          
         PTMOSRIESGO INT,      
         IMOR7 MONEY,IMOR15 MONEY,IMOR30 MONEY)                        
INSERT INTO @CARTERAFIN                        
SELECT   C.FECHA             
,C.CODASESOR    
,SUM(CASE WHEN C.NRODIASATRASO<=7 THEN C.SALDOCAPITAL ELSE 0 END)SALDOFIN0A7             --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
,SUM(CASE WHEN C.NRODIASATRASO<=30 THEN C.SALDOCAPITAL ELSE 0 END)SALDOFIN0A30                    
,SUM(CASE WHEN C.NRODIASATRASO>=31 THEN C.SALDOCAPITAL ELSE 0 END)SALDOFIN31M                    
,COUNT(CASE WHEN C.NRODIASATRASO<=30 THEN C.CODPRESTAMO END) 'VIGENTE 0-30'                              
,COUNT(CASE WHEN C.NRODIASATRASO>=31 THEN C.CODPRESTAMO END)  'VENCIDO'            
,SUM(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE=1 THEN C.SALDOCAPITAL ELSE 0 END) CARTERAFINALC1                    
,COUNT(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE=1 THEN C.CODPRESTAMO END) CREDITOSFINALESC1           
,SUM(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE=2 THEN C.SALDOCAPITAL ELSE 0 END) CARTERAFINALC2                    
,COUNT(CASE  WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE=2 THEN C.CODPRESTAMO END) CREDITOSFINALESC2          
,SUM(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE=3 THEN C.SALDOCAPITAL ELSE 0 END) CARTERAFINALC3                    
,COUNT(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE=3 THEN C.CODPRESTAMO END) CREDITOSFINALESC3          
,SUM(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE>=4 AND D.SECUENCIACLIENTE <= 10 THEN C.SALDOCAPITAL ELSE 0 END) 'CARTERAFINALC4-10'                  
,COUNT(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE>=4 AND D.SECUENCIACLIENTE <= 10 THEN C.CODPRESTAMO END) 'CREDITOSFINALESC4-10'          
,SUM(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE>=11 THEN C.SALDOCAPITAL ELSE 0 END) 'CARTERAFINALC11+'                  
,COUNT(CASE WHEN C.NRODIASATRASO<=30 AND D.SECUENCIACLIENTE>=11 THEN C.CODPRESTAMO END) 'CREDITOSFINALESC11+'          
,SUM(CASE WHEN C.NRODIASATRASO>=23 AND C.NRODIASATRASO<=30 THEN C.SALDOCAPITAL ELSE 0 END) 'CARTERARIESGO'                  
,COUNT(CASE WHEN C.NRODIASATRASO>=23 AND C.NRODIASATRASO<=30 THEN C.CODPRESTAMO END) 'CREDITOSRIESGO'         
,(SUM(CASE WHEN C.NRODIASATRASO>=7 THEN D.SALDOCAPITAL ELSE 0 END)/SUM(D.SALDOCAPITAL))*100 IMOR7        
,(SUM(CASE WHEN C.NRODIASATRASO>=15 THEN D.SALDOCAPITAL ELSE 0 END)/SUM(D.SALDOCAPITAL))*100 IMOR15        
,(SUM(CASE WHEN C.NRODIASATRASO>=30 THEN D.SALDOCAPITAL ELSE 0 END)/SUM(D.SALDOCAPITAL))*100 IMOR30      
FROM TCSCARTERA C WITH(NOLOCK)                      
INNER JOIN TCSCARTERADET D WITH(NOLOCK) ON C.FECHA=D.FECHA AND C.CODPRESTAMO=D.CODPRESTAMO                      
WHERE C.FECHA=@FECHA  --> FECHA CONSULTA            
AND C.CODPRESTAMO NOT IN (SELECT CODPRESTAMO FROM TCSCARTERAALTA WITH(NOLOCK))                 
AND C.CODOFICINA NOT IN('97','230','231','999')                   
AND C.CARTERA='ACTIVA'           
AND C.TIPOREPROG<>'REEST'                    
GROUP BY  C.FECHA ,C.CODASESOR                   
          
--SET @T2=GETDATE()          
--PRINT '2 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()      



--+++++++++++++++++++++++++++++/*CARTERA CASTIGADA */+++++++++++++++++++++++++++++++++++++++++       2024.04.12  Sil


------ #ptmos_Castigados
select ultimoasesor, codUsuario, codprestamo 'codprestamo_Canc'  --cancelacion, TIPOREPROG 
into #ptmos_Castigados
from tcspadroncarteradet with(nolock)                                           --> se uso tcspadroncarteradet 
where pasecastigado>=@FECCASTIGO and pasecastigado<=@FECHA  --@FECFIN  si se recalcula a fechaposterior va a modificar        --> Final del MES ACTUAL    
                                                   --- Ajuste al 13.03.2025 Sil: Mauricio pidio cambiar el rango de @FECINI a @FECHA, a sólo el final del mes previo 
--and carteraactual='CASTIGADA' 
and codoficina not in('97','230','231','999')
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
AND TIPOREPROG<>'REEST'                                                          
order by UltimoAsesor, codusuario


------ #Cartera_Castigada
SELECT  
--C.FECHA,                      
C.CODASESOR  CODASESOR
--,codusuario, codprestamo 'codprestamo_Cast', SALDOCAPITAL
,COUNT(C.CODPRESTAMO) 'Ptmos_Castigados'
,SUM(C.SALDOCAPITAL) 'SALDO_Castigado' 
into #Cartera_Castigada
FROM TCSCARTERA C WITH(NOLOCK)                          
WHERE C.FECHA=@FECINI                                                                   -->  Saldo al inicio del mes
		and CODPRESTAMO in ( select codprestamo_Canc from #ptmos_Castigados)                           -->  cuenta cambio a cuenta castigada en lo que va del mes
GROUP BY  C.CODASESOR
           --,C.FECHA
order by C.CODASESOR


--drop table #ptmos_Castigados
--drop table #Cartera_Castigada



                         
--+++++++++++++++++++++++++++++/*CRECIMIENTO DE CARTERA */+++++++++++++++++++++++++++++++++++++++++                   
                    
DECLARE @CRECARTERA TABLE( FECHA SMALLDATETIME,CODASESOR VARCHAR(15), 
		 SALDOFIN0A7 MONEY,                      --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
      SALDOFIN0A30 MONEY ,SALDOFIN31M MONEY,                    
         SALDOINI0A30 MONEY,SALDOINI31M MONEY,                   
         PTMOSVGTEINI INT ,PTMOSVENCIDOINI INT,                    
         PTMOSVGTEFIN INT,PTMOSVENCIDOFIN INT,          
         SALDOVIGTEINIC1 MONEY,PTMOSVIGTEINIC1 INT,          
         SALDOVIGTEINIC2 MONEY,PTMOSVIGTEINIC2 INT,          
         SALDOVIGTEINIC3 MONEY,PTMOSVIGTEINIC3 INT,          
         SALDOVIGTEINIC410 MONEY,PTMOSVIGTEINIC410 INT,          
         SALDOVIGTEINIC11 MONEY,PTMOSVIGTEINIC11 INT,          
         SALDOVIGTEFINC1 MONEY,PTMOSVIGTEFINC1 INT,          
         SALDOVIGTEFINC2 MONEY,PTMOSVIGTEFINC2 INT,          
         SALDOVIGTEFINC3 MONEY,PTMOSVIGTEFINC3 INT,          
         SALDOVIGTEFINC410 MONEY,PTMOSVIGTEFINC410 INT,          
         SALDOVIGTEFINC11 MONEY,PTMOSVIGTEFINC11 INT,          
         SALDORIESGO MONEY,PTMOSRIESGO INT,           
         DIF_SALDO_C1 MONEY,DIF_SALDO_C2 MONEY,          
         DIF_SALDO_C3 MONEY,DIF_SALDO_C4a10 MONEY,          
         DIF_SALDO_C11M MONEY,DIF_PTMOS_C1 INT,          
         DIF_PTMOS_C2 INT,DIF_PTMOS_C3 INT,          
         DIF_PTMOS_C4a10 INT,DIF_PTMOS_C11M INT,          
         PORCE_PASO_VENCIDA DECIMAL(7,3),       
         IMOR7 MONEY,IMOR15 MONEY,IMOR30 MONEY)                                   
INSERT INTO @CRECARTERA                           
SELECT                     
F.FECHA ,F.CODASESOR, 
SALDOFIN0A7,                      --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
SALDOFIN0A30,SALDOFIN31M,                     
SALDOINI0A30,SALDOINI31M,                    
PTMOSVGTEINI,PTMOSVENCIDOINI,                     
PTMOSVGTEFIN,PTMOSVENCIDOFIN,          
SALDOVIGTEINIC1,PTMOSVIGTEINIC1,          
SALDOVIGTEINIC2,PTMOSVIGTEINIC2,          
SALDOVIGTEINIC3,PTMOSVIGTEINIC3,          
SALDOVIGTEINIC410,PTMOSVIGTEINIC410,          
SALDOVIGTEINIC11,PTMOSVIGTEINIC11,          
SALDOVIGTEFINC1,PTMOSVIGTEFINC1,          
SALDOVIGTEFINC2,PTMOSVIGTEFINC2,          
SALDOVIGTEFINC3,PTMOSVIGTEFINC3,          
SALDOVIGTEFINC410,PTMOSVIGTEFINC410,          
SALDOVIGTEFINC11,PTMOSVIGTEFINC11,          
SALDORIESGO,PTMOSRIESGO,          
---DIFERENCIA CARTERA POR CICLOS -SALDOS          
ISNULL(SALDOVIGTEFINC1,0)-ISNULL(SALDOVIGTEINIC1,0) DIF_SALDO_C1,          
ISNULL(SALDOVIGTEFINC2,0)-ISNULL(SALDOVIGTEINIC2,0)DIF_SALDO_C2,          
ISNULL(SALDOVIGTEFINC3,0)-ISNULL(SALDOVIGTEINIC3,0)DIF_SALDO_C3,          
ISNULL(SALDOVIGTEFINC410,0)-ISNULL(SALDOVIGTEINIC410,0)DIF_SALDO_C4a10,          
ISNULL(SALDOVIGTEFINC11,0)-ISNULL(SALDOVIGTEINIC11,0)DIF_SALDO_C11M,          
---DIFERENCIA CARTERA POR CICLOS . PTMOS          
ISNULL(PTMOSVIGTEFINC1,0)-ISNULL(PTMOSVIGTEINIC1,0) DIF_PTMOS_C1,          
ISNULL(PTMOSVIGTEFINC2,0)-ISNULL(PTMOSVIGTEINIC2,0)DIF_PTMOS_C2,          
ISNULL(PTMOSVIGTEFINC3,0)-ISNULL(PTMOSVIGTEINIC3,0)DIF_PTMOS_C3,          
ISNULL(PTMOSVIGTEFINC410,0)-ISNULL(PTMOSVIGTEINIC410,0)DIF_PTMOS_C4a10,          
ISNULL(PTMOSVIGTEFINC11,0)-ISNULL(PTMOSVIGTEINIC11,0)DIF_PTMOS_C11M          
-----PORCENTAJE PASO A VENCIDA       
-------- Modificacion     PORCE_PASO_VENCIDA debido a     CART_VENCIDA_FIN = CART_VENCIDA_FIN + SALDOCASTIGADO         modificado el 2024.04.12  Sil
,CASE WHEN ISNULL(SALDOINI0A30,0)= 0 THEN 0 ELSE (ISNULL(SALDOFIN31M,0) +ISNULL(Casti.SALDO_Castigado, 0) - ISNULL(SALDOINI31M,0))/ISNULL(SALDOINI0A30,0)END PORCE_PASO_VENCIDA          
,ISNULL(IMOR7,0)IMOR7      
,ISNULL(IMOR15,0)IMOR15      
,ISNULL(IMOR30,0)IMOR30      
FROM @CARTERAFIN F                    
LEFT OUTER JOIN @CARTERAINI I ON I.CODASESOR=F.CODASESOR 
LEFT OUTER JOIN #Cartera_Castigada Casti ON Casti.CODASESOR=F.CODASESOR
          
          
--SET @T2=GETDATE()          
--PRINT '3 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          








--+++++++++++++++++++++++++++++/*PRESTAMOS LIQUIDADOS Y RENOVADOS*/  +++++++++++++++++++++++++++++++++++++++++         2024.04.12  Sil


--/Prestamos Liquidados y Renovados/        
        
create table #baseLiqui (codoficina varchar(5)        
      ,sucursal varchar(50)        
      ,coordinador  varchar(500)        
      ,codpromotor  varchar(50)        
      ,codprestamo varchar(35)        
      ,secuenciacliente int        
      ,cancelacion  smalldatetime        
      ,atrasomaximo  int        
      ,Estado  varchar(30))         
        
insert into #baseLiqui         
exec pCsCaLiqRRPromotor @fecha,@fecini        
        

------ #ptmos_Liquidados                 ---  falta saldo 

--/Para ciclos 1,2 y 3 se toman hasta 8 dias de atraso, c4+ hasta 15 dias a. -- cambio solicitado por Laura/        
declare  @liq table(codoficina varchar(4),coordinador varchar(500),codpromotor varchar(50),codprestamo varchar(35),Estado  varchar(30))        
insert into @liq        
select codoficina,coordinador,codpromotor--,count(codprestamo) nro--,sum(monto)monto    
,case when secuenciaCliente<=3 and atrasomaximo<=8 then codprestamo          
   when secuenciaCliente>3 and atrasomaximo<=15 then codprestamo        
   else NULL end codprestamo 
   ,Estado
--,sum(case when secuenciaCliente<=3 and atrasomaximo<=8 then 1          
--   when secuenciaCliente>3 and atrasomaximo<=15 then 1        
--   else 0 end) nro        
from #baseLiqui  --with(nolock)         
where cancelacion>=@fecini and cancelacion<=@fecha        
--and atrasomaximo<=15     
--and CODPROMOTOR='CBJ881122FH600' -------OJO           
--group by codoficina,coordinador,codpromotor   

drop table #baseLiqui 


        

------ #TCSCARTERA_Liquidados        --- desgloce por prestamos con saldo sacado de TCSCARTERA

DECLARE @TCSCARTERA_Liquidados TABLE (
    CODASESOR varchar(50),
    Ptmos_Liquidados varchar(35),
    SALDO_Liquidado MONEY
      ,Estado  varchar(30))         

INSERT INTO @TCSCARTERA_Liquidados (CODASESOR, Ptmos_Liquidados, SALDO_Liquidado, Estado)
SELECT   
--C.FECHA,                      
liq.codpromotor  CODASESOR
,(CASE WHEN C.NRODIASATRASO <=30 THEN C.CODPRESTAMO END) 'Ptmos_Liquidados'
,(CASE WHEN C.NRODIASATRASO <=30 THEN C.SALDOCAPITAL ELSE 0 END) 'SALDO_Liquidado'
,liq.Estado
FROM TCSCARTERA C WITH(NOLOCK)    
inner join @liq liq ON   liq.codprestamo = C.codprestamo  --liq.codpromotor = C.CODASESOR and
WHERE C.FECHA=@FECINI                                                               -->  Estaba activo al inicio del mes
		and C.CODPRESTAMO in ( select codprestamo from @liq )                         -->  se liquido en lo que va del mes
order by C.CODASESOR


------ #Cartera_Liquidados         --- suma por asesor
DECLARE @Cartera_Liquidados TABLE (
    CODASESOR varchar(50),
    Ptmos_Liquidados int,
    SALDO_Liquidado MONEY
)
INSERT INTO @Cartera_Liquidados (CODASESOR, Ptmos_Liquidados, SALDO_Liquidado)
SELECT 
	CODASESOR
	,COUNT(Ptmos_Liquidados) 'Ptmos_Liquidados'
	,SUM(SALDO_Liquidado) 'SALDO_Liquidado' 
FROM @TCSCARTERA_Liquidados
GROUP BY  CODASESOR
order by CODASESOR






------ #ptmosANTERIOR_Renovado           --- el codigo de prestamo es el que dejo de estar vigente este mes. 

DECLARE @codANTERIOR_Renovados TABLE (
    CODASESOR varchar(50),
    PtmosANTERIOR_Renovados varchar(35),
    SALDO_Liquidado MONEY
      ,Estado  varchar(30))         

INSERT INTO  @codANTERIOR_Renovados (CODASESOR, PtmosANTERIOR_Renovados, SALDO_Liquidado, Estado)
SELECT   
*
FROM @TCSCARTERA_Liquidados   
WHERE   Estado = 'RENOVADO'        
order by CODASESOR



------ #ptmosNuevos_Renovados           --- nuevo prestamo debido a una renovacion durante el mes. 

DECLARE @TCSCARTERA_Renovados TABLE (
    CODASESOR varchar(50),
    Ptmos_Renovados varchar(35),
    SALDO_Renovado MONEY
      ,Estado  varchar(30))         

INSERT INTO @TCSCARTERA_Renovados (CODASESOR, Ptmos_Renovados, SALDO_Renovado, Estado)
SELECT   
--C.FECHA,                      
C.CODASESOR  CODASESOR
,(CASE WHEN C.NRODIASATRASO <=30 THEN C.CODPRESTAMO END) 'Ptmos_Renovados'
,(CASE WHEN C.NRODIASATRASO <=30 THEN C.SALDOCAPITAL ELSE 0 END) 'SALDO_Renovado'
, C.Estado
FROM TCSCARTERA C WITH(NOLOCK)    
inner join @codANTERIOR_Renovados Ren  -->  se liquido en lo que va del mes
			ON   Ren.CODASESOR = C.CODASESOR and  Ren.PtmosANTERIOR_Renovados = C.codANTERIOR        -- se renueva con el mismo asesor
WHERE C.FECHA=@FECHA                                                               -->  Estaba activo al inicio del mes
order by C.CODASESOR



------ #Cartera_RENOVADOS
DECLARE @Cartera_Renovados TABLE (
    CODASESOR varchar(50),
    Ptmos_Renovados int,
    SALDO_Renovado MONEY
)

INSERT INTO @Cartera_Renovados (CODASESOR, Ptmos_Renovados, SALDO_Renovado)
SELECT 
	CODASESOR
	,COUNT(Ptmos_Renovados) 'Ptmos_Renovados'
	,SUM(SALDO_Renovado) 'SALDO_Renovado' 
FROM @TCSCARTERA_Renovados
GROUP BY  CODASESOR
order by CODASESOR


--select * from @Cartera_Liquidados Liq
--inner join @Cartera_Renovados Ren on Liq.CODASESOR = Ren.CODASESOR



          
--+++++++++++++++++++++++++++++/*CARTERA CASTIGADA */+++++++++++++++++++++++++++++++++++++++++                   
               
--CREATE TABLE #PTMOSCAST(CODPRESTAMO VARCHAR(25))                    
--INSERT INTO #PTMOSCAST                    
--SELECT C.CODPRESTAMO                    
--FROM TCSCARTERA C WITH(NOLOCK)                    
--INNER JOIN TCLOFICINAS O WITH(NOLOCK) ON O.CODOFICINA=C.CODOFICINA                    
--WHERE C.FECHA=@FECHA          
--AND C.CODPRESTAMO NOT IN (SELECT CODPRESTAMO FROM TCSCARTERAALTA WITH(NOLOCK))                    
--AND C.CODOFICINA NOT IN('97','230','231','999','98')                    
--AND C.CARTERA='ACTIVA'           
--AND O.TIPO<>'CERRADA'                     
--GROUP BY C.FECHA,C.CODPRESTAMO            
          
--SET @T2=GETDATE()          
--PRINT '4 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()                  
                    
--INSERT INTO #PTMOSCAST                    
--SELECT CODPRESTAMO                    
--FROM TCSPADRONCARTERADET WITH(NOLOCK)                    
--WHERE PASECASTIGADO>=@FECINI AND PASECASTIGADO<=@FECHA                    
                    
--SET @T2=GETDATE()          
--PRINT '5 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()              
          
------SE CREA TEMPORAL           
----CREATE TABLE #TMPCACASTIGADO(PROMOTOR VARCHAR(255),CODOFICINA VARCHAR(5),FECHA SMALLDATETIME,CODASESOR VARCHAR(30)          
----,CODPRESTAMO VARCHAR(30),SALDOCASTIGADO MONEY)          
----INSERT INTO #TMPCACASTIGADO                  
--SELECT                     
--CD.CODOFICINA,C.FECHA,                  
--C.CODASESOR,C.CODPRESTAMO,          
--CASE WHEN C.ESTADO='CASTIGADO' THEN (CD.SALDOCAPITAL) ELSE 0 END SALDOCASTIGADO           
--INTO #TMPCACASTIGADO                           
--FROM TCSCARTERA C WITH(NOLOCK)                    
--INNER JOIN TCSCARTERADET CD WITH(NOLOCK) ON C.FECHA=CD.FECHA AND C.CODPRESTAMO=CD.CODPRESTAMO                    
--WHERE C.FECHA=@FECHA AND C.CODPRESTAMO IN(SELECT CODPRESTAMO FROM #PTMOSCAST)             
                
                    
--DECLARE @CASTIGADA TABLE ( FECHA SMALLDATETIME,                    
--         CODOFICINA VARCHAR(3),                        
--         CODASESOR VARCHAR(15),                        
--         SALDOCASTIGADO MONEY)                        
--INSERT INTO @CASTIGADA                      
--SELECT FECHA,CODOFICINA,CODASESOR                  
--,SUM(SALDOCASTIGADO) SALDOCASTIGADO              
--FROM #TMPCACASTIGADO A WITH(NOLOCK)                         
--GROUP BY FECHA,CODOFICINA,CODASESOR                 
          
--SET @T2=GETDATE()          
--PRINT '6 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
                   
--DROP TABLE #PTMOSCAST                    
--DROP TABLE #TMPCACASTIGADO                                      
----SELECT * FROM @CASTIGADA                    
          
--SET @T2=GETDATE()          
--PRINT '7 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
--------------------------          
--+++++++++++++++++++++++++++++/*COLOCACIÓN */+++++++++++++++++++++++++++++++++++++++++                   
          
--DECLARE @COLOCACION TABLE(   CODASESOR VARCHAR(15),                    
--         MONTOCOLOCACION MONEY,                   
--         TOTALPTMOS INT)                    
--INSERT INTO @COLOCACION                   
--SELECT P.ULTIMOASESOR,                    
--SUM(P.MONTO)MONTOENTREGA,                    
--COUNT(P.CODPRESTAMO)TOTALPTMOS                    
--FROM TCSPADRONCARTERADET P WITH(NOLOCK)                    
--WHERE P.DESEMBOLSO>=@FECINI AND P.DESEMBOLSO<=@FECHA                    
--AND P.CODOFICINA NOT IN ('97','999')                 
--GROUP BY P.ULTIMOASESOR                    
                    
--SET @T2=GETDATE()          
--PRINT '8 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()                 
                    
                            
     ---COMENTADO--- ACTUALMENTE SIN USARSE --           
               
--+++++++++++++++++++++++++++++/*PRESTAMOS LIQUIDADOS Y RENOVADOS*/  +++++++++++++++++++++++++++++++++++++++++                   
                
--CREATE TABLE #BASELIQUI (CODOFICINA VARCHAR(5)                    
--      ,SUCURSAL VARCHAR(50)                    
--      ,COORDINADOR  VARCHAR(500)                    
--      ,CODPROMOTOR  VARCHAR(50)                    
--      ,CODPRESTAMO VARCHAR(35)                    
--      ,SECUENCIACLIENTE INT                    
--      ,CANCELACION  SMALLDATETIME                    
--      ,ATRASOMAXIMO  INT                    
--      ,ESTADO  VARCHAR(30))                             
--INSERT INTO #BASELIQUI                     
--EXEC PCSCALIQRRPROMOTOR @FECHA,@FECINI   ----NO USAR PCSCALIQRRPROMOTOR             
               
               
--SET @T2=GETDATE()          
--PRINT '9 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
               
/*PARA CICLOS 1,2 Y 3 SE TOMAN HASTA 8 DIAS DE ATRASO, C4+ HASTA 15 DIAS A. -- CAMBIO SOLICITADO POR LAURA VEGA*/                    
--DECLARE  @LIQ TABLE(CODOFICINA VARCHAR(4),COORDINADOR VARCHAR(500),CODPROMOTOR VARCHAR(50),NRO INT)                    
--INSERT INTO @LIQ                    
--SELECT CODOFICINA,COORDINADOR,CODPROMOTOR--,COUNT(CODPRESTAMO) NRO--,SUM(MONTO)MONTO                    
--,SUM(CASE WHEN SECUENCIACLIENTE<=3 AND ATRASOMAXIMO<=8 THEN 1                      
--   WHEN SECUENCIACLIENTE>3 AND ATRASOMAXIMO<=15 THEN 1                    
--   ELSE 0 END) NRO                    
--FROM #BASELIQUI  --WITH(NOLOCK)                     
--WHERE CANCELACION>=@FECINI AND CANCELACION<=@FECHA                    
--AND ATRASOMAXIMO<=15                 
----AND CODPROMOTOR='CBJ881122FH600' -------OJO                       
--GROUP BY CODOFICINA,COORDINADOR,CODPROMOTOR                    
                    
--SET @T2=GETDATE()          
--PRINT '10 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
                            
--DROP TABLE #BASELIQUI                     
             
--+++++++++++++++++++++++++++++ /*COBRANZA PUNTUAL */ +++++++++++++++++++++++++++++++++++++++++   --- se optimiza sp 2023.10.17 zccu                    
                
   
create table #ptmosCPP (codprestamo varchar(25),codoficina varchar(4),nrodiasatraso int,secuenciacliente int,codproducto char(3),codasesor varchar(15))--          
insert into #ptmosCPP          
select c.codprestamo,c.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,codasesor----,d.ultimoasesor ---->Se cambia por codasesor(cartera)           
from tcscartera c with(nolock)          
inner join tcspadroncarteradet d with(nolock) on c.codprestamo=d.codprestamo          
where c.fecha=@fecha---1   
and c.codoficina not in ('97','230','231','999')         
and cartera='ACTIVA'          
        
insert into #ptmosCPP          
select d.codprestamo,d.codoficina,c.nrodiasatraso,d.secuenciacliente,c.codproducto,d.ultimoasesor          
from tcspadroncarteradet d with(nolock)          
left outer join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fechacorte          
where d.cancelacion>=@fecini and d.cancelacion<=@fecha          
and c.codoficina not in ('97','230','231','999')    
        
        
        
create table #CUOCPP(          
          codoficina varchar(4),          
          codprestamo varchar(25),          
          seccuota int,          
          montodevengado money,          
          montopagado money,          
          montocondonado money,          
          fechavencimiento smalldatetime,          
          fechapago smalldatetime,          
          estadocuota varchar(20))          
insert into #CUOCPP          
select p.codoficina,cu.codprestamo,cu.seccuota          
,sum(cu.montodevengado) montodevengado          
,sum(cu.montopagado) montopagado          
,sum(cu.montocondonado) montocondonado          
,cu.fechavencimiento          
,max(cu.fechapagoconcepto) fechapago          
,cu.estadocuota          
from tcspadronplancuotas cu with(nolock)          
inner join #ptmosCPP p with(nolock) on p.codprestamo=cu.codprestamo          
where cu.codprestamo in(select codprestamo from #ptmosCPP)          
and cu.numeroplan=0          
and cu.seccuota>0 
and cu.codconcepto = 'CAPI'                  
and cu.fechavencimiento>=@fecini and cu.fechavencimiento<=@fecha          
group by cu.codprestamo,cu.seccuota,cu.fechavencimiento          
,cu.estadocuota,p.codoficina          
    
  CREATE TABLE #COBRANZAP (FECHA SMALLDATETIME,          
						   REGION VARCHAR(30),          
						   SUCURSAL VARCHAR(30),          
						   CODOFICINA VARCHAR(4),          
						   PROMOTOR VARCHAR(200),          
						   ATRASO VARCHAR (10),          
						   PROGRAMADO_S MONEY,          
						   MONTO_ANTICIPADO MONEY,          
						   MONTO_PUNTUAL MONEY,          
						   MONTO_ATRASADO MONEY)                    
INSERT INTO  #COBRANZAP          
select @fecha fecha, z.Nombre region          
,o.nomoficina sucursal        
,p.codoficina codoficina        
,pro.nombrecompleto promotor             
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'          
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'          
            when ca.nrodiasatraso>=31 then '31+DM' else '' end atraso               
,sum(p.montodevengado) programado_s          
,sum(case when p.estadocuota='CANCELADO'and p.fechapago<p.fechavencimiento then p.montopagado else 0 end) monto_anticipado          
,sum(case when p.estadocuota='CANCELADO' and p.fechapago=p.fechavencimiento then p.montopagado else 0 end) monto_puntual          
,sum(case when p.estadocuota='CANCELADO' and p.fechapago>p.fechavencimiento and p.fechapago<=@fecha then p.montopagado else 0 end) momto_atrasado            
from #CUOCPP p with(nolock)          
inner join #ptmosCPP ca with(nolock) on ca.codprestamo=p.codprestamo          
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina          
inner join tclzona z with(nolock) on z.zona=o.zona          
inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor          
where o.zona not in('ZSC','ZCO')          
group by p.fechavencimiento,z.Nombre          
,o.nomoficina         
,p.codoficina         
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'          
when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'          
            when ca.nrodiasatraso>=31 then '31+DM' else '' end          
            ,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then 1          
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then 2          
            when ca.nrodiasatraso>=31 then 3 else 4 end          
,pro.nombrecompleto          
order by z.Nombre          
              
drop table #ptmosCPP          
drop table #CUOCPP          
              
------DEL PRIMER DIA DEL MES A LA FECHA DE CONSULTA                          
--CREATE TABLE #COBRANZAP (FECHA SMALLDATETIME,          
--						   REGION VARCHAR(15),          
--						   SUCURSAL VARCHAR(30),          
--						   CODOFICINA VARCHAR(4),          
--						   PROMOTOR VARCHAR(200),          
--						   ATRASO VARCHAR (10),          
--						   PROGRAMADO_S MONEY,          
--						   MONTO_ANTICIPADO MONEY,          
--						   MONTO_PUNTUAL MONEY,          
--						   MONTO_ATRASADO MONEY)                    
--INSERT INTO  #COBRANZAP                    
--EXEC PCSCACOBRANZAPUNTUALCARTAS @FECHA,@FECINI     --- se optimiza sp 2023.10.17 zccu     
             
         
--SET @T2=GETDATE()          
--PRINT '4 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
                
--CREATE TABLE #COBRANZAP (                    
--   FECHA SMALLDATETIME,FECHAVENCIMIENTO SMALLDATETIME,REGION VARCHAR(15)                     
--   ,SUCURSAL VARCHAR(30),ATRASO VARCHAR (10),RANGOCICLO VARCHAR(10)                    
--   ,SALDO MONEY,CONDONADO MONEY,PROGRAMADO_N INT,PROGRAMADO_S MONEY                     
--   ,ANTICIPADO INT,PUNTUAL INT ,ATRASADO INT,MONTO_ANTICIPADO MONEY                     
--   ,MONTO_PUNTUAL MONEY,MONTO_ATRASADO MONEY,CREDITOSPAGADOS INT                     
--   ,CAPITALPAGADO MONEY,PAGADO_POR MONEY,SINPAGO_N INT                    
--   ,SINPAGO_S MONEY,SINPAGO_POR MONEY,PAGOPARCIAL_N INT                    
--   ,PAGOPARCIAL_S MONEY,PARCIAL_POR MONEY,TOTAL_N INT                    
--   ,TOTAL_S MONEY,TOTAL_POR MONEY,ORDEN INT,PROMOTOR VARCHAR(200))                    
--INSERT INTO  #COBRANZAP                    
--EXEC PCSCACOBRANZAPUNTUAL @FECHA,@FECINI                    
                    
DECLARE @COP TABLE ( FECHA SMALLDATETIME,             
					 PROMOTOR VARCHAR(200),                    
					 PROGRAMADO_S MONEY,                    
					 MONTO_ANTICIPADO MONEY,                    
					 MONTO_PUNTUAL MONEY,                   
					 MONTO_ATRASADO MONEY,                    
					 PAGOPUNTUAL MONEY,                    
					 PAGOACUMULADO MONEY)                    
INSERT INTO @COP                    
SELECT FECHA,PROMOTOR,                  
SUM(PROGRAMADO_S) PROGRAMADO_S,                    
SUM(MONTO_ANTICIPADO)MONTO_ANTICIPADO,                    
SUM(MONTO_PUNTUAL)MONTO_PUNTUAL,                    
SUM(MONTO_ATRASADO) MONTO_ATRASADO,                   
CASE WHEN SUM(PROGRAMADO_S)=0  THEN 0 ELSE SUM(MONTO_PUNTUAL+MONTO_ANTICIPADO)/SUM(PROGRAMADO_S)END  PAGOPUNTUAL,                    
CASE WHEN SUM(PROGRAMADO_S)=0  THEN 0 ELSE SUM(MONTO_ANTICIPADO+MONTO_PUNTUAL+MONTO_ATRASADO)/SUM(PROGRAMADO_S)END  PAGOACUMULADO                    
FROM #COBRANZAP WITH(NOLOCK)                    
WHERE ATRASO IN ('0-7DM','8-30DM')                    
GROUP BY FECHA,PROMOTOR                    
          
--SET @T2=GETDATE()          
--PRINT '5 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
                  
DROP TABLE #COBRANZAP                    
             
--+++++++++++++++++++++++++++++/*INTERESES COBRADOS POR PROMOTOR*/  +++++++++++++++++++++++++++++++++++++++++                   
--- AJUSTE EN INTERES COBRADO 27.02.2023 ZCCU              
--- CALCULO MENSUAL          
          
CREATE TABLE  #PTMOSPAGOS(FECHA SMALLDATETIME,CODPRESTAMO VARCHAR(25),INTERES MONEY)              
INSERT INTO #PTMOSPAGOS              
SELECT D.FECHA,CODIGOCUENTA,MONTOINTERESTRAN            
FROM TCSTRANSACCIONDIARIA D WITH(NOLOCK)              
WHERE  D.FECHA>=@FECINI AND D.FECHA<=@FECHA              
AND D.CODSISTEMA='CA'             
AND TIPOTRANSACNIVEL3 IN(104,105)             
AND EXTORNADO=0              
            
--SET @T2=GETDATE()          
--PRINT '6 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
          
CREATE TABLE  #INTCO(FECHA SMALLDATETIME,              
					CODPRESTAMO VARCHAR(25),              
					INTERES MONEY,            
					NRODIAS INT,            
					CODOFICINA VARCHAR(4),            
					CODASESOR VARCHAR(25))             
INSERT INTO #INTCO            
SELECT            
P.FECHA,P.CODPRESTAMO,P.INTERES,C.NRODIASATRASO DIAS,C.CODOFICINA,CODASESOR            
FROM #PTMOSPAGOS P WITH(NOLOCK)              
INNER JOIN TCSCARTERA C WITH(NOLOCK) ON (C.FECHA+1)=P.FECHA AND C.CODPRESTAMO=P.CODPRESTAMO               
WHERE C.CODOFICINA NOT IN('98','97','230','231','999')  
AND  ISNULL(C.NRODIASATRASO,0)<=30           
          
           
--SET @T2=GETDATE()          
--PRINT '7 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()           
           
INSERT INTO #INTCO            
SELECT P.FECHA,P.CODPRESTAMO,          
P.INTERES,0 DIAS,PD.CODOFICINA,ISNULL(ULTIMOASESOR,PRIMERASESOR)            
FROM #PTMOSPAGOS P WITH(NOLOCK)              
INNER JOIN TCSPADRONCARTERADET PD WITH(NOLOCK)ON P.FECHA=PD.DESEMBOLSO AND P.CODPRESTAMO=PD.CODPRESTAMO             
          
--SET @T2=GETDATE()          
--PRINT '8 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
          
DECLARE @INTECOBRADO TABLE(FECHA SMALLDATETIME,CODASESOR VARCHAR(25),INTERESCOBRADO MONEY)                 
INSERT INTO @INTECOBRADO              
SELECT @FECHA,CODASESOR,SUM(INTERES)INTERES            
FROM #INTCO C WITH(NOLOCK)             
WHERE ISNULL(NRODIAS,0)<=30              
GROUP BY CODASESOR             
           
          
--SET @T2=GETDATE()          
--PRINT '9 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
          
--DROP TABLE #PTMOSPAGOS            
--DROP TABLE #INTCO            
          
          
--+++++++++++++++++++++++++++++/*INTERESES COBRADOS POR PROMOTOR PARA LA PRIMERA Y SEGUNDA QUINCENA  */  +++++++++++++++++++++++++++++++++++++++++                   
DECLARE @INTECOBRADO_1Q TABLE(FECHA SMALLDATETIME,CODASESOR VARCHAR(25),INTERESCOBRADO MONEY)                 
DECLARE @INTECOBRADO_2Q TABLE(FECHA SMALLDATETIME,CODASESOR VARCHAR(25),INTERESCOBRADO MONEY)                 
          
          
IF(@EVA=1)           
  BEGIN          
  INSERT INTO @INTECOBRADO_1Q               
  SELECT @FECHA,CODASESOR,SUM(INTERES)INTERES            
  FROM #INTCO C WITH(NOLOCK)             
  WHERE ISNULL(NRODIAS,0)<=30              
  GROUP BY CODASESOR           
            
  INSERT INTO @INTECOBRADO_2Q               
  SELECT @FECHA,CODASESOR,0 INTERES            
  FROM #INTCO C WITH(NOLOCK)             
  WHERE ISNULL(NRODIAS,0)<=30              
  GROUP BY CODASESOR              
  END          
ELSE          
  BEGIN           
  INSERT INTO @INTECOBRADO_1Q               
  SELECT @FECHA,CODASESOR,SUM(INTERES)INTERES            
  FROM #INTCO C WITH(NOLOCK)             
  WHERE ISNULL(NRODIAS,0)<=30            
        AND C.FECHA>=@FECINI AND C.FECHA<@FECEVAL           
  GROUP BY CODASESOR           
          
  INSERT INTO @INTECOBRADO_2Q               
  SELECT @FECHA,CODASESOR,SUM(INTERES)INTERES            
  FROM #INTCO C WITH(NOLOCK)             
  WHERE ISNULL(NRODIAS,0)<=30           
  AND C.FECHA>=@FECEVAL            
  GROUP BY CODASESOR     
           
  END          
            
DROP TABLE #PTMOSPAGOS            
DROP TABLE #INTCO            
          
--+++++++++++++++++++++++++++++/*METAS DE CRECIMIENTO*/  +++++++++++++++++++++++++++++++++++++++++                   
          
DECLARE @METAS TABLE(CODASESOR VARCHAR(15),PTMOSMETAMENSUAL INT,SALDOMETAMENSUAL MONEY)          
INSERT INTO @METAS          
SELECT CODIGO CODASESOR,          
SUM(CASE WHEN META = 4 THEN MONTO ELSE 0 END) PTMOSMETAMENSUAL,          
SUM(CASE WHEN META = 1 THEN MONTO ELSE 0 END) SALDOMETAMENSUAL          
FROM TCSCAMETAS WITH(NOLOCK)          
WHERE FECHA=@FECFIN AND TIPOCODIGO = 2          
GROUP BY CODIGO          
            
--SET @T2=GETDATE()          
--PRINT '16 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
          
--+++++++++++++++++++++++++++++/*ANTIGUEDAD DE PROMOTORES ACTIVOS */  +++++++++++++++++++++++++++++++++++++++++                   
--ANTIGUEDAD POR MESES NO POR DIAS, SOLICITADO POR MERCEDES               
                 
DECLARE @ANTIQUEDAD TABLE(FECHA SMALLDATETIME,          
       CODOFICINA VARCHAR(4),          
       CODUSUARIO VARCHAR(30),          
       COORDINADOR VARCHAR(250),          
       MES INT,          
       RANGO VARCHAR(10),           
       INGRESO SMALLDATETIME)                    
INSERT INTO @ANTIQUEDAD                    
SELECT B1.FECHA,          
--CO.CODOFICINA,       
E.CODOFICINANOM,         
B1.CODUSUARIO,                    
CASE WHEN (E.CODUSUARIO IS NULL OR E.CODPUESTO<>66) THEN 'HUERFANO' ELSE CO.NOMBRECOMPLETO END COORDINADOR,                        
(DATEDIFF(MONTH,E.INGRESO,B1.FECHA)) MESESANTIGUEDAD,                     
CASE  WHEN (DATEDIFF(MONTH,E.INGRESO,B1.FECHA)) >= 12 THEN '12+M'                    
  WHEN (DATEDIFF(MONTH,E.INGRESO,B1.FECHA)) >= 9 THEN '9-12M'                    
  WHEN (DATEDIFF(MONTH,E.INGRESO,B1.FECHA)) >= 6 THEN '6-9M'                    
  WHEN (DATEDIFF(MONTH,E.INGRESO,B1.FECHA)) >= 3 THEN '3-6M'                    
  ELSE '0-3M' END RANGOANTIGUEDAD,                    
E.INGRESO INGRESO                    
FROM TCSEMPLEADOSFECHA AS B1 WITH(NOLOCK)                    
INNER JOIN TCSEMPLEADOS AS E WITH(NOLOCK) ON B1.CODUSUARIO=E.CODUSUARIO                    
INNER JOIN TCSPADRONCLIENTES CO WITH(NOLOCK) ON CO.CODUSUARIO=E.CODUSUARIO                       
WHERE B1.CODPUESTO=66           
AND B1.FECHA=@FECHA    -- '20250118' --       
AND E.ESTADO=1                      
AND B1.CODOFICINA NOT IN ('98','97','99','230','231','999') 
--and co.codusuario='BPN970827FM600'


--select * from @ANTIQUEDAD

SELECT CodUsuario, 66 CodPuesto,  MIN(Fecha)  AS FechaIngresoPromotor
into #ingresoPromotor
FROM TCSEMPLEADOSFECHA
WHERE codusuario in (select codusuario from @ANTIQUEDAD)
and CodPuesto = 66
GROUP BY CodUsuario;

                   
--SET @T2=GETDATE()          
--PRINT '17 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
                   
DELETE FROM @ANTIQUEDAD WHERE COORDINADOR='HUERFANO'                      
          
--+++++++++++++++++++++++++++++/*NIVEL DE PROMOTOR / CATEGORIAS */  +++++++++++++++++++++++++++++++++++++++++                   
          
--+++++++++++++++++++++++++++++/*ASIGNACIONES Y QUITAS DE CARTERA */  +++++++++++++++++++++++++++++++++++++++++           
---TABLA DIARIA CON INFORMACION A LA FECHA DE CORTE              
--DECLARE @QUITAS TABLE (CODPROMOTOR VARCHAR(15),          
--      PTMOS_QUITAS INT,          
--      SALDO_QUITAS MONEY,          
--      PTMOS_ASIG INT,          
--      SALDO_ASIG MONEY)          
--INSERT INTO @QUITAS          
--SELECT CODPROMOTOR,          
--ISNULL(QUI_NRO_QUI,0) PTMOS_QUITA,          
--ISNULL(QUI_MONTO_QUI,0) CARTERA_QUITA,          
--ISNULL(ASI_NRO_ASI,0) PTMOS_ASIG,          
--ISNULL(ASI_MONTO_ASI,0) CARTERA_ASIG          
--FROM TCSACRECIMIENTOPROMOTOR WITH(NOLOCK)          
--WHERE CODPROMOTOR IS NOT NULL  ----VERSION ANTIGUA     
    
  ---- Nuevo calculo para Quitas y asignaciones de Cartera JRAC --solicitado por Mauricio  
    
--create table #o (sec int identity(1,1),codoficina varchar(4))      
--insert into #o(codoficina)      
--select codoficina from tcloficinas with(nolock) where tipo<>'Cerrada'      
--and codoficina not in('98','97','99','230','231','999')      
--and (cast(codoficina as int)<=99 or cast(codoficina as int)>=300)      

   
--SET @T2=GETDATE()          
--PRINT '18 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
 
CREATE TABLE #quitastab  (promotor VARCHAR(200),      
						  codpromotor VARCHAR(30),      
						  qui_nro_qui int,      
						  qui_monto_qui money,      
						  asi_nro_asi  int,      
						  asi_monto_asi MONEY)  
INSERT INTO  #quitastab    
exec  pCsACaCreciappquitasappVs2   -- crea nuevo sp: calcular todas las sucursales 
     
--declare @codoficina varchar(4)      ----- demora el doble al calcular las quitas en un while
--declare @n int      
--declare @x int      
--select @n=count(*) from #o      
--set @x=1      
--while(@x<=@n)      
--begin      
--select @codoficina=codoficina from #o where sec=@x      
----print @codoficina      
--INSERT INTO  #quitastab    
--exec  pCsACaCreciappquitasapp @codoficina    
----print @x      
--set @x=@x+1      
--end      
     
--SET @T2=GETDATE()          
--PRINT '19 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()             
    
---TABLA DIARIA CON INFORMACION A LA FECHA DE CORTE              
DECLARE @QUITAS TABLE(CODPROMOTOR VARCHAR(15),          
					  PTMOS_QUITAS INT,          
					  SALDO_QUITAS MONEY,          
					  PTMOS_ASIG INT,          
					  SALDO_ASIG MONEY)       
             
--INSERT INTO @QUITAS          
--SELECT CODPROMOTOR,          
--ISNULL(QUI_NRO_QUI,0) PTMOS_QUITA,          
--ISNULL(QUI_MONTO_QUI,0) CARTERA_QUITA,          
--ISNULL(ASI_NRO_ASI,0) PTMOS_ASIG,          
--ISNULL(ASI_MONTO_ASI,0) CARTERA_ASIG          
--FROM TCSACRECIMIENTOPROMOTOR WITH(NOLOCK)          
--WHERE CODPROMOTOR IS NOT NULL          
               
INSERT INTO @QUITAS       
SELECT codpromotor,          
ISNULL(qui_nro_qui,0) PTMOS_QUITA,          
ISNULL(qui_monto_qui,0) CARTERA_QUITA,          
ISNULL(asi_nro_asi ,0) PTMOS_ASIG,          
ISNULL(asi_monto_asi,0) CARTERA_ASIG          
FROM #quitastab  WITH(NOLOCK)          
WHERE CODPROMOTOR IS NOT NULL          
               
    
--drop table #o      
drop table #quitastab              
        
               
               
--SET @T2=GETDATE()          
--PRINT '20 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()               
               
               
--+++++++++++++++++++++++++++++/*COLOCACIÓN --- CREDITOS NUEVOS DESEMBOLSADOS CORRESPONDIENES AL CICLO 1 */+++++++++++++++++++++++++++++++++++++++++                   
          
--DECLARE @PTMOS_NUEVOS TABLE(   CODASESOR VARCHAR(15),                    
--         MONTOCOLOCACION_NUEVOS  MONEY,                   
--         TOTALPTMOS_NUEVOS INT)                    
--INSERT INTO @PTMOS_NUEVOS                   
--SELECT P.ULTIMOASESOR,                    
--SUM(P.MONTO)MONTOENTREGA,                    
--COUNT(P.CODPRESTAMO)TOTALPTMOS            
-----SELECT TOP 1 *                  
--FROM TCSPADRONCARTERADET P WITH(NOLOCK)                    
--WHERE P.DESEMBOLSO>=@FECINI AND P.DESEMBOLSO<=@FECHA                    
--AND P.CODOFICINA NOT IN ('97','999')          
--AND ISNULL(SECUENCIACLIENTE,1)=1               
--GROUP BY P.ULTIMOASESOR                    
                       
               
--+++++++++++++++++++++++++++++/*COLOCACIÓN --- CREDITOS NUEVOS-RENOVADOS-REACTIVADOS */+++++++++++++++++++++++++++++++++++++++++                   
          
     
DECLARE @LIQRENO TABLE(CODPRESTAMO VARCHAR(30)          
      ,DESEMBOLSO SMALLDATETIME          
      ,CODUSUARIO VARCHAR(15)          
      ,CANCELACION SMALLDATETIME)          
INSERT INTO @LIQRENO          
SELECT P.CODPRESTAMO,P.DESEMBOLSO,P.ULTIMOASESOR,MAX(A.CANCELACION) CANCELACION          
--SELECT TOP 10*          
FROM TCSPADRONCARTERADET P WITH(NOLOCK)          
LEFT OUTER JOIN TCSPADRONCARTERADET A WITH(NOLOCK) ON P.CODUSUARIO=A.CODUSUARIO AND A.CANCELACION<=P.DESEMBOLSO          
WHERE P.DESEMBOLSO>=@FECINI           
AND P.DESEMBOLSO<=@FECHA           
AND P.CODOFICINA not in ('97','230','231','999')            
GROUP BY P.CODPRESTAMO,P.DESEMBOLSO,P.ULTIMOASESOR          
HAVING MAX(A.CANCELACION) IS NOT NULL          
          
DECLARE @COLOCACION_MONTOS TABLE(--CODOFICINA VARCHAR(30),          
      CODASESOR VARCHAR(30)               
      ,RENOVANTENT MONEY       
      ,REACTENT MONEY          
      ,RENOVENT MONEY          
      ,NUEVOENT MONEY          
      ,MONTOENTREGA MONEY          
      ,RENOVPTMOS INT          
      ,RANTICIPAPTMOS INT          
      ,REACTIVAPTMOS  INT          
      ,NUEVOSPTMOS  INT          
      ,TOTAPTMOS INT)          
INSERT INTO @COLOCACION_MONTOS          
SELECT --P.CODOFICINA,
C.CODASESOR--P.ULTIMOASESOR,          
------------------------ COLOCACION ENTREGA --MONTO          
,SUM(CASE WHEN P.TIPOREPROG='RENOV' THEN P.MONTO ELSE 0 END )RENOVANTENT          
,SUM(CASE WHEN P.TIPOREPROG='RENOV' THEN 0 ELSE          
                CASE WHEN L.CANCELACION IS NULL THEN 0 ELSE          
                CASE WHEN MONTH(L.CANCELACION)=MONTH(P.DESEMBOLSO) AND YEAR(L.CANCELACION)=YEAR(P.DESEMBOLSO)          
                      THEN 0 ELSE P.MONTO END END END) REACENTREGA          
,SUM(CASE WHEN P.TIPOREPROG='RENOV' THEN 0 ELSE          
                CASE WHEN L.CANCELACION IS NULL THEN 0 ELSE          
                CASE WHEN MONTH(L.CANCELACION)=MONTH(P.DESEMBOLSO) AND YEAR(L.CANCELACION)=YEAR(P.DESEMBOLSO)          
                               THEN P.MONTO  ELSE 0 END END END) RENOVENT             
,SUM(CASE WHEN L.CANCELACION IS NULL  THEN P.MONTO ELSE 0 END) NUEVOENTREGA          
,SUM(P.MONTO)MONTOENTREGA          
---------------------------#CRÉDITOS           
,SUM(CASE WHEN P.TIPOREPROG='RENOV' THEN 0 ELSE          
                CASE WHEN L.CANCELACION IS NULL THEN 0 ELSE          
                CASE WHEN MONTH(L.CANCELACION)=MONTH(P.DESEMBOLSO) AND YEAR(L.CANCELACION)=YEAR(P.DESEMBOLSO)          
                               THEN 1  ELSE 0 END END END) #RENOVPTMOS          
,SUM(CASE WHEN P.TIPOREPROG='RENOV' THEN 1 ELSE 0 END )#RANTICIPAPTMOS          
,SUM(CASE WHEN P.TIPOREPROG='RENOV' THEN 0 ELSE          
                CASE WHEN L.CANCELACION IS NULL THEN 0 ELSE          
                CASE WHEN MONTH(L.CANCELACION)=MONTH(P.DESEMBOLSO) AND YEAR(L.CANCELACION)=YEAR(P.DESEMBOLSO)          
                               THEN 0 ELSE 1 END END END) #REACTIVAPTMOS          
,SUM(CASE WHEN L.CANCELACION IS NULL  THEN 1 ELSE 0 END) #NUEVOSPTMOS          
,COUNT(P.CODPRESTAMO)#TOTAPTMOS          
FROM TCSPADRONCARTERADET P WITH(NOLOCK)          
LEFT OUTER JOIN @LIQRENO L ON L.CODPRESTAMO=P.CODPRESTAMO          
INNER JOIN TCSCARTERA C WITH(NOLOCK) ON C.CODPRESTAMO=P.CODPRESTAMO AND C.FECHA=P.DESEMBOLSO          
LEFT OUTER JOIN [10.0.2.14].FINMAS.DBO.TCASOLICITUDRENOVACIONANTICIPADAPROCE S ON S.CODSOLICITUD=C.CODSOLICITUD AND S.CODOFICINA=C.CODOFICINA          
WHERE P.DESEMBOLSO>=@FECINI AND P.DESEMBOLSO<=@FECHA          
AND P.CODOFICINA not in ('97','230','231','999')           
GROUP BY --P.CODOFICINA,
C.CODASESOR--,P.ULTIMOASESOR          
          
            
               
-- SET @T2=GETDATE()          
--PRINT '21 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          








                
--+++++++++++++++++++++++++++++/*CONSULTA FINAL */  +++++++++++++++++++++++++++++++++++++++++                   
                          
SELECT DISTINCT @FECINI FECHAINICIO          
,@FECHA FECHACONSULTA,A.CODUSUARIO CODASESOR          
,Z.NOMBRE REGION,O.NOMOFICINA SUCURSAL,A.COORDINADOR PROMOTOR            
,INGRESO FECHA_INGRESO 
,CASE  when IPr.FechaIngresoPromotor>'20180228' then CASE  
             WHEN IPr.FechaIngresoPromotor > INGRESO THEN IPr.FechaIngresoPromotor  
             ELSE INGRESO  END
      else INGRESO     END 'FechaIngresoPromotor'   
,MES ANTIGUEDAD            
,CASE WHEN ISNULL (C.SALDOINI0A30,0) <= 250000 THEN 'TRAINEE 1'           
      WHEN ISNULL (C.SALDOINI0A30,0) <= 500000 THEN 'TRAINEE 2'          
   WHEN ISNULL (C.SALDOINI0A30,0) <= 750000 THEN 'JUNIOR 1'          
   WHEN ISNULL (C.SALDOINI0A30,0) <= 1000000 THEN 'JUNIOR 2'          
   WHEN ISNULL (C.SALDOINI0A30,0) <= 1250000 THEN 'SENIOR 1'          
   WHEN ISNULL (C.SALDOINI0A30,0) <= 1500000 THEN 'SENIOR 2'          
   ELSE 'MASTER' END NIVEL_PROMOTOR          
,CASE WHEN ISNULL (C.SALDOINI0A30,0) <= 250000 THEN 2500           
      WHEN ISNULL (C.SALDOINI0A30,0) <= 500000 THEN 3000          
   WHEN ISNULL (C.SALDOINI0A30,0) <= 750000 THEN 5000          
   WHEN ISNULL (C.SALDOINI0A30,0) <= 1000000 THEN 7000          
   WHEN ISNULL (C.SALDOINI0A30,0) <= 1250000 THEN 9000          
   WHEN ISNULL (C.SALDOINI0A30,0) <= 1500000 THEN 11000          
--   ELSE (ISNULL(M.SALDOMETAMENSUAL,56000) + ISNULL (C.SALDOINI0A30,0)) *(0.08)/3*(0.04)*7 END BONO_ESTIMADO_CALCULADO ---se añama el termino (7/3) para que sea 7%        
   ELSE ISNULL (I.INTERESCOBRADO,0)*(0.08) END BONO_ESTIMADO_CALCULADO ---- SE AJUSTA PARA LOS MASTER CONSIDERAR EL 8% DE LOS INT COBRADOS       
         
,ISNULL (C.SALDOINI0A30,0) CA_VTGE0A30_INI          
,ISNULL (C.SALDOFIN0A30,0) CA_VTGE0A30_FIN          
          
,ISNULL(C.PTMOSVGTEINI,0)PTMOS_VGTE_INI          
,ISNULL(C.PTMOSVGTEFIN,0)PTMOS_VGTE_FIN          
          
,ISNULL(CP.SALDO_ASIG,0) MONTO_ASIG            
,ISNULL(CP.PTMOS_ASIG,0) PTMOS_ASIG          
          
,ISNULL(CP.SALDO_QUITAS,0) MONTO_QUITAS          
,ISNULL(CP.PTMOS_QUITAS,0) PTMOS_QUITAS          
------8 créditos y 56,000          
,ISNULL (C.SALDOFIN0A30,0) - ISNULL (C.SALDOINI0A30,0) - ISNULL(CP.SALDO_ASIG,0) + ISNULL(CP.SALDO_QUITAS,0)  DIFF_CARTERA          
,ISNULL(M.SALDOMETAMENSUAL,80000) SALDO_CRECIMIENTO_META          
,CASE WHEN (ISNULL (C.SALDOFIN0A30,0) - ISNULL (C.SALDOINI0A30,0) - ISNULL(CP.SALDO_ASIG,0) + ISNULL(CP.SALDO_QUITAS,0)) <= 0 THEN 0   
      WHEN SALDOMETAMENSUAL=0 THEN 0  
      ELSE (ISNULL (C.SALDOFIN0A30,0) - ISNULL (C.SALDOINI0A30,0) - ISNULL(CP.SALDO_ASIG,0) + ISNULL(CP.SALDO_QUITAS,0))/ISNULL(SALDOMETAMENSUAL,80000)           
      END CUMP_CARTERA          
          
,ISNULL(C.PTMOSVGTEFIN,0)-ISNULL(PTMOSVGTEINI,0) + ISNULL(CP.PTMOS_QUITAS,0) - ISNULL(CP.PTMOS_ASIG,0)CRECI_PTMOS_VGTES                             
,ISNULL(M.PTMOSMETAMENSUAL,12) PTMOS_CRECIMIENTO_META          
,CASE WHEN (ISNULL(C.PTMOSVGTEFIN,0)-ISNULL(C.PTMOSVGTEINI,0) + ISNULL(CP.PTMOS_QUITAS,0) - ISNULL(CP.PTMOS_ASIG,0))<= 0 THEN 0   
WHEN PTMOSMETAMENSUAL=0 THEN 0  
ELSE CAST ((ISNULL(C.PTMOSVGTEFIN,0)-ISNULL(C.PTMOSVGTEINI,0) + ISNULL(CP.PTMOS_QUITAS,0) - ISNULL(CP.PTMOS_ASIG,0))AS DECIMAL(6,2))/CAST(ISNULL(PTMOSMETAMENSUAL,12)AS DECIMAL(6,2))          
   END CUMP_CLIENTES          
          
,ISNULL(COP.PROGRAMADO_S,0) PROGRAMADO_S              
,ISNULL(COP.MONTO_ANTICIPADO,0) + ISNULL(MONTO_PUNTUAL,0) + ISNULL(MONTO_ATRASADO,0) MONTO_COBRADO          
,ISNULL (COP.PAGOPUNTUAL,0) PAGO_PUNTUAL                    
,ISNULL (COP.PAGOACUMULADO,0) PAGO_ACUMULADO                    
          
,ISNULL (C.SALDOINI31M,0) CART_VENCIDA_INI                
-------- Modificacion      Se quito que se sumaba el saldoCastigado por petición de Mauricio. El 2025.01.14  Sil.   Se quito : -- +ISNULL(Casti.SALDO_Castigado, 0)
,ISNULL (C.SALDOFIN31M,0) CART_VENCIDA_FIN                      
          
,ISNULL(C.SALDORIESGO,0) SALDO_RIESGO          
,ISNULL(C.PTMOSRIESGO,0)  PTMOS_RIESGO          
          
,ISNULL(MM.MONTOENTREGA,0)MOTO_COLOCACION_TOTAL          
,ISNULL(MM.TOTAPTMOS,0)PTMOS_COLOCACION_TOTAL          
          
,ISNULL(MM.NUEVOENT,0)MONTO_NUEVOS          
,ISNULL(MM.NUEVOSPTMOS,0)PTMOS_NUEVOS          
          
,ISNULL(MM.RENOVENT,0) MONTO_RENOV          
,ISNULL(MM.RENOVPTMOS,0)PTMOS_RENOV          
          
,ISNULL(MM.REACTENT,0)MONTO_REACTIVACIONES          
,ISNULL(MM.REACTIVAPTMOS,0)PTMOS_REACTIVACIONES          
          
,ISNULL(C.SALDOVIGTEINIC1,0) SALDO_VGTE_INI_C1          
,ISNULL(C.SALDOVIGTEFINC1,0) SALDO_VGTE_FIN_C1          
,ISNULL(C.DIF_SALDO_C1,0)DIF_SALDO_C1          
          
,ISNULL(C.PTMOSVIGTEINIC1,0) PTMOS_VGTE_INI_C1          
,ISNULL(C.PTMOSVIGTEFINC1,0) PTMOS_VGTE_FIN_C1          
,ISNULL(C.DIF_PTMOS_C1,0)DIF_PTMOS_C1          
          
,ISNULL(C.SALDOVIGTEINIC2,0) SALDO_VGTE_INI_C2          
,ISNULL(C.SALDOVIGTEFINC2,0) SALDO_VGTE_FIN_C2          
,ISNULL(C.DIF_SALDO_C2,0)DIF_SALDO_C2          
          
          
,ISNULL(C.PTMOSVIGTEINIC2,0) PTMOS_VGTE_INI_C2          
,ISNULL(C.PTMOSVIGTEFINC2,0) PTMOS_VGTE_FIN_C2          
,ISNULL(C.DIF_PTMOS_C2,0)DIF_PTMOS_C2          
          
,ISNULL(C.SALDOVIGTEINIC3,0) SALDO_VGTE_INI_C3          
,ISNULL(C.SALDOVIGTEFINC3,0) SALDO_VGTE_FIN_C3          
,ISNULL(C.DIF_SALDO_C3,0)DIF_SALDO_C3          
          
,ISNULL(C.PTMOSVIGTEINIC3,0) PTMOS_VGTE_INI_C3          
,ISNULL(C.PTMOSVIGTEFINC3,0) PTMOS_VGTE_FIN_C3          
,ISNULL(C.DIF_PTMOS_C3,0)DIF_PTMOS_C3          
          
,ISNULL(C.SALDOVIGTEINIC410,0) SALDO_VGTE_INI_C4a10          
,ISNULL(C.SALDOVIGTEFINC410,0) SALDO_VGTE_FIN_C4a10          
,ISNULL(C.DIF_SALDO_C4a10,0)DIF_SALDO_C4a10          
          
,ISNULL(C.PTMOSVIGTEINIC410,0) PTMOS_VGTE_INI_C4a10          
,ISNULL(C.PTMOSVIGTEFINC410,0) PTMOS_VGTE_FIN_C4a10          
,ISNULL(C.DIF_PTMOS_C4a10,0)DIF_PTMOS_C4a10          
          
,ISNULL(C.SALDOVIGTEINIC11,0)  SALDO_VGTE_INI_C11          
,ISNULL(C.SALDOVIGTEFINC11,0)  SALDO_VGTE_FIN_C11          
,ISNULL(C.DIF_SALDO_C11M,0)DIF_SALDO_C11M          
          
,ISNULL(C.PTMOSVIGTEINIC11,0)  PTMOS_VGTE_INI_C11          
,ISNULL(C.PTMOSVIGTEFINC11,0)  PTMOS_VGTE_FIN_C11        
,ISNULL(C.DIF_PTMOS_C11M,0)DIF_PTMOS_C11M          
          
,ISNULL (I.INTERESCOBRADO,0)  INT_COBRADO_TOTAL                    
,ISNULL (ERQ.INTERESCOBRADO,0)  INT_COBRADO_1ERQ            
,ISNULL (DAQ.INTERESCOBRADO,0)  INT_COBRADO_2DAQ            
          
---------CALCULAR PARAMETROS       
---------------------------------------------------------- Modificacion      PORCE_PASO_VENCIDA =  DIFF_CARTERA_VENCIDA( incluyendo el saldo castigado) / CA_VTGE0A30_INI.      Agregado el 2024.04.12  Sil
,ISNULL(C.PORCE_PASO_VENCIDA,0)PORCE_PASO_VENCIDA       
-- PORCE_PENALIZACION: Si PORCE_PASO_VENCIDA >= 2%, 30%, SI PORCE_PASO_VENCIDA >= 1%, 20%, si no 0%,     
,CASE WHEN PORCE_PASO_VENCIDA >=0.02 THEN 0.3       
   WHEN PORCE_PASO_VENCIDA >=0.01 THEN 0.2       
   ELSE 0 END PORCE_PENALIZACION         
      
----CAMPOS NUEVOS       
,ISNULL(MM.RENOVANTENT,0)MONTO_RENOV_ANT          
,ISNULL(MM.RANTICIPAPTMOS,0)PTMOS_RENOV_ANT              
,ISNULL(IMOR7,0)IMOR7      
,ISNULL(IMOR15,0)IMOR15      
,ISNULL(IMOR30,0)IMOR30     
-------- Modificacion     DIFF_CARTERA_VENCIDA debido a     CART_VENCIDA_FIN = CART_VENCIDA_FIN + SALDOCASTIGADO         modificado el 2024.04.12  Sil
,ISNULL (C.SALDOFIN31M,0)-ISNULL (C.SALDOINI31M,0)+ISNULL(Casti.SALDO_Castigado, 0) DIFF_CARTERA_VENCIDA      
--Si el IMOR_7 es menor o igual al 10%, 20%, si no, 0%      
--CASE WHEN IMOR7 <=10 THEN 0.2      
--   ELSE 0 END
,  0 PORCE_BONO_IMOR     ---- modificacion al 10.04.2024  ---> Poner siempre 0%    
,O.CODOFICINA CODOFICINA --- SE AGREGA PARA EL REPORTE EN DATANEGOCIO   

-------- SALDO_Castigado:  Identificar las cuentas castigadas en lo que va del mes actual y tomar su saldo de capital a inicio de mes.      Agregado el 2024.04.12  Sil
,ISNULL(Casti.SALDO_Castigado, 0) SALDO_Castigado
-------- Ptmos Liquidados:  Ptmos liquidados en lo que va del mes actual.      Agregado el 2024.04.12  Sil
,ISNULL(Liqui.Ptmos_Liquidados, 0) Ptmos_Liquidados
-------- Ptmos Renovados:  Ptmos liquidados en lo que va del mes actual ya renovados.      Agregado el 2024.04.12  Sil
,ISNULL(Renov.Ptmos_Renovados, 0) Ptmos_Renovados
-------- Saldo Liquidado:  Saldo de capital de los ptmos liquidados en lo que va del mes actual.      Agregado el 2024.04.12  Sil
,ISNULL(Liqui.SALDO_Liquidado, 0) SALDO_Liquidado
-------- Saldo Renovado:  Nuevo monto desembolso de los ptmos liquidados en lo que va del mes actual ya renovados.      Agregado el 2024.04.12  Sil
,ISNULL(Renov.SALDO_Renovado, 0) SALDO_Renovado

,ISNULL (C.SALDOFIN0A7,0) Cartera07                     --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
INTO #BASE          
FROM @ANTIQUEDAD A                     
LEFT OUTER JOIN  @CRECARTERA  C ON A.CODUSUARIO=C.CODASESOR                  
LEFT OUTER JOIN @INTECOBRADO I ON I.CODASESOR=A.CODUSUARIO                
LEFT OUTER JOIN @COP COP ON COP.PROMOTOR=A.COORDINADOR           
LEFT OUTER JOIN @QUITAS CP  ON A.CODUSUARIO = CP.CODPROMOTOR            
LEFT OUTER JOIN @COLOCACION_MONTOS MM ON MM.CODASESOR=A.CODUSUARIO          
LEFT OUTER JOIN @METAS M ON A.CODUSUARIO = M.CODASESOR          
LEFT OUTER JOIN TCLOFICINAS O WITH(NOLOCK) ON O.CODOFICINA=A.CODOFICINA                   
LEFT OUTER JOIN TCLZONA Z WITH(NOLOCK) ON Z.ZONA=O.ZONA           
LEFT OUTER JOIN @INTECOBRADO_1Q ERQ ON ERQ.CODASESOR=I.CODASESOR             
LEFT OUTER JOIN @INTECOBRADO_2Q DAQ ON DAQ.CODASESOR=I.CODASESOR  
LEFT OUTER JOIN @Cartera_Liquidados Liqui ON Liqui.CODASESOR=C.CODASESOR
LEFT OUTER JOIN @Cartera_Renovados Renov ON Renov.CODASESOR=C.CODASESOR
LEFT OUTER JOIN #ingresoPromotor  IPr ON IPr.CODUSUARIO=C.CODASESOR 
LEFT OUTER JOIN #Cartera_Castigada Casti ON Casti.CODASESOR=C.CODASESOR


                
-- SET @T2=GETDATE()          
--PRINT '22 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
       
        
------------------------VALIDACIONES          
---select * from  FNMGConsolidado.dbo.tCaCartaPromotor3APP with(nolock)where fechaconsulta='20230625'          
         
          
SELECT *         
---- PORCE_BONO_CRECIMIENTO:	Modificar el %, si cumple con el crecimiento, 50%, si no, 0%
,CASE WHEN CUMP_CARTERA >= 1 AND CUMP_CLIENTES >= 1 THEN 0.5 ELSE 0 END PORCE_BONO_CRECIMIENTO   
---- PORCE_BONO_COBRANZA	Modificar el %, si cumple con el 93.6% de PAGO_ACUMULADO, 50%, si no, 0%
,CASE WHEN PAGO_ACUMULADO >=0.936 THEN 0.5 ELSE 0 END PORCE_BONO_COBRANZA      
---- PORCE_BONO_GANADO:	Sumar PORCE_BONO_CRECIMIENTO + PORCE_BONO_COBRANZA + PORCE_PENALIZACION.  Se quito del calculo a +(PORCE_BONO_IMOR)
,(CASE WHEN CUMP_CARTERA >= 1 AND CUMP_CLIENTES >= 1 THEN 0.5 ELSE 0 END)+(CASE WHEN PAGO_ACUMULADO >=0.936 THEN 0.5 ELSE 0 END)-(PORCE_PENALIZACION)   as'PORCE_BONO_GANADO'  
-- >>> SALDO_BONO_GANADO se repite el cambio de PORCE_BONO_GANADO:
,BONO_ESTIMADO_CALCULADO*((CASE WHEN CUMP_CARTERA >= 1 AND CUMP_CLIENTES >= 1 THEN 0.5 ELSE 0 END)+(CASE WHEN PAGO_ACUMULADO >=0.936 THEN 0.5 ELSE 0 END)-(PORCE_PENALIZACION)) SALDO_BONO_GANADO         
INTO #BASE_INTERMEDIA       
FROM #BASE WITH(NOLOCK)         
      
      
                
-- SET @T2=GETDATE()          
--PRINT '23 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          
     
----------CONSULTA FINAL       
      --- 
DELETE FROM FNMGCONSOLIDADO.DBO.TCACARTAPROMOTOR3APP  WHERE FECHACONSULTA=@FECHA---'20230618'          
INSERT INTO FNMGCONSOLIDADO.DBO.TCACARTAPROMOTOR3APP       
      
        
SELECT FECHAINICIO, FECHACONSULTA,CODASESOR,REGION,SUCURSAL,PROMOTOR
,FechaIngresoPromotor          --++ 07.02.2025 Sil      ++-- Sustituye Columna -->  ,FECHA_INGRESO
,ANTIGUEDAD , NIVEL_PROMOTOR,BONO_ESTIMADO_CALCULADO,        
CA_VTGE0A30_INI,CA_VTGE0A30_FIN,PTMOS_VGTE_INI,PTMOS_VGTE_FIN,        
MONTO_ASIG,PTMOS_ASIG,MONTO_QUITAS,PTMOS_QUITAS,        
DIFF_CARTERA,SALDO_CRECIMIENTO_META,100*CUMP_CARTERA as 'CUMP_CARTERA',        
CRECI_PTMOS_VGTES,PTMOS_CRECIMIENTO_META,100*CUMP_CLIENTES as 'CUMP_CLIENTES',        
PROGRAMADO_S,MONTO_COBRADO, 100*PAGO_PUNTUAL as 'PAGO_PUNTUAL',100*PAGO_ACUMULADO as 'PAGO_ACUMULADO',        
CART_VENCIDA_INI,CART_VENCIDA_FIN,        
SALDO_RIESGO,PTMOS_RIESGO,        
MOTO_COLOCACION_TOTAL, PTMOS_COLOCACION_TOTAL,        
MONTO_NUEVOS,PTMOS_NUEVOS,        
MONTO_RENOV,PTMOS_RENOV,        
MONTO_REACTIVACIONES,PTMOS_REACTIVACIONES,        
SALDO_VGTE_INI_C1,SALDO_VGTE_FIN_C1,DIF_SALDO_C1,        
PTMOS_VGTE_INI_C1,PTMOS_VGTE_FIN_C1,DIF_PTMOS_C1,        
SALDO_VGTE_INI_C2,SALDO_VGTE_FIN_C2,DIF_SALDO_C2,        
PTMOS_VGTE_INI_C2,PTMOS_VGTE_FIN_C2,DIF_PTMOS_C2,        
SALDO_VGTE_INI_C3,SALDO_VGTE_FIN_C3,DIF_SALDO_C3,        
PTMOS_VGTE_INI_C3,PTMOS_VGTE_FIN_C3,DIF_PTMOS_C3,        
SALDO_VGTE_INI_C4a10,SALDO_VGTE_FIN_C4a10,DIF_SALDO_C4a10,        
PTMOS_VGTE_INI_C4a10,PTMOS_VGTE_FIN_C4a10,DIF_PTMOS_C4a10,        
SALDO_VGTE_INI_C11,SALDO_VGTE_FIN_C11,DIF_SALDO_C11M,        
PTMOS_VGTE_INI_C11,PTMOS_VGTE_FIN_C11,DIF_PTMOS_C11M,        
INT_COBRADO_TOTAL,        
INT_COBRADO_1ERQ,        
INT_COBRADO_2DAQ,        
100*PORCE_PASO_VENCIDA as 'PORCE_PASO_VENCIDA',        
100*PORCE_PENALIZACION as 'PORCE_PENALIZACION',        
100*PORCE_BONO_CRECIMIENTO as 'PORCE_BONO_CRECIMIENTO',        
100*PORCE_BONO_COBRANZA as 'PORCE_BONO_COBRANZA',       
(CASE WHEN PORCE_BONO_GANADO>=0 THEN (100*PORCE_BONO_GANADO) ELSE 0 END) AS 'PORCE_BONO_GANADO',        
(CASE WHEN SALDO_BONO_GANADO>=0 THEN SALDO_BONO_GANADO ELSE 0 END) AS 'SALDO_BONO_GANADO'        
----CAMPOS NUEVOS  
,ISNULL (CART_VENCIDA_FIN,0)-ISNULL (CART_VENCIDA_INI,0)+ISNULL(SALDO_Castigado, 0) DIFF_CARTERA_VENCIDA      
,ISNULL(MONTO_RENOV_ANT,0)MONTO_RENOV_ANT          
,ISNULL(PTMOS_RENOV_ANT,0)PTMOS_RENOV_ANT              
,ISNULL(IMOR7,0)IMOR7      
,ISNULL(IMOR15,0)IMOR15      
,ISNULL(IMOR30,0)IMOR30      
,100*PORCE_BONO_IMOR as 'PORCE_BONO_IMOR' 
,CODOFICINA     
,SALDO_Castigado
,Ptmos_Liquidados
,Ptmos_Renovados
,SALDO_Liquidado
,SALDO_Renovado
,Cartera07                     --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
FROM #BASE_INTERMEDIA WITH(NOLOCK)   
------------- Codusuarios filtrados (cambiaron a los promotores de sucursarl y les crearon otro codusuario para la transicion, estos ya quedaron en ceros y deben ser filtrados)
where codasesor not in ('MRJ800622FH300', 'TRE821108FH100', 'VSM831122F271A' )
--where codasesor='CMR010316M2426'
--order by FECHA_INGRESO--codasesor



               
-- SET @T2=GETDATE()          
--PRINT '24 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          


DROP TABLE #BASE        
DROP TABLE #BASE_INTERMEDIA
--drop table #ptmosCPP
drop table #ptmos_Castigados
drop table #Cartera_Castigada
drop table #ingresoPromotor
GO