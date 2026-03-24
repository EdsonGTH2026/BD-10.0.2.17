SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[pCsCaCuadroEstimacionMovimiento]
@FI SmallDateTime, @FF SmallDateTime
As
--Set @FI = '20100612'
--Set @FF = '20100613'

Declare @Temp SmallDateTime

If @FI = @FF Begin Set @FI = DateAdd(Day, -1, @FI) End
If @FI > @FF 
Begin 
	Set @Temp 	= @FF
	Set @FF 	= @FI
	Set @FI		= @Temp
End


Select * from (
SELECT     tCsCarteraDet.Fecha AS Periodo, Concepto = 'AA-Saldo Inicial', SUM(tCsCarteraDet.SaldoCapital) AS Capital, 
                      SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido) AS Interes, 
                      + SUM(tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido) 
                      AS SaldoCartera, SUM(tCsCarteraDet.SReservaCapital) AS ReservaCapital, SUM(tCsCarteraDet.SReservaInteres) AS ReservaInteres, 
                      SUM(tCsCarteraDet.SReservaCapital) + SUM(tCsCarteraDet.SReservaInteres) AS ReservaPreventiva
FROM         tCsCarteraDet INNER JOIN
                      tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
WHERE     (tCsCarteraDet.Fecha = @FI) AND (tCsCartera.Cartera = 'ACTIVA')
GROUP BY tCsCarteraDet.Fecha
union
SELECT     Periodo = Cast(Periodo as SmallDateTime), Observacion AS Movimientos, SUM(SK) AS MovimientoCapital, SUM(SI) AS MovimientoInteres, SUM(SCartera) AS MovimientoCartera, SUM(IK) AS IK, SUM(II) 
                      AS II, SUM(Reserva) AS MovimientoReserva
FROM         (SELECT     Datos.*, tCsCartera.Estado, 	CASE 	WHEN Estado 	IS NULL			THEN 'Cancelación de Crédito' 		
								WHEN Estado 	= 'CASTIGADO' 		THEN 'Castigo de Crédito' 
								WHEN EstadoA 	IS NULL 		THEN 'Apertura de Crédito' 		
								WHEN Estado 	IS NOT NULL AND Estado NOT IN ('CASTIGADO') AND reservapreventivad IS NULL 
                                              								THEN 'Reclasificación de Tipo de Crédito' 
								WHEN IK = 0 AND II = 0 			THEN 'Mantiene' 
								WHEN IK + II < 0 			THEN 'Amortización' 
								WHEN IK + II > 0 			THEN 'Deterioro de Cartera' 
							END AS Observacion
                       FROM          (SELECT     ISNULL(Despues.Periodo, Antes.Periodo) AS Periodo, ISNULL(Antes.CodPrestamo, Despues.CodPrestamo) AS CodPrestamo, 
                                                        ISNULL(Despues.ReservaCapitalD, 0) - ISNULL(Antes.ReservaCapitalA, 0) AS IK, 
							ISNULL(Despues.ReservaInteresD, 0) - ISNULL(Antes.ReservaInteresA, 0) AS II, 
							EstadoA, 
							ISNULL(Despues.CapitalD, 0) - ISNULL(Antes.CapitalA, 0) AS SK, 
							ISNULL(Despues.InteresD, 0) - ISNULL(Antes.InteresA, 0) AS SI, 
							ISNULL(Despues.SaldoCarteraD, 0) - ISNULL(Antes.SaldoCarteraA, 0) AS SCartera, 
                                                        ISNULL(Despues.ReservaPreventivaD, 0) - ISNULL(Antes.ReservaPreventivaA, 0) AS Reserva, Despues.ReservaPreventivaD, 
                                                        Antes.ReservaPreventivaA
                                               FROM          (SELECT     dbo.fdufechaatexto(tCsCarteraDet.Fecha, 'AAAAMMDD') AS Periodo, tCsCarteraDet.CodPrestamo, SUM(tCsCarteraDet.SaldoCapital) 
                                                                                              AS CapitalA, 
                                                                                              SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido)
                                                                                               AS InteresA, 
                                                                                              + SUM(tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido)
                                                                                               AS SaldoCarteraA, SUM(tCsCarteraDet.SReservaCapital) AS ReservaCapitalA, SUM(tCsCarteraDet.SReservaInteres) 
                                                                                              AS ReservaInteresA, SUM(tCsCarteraDet.SReservaCapital) + SUM(tCsCarteraDet.SReservaInteres) AS ReservaPreventivaA, 
                                                                                              tCsCartera.Estado AS EstadoA
                                                                       FROM          tCsCarteraDet INNER JOIN
                                                                                              tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
                                                                       WHERE      (tCsCarteraDet.Fecha = @FI) AND (tCsCartera.Cartera = 'ACTIVA')
                                                                       GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCartera.Estado) Antes FULL OUTER JOIN
                                                                          (SELECT     dbo.fdufechaatexto(tCsCarteraDet.Fecha, 'AAAAMMDD') AS Periodo, tCsCarteraDet.CodPrestamo, SUM(tCsCarteraDet.SaldoCapital) 
                                                                                                   AS CapitalD, 
                                                                                                   SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido)
                                                                                                    AS InteresD, 
                                                                                                   + SUM(tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente
                                                                                                    + tCsCarteraDet.MoratorioVencido) AS SaldoCarteraD, SUM(tCsCarteraDet.SReservaCapital) AS ReservaCapitalD, 
                                                                                                   SUM(tCsCarteraDet.SReservaInteres) AS ReservaInteresD, SUM(tCsCarteraDet.SReservaCapital) 
                                                                                                   + SUM(tCsCarteraDet.SReservaInteres) AS ReservaPreventivaD, tCsCartera.Estado AS EstadoD
                                                                            FROM          tCsCarteraDet INNER JOIN
                                                                                                   tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
                                                                            WHERE      (tCsCarteraDet.Fecha = @FF) AND (tCsCartera.Cartera = 'ACTIVA')
                                                                            GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCartera.Estado) Despues ON Antes.CodPrestamo = Despues.CodPrestamo) 
                                              Datos LEFT OUTER JOIN
                                                  (SELECT     *
                                                    FROM          tcscartera
                                                    WHERE      fecha = @FF) tCsCartera ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCartera.CodPrestamo) Datos
WHERE     (Observacion <> 'Mantiene')
GROUP BY Observacion, Periodo
union
SELECT     tCsCarteraDet.Fecha AS Periodo, Concepto = 'ZZ-Saldo Final', SUM(tCsCarteraDet.SaldoCapital) AS Capital, 
                      SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido) AS Interes, 
                      + SUM(tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido) 
                      AS SaldoCartera, SUM(tCsCarteraDet.SReservaCapital) AS ReservaCapital, SUM(tCsCarteraDet.SReservaInteres) AS ReservaInteres, 
                      SUM(tCsCarteraDet.SReservaCapital) + SUM(tCsCarteraDet.SReservaInteres) AS ReservaPreventiva
FROM         tCsCarteraDet INNER JOIN
                      tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
WHERE     (tCsCarteraDet.Fecha = @FF) AND (tCsCartera.Cartera = 'ACTIVA')
GROUP BY tCsCarteraDet.Fecha) Datos 
Order by Periodo, Concepto

GO