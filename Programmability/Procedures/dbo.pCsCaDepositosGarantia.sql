SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCaR21DepositosGarantia
CREATE Procedure [dbo].[pCsCaDepositosGarantia]
@Fecha SmallDateTime,
@Valor Decimal(18,4) OUTPUT
--Set @Fecha = '20080831'
AS

SELECT     @Valor = SUM(Garantia) 
FROM         tCsDiaGarantias
WHERE     (TipoGarantia IN ('GADPF', 'GARAH', '-A-')) AND (Fecha = @Fecha) AND (Estado NOT IN ('INACTIVO'))

--Select @Valor = Sum(SaldoCuenta) from #B
GO