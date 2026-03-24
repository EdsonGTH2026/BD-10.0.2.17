SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
------------------------------------
create PROCEDURE [dbo].[pCsGeneraTrans481] @NumeroContrato VARCHAR(30),@FechaTrans SMALLDATETIME
as
set nocount on

DECLARE  @FechaTransaccion smalldatetime
DECLARE  @CodUsuario VARCHAR(20)
DECLARE  @CodCuenta  VARCHAR(25) 
DECLARE  @NumContrato  VARCHAR(30)   
DECLARE  @Renovado int
DECLARE  @Monto   MONEY   
DECLARE  @TipoTrans  VarChar(30)
DECLARE  @CodTipoTrans INT
DECLARE  @CodFormaTrans INT  
DECLARE  @TipoTrans1 VarChar(5)  
DECLARE  @TipoCtaTrans   VarChar(255)  
DECLARE  @folioOrigen   VarChar(255)  
DECLARE  @CodOficina  VarChar(10)--- DONDE SE HACE EL MOVIMIENTO 

--SET @FechaTransaccion='20240930' ---- ULTIMO DIA DEL MES
SET  @FechaTransaccion = @FechaTrans
SET  @NumContrato  = @NumeroContrato
 
--SELECT top 1 * FROM FNMGCONSOLIDADO.DBO.tCsProcesaCuentas841
--@TipoTrans   --  4:deposito - 3:retiro 
--@CodFormaTrans---2:ahorro     1:garantia
--@TipoTrans3 = 'I' --  I:deposito - E:retiro 

SELECT top 1 @CodUsuario=codUsuario,@CodCuenta=CodCuenta,@Renovado = Renovado--,@NumContrato=NumCuenta
,@Monto=MontoTransaccion
,@TipoTrans = TipoTransaccion
,@CodTipoTrans = CASE WHEN TipoTransaccion='RETIRO' THEN 3 WHEN TipoTransaccion='DEPOSITO' THEN 4 ELSE 0 END
,@TipoTrans1   = CASE WHEN @TipoTrans ='RETIRO' THEN 'E' WHEN @TipoTrans='DEPOSITO' THEN 'I' ELSE 'OTRO' END
,@CodFormaTrans = Renovado
FROM FNMGCONSOLIDADO.DBO.tCsProcesaCuentas841 WITH(NOLOCK)
WHERE Procesa = 0 and NumCuenta = @NumContrato

IF @CodTipoTrans = 0 
 BEGIN 
 raiserror('Revisar el proceso - Operación no definida para: ', 16, -1, @NumContrato)  
 return  
 END
 
SET @TipoCtaTrans = CASE WHEN @CodFormaTrans = 1 THEN 'Cta de GARAH' WHEN @CodFormaTrans = 0 THEN 'Cta de Ahorro' ELSE 'OTRO' END
SET @folioOrigen = @TipoTrans + ' Interno - ' + @TipoCtaTrans

--SELECT @folioOrigen

--select * FROM FNMGCONSOLIDADO.DBO.tCsTransaccionR841
-----------------------------------------
---DELETE FROM FNMGCONSOLIDADO.DBO.tCsTransaccionR841
INSERT INTO FNMGCONSOLIDADO.DBO.tCsTransaccionR841 (Fecha,CodCuenta,FraccionCta,Renovado,NumContrato	
												,CodSistema,TipoTransacNivel1,TipoTransacNivel2,TipoTransacNivel3
												,Extornado,DescripcionTran,MontoTotalTran,CodUsuario,Autorizado)
VALUES(@FechaTransaccion,@CodCuenta,0,@Renovado,@NumContrato,'AH',@TipoTrans1,'INTERNO'
,@CodTipoTrans,0,@folioOrigen,@Monto,@CodUsuario,'Riesgos')






GO