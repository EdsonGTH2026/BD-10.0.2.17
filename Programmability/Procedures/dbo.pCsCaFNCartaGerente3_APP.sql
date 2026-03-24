SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++             
++ Genera Informacion para calculo de Bonos para GERENTE - 20231026 ZCCU          
++-- 2023.10.26 ZCCU  



--++-- 16.08.2024 Sil
--++-- Nueva Columna -->  Cartera07: el saldo capital de las cuentas que se encuentran entre 0 y 7 días de atraso

--++-- 07.03.2025  Sil
--++-- Se sutituye la columna Fecha Ingreso (a la empresa) por FechaIngresoGerente (en especifico con el rol de Gerente)

 ++-- 20.03.2025 Sil
 ++-- Nueva Columna --> Saldo_Castigado: El saldo al inicio del mes de las cuentas Castigadas al final de mes.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  */          
         
          
CREATE PROCEDURE  [dbo].[pCsCaFNCartaGerente3_APP]           
AS          
SET NOCOUNT ON                  
         
--+++++++++++++++++++++++++++++ DECLARAR VARIABLES +++++++++++++++++++++++++++++++++++--          
DECLARE @FECHA SMALLDATETIME,          
         @FECINI SMALLDATETIME,          
         @FECANTE SMALLDATETIME,            
         @FECFIN SMALLDATETIME,            
         @DIACORTE INT ,          
         @EVA INT,      
		 @FECCASTIGO SMALLDATETIME,
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
      --SELECT @FECCASTIGO AS Valor_FecCastigo;

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




-----------------------VARIABLES DE TIEMPO----------          
DECLARE @T1 DATETIME          
DECLARE @T2 DATETIME          
SET @T1=GETDATE()          
          

--+++++++++++++++++++++++++++++/*CARTERA INICIAL */--SALDOS EN CARTERA +++++++++++++++++++++++++++++++++++++                   
                    
CREATE TABLE #CARTERAINI (  FECHA SMALLDATETIME,                    
							 --CODASESOR VARCHAR(15), 
							 CODOFICINA VARCHAR (5),                       
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
INSERT INTO #CARTERAINI                        
SELECT   C.FECHA                      
--,C.CODASESOR  CODASESOR 
,C.CODOFICINA CODOFICINA               
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
,SUM(CASE WHEN C.NRODIASATRASO <=30 AND D.SECUENCIACLIENTE>=11 THEN C.SALDOCAPITAL ELSE 0 END) 'SALDOVIGTEINIC11+'                  
,COUNT(CASE WHEN C.NRODIASATRASO <=30 AND D.SECUENCIACLIENTE>=11 THEN C.CODPRESTAMO END) 'PTMOSVIGTEINIC11+'          
FROM TCSCARTERA C WITH(NOLOCK)                        
INNER JOIN TCSCARTERADET D WITH(NOLOCK) ON C.FECHA=D.FECHA AND C.CODPRESTAMO=D.CODPRESTAMO                      
WHERE C.FECHA=@FECANTE--> FECHA DE CORTE DEL MES ANTERIOR           
AND C.CODPRESTAMO NOT IN (SELECT CODPRESTAMO FROM TCSCARTERAALTA WITH(NOLOCK))                  
AND C.CODOFICINA NOT IN('97','230','231','999')                     
AND C.CARTERA='ACTIVA'           
AND C.TIPOREPROG<>'REEST'                   
GROUP BY  C.FECHA,C.CODOFICINA    

SET @T2=GETDATE()          
PRINT '1 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE() 
--+++++++++++++++++++++++++++++/*CARTERA FINAL */--SALDOS EN CARTERA +++++++++++++++++++++++++++++++++++++                   
                   
CREATE TABLE #CARTERAFIN (  FECHA SMALLDATETIME,                    
							 --CODASESOR VARCHAR(15), 
							 CODOFICINA VARCHAR (5),   
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
INSERT INTO #CARTERAFIN                        
SELECT   C.FECHA             
--,C.CODASESOR    
,C.CODOFICINA CODOFICINA   
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
GROUP BY  C.FECHA ,C.CODOFICINA    

SET @T2=GETDATE()          
PRINT '2 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE() 




--+++++++++++++++++++++++++++++/*CARTERA CASTIGADA */+++++++++++++++++++++++++++++++++++++++++       2024.05.12  Sil


------ #ptmos_Castigados
select ultimoasesor, codUsuario, codprestamo 'codprestamo_Canc'  --cancelacion, TIPOREPROG 
into #ptmos_Castigados
from tcspadroncarteradet with(nolock)                                           --> se uso tcspadroncarteradet 
where pasecastigado>=@FECCASTIGO and pasecastigado<=@FECHA                       --@FECFIN  si se recalcula a fechaposterior va a modificar        --> Final del MES ACTUAL    
                                                   --- Ajuste al 13.03.2025 Sil: Mauricio pidio cambiar el rango de @FECINI a @FECHA, a sólo el final del mes previo 
 
