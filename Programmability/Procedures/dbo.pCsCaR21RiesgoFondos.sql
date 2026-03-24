SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCaR21RiesgoFondos
Create Procedure [dbo].[pCsCaR21RiesgoFondos]
@Fecha 		SmallDateTime,
@Gobierno	Bit,
@Complemento	Bit,
@Valor Decimal(18,4) OUTPUT
--Set @Fecha = '20080831'
AS
Declare @PC Int

Set @PC = 0
IF @Complemento = 1 BEGIN Set @PC = 100 END

SELECT    @Valor = SUM(Saldo)
FROM         (SELECT     tCsCarteraDet.Fecha, tCsCartera.CodFondo, tClFondos.NemFondo, 
                                              (SUM(tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido)
                                               - SUM(tCsCarteraDet.SReservaCapital + tCsCarteraDet.SReservaInteres) * tClFondos.R21Estimacion) 
                                              * ABS(@PC - tClFondos.R21Porcentaje)/ 100 AS Saldo
                       FROM          tCsCartera INNER JOIN
                                              tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo LEFT OUTER JOIN
                                              tClFondos ON tCsCartera.CodFondo = tClFondos.CodEntero
                       WHERE      (tCsCartera.Fecha = @Fecha) AND (tCsCartera.Cartera = 'ACTIVA') AND (tClFondos.R21Gobierno = @Gobierno)
                       GROUP BY tCsCarteraDet.Fecha, tCsCartera.CodFondo, tClFondos.NemFondo, tClFondos.R21Porcentaje, tClFondos.R21Estimacion) Datos


GO