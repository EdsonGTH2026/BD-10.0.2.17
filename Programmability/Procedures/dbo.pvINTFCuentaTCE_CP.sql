SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---se genera sp de créditos de vivienda. 2023.09.01 ZCCU
---1 paso: subir los pagos de TCE  a la tabla [FNMGConsolidado].[dbo].[TCEPagos]
---2 paso: Ejecutar sp
--sp_helptext pvINTFCuentaTCE_CP

CREATE PROCEDURE [dbo].[pvINTFCuentaTCE_CP]  @fecini smalldatetime,@fecha smalldatetime  
AS    
set nocount on      
  
---declara variables   
--declare @fecha smalldatetime           
--set @fecha='20230911'   --Fecha final de corte          
            
--declare @fecini smalldatetime            
--set @fecini='20230905'    --Fecha inicial de corte  
  
---TABLAS TCE   
--select * from  [FinamigoBasesSic].[dbo].[TCETmpCuentav14] WITH(NOLOCK)  
  
---PAGOS DEL PERIODO   
select PERIODO,FECHAPAGO,MONTO,SALDOINSOLUTO,CODPRESTAMO  
INTO #PAGOS  
FROM [FNMGConsolidado].[dbo].[TCEPagos] P WITH(NOLOCK)  
INNER JOIN [FNMGConsolidado].[dbo].[TCEAuxContrato] A ON A.CONTRATO=P.CONTRATO  
WHERE FECHAPAGO>=@fecini   
AND FECHAPAGO<=@fecha  
  
delete from [FINAMIGOCONSOLIDADO].[DBO].[tCsBuroxTblReICueVr14CP] where substring(codprestamo,1,3)='500'    ------OJO: COMENTAR PARA PRUEBAS       
insert into [FINAMIGOCONSOLIDADO].[DBO].[tCsBuroxTblReICueVr14CP]  -----------------------------------------------OJO    
  
select C.CodPrestamo,C.CodUsuario,C.ClaveUsuario,C.NombreUsuario,C.Responsabilidad,C.TipoCuenta,C.TipoContrato,C.UnidadMonetaria,  
C.ImporteAvaluo,C.NumeroPagos,C.FrecuenciaPagos,  
case when pagos.SALDOINSOLUTO=0 then 0 else round(MONTO,0)end AS MontoPagar,C.Apertura,  
dbo.fduFechaATexto(FECHAPAGO, 'DDMMAAAA') AS  UltimoPago,C.Disposicion,  
''Cancelacion,  
dbo.fduFechaATexto(@fecha, 'DDMMAAAA') AS  Reporte,C.Garantia,C.CreditoMaximo,  
round(pagos.SALDOINSOLUTO,0) AS SaldoActual,C.LimiteCredito,C.SaldoVencido,C.PagosVencidos,C.MOP,C.HistoricoPagos,  
''Observacion,C.PagosReportados,C.MOP02,C.MOP03,C.MOP04,C.MOP05mas,C.AOClave,C.AONombre,C.AOCuenta,C.FprimerIncum,  
round(pagos.SALDOINSOLUTO,0) AS SaldoInsoluto,C.FinSegmento,  
round(MONTO,0) AS Montoultpago,C.PlazoMeses,C.MontoDesembolso,C.DiasAtraso  
from  [FinamigoBasesSic].[dbo].[TCETmpCuentav14] C WITH(NOLOCK)  
inner join #PAGOS pagos on pagos.codprestamo=c.codprestamo  
 
----validaciones 
----'MONTO A PAGAR no puede ser mayor a SALDO ACTUAL'
--SELECT codprestamo,MONTOPAGAR ,SALDOACTUAL
--FROM [FINAMIGOCONSOLIDADO].[DBO].[tCsBuroxTblReICueVr14CP] WITH(NOLOCK)
--WHERE SUBSTRING(CODPRESTAMO,1,3) = '500'
--AND MONTOPAGAR > SALDOACTUAL

  
UPDATE [FINAMIGOCONSOLIDADO].[DBO].[tCsBuroxTblReICueVr14CP]
SET MONTOPAGAR = SALDOACTUAL
FROM [FINAMIGOCONSOLIDADO].[DBO].[tCsBuroxTblReICueVr14CP] WITH(NOLOCK)
WHERE SUBSTRING(CODPRESTAMO,1,3) = '500'
AND MONTOPAGAR > SALDOACTUAL

  
DROP TABLE #PAGOS  
  
  
  
--select* from [FINAMIGOCONSOLIDADO].[DBO].[tCsBuroxTblReICueVr14CP] where substring(codprestamo,1,3)='500'    
GO