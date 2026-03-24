SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--SELECT * FROM [FNMGConsolidado].[dbo].[TCEPadronCartera451]WITH(NOLOCK)-- POR PERIODO MENSUAL
--SELECT *,saldoinicial-montopagado FROM [FNMGConsolidado].[dbo].[TCEPadronCartera452]WITH(NOLOCK)-- POR PERIODO MENSUAL
--SELECT * FROM [FNMGConsolidado].[dbo].[TCEPagos] WITH(NOLOCK)
--SELECT * FROM [FNMGConsolidado].[dbo].[TCEAuxContrato] WITH(NOLOCK)
---exec pvBOFCuentaTCESIC '20230814','20230819'
CREATE PROCEDURE [dbo].[pvBOFCuentaTCESIC]  @fecini smalldatetime,@fecha smalldatetime
AS  
set nocount on    


---declara variables 
--declare @fecha smalldatetime         
--set @fecha='20230904'   --Fecha final de corte        
          
--declare @fecini smalldatetime          
--set @fecini='20230829'    --Fecha inicial de corte

declare @CorteMesAnterior smalldatetime          
set @CorteMesAnterior=cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1        
      
----
--select @fecha as '@fecha'
--,@fecini as '@fecini'
--,@CorteMesAnterior as '@CorteMesAnterior'


select substring(CodPrestamo,5,25) as CodPrestamo,substring(NumeroPagos,5,20)NumeroPagos--,*
INTO #AltaPrevia
from finamigoBasesSic.dbo.tINTFCuenta where Periodo = '202306'--dbo.fdufechaaperiodo(@CorteMesAnterior)
and usados=1 and substring(CodPrestamo,5,3)='500'
        

---MES ANTERIOR 
SELECT NROCONTRATO,OTORGAMIENTO,MONTOLINEA,CURP
INTO #TCEdetalle  
FROM [FNMGConsolidado].[dbo].[TCEPadronCartera451]WITH(NOLOCK)-- POR PERIODO MENSUAL
WHERE PERIODO='202301'--dbo.fdufechaaperiodo(@CorteMesAnterior)

---MES ANTERIOR 
SELECT CONTRATO,MONTOPAGOEXIGIBLE
INTO #TCEsaldos
FROM [FNMGConsolidado].[dbo].[TCEPadronCartera452]WITH(NOLOCK)
WHERE FECHACORTE='20230131'--@CorteMesAnterior

--select * from [FINAMIGOBASESSIC].[DBO].[tBOFCuenta] where substring(codprestamo,1,3)='500'  
delete from [FINAMIGOBASESSIC].[DBO].[tBOFCuenta] where substring(codprestamo,1,3)='500'    -------------------------------------------OJO: COMENTAR PARA PRUEBAS     
insert into [FINAMIGOBASESSIC].[DBO].[tBOFCuenta]    --------------------------------------------------------------------------------------------OJO        
    -----GENERAR INFORMACIÓN DE TCE PARA REPORTAR PAGOS RECIBIDOS 
SELECT A.CODPRESTAMO
,'.' CODUSUARIO
,'I' RESPONSABILIDAD
,'M' TIPOCUENTA
,'SE' TIPOCONTRATO
,'MX' UNIDADMONETARIA
,AL.NUMEROPAGOS NUMEROPAGOS
,'M' FRECUENCIAPAGOS
,round(MONTOPAGOEXIGIBLE,0) MONTOPAGAR
,dbo.fduFechaATexto(OTORGAMIENTO, 'DDMMAAAA') AS APERTURA          
,dbo.fduFechaATexto(P.FECHAPAGO, 'DDMMAAAA') AS ULTIMOPAGO          
,dbo.fduFechaATexto(OTORGAMIENTO, 'DDMMAAAA') AS DISPOSICION          
,'' CANCELACION  ---- EN CINTAS PARCIALES NO PONDREMOS FECHA DE CANCELACION: CAMPO OPCIONAL ---> SE REPORTARÁ EN LA CINTA MENSUAL
,dbo.fduFechaATexto(@fecha, 'DDMMAAAA') AS REPORTE   -----> COLOCAR LA FECHA DE LA CABECERA
,round(MONTOLINEA,0) AS 'CREDITOMAXIMO'
,round(SaldoInsoluto,0) SALDOACTUAL ---> SALDO INSOLUTO : VALOR A ACTUALIZAR EN CADA REPORTE
,'' LIMITECREDITO
,0 SALDOVENCIDO
,'0' PAGOSVENCIDOS
,'1' MOP
,'' OBSERVACION
,'**'FINSEGMENTO
,round(P.MONTO,0) MONTOULTPAGO
---select *
FROM [FNMGConsolidado].[dbo].[TCEPagos] P WITH(NOLOCK)
INNER JOIN [FNMGConsolidado].[dbo].[TCEAuxContrato] A ON A.CONTRATO=P.CONTRATO
INNER JOIN #TCEdetalle PD ON A.CONTRATO=PD.NROCONTRATO
INNER JOIN #TCEsaldos SD ON A.CONTRATO=SD.CONTRATO
INNER JOIN #AltaPrevia AL ON AL.CODPRESTAMO=A.CODPRESTAMO
WHERE FECHAINICIO>=@fecini 
AND FECHAFINAL<=@fecha


DROP TABLE #TCEdetalle
DROP TABLE #TCEsaldos
DROP TABLE #AltaPrevia
GO