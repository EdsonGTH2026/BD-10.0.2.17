SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--'''INPE'', ''INTE'', ''INVE'''
--'''MORA'', ''COM'', ''CLC'''
--Drop Procedure pCsCaAnexosTransacciones
CREATE Procedure [dbo].[pCsCaAnexosTransacciones]
@Fecha 		SmallDateTime,
@Conceptos 	Varchar(1000),
@TipoCredito	Varchar(100),
@Garantia	Int,
@DI		Int,
@DF		Int,
@Valor 		Decimal(18,4) OUTPUT
As

--Set @Fecha 		= '20080930'
--Set @Conceptos	= '''MORA'', ''COM'', ''CLC'''
--Set @TipoCredito 	= '1'	
--Set @Garantia		= 2

Declare @Cadena 	Varchar(4000)
Declare @GarantiaC 	Varchar(1000)
Declare @FechaI 	SmallDateTime

Set @FechaI = CAST(dbo.FduFechaAtexto(@Fecha, 'AAAAMM') +  '01' as SmallDateTime)

Create Table #Saldo (Valor [decimal](18,4) null)

If @Garantia = 2 
Begin 
	Set @GarantiaC = '' 
End 
If @Garantia In(0,1) 
Begin 
	Set @GarantiaC = 'AND Garantia In('+ Cast(@Garantia as Varchar(1)) +')' 
End 

Set @Cadena = 'SELECT SUM(MontoPagado) AS Pago '
Set @Cadena = @Cadena + 'FROM (SELECT Pagos.Fecha AS FechaPago, Pagos.CodPrestamo, Pagos.CodConcepto, Pagos.MontoPagado, Pagos.SecPago, Pagos.SecCuota, '
Set @Cadena = @Cadena + 'tCsCartera.Fecha, tCsCartera.NroDiasAtraso, ISNULL(Garantias.Activo, 0) AS Garantia, CodTipoCredito '
Set @Cadena = @Cadena + 'FROM (SELECT Fecha, CodPrestamo, CodConcepto, MontoPagado, SecPago, SecCuota '
Set @Cadena = @Cadena + 'FROM tCsPagoDet with(nolock) '
Set @Cadena = @Cadena + 'WHERE (Extornado = 0) AND (CodConcepto IN (''INPE'', ''INTE'', ''INVE'', ''MORA'')) AND fecha <= ''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''' AND fecha >= ''' + dbo.FduFechaAtexto(@FechaI, 'AAAAMMDD') + ''' '
Set @Cadena = @Cadena + 'UNION '
Set @Cadena = @Cadena + 'SELECT DISTINCT ' 
Set @Cadena = @Cadena + 'tCsPadronCarteraDet.Desembolso AS Fecha, tCsConceptosPrestamo.CodPrestamo, tCsConceptosPrestamo.CodConcepto, '
Set @Cadena = @Cadena + 'tCsConceptosPrestamo.TotalPagado - tCsConceptosPrestamo.TotalCondonado AS Pagado, SecPago = 0, SecCuota = 1 '
Set @Cadena = @Cadena + 'FROM tCsConceptosPrestamo with(nolock) INNER JOIN '
Set @Cadena = @Cadena + 'tCsPadronCarteraDet with(nolock) ON tCsConceptosPrestamo.CodPrestamo = tCsPadronCarteraDet.CodPrestamo '
Set @Cadena = @Cadena + 'WHERE (tCsConceptosPrestamo.TipoCobro = ''A'') AND (tCsConceptosPrestamo.CodConcepto IN (''COM'', ''CLC'')) AND '
Set @Cadena = @Cadena + 'tCsPadronCarteraDet.Desembolso <= ''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''' AND tCsPadronCarteraDet.Desembolso >= ''' + dbo.FduFechaAtexto(@FechaI, 'AAAAMMDD') + ''') Pagos LEFT OUTER JOIN '
Set @Cadena = @Cadena + '(SELECT DISTINCT Fecha, Codigo, 1 AS Activo '
Set @Cadena = @Cadena + 'FROM tCsDiaGarantias with(nolock) '
Set @Cadena = @Cadena + 'WHERE fecha = ''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''') Garantias ON Pagos.CodPrestamo = Garantias.Codigo LEFT OUTER JOIN '
Set @Cadena = @Cadena + 'tCsCartera with(nolock) ON Pagos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo '
Set @Cadena = @Cadena + 'WHERE (tCsCartera.Fecha = ''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''') AND (tCsCartera.Cartera = ''ACTIVA'')) Datos '
Set @Cadena = @Cadena + 'WHERE (CodConcepto IN (' + @Conceptos + ')) And CodTipoCredito in (' + @TipoCredito + ') AND (NroDiasAtraso >= '+ Cast(@DI as Varchar(10)) +') AND (NroDiasAtraso <= '+ Cast(@DF as Varchar(10)) +') ' + @GarantiaC

--Print @Cadena

Exec ('Insert Into #Saldo (Valor) ' + @Cadena)
Set @Valor = 0
Select @Valor = Isnull(Valor,0) From #Saldo

Print @Valor

Drop Table #Saldo
GO