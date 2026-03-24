SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsAhEstadoCuentaMovimientos] @Cuenta Varchar(25),@fraccioncta varchar(3), @renovado int,@Inicio SmallDateTime,@Fin SmallDateTime  
As  
--set nocount on  
--Declare @Cuenta   Varchar(25)  
--declare @fraccioncta varchar(3)  
--declare @renovado   int  
--Declare @Inicio   SmallDateTime  
--Declare @Fin   SmallDateTime  
--set @Cuenta='098-105-06-2-1-00179'--'098-105-06-2-7-00192'  
--set @fraccioncta='0'  
--set @renovado=0  
--set @Inicio = '20200601'  
--set @Fin = '20200630'  
  
Declare @SaldoAnterior Decimal(20,4)  
Declare @SaldoActual Decimal(20,4)  
Declare @CodConcepto Varchar(10)  
Declare @PIVA   Decimal(10,4)  
Declare @Sistema  Varchar(2)  
  
declare @SaldoInicialPeriodo money  
set  @Sistema='AH'  
  
SELECT     
 @Sistema AS Sistema,   
 (t.CodigoCuenta + '-' + t.FraccionCta + '-' + CAST(t.Renovado AS varchar(5))) AS Cuenta,  
 t.Fecha, t.NroTransaccion, 'CAPI' AS CodConcepto, ISNULL(tAhClTipoTrans.Descripcion, t.DescripcionTran)   
 + ' en Oficina ' + o.NomOficina + '. Operación ' + LTRIM(RTRIM(STR(t.NroTransaccion, 10, 0))) + '.' AS Concepto,   
  
 CASE   
 WHEN t.TipoTransacNivel1 = 'I' THEN t.MontoTotalTran    
 WHEN t.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (2,4) THEN t.MontoTotalTran   
 ELSE 0 END AS Deposito,   
  
 CASE   
 WHEN t.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (1, 7, 62,3,16) THEN t.MontoTotalTran   
 ELSE 0 END AS Retiro,  
  
 CASE   
 WHEN t.TipoTransacNivel1 = 'I' THEN t.MontoTotalTran    
 WHEN t.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (2) THEN t.MontoTotalTran   
 ELSE 0 END AS DepositoD,   
  
 CASE   
 WHEN t.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (1, 3, 62, 3,16) THEN t.MontoTotalTran   
 ELSE 0 END AS RetiroD  
   
 ,isnull(@SaldoAnterior,0) AS SaldoAnterior  
 ,isnull(@SaldoActual,0) AS SaldoActual  
 ,Orden = (Year(t.Fecha)*1000) + (Month(t.Fecha)*10000) + (Day(t.Fecha)* 1000) +  
    (t.TranHora*100) +  (t.TranMinuto*10) + t.TranSegundo + t.TranMicroSegundo  
  
 , convert(money,99.01) as SaldoCuenta --  9999999.01 as SaldoCuenta  
  
into #tablaMovs  
FROM tCsTransaccionDiaria t with(nolock)   
LEFT OUTER JOIN tClOficinas o with(nolock) ON t.CodOficina = o.CodOficina   
LEFT OUTER JOIN tAhClTipoTrans with(nolock) ON t.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans  
left join tCsAhorros as a with(nolock) on a.codcuenta=t.CodigoCuenta and a.FraccionCta=t.FraccionCta and a.Renovado=t.Renovado and a.Fecha=t.Fecha   
WHERE (t.Fecha>=@Inicio) AND (t.Fecha<=@Fin) AND (t.CodSistema='AH') and (t.CodigoCuenta=@Cuenta and t.FraccionCta=@FraccionCta and t.Renovado=@Renovado)  
and t.extornado = 0 ---- zccu 2025.01.13 
  
--select   
--@SaldoInicialPeriodo =   
--      (  
--      isnull(sum(  
--      case    
--       when TipoTransacNivel3 in (2, 4, 15) --OSC, 12-09-2018:VERIFICAR SI FUNCIONAARA DPF  
--       then td.MontoTotalTran   
--          else 0   
--      end  
--      ),0)  
--      )   
--     -  
--      (  
--      isnull(sum(  
--      case    
--       when TipoTransacNivel3 in (1, 3, 62)  --OSC, 12-09-2018:VERIFICAR SI FUNCIONAARA DPF  
--       then td.MontoTotalTran   
--         else 0   
--      end  
--      ),0)  
--      )  
--from tCsTransaccionDiaria as td with(nolock)  
--inner join tAhClTipoTrans as tt with(nolock) on tt.idTipoTrans = td.TipoTransacNivel3  
--and (td.CodigoCuenta= @Cuenta and td.FraccionCta=@FraccionCta and td.Renovado=@Renovado )  
--and td.Fecha < @Inicio  
SELECT @SaldoInicialPeriodo = SaldoCuenta  
FROM tCsAhorros WITH(NOLOCK)  
WHERE codcuenta=@Cuenta and FraccionCta=@FraccionCta and Renovado=@Renovado  
AND fecha=@Inicio-1  
  
---------------------------------  
set @SaldoInicialPeriodo = isnull(@SaldoInicialPeriodo,0)  
--print 'SALDO INICIAL: ' +  convert(varchar,@SaldoInicialPeriodo) -- COMENTAR  
  
--Actualizar saldo a 0  
update #tablaMovs set SaldoCuenta = 0.0  
  
--<<<<<<<<<< INICIA CURSOR para actualizar saldo  
declare @NroTransaccion integer   
declare @DepositoD money   
declare @RetiroD money  
declare @SaldoCuenta money  
  
set @SaldoCuenta = @SaldoInicialPeriodo  
  
DECLARE db_cursor CURSOR FOR   
 select NroTransaccion, DepositoD, RetiroD   from #tablaMovs order by Fecha,NroTransaccion  --order by NroTransaccion  
OPEN db_cursor    
FETCH NEXT FROM db_cursor INTO @NroTransaccion, @DepositoD, @RetiroD     
  
--select @NroTransaccion, @DepositoD, @RetiroD, @SaldoCuenta  --COMENTAR   
  
WHILE @@FETCH_STATUS = 0    
BEGIN    
 set @SaldoCuenta = @SaldoCuenta + @DepositoD - @RetiroD  
 --select @NroTransaccion, @DepositoD, @RetiroD, @SaldoCuenta  --COMENTAR   
  
 update #tablaMovs set SaldoCuenta = @SaldoCuenta where NroTransaccion = @NroTransaccion  
  
    FETCH NEXT FROM db_cursor INTO @NroTransaccion, @DepositoD, @RetiroD    
END   
  
CLOSE db_cursor    
DEALLOCATE db_cursor   
  
-->>>>>>>>>> FIN CURSOR  
  
select * from #tablaMovs order by Fecha, NroTransaccion  
  
drop table #tablaMovs  
GO