SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCaHistoricoSaldoConcepto]
                 @TFechaProceso  datetime,
                 @CodOficina     varchar(4)  
WITH ENCRYPTION
AS

SET NOCOUNT ON



INSERT INTO tCaHistoricoSaldosConcepto ( FechaProceso, CodPrestamo, CodConcepto, Estado, Saldo)
	SELECT Z.FechaProceso , Z.CodPrestamo, Z.CodConcepto, Z.Estado, Z.Saldo
	FROM (
			SELECT	@TFechaProceso as FechaProceso, PP.CodPrestamo, C.CodConcepto, PP.Estado,
				 		C.Saldo
				FROM tCaPrestamos PP 
					INNER JOIN ( SELECT CodPrestamo, NumeroPlan, CodConcepto, SUM (MontoDevengado) - SUM (MontoPagado) - SUM (MontoCondonado) AS Saldo
												FROM tCaCuotasCli 
												GROUP BY CodPrestamo, NumeroPlan, CodConcepto ) C
					ON C.CodPrestamo = PP.CodPrestamo
				WHERE (PP.CodPrestamo NOT LIKE '000-%') AND (PP.Estado NOT IN ('ANULADO'))
							AND (PP.Estado NOT IN ('TRAMITE', 'ANULADO', 'APROBADO', 'CANCELADO'))
							AND NOT (PP.Estado = 'CANCELADO' AND PP.EstadoAnterior = 'CANCELADO')
							AND PP.CodOficina = @CodOficina
					 		AND C.NumeroPlan = 0 
			) Z
	WHERE NOT EXISTS (SELECT 1 FROM tCaHistoricoSaldosConcepto H
                 			WHERE Z.FechaProceso = H.FechaProceso AND Z.CodPrestamo = H.CodPrestamo AND Z.CodConcepto = H.CodConcepto)


GO