--and carteraactual='CASTIGADA' 
and codoficina not in('97','230','231','999')
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
AND TIPOREPROG<>'REEST'                                                          
order by UltimoAsesor, codusuario


------ #Cartera_Castigada
SELECT  
--C.FECHA,                      
C.CODOFICINA  CODOFICINA
--,codusuario, codprestamo 'codprestamo_Cast', SALDOCAPITAL
,COUNT(C.CODPRESTAMO) 'Ptmos_Castigados'
,SUM(C.SALDOCAPITAL) 'SALDO_Castigado' 
into #Cartera_Castigada
FROM TCSCARTERA C WITH(NOLOCK)                          
WHERE C.FECHA=@FECINI                                                                   -->  Saldo al inicio del mes
		and CODPRESTAMO in ( select codprestamo_Canc from #ptmos_Castigados)                           -->  cuenta cambio a cuenta castigada en lo que va del mes
GROUP BY  C.CODOFICINA
           --,C.FECHA
order by C.CODOFICINA


--select * from #Cartera_Castigada


--drop table #ptmos_Castigados
--drop table #Cartera_Castigada






--+++++++++++++++++++++++++++++/ *CRECIMIENTO DE CARTERA */+++++++++++++++++++++++++++++++++++++++++                   
                    
DECLARE @CRECIMIENTOCARTERA TABLE (  FECHA SMALLDATETIME    ,CODOFICINA VARCHAR(5),   
		                             SALDOFIN0A7 MONEY,                      --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
									 SALDOFIN0A30 MONEY     ,SALDOFIN31M MONEY,                    
									 SALDOINI0A30 MONEY     ,SALDOINI31M MONEY,                   
									 PTMOSVGTEINI INT       ,PTMOSVENCIDOINI INT,                    
									 PTMOSVGTEFIN INT       ,PTMOSVENCIDOFIN INT,          
									 SALDOVIGTEINIC1 MONEY  ,PTMOSVIGTEINIC1 INT,          
									 SALDOVIGTEINIC2 MONEY  ,PTMOSVIGTEINIC2 INT,          
									 SALDOVIGTEINIC3 MONEY  ,PTMOSVIGTEINIC3 INT,          
									 SALDOVIGTEINIC410 MONEY,PTMOSVIGTEINIC410 INT,          
									 SALDOVIGTEINIC11 MONEY ,PTMOSVIGTEINIC11 INT,          
									 SALDOVIGTEFINC1 MONEY  ,PTMOSVIGTEFINC1 INT,          
									 SALDOVIGTEFINC2 MONEY  ,PTMOSVIGTEFINC2 INT,          
									 SALDOVIGTEFINC3 MONEY  ,PTMOSVIGTEFINC3 INT,          
									 SALDOVIGTEFINC410 MONEY,PTMOSVIGTEFINC410 INT,          
									 SALDOVIGTEFINC11 MONEY ,PTMOSVIGTEFINC11 INT,          
									 SALDORIESGO MONEY      ,PTMOSRIESGO INT,           
									 DIF_SALDO_C1 MONEY     ,DIF_SALDO_C2 MONEY,          
									 DIF_SALDO_C3 MONEY     ,DIF_SALDO_C4a10 MONEY,          
									 DIF_SALDO_C11M MONEY   ,DIF_PTMOS_C1 INT,          
									 DIF_PTMOS_C2 INT       ,DIF_PTMOS_C3 INT,          
									 DIF_PTMOS_C4a10 INT    ,DIF_PTMOS_C11M INT,          
									 PORCE_PASO_VENCIDA DECIMAL(7,3),       
									 IMOR7 MONEY,IMOR15 MONEY,IMOR30 MONEY)                                   
INSERT INTO @CRECIMIENTOCARTERA                           
SELECT                     
F.FECHA ,
--F.CODASESOR,
F.CODOFICINA,  
ISNULL(SALDOFIN0A7,0)SALDOFIN0A7,                      --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
ISNULL(SALDOFIN0A30,0)SALDOFIN0A30,
ISNULL(SALDOFIN31M,0)SALDOFIN31M,                     
ISNULL(SALDOINI0A30,0)SALDOINI0A30,
ISNULL(SALDOINI31M,0)SALDOINI31M,                    
ISNULL(PTMOSVGTEINI,0)PTMOSVGTEINI,
ISNULL(PTMOSVENCIDOINI,0)PTMOSVENCIDOINI,                     
ISNULL(PTMOSVGTEFIN,0)PTMOSVGTEFIN,
ISNULL(PTMOSVENCIDOFIN,0)PTMOSVENCIDOFIN,          
ISNULL(SALDOVIGTEINIC1,0)SALDOVIGTEINIC1,
ISNULL(PTMOSVIGTEINIC1,0)PTMOSVIGTEINIC1,          
ISNULL(SALDOVIGTEINIC2,0)SALDOVIGTEINIC2,
ISNULL(PTMOSVIGTEINIC2,0)PTMOSVIGTEINIC2,          
ISNULL(SALDOVIGTEINIC3,0)SALDOVIGTEINIC3,
ISNULL(PTMOSVIGTEINIC3,0)PTMOSVIGTEINIC3,          
ISNULL(SALDOVIGTEINIC410,0)SALDOVIGTEINIC410,
ISNULL(PTMOSVIGTEINIC410,0)PTMOSVIGTEINIC410,          
ISNULL(SALDOVIGTEINIC11,0)SALDOVIGTEINIC11,
ISNULL(PTMOSVIGTEINIC11,0)PTMOSVIGTEINIC11,          
ISNULL(SALDOVIGTEFINC1,0)SALDOVIGTEFINC1,
ISNULL(PTMOSVIGTEFINC1,0)PTMOSVIGTEFINC1,          
ISNULL(SALDOVIGTEFINC2,0)SALDOVIGTEFINC2,
ISNULL(PTMOSVIGTEFINC2,0)PTMOSVIGTEFINC2,          
ISNULL(SALDOVIGTEFINC3,0)SALDOVIGTEFINC3,
ISNULL(PTMOSVIGTEFINC3,0)PTMOSVIGTEFINC3,          
ISNULL(SALDOVIGTEFINC410,0)SALDOVIGTEFINC410,
ISNULL(PTMOSVIGTEFINC410,0)PTMOSVIGTEFINC410,          
ISNULL(SALDOVIGTEFINC11,0)SALDOVIGTEFINC11,
ISNULL(PTMOSVIGTEFINC11,0)PTMOSVIGTEFINC11,          
ISNULL(SALDORIESGO,0)SALDORIESGO,
ISNULL(PTMOSRIESGO,0)PTMOSRIESGO,          
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
,CASE WHEN ISNULL(SALDOINI0A30,0)= 0 THEN 0 ELSE (ISNULL(SALDOFIN31M,0) - ISNULL(SALDOINI31M,0))/ISNULL(SALDOINI0A30,0)END PORCE_PASO_VENCIDA          
,ISNULL(IMOR7,0)IMOR7      
,ISNULL(IMOR15,0)IMOR15      
,ISNULL(IMOR30,0)IMOR30      
FROM #CARTERAFIN F  WITH(NOLOCK)                   
LEFT OUTER JOIN #CARTERAINI I WITH(NOLOCK) ON I.CODOFICINA = F.CODOFICINA     


DROP TABLE #CARTERAINI
DROP TABLE #CARTERAFIN

--SELECT * FROM @CRECIMIENTOCARTERA 
SET @T2=GETDATE()          
PRINT '3 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE() 
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
        
SET @T2=GETDATE()          
PRINT '4 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()         
        
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
group by p.codoficina ,cu.codprestamo,cu.seccuota,cu.fechavencimiento          
,cu.estadocuota         
    
CREATE TABLE #COBRANZAP (  FECHA SMALLDATETIME,          
						   --REGION VARCHAR(15),          
						   --SUCURSAL VARCHAR(30),          
						   CODOFICINA VARCHAR(4),          
						   --PROMOTOR VARCHAR(200),          
						   ATRASO VARCHAR (10),          
						   PROGRAMADO_S MONEY,          
						   MONTO_ANTICIPADO MONEY,          
						   MONTO_PUNTUAL MONEY,          
						   MONTO_ATRASADO MONEY)                    
INSERT INTO  #COBRANZAP          
select @fecha fecha
--, z.Nombre region          
--,o.nomoficina sucursal        
,p.codoficina codoficina        
--,pro.nombrecompleto promotor             
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
--inner join tclzona z with(nolock) on z.zona=o.zona          
--inner join tcspadronclientes pro with(nolock) on pro.codusuario=ca.codasesor          
where o.zona not in('ZSC','ZCO')          
group by p.fechavencimiento
--,z.Nombre          
--,o.nomoficina         
,p.codoficina         
,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then '0-7DM'          
when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then '8-30DM'          
            when ca.nrodiasatraso>=31 then '31+DM' else '' end          
            ,case when ca.nrodiasatraso>=0 and ca.nrodiasatraso<=7 then 1          
            when ca.nrodiasatraso>=8 and ca.nrodiasatraso<=30 then 2          
            when ca.nrodiasatraso>=31 then 3 else 4 end          
--,pro.nombrecompleto          

              
drop table #ptmosCPP          
drop table #CUOCPP          
              
         
SET @T2=GETDATE()          
PRINT '5 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()                    
                    
CREATE TABLE #COP  ( FECHA SMALLDATETIME,             
					 CODOFICINA VARCHAR(5),                    
					 PROGRAMADO_S MONEY,                    
					 MONTO_ANTICIPADO MONEY,                    
					 MONTO_PUNTUAL MONEY,                   
					 MONTO_ATRASADO MONEY,                    
					 PAGOPUNTUAL MONEY,                    
					 PAGOACUMULADO MONEY)                    
INSERT INTO #COP                    
SELECT FECHA,CODOFICINA,                  
SUM(PROGRAMADO_S) PROGRAMADO_S,                    
SUM(MONTO_ANTICIPADO)MONTO_ANTICIPADO,                    
SUM(MONTO_PUNTUAL)MONTO_PUNTUAL,                    
SUM(MONTO_ATRASADO) MONTO_ATRASADO,                   
CASE WHEN SUM(PROGRAMADO_S)=0  THEN 0 ELSE SUM(MONTO_PUNTUAL+MONTO_ANTICIPADO)/SUM(PROGRAMADO_S)END  PAGOPUNTUAL,                    
CASE WHEN SUM(PROGRAMADO_S)=0  THEN 0 ELSE SUM(MONTO_ANTICIPADO+MONTO_PUNTUAL+MONTO_ATRASADO)/SUM(PROGRAMADO_S)END  PAGOACUMULADO                    
FROM #COBRANZAP WITH(NOLOCK)                    
WHERE ATRASO IN ('0-7DM','8-30DM')                    
GROUP BY FECHA,CODOFICINA                    
          
SET @T2=GETDATE()          
PRINT '5.1 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()          
                  
DROP TABLE #COBRANZAP 

--+++++++++++++++++++++++++++++/*INTERESES COBRADOS POR PROMOTOR*/  +++++++++++++++++++++++++++++++++++++++++                   
--- AJUSTE EN INTERES COBRADO 26.10.2023 ZCCU              
--- CALCULO MENSUAL          
          
CREATE TABLE  #PTMOSPAGOS(FECHA SMALLDATETIME,CODPRESTAMO VARCHAR(25),INTERES MONEY)              
INSERT INTO #PTMOSPAGOS              
SELECT D.FECHA,CODIGOCUENTA,MONTOINTERESTRAN            
FROM TCSTRANSACCIONDIARIA D WITH(NOLOCK)              
WHERE  D.FECHA>=@FECINI AND D.FECHA<=@FECHA              
AND D.CODSISTEMA='CA'             
AND TIPOTRANSACNIVEL3 IN(104,105)             
AND EXTORNADO=0              
            
SET @T2=GETDATE()          
PRINT '6 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()   

--SELECT FECHA,CODOFICINA,CODPRESTAMO,NRODIASATRASO
--INTO #TCSCARTERADET
--FROM TCSCARTERA C WITH(NOLOCK)    
--WHERE C.CODOFICINA NOT IN('98','97','230','231','999')  
 
          
CREATE TABLE  #INTCO(FECHA SMALLDATETIME,              
					CODPRESTAMO VARCHAR(25),              
					INTERES MONEY,            
					NRODIAS INT,            
					CODOFICINA VARCHAR(4))            
					--CODASESOR VARCHAR(25)             
INSERT INTO #INTCO            
SELECT            
P.FECHA,P.CODPRESTAMO,P.INTERES,C.NRODIASATRASO DIAS,C.CODOFICINA--,CODASESOR            
FROM #PTMOSPAGOS P WITH(NOLOCK)              
INNER JOIN TCSCARTERA C WITH(NOLOCK) ON (C.FECHA+1)=P.FECHA AND C.CODPRESTAMO=P.CODPRESTAMO               
WHERE C.CODOFICINA NOT IN('98','97','230','231','999')  
AND  ISNULL(C.NRODIASATRASO,0)<=30           

--DROP TABLE #TCSCARTERADET         
           
SET @T2=GETDATE()          
PRINT '7 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()           
           
INSERT INTO #INTCO            
SELECT P.FECHA,P.CODPRESTAMO,          
P.INTERES,0 DIAS,PD.CODOFICINA--,ISNULL(ULTIMOASESOR,PRIMERASESOR)            
FROM #PTMOSPAGOS P WITH(NOLOCK)              
INNER JOIN TCSPADRONCARTERADET PD WITH(NOLOCK)ON P.FECHA=PD.DESEMBOLSO AND P.CODPRESTAMO=PD.CODPRESTAMO             
          
SET @T2=GETDATE()          
PRINT '8 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()          
          
CREATE TABLE #INTECOBRADO (FECHA SMALLDATETIME,CODOFICINA VARCHAR(5),INTERESCOBRADO MONEY)                 
INSERT INTO #INTECOBRADO              
SELECT @FECHA,CODOFICINA,SUM(INTERES)INTERES            
FROM #INTCO C WITH(NOLOCK)             
WHERE ISNULL(NRODIAS,0)<=30              
GROUP BY CODOFICINA             
           
          
SET @T2=GETDATE()          
PRINT '9 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()          
          
   --SELECT * FROM @INTECOBRADO       
          
          
--DROP TABLE #PTMOSPAGOS            
--DROP TABLE #INTCO       

     --+++++++++++++++++++++++++++++/*INTERESES COBRADOS POR PROMOTOR PARA LA PRIMERA Y SEGUNDA QUINCENA  */  +++++++++++++++++++++++++++++++++++++++++                   
DECLARE @INTECOBRADO_1Q TABLE(FECHA SMALLDATETIME,CODOFICINA VARCHAR(5),INTERESCOBRADO MONEY)                 
DECLARE @INTECOBRADO_2Q TABLE(FECHA SMALLDATETIME,CODOFICINA VARCHAR(5),INTERESCOBRADO MONEY)                 
          
          
IF(@EVA=1)           
  BEGIN          
  INSERT INTO @INTECOBRADO_1Q               
  SELECT @FECHA,CODOFICINA,SUM(INTERES)INTERES            
  FROM #INTCO C WITH(NOLOCK)             
  WHERE ISNULL(NRODIAS,0)<=30              
  GROUP BY CODOFICINA           
            
  INSERT INTO @INTECOBRADO_2Q               
  SELECT @FECHA,CODOFICINA,0 INTERES            
  FROM #INTCO C WITH(NOLOCK)             
  WHERE ISNULL(NRODIAS,0)<=30              
  GROUP BY CODOFICINA              
  END          
ELSE          
  BEGIN           
  INSERT INTO @INTECOBRADO_1Q               
  SELECT @FECHA,CODOFICINA,SUM(INTERES)INTERES            
  FROM #INTCO C WITH(NOLOCK)             
  WHERE ISNULL(NRODIAS,0)<=30            
        AND C.FECHA>=@FECINI AND C.FECHA<@FECEVAL           
  GROUP BY CODOFICINA           
          
  INSERT INTO @INTECOBRADO_2Q               
  SELECT @FECHA,CODOFICINA,SUM(INTERES)INTERES            
  FROM #INTCO C WITH(NOLOCK)             
  WHERE ISNULL(NRODIAS,0)<=30           
  AND C.FECHA>=@FECEVAL            
  GROUP BY CODOFICINA     
           
  END          
            
DROP TABLE #PTMOSPAGOS            
DROP TABLE #INTCO  
          
          
--+++++++++++++++++++++++++++++/*METAS DE CRECIMIENTO*/  +++++++++++++++++++++++++++++++++++++++++                   
          
DECLARE @METAS TABLE(CODOFICINA VARCHAR(15),PTMOSMETAMENSUAL INT,SALDOMETAMENSUAL MONEY)          
INSERT INTO @METAS          
SELECT CODIGO CODOFICINA,          
SUM(CASE WHEN META = 4 THEN MONTO ELSE 0 END) PTMOSMETAMENSUAL,          
SUM(CASE WHEN META = 1 THEN MONTO ELSE 0 END) SALDOMETAMENSUAL          
FROM TCSCAMETAS WITH(NOLOCK)          
WHERE FECHA=@FECFIN --'20231031'--
AND TIPOCODIGO = 1          
GROUP BY CODIGO          
            
SET @T2=GETDATE()          
PRINT '10 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()          
          
--+++++++++++++++++++++++++++++/*ANTIGUEDAD DE PROMOTORES ACTIVOS */  +++++++++++++++++++++++++++++++++++++++++                   
--ANTIGUEDAD POR MESES NO POR DIAS, SOLICITADO POR MERCEDES               
                 
DECLARE @ANTIQUEDAD TABLE (FECHA SMALLDATETIME,          
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
CO.NOMBRECOMPLETO  GERENTE,                        
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
WHERE B1.CODPUESTO=41           
AND B1.FECHA=@FECHA--'20231025'--             
AND E.ESTADO=1                      
AND B1.CODOFICINA NOT IN ('98','97','99','230','231','999')                    

--select * from @ANTIQUEDAD

SELECT  F.CodUsuario, 41 CodPuesto,  MIN(F.Fecha)  AS FechaIngresoGerente    
into #ingresoGerente
FROM TCSEMPLEADOSFECHA F
inner join @ANTIQUEDAD A ON A.CODUSUARIO=F.CodUsuario --and A.CODOFICINA=F.CodOficina  El Gerente pudo haber cambiado de sucursal, por eso no se hace join con el codoficina
WHERE F.CodPuesto = 41
GROUP BY  F.CodUsuario    


select codoficina,nomoficina,zona 
into #ofic 
from tcloficinas with(nolock)
where codoficina not in ('501','999') and tipo = 'Operativo'


               
SET @T2=GETDATE()          
PRINT '11 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()    

--+++++++++++++++++++++++++++++/*COLOCACIÓN --- CREDITOS NUEVOS-RENOVADOS-REACTIVADOS */+++++++++++++++++++++++++++++++++++++++++                   
          
     
CREATE TABLE #LIQRENO (CODPRESTAMO VARCHAR(30)          
      ,DESEMBOLSO SMALLDATETIME          
      ,CODUSUARIO VARCHAR(15)          
      ,CANCELACION SMALLDATETIME)          
INSERT INTO #LIQRENO          
SELECT P.CODPRESTAMO,P.DESEMBOLSO,P.ULTIMOASESOR,MAX(A.CANCELACION) CANCELACION          
--SELECT TOP 10*          
FROM TCSPADRONCARTERADET P WITH(NOLOCK)          
LEFT OUTER JOIN TCSPADRONCARTERADET A WITH(NOLOCK) ON P.CODUSUARIO=A.CODUSUARIO AND A.CANCELACION<=P.DESEMBOLSO          
WHERE P.DESEMBOLSO>=@FECINI           
AND P.DESEMBOLSO<=@FECHA           
AND P.CODOFICINA not in ('97','230','231','999')            
GROUP BY P.CODPRESTAMO,P.DESEMBOLSO,P.ULTIMOASESOR          
HAVING MAX(A.CANCELACION) IS NOT NULL          
          
CREATE TABLE #COLOCACION_MONTOS  (CODOFICINA VARCHAR(30)          
								  --,CODASESOR VARCHAR(30)               
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
INSERT INTO #COLOCACION_MONTOS          
SELECT P.CODOFICINA--,C.CODASESOR--P.ULTIMOASESOR,          
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
LEFT OUTER JOIN #LIQRENO L WITH(NOLOCK)ON L.CODPRESTAMO=P.CODPRESTAMO          
INNER JOIN TCSCARTERA C WITH(NOLOCK) ON C.CODPRESTAMO=P.CODPRESTAMO AND C.FECHA=P.DESEMBOLSO          
LEFT OUTER JOIN [10.0.2.14].FINMAS.DBO.TCASOLICITUDRENOVACIONANTICIPADAPROCE S ON S.CODSOLICITUD=C.CODSOLICITUD AND S.CODOFICINA=C.CODOFICINA          
WHERE P.DESEMBOLSO>=@FECINI AND P.DESEMBOLSO<=@FECHA          
AND P.CODOFICINA not in ('97','230','231','999')           
GROUP BY P.CODOFICINA--,C.CODASESOR--,P.ULTIMOASESOR          
          
SET @T2=GETDATE()          
PRINT '12 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()          


--+++++++++++++++++++++++++++++/*CONSULTA FINAL */  +++++++++++++++++++++++++++++++++++++++++                   
                          
SELECT DISTINCT @FECINI FECHAINICIO          
,@FECHA FECHACONSULTA         
,Z.NOMBRE REGION,O.CODOFICINA CODOFICINA --- SE AGREGA PARA EL REPORTE EN DATANEGOCIO           
,O.NOMOFICINA SUCURSAL
,A.CODUSUARIO CODUSUARIO ,A.COORDINADOR GERENTE            
--,INGRESO FECHA_INGRESO 
,CASE  when IGe.FechaIngresoGerente>'20180228' then CASE  
             WHEN IGe.FechaIngresoGerente > INGRESO THEN IGe.FechaIngresoGerente  
             ELSE INGRESO  END
      else INGRESO     END 'FechaIngresoGerente'
,MES ANTIGUEDAD                
,ISNULL (I.INTERESCOBRADO,0)*(0.03)  BONO_ESTIMADO_CALCULADO ---- SE AJUSTA PARA LOS MASTER CONSIDERAR EL 8% DE LOS INT COBRADOS       
         
,ISNULL (C.SALDOINI0A30,0) CA_VTGE0A30_INI          
,ISNULL (C.SALDOFIN0A30,0) CA_VTGE0A30_FIN          
          
,ISNULL(C.PTMOSVGTEINI,0)PTMOS_VGTE_INI          
,ISNULL(C.PTMOSVGTEFIN,0)PTMOS_VGTE_FIN          

,ISNULL(IMOR7,0)IMOR7      
,ISNULL(IMOR15,0)IMOR15      
,ISNULL(IMOR30,0)IMOR30  
                
,ISNULL (C.SALDOFIN0A30,0) - ISNULL (C.SALDOINI0A30,0) DIFF_CARTERA         
,ISNULL(M.SALDOMETAMENSUAL,0) SALDO_CRECIMIENTO_META     
,CASE WHEN (ISNULL (C.SALDOFIN0A30,0) - ISNULL (C.SALDOINI0A30,0)) <= 0 THEN 0   
      WHEN ISNULL(SALDOMETAMENSUAL,0)=0 THEN 0  
      ELSE (ISNULL (C.SALDOFIN0A30,0) - ISNULL (C.SALDOINI0A30,0))/ISNULL(SALDOMETAMENSUAL,0)           
      END CUMP_CARTERA          
          
,ISNULL(C.PTMOSVGTEFIN,0)-ISNULL(PTMOSVGTEINI,0) CRECI_PTMOS_VGTES                             
,ISNULL(M.PTMOSMETAMENSUAL,0) PTMOS_CRECIMIENTO_META          
,CASE WHEN (ISNULL(C.PTMOSVGTEFIN,0)-ISNULL(C.PTMOSVGTEINI,0))<= 0 THEN 0   
WHEN ISNULL(PTMOSMETAMENSUAL,0)=0 THEN 0  
ELSE CAST ((ISNULL(C.PTMOSVGTEFIN,0)-ISNULL(C.PTMOSVGTEINI,0))AS DECIMAL(6,2))/CAST(ISNULL(PTMOSMETAMENSUAL,0)AS DECIMAL(6,2))          
   END CUMP_CLIENTES          
          
,ISNULL(COP.PROGRAMADO_S,0) PROGRAMADO_S              
,ISNULL(COP.MONTO_ANTICIPADO,0) + ISNULL(MONTO_PUNTUAL,0) + ISNULL(MONTO_ATRASADO,0) MONTO_COBRADO          
,ISNULL (COP.PAGOPUNTUAL,0) PAGO_PUNTUAL                    
,ISNULL (COP.PAGOACUMULADO,0) PAGO_ACUMULADO                    
          
,ISNULL (C.SALDOINI31M,0) CART_VENCIDA_INI                   
,ISNULL (C.SALDOFIN31M,0) CART_VENCIDA_FIN                 
,ISNULL (C.SALDOFIN31M,0)-ISNULL (C.SALDOINI31M,0) DIFF_CARTERA_VENCIDA      

,ISNULL(C.SALDORIESGO,0) SALDO_RIESGO          
,ISNULL(C.PTMOSRIESGO,0)  PTMOS_RIESGO          
          
,ISNULL(MM.MONTOENTREGA,0)MOTO_COLOCACION_TOTAL          
,ISNULL(MM.TOTAPTMOS,0)PTMOS_COLOCACION_TOTAL          
          
,ISNULL(MM.NUEVOENT,0)MONTO_NUEVOS          
,ISNULL(MM.NUEVOSPTMOS,0)PTMOS_NUEVOS          
          
,ISNULL(MM.RENOVENT,0) MONTO_RENOV          
,ISNULL(MM.RENOVPTMOS,0)PTMOS_RENOV    

,ISNULL(MM.RENOVANTENT,0)MONTO_RENOV_ANT          
,ISNULL(MM.RANTICIPAPTMOS,0)PTMOS_RENOV_ANT              
      
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
,ISNULL(C.PORCE_PASO_VENCIDA,0)PORCE_PASO_VENCIDA       
-- PORCE_PENALIZACION: si PORCE_PASO_VENCIDA >= 1.5%, 20%, si PORCE_PASO_VENCIDA >= 1%, 10%, si no 0%,      
,CASE WHEN PORCE_PASO_VENCIDA >=0.015 THEN 0.2       
      WHEN PORCE_PASO_VENCIDA >=0.01 THEN 0.1       
      ELSE 0 END PORCE_PENALIZACION         
      
--Si el IMOR_7 es menor o igual al 10%, 20%, si no, 0%      
,CASE WHEN IMOR7 <=10 THEN 0.2      
   ELSE 0 END  PORCE_BONO_IMOR  
 
,ISNULL (C.SALDOFIN0A7,0) Cartera07                     --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
-------- SALDO_Castigado:  Identificar las cuentas castigadas en lo que va del mes actual y tomar su saldo de capital a inicio de mes.      Agregado el 2025.03.18  Sil
,ISNULL(Casti.SALDO_Castigado, 0) SALDO_Castigado
INTO #BASE          
FROM #ofic O WITH(NOLOCK)
LEFT OUTER JOIN @ANTIQUEDAD A  ON A.CODOFICINA=O.CODOFICINA                    
INNER JOIN @CRECIMIENTOCARTERA  C ON O.CODOFICINA=C.CODOFICINA                  
LEFT OUTER JOIN #INTECOBRADO I WITH(NOLOCK) ON I.CODOFICINA=O.CODOFICINA                
LEFT OUTER JOIN #COP COP WITH(NOLOCK)ON COP.CODOFICINA=O.CODOFICINA           
--LEFT OUTER JOIN @QUITAS CP  ON A.CODUSUARIO = CP.CODPROMOTOR            
LEFT OUTER JOIN #COLOCACION_MONTOS MM WITH(NOLOCK) ON MM.CODOFICINA=O.CODOFICINA          
LEFT OUTER JOIN @METAS M ON O.CODOFICINA = M.CODOFICINA          
--LEFT OUTER JOIN TCLOFICINAS O WITH(NOLOCK) ON O.CODOFICINA=A.CODOFICINA                   
LEFT OUTER JOIN TCLZONA Z WITH(NOLOCK) ON Z.ZONA=O.ZONA           
LEFT OUTER JOIN @INTECOBRADO_1Q ERQ ON ERQ.CODOFICINA=I.CODOFICINA             
LEFT OUTER JOIN @INTECOBRADO_2Q DAQ ON DAQ.CODOFICINA=I.CODOFICINA   
LEFT OUTER JOIN #ingresoGerente IGe  ON A.CODUSUARIO=IGe.CodUsuario 
LEFT OUTER JOIN #Cartera_Castigada Casti ON Casti.CODOFICINA=C.CODOFICINA

                
 SET @T2=GETDATE()          
PRINT '22 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
SET @T1=GETDATE()          
       
       

SELECT *         
,CASE WHEN CUMP_CARTERA >= 1 AND CUMP_CLIENTES >= 1 THEN 0.6 ELSE 0 END PORCE_BONO_CRECIMIENTO         
,CASE WHEN PAGO_ACUMULADO >=0.936 THEN 0.2 ELSE 0 END PORCE_BONO_COBRANZA   --------> SE AJUSTA %COBRANZA DE 40 % A 20%      
,(CASE WHEN CUMP_CARTERA >= 1 AND CUMP_CLIENTES >= 1 THEN 0.6 ELSE 0 END)+(CASE WHEN PAGO_ACUMULADO >=0.936 THEN 0.2 ELSE 0 END)-(PORCE_PENALIZACION)+(PORCE_BONO_IMOR)as'PORCE_BONO_GANADO'         
,BONO_ESTIMADO_CALCULADO*((CASE WHEN CUMP_CARTERA >= 1 AND CUMP_CLIENTES >= 1 THEN 0.6 ELSE 0 END)+      
(CASE WHEN PAGO_ACUMULADO >=0.936 THEN 0.2 ELSE 0 END)-(PORCE_PENALIZACION)+(PORCE_BONO_IMOR))SALDO_BONO_GANADO         
INTO #BASE_INTERMEDIA       
FROM #BASE WITH(NOLOCK)          
   
   
 ----------CONSULTA FINAL       
      
DELETE FROM FNMGCONSOLIDADO.DBO.tCaCartaGerente3APP WHERE FECHACONSULTA=@FECHA---'20230618'          
INSERT INTO FNMGCONSOLIDADO.DBO.tCaCartaGerente3APP         
      
  
   
SELECT FECHAINICIO, FECHACONSULTA,REGION,CODOFICINA,SUCURSAL,
ISNULL(CODUSUARIO,'-----')CODUSUARIO,
ISNULL(GERENTE,'SIN GERENTE ASIGNADO')GERENTE,
--ISNULL(FECHA_INGRESO,'')FECHA_INGRESO,     ---Se sustituye por FechaIngresoGerente
ISNULL(FechaIngresoGerente,'') FechaIngresoGerente,
ISNULL(ANTIGUEDAD,0)ANTIGUEDAD,
BONO_ESTIMADO_CALCULADO,        
CA_VTGE0A30_INI,
CA_VTGE0A30_FIN,
PTMOS_VGTE_INI,
PTMOS_VGTE_FIN, 
ISNULL(IMOR7,0)IMOR7,      
ISNULL(IMOR15,0)IMOR15,      
ISNULL(IMOR30,0)IMOR30,           
DIFF_CARTERA,SALDO_CRECIMIENTO_META,100*CUMP_CARTERA as 'CUMP_CARTERA',        
CRECI_PTMOS_VGTES,PTMOS_CRECIMIENTO_META,100*CUMP_CLIENTES as 'CUMP_CLIENTES',        
PROGRAMADO_S,MONTO_COBRADO, 100*PAGO_PUNTUAL as 'PAGO_PUNTUAL',100*PAGO_ACUMULADO as 'PAGO_ACUMULADO',        
CART_VENCIDA_INI,CART_VENCIDA_FIN ,ISNULL (CART_VENCIDA_FIN,0)-ISNULL (CART_VENCIDA_INI,0) DIFF_CARTERA_VENCIDA,           
SALDO_RIESGO,PTMOS_RIESGO,        
MOTO_COLOCACION_TOTAL, PTMOS_COLOCACION_TOTAL,        
MONTO_NUEVOS,PTMOS_NUEVOS,        
MONTO_RENOV,PTMOS_RENOV,  
ISNULL(MONTO_RENOV_ANT,0)MONTO_RENOV_ANT ,         
ISNULL(PTMOS_RENOV_ANT,0)PTMOS_RENOV_ANT ,                 
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
100*PORCE_BONO_IMOR as 'PORCE_BONO_IMOR' ,
100*PORCE_BONO_CRECIMIENTO as 'PORCE_BONO_CRECIMIENTO',        
100*PORCE_BONO_COBRANZA as 'PORCE_BONO_COBRANZA',       
(CASE WHEN PORCE_BONO_GANADO>=0 THEN (100*PORCE_BONO_GANADO) ELSE 0 END) AS 'PORCE_BONO_GANADO',        
(CASE WHEN SALDO_BONO_GANADO>=0 THEN SALDO_BONO_GANADO ELSE 0 END) AS 'SALDO_BONO_GANADO'   
,Cartera07                     --++ 16.08.2024 Sil      ++-- Nueva Columna -->  Cartera07
,SALDO_Castigado               --++ 18.03.2025 Sil      ++-- Nueva Columna -->  Cartera07
FROM #BASE_INTERMEDIA WITH(NOLOCK)          
where CA_VTGE0A30_FIN > 0


               
-- SET @T2=GETDATE()          
--PRINT '24 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))          
--SET @T1=GETDATE()          


DROP TABLE #BASE        
DROP TABLE #BASE_INTERMEDIA 
DROP TABLE #ofic
DROP TABLE #COP
DROP TABLE #LIQRENO 
DROP TABLE #COLOCACION_MONTOS
DROP TABLE #INTECOBRADO
drop table #ptmos_Castigados
drop table #Cartera_Castigada
    
GO