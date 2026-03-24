SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsEstadoCuentaAHMovimientos]
	@Cuenta 		Varchar(25),
	@Inicio			SmallDateTime,
	@Fin			SmallDateTime
As

--comentar
/*
Declare @Cuenta 		Varchar(25)
Declare	@Inicio			SmallDateTime
Declare	@Fin			SmallDateTime
set @Cuenta = '098-209-06-2-0-00001-0-0'
set @Inicio = '20170505'
set @Fin = '20190105'
*/

set @Inicio = convert(varchar,@Inicio, 112)
set @Fin = convert(varchar,@Fin, 112)

Declare @SaldoAnterior	Decimal(20,4)
Declare @SaldoActual	Decimal(20,4)
Declare @CodConcepto	Varchar(10)
Declare @PIVA			Decimal(10,4)
Declare @Sistema		Varchar(2)

declare @SaldoInicialPeriodo money

/*
If @Dato = 1 Or Len(@Cuenta) = 19
Begin
	Set @Sistema	= 'CA'
End
If @Dato = 2 Or Len(@Cuenta) > 19
Begin
	Set @Sistema	= 'AH'
End
If @Dato = 3 Or Len(@Cuenta) < 19
Begin
	Set @Sistema	= 'TA'
End

Print @Sistema
*/
--If @Dato = 2
--Begin
	--Insert Into  tCsEstadoCuentaMO
	SELECT   
	@Sistema AS Sistema, 
	(tCsTransaccionDiaria.CodigoCuenta + '-' + tCsTransaccionDiaria.FraccionCta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5))) AS Cuenta,
	--tCsTransaccionDiaria.CodigoCuenta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5)) + '-' + tCsTransaccionDiaria.FraccionCta AS Cuenta, 
						tCsTransaccionDiaria.Fecha, tCsTransaccionDiaria.NroTransaccion, 'CAPI' AS CodConcepto, ISNULL(tAhClTipoTrans.Descripcion, tCsTransaccionDiaria.DescripcionTran) 
						--+ ' en ' + tClOficinas.NomOficina + '. ' + LTRIM(RTRIM(STR(tCsTransaccionDiaria.NroTransaccion, 10, 0))) + '.' AS Concepto, 
						+ ' en Oficina ' + tClOficinas.NomOficina + '. Operación ' + LTRIM(RTRIM(STR(tCsTransaccionDiaria.NroTransaccion, 10, 0))) + '.' AS Concepto, 

						--tCsTransaccionDiaria.DescripcionTran, 
						--tCsTransaccionDiaria.TipoTransacNivel1,
						--tCsTransaccionDiaria.TipoTransacNivel2,
						--tCsTransaccionDiaria.TipoTransacNivel3,

						--CASE tCsTransaccionDiaria.TipoTransacNivel1 WHEN 'I' THEN tCsTransaccionDiaria.MontoTotalTran ELSE 0 END AS Deposito, 
						--CASE tCsTransaccionDiaria.TipoTransacNivel1 WHEN 'E' THEN tCsTransaccionDiaria.MontoTotalTran ELSE 0 END AS Retiro, --tCsTransaccionDiaria.DescripcionTran, 
						--CASE tCsTransaccionDiaria.TipoTransacNivel1 WHEN 'I' THEN tCsTransaccionDiaria.MontoTotalTran ELSE 0 END AS DepositoD, 
						--CASE tCsTransaccionDiaria.TipoTransacNivel1 WHEN 'E' THEN tCsTransaccionDiaria.MontoTotalTran ELSE 0 END AS RetiroD,

						CASE 
						WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'I' THEN tCsTransaccionDiaria.MontoTotalTran  
						WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (2) THEN tCsTransaccionDiaria.MontoTotalTran 
						ELSE 0 END AS Deposito, 

						CASE 
						WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (1, 7, 62,3) THEN tCsTransaccionDiaria.MontoTotalTran 
						ELSE 0 END AS Retiro,

						CASE 
						WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'I' THEN tCsTransaccionDiaria.MontoTotalTran  
						WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (2) THEN tCsTransaccionDiaria.MontoTotalTran 
						ELSE 0 END AS DepositoD, 

						CASE 
						WHEN tCsTransaccionDiaria.TipoTransacNivel1 = 'E' and TipoTransacNivel3 in (1, 3, 62, 3) THEN tCsTransaccionDiaria.MontoTotalTran 
						ELSE 0 END AS RetiroD,

						isnull(@SaldoAnterior,0) AS SaldoAnterior,
						isnull(@SaldoActual,0) AS SaldoActual,  Orden = (Year(tCsTransaccionDiaria.Fecha)*1000) + (Month(tCsTransaccionDiaria.Fecha)*10000) + (Day(tCsTransaccionDiaria.Fecha)* 1000) +
                        (tCsTransaccionDiaria.TranHora*100) +  (tCsTransaccionDiaria.TranMinuto*10) + tCsTransaccionDiaria.TranSegundo + tCsTransaccionDiaria.TranMicroSegundo
	--,isnull(a.SaldoCuenta,0) as SaldoCuenta
	, convert(money,99.01) as SaldoCuenta --  9999999.01 as SaldoCuenta
into #tablaMovs
	FROM         tCsTransaccionDiaria with(nolock) LEFT OUTER JOIN
						  tClOficinas with(nolock) ON tCsTransaccionDiaria.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
						  tAhClTipoTrans with(nolock) ON tCsTransaccionDiaria.TipoTransacNivel3 = tAhClTipoTrans.idTipoTrans
	left join tCsAhorros as a with(nolock) on a.codcuenta = tCsTransaccionDiaria.CodigoCuenta and a.FraccionCta = tCsTransaccionDiaria.FraccionCta and a.Renovado = tCsTransaccionDiaria.Renovado and a.Fecha = tCsTransaccionDiaria.Fecha 
	WHERE     (tCsTransaccionDiaria.Fecha >= @Inicio) AND (tCsTransaccionDiaria.Fecha <= @Fin) AND (tCsTransaccionDiaria.CodSistema = 'AH') 
              --AND  (tCsTransaccionDiaria.CodigoCuenta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5)) + '-' + tCsTransaccionDiaria.FraccionCta = @Cuenta)
	and (tCsTransaccionDiaria.CodigoCuenta + '-' + tCsTransaccionDiaria.FraccionCta + '-' + CAST(tCsTransaccionDiaria.Renovado AS varchar(5)) = @Cuenta )
--and tCsTransaccionDiaria.CodigoCuenta = '098-105-06-2-2-00180'
--End    

--select * from #tablaMovs order by fecha,NroTransaccion --COMENTAR

---------------------------------
--OSC, obtiene el saldo inicial del periodo
select 
@SaldoInicialPeriodo = 
(
isnull(sum(
case  
   --when tt.EsDebito = 0 
   --when TipoTransacNivel3 in (2, 7, 63, 7)
	when TipoTransacNivel3 in (2, 4, 15) --OSC, 12-09-2018:VERIFICAR SI FUNCIONAARA DPF
   then td.MontoTotalTran 
   else 0 
end
),0)
) 
-
(
isnull(sum(
case  
   --when tt.EsDebito = 1 
   --when TipoTransacNivel3 in (62, 1)
	when TipoTransacNivel3 in (1, 3, 62)  --OSC, 12-09-2018:VERIFICAR SI FUNCIONAARA DPF
   then td.MontoTotalTran 
   else 0 
end
),0)
)
from tCsTransaccionDiaria as td
inner join tAhClTipoTrans as tt on tt.idTipoTrans = td.TipoTransacNivel3
where (td.CodigoCuenta  + '-' + td.FraccionCta + '-' + CAST(td.Renovado AS varchar(5)) = @Cuenta) 
and td.Fecha < @Inicio


---------------------------------
set @SaldoInicialPeriodo = isnull(@SaldoInicialPeriodo,0)
print 'SALDO INICIAL: ' +  convert(varchar,@SaldoInicialPeriodo) -- COMENTAR

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