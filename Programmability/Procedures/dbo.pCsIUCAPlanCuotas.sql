SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIUCAPlanCuotas] @CodUsuario varchar(25), @CodPrestamo varchar(25) AS


declare  @csql varchar(8000)

SET  @csql = ' SELECT  SecCuota, DiasAtrCuota, FechaVencimiento, MAX(FechaPagoConcepto) AS FechaPagoConcepto, SUM(MontoCuota) AS MontoCuota,  '
SET  @csql = @csql + ' SUM(MontoDevengado) AS MontoDevengado, SUM(MontoPagado) AS MontoPagado, SUM(MontoCondonado) AS MontoCondonado, SUM(SaldoCuota)  '
SET  @csql = @csql + ' AS SaldoCuota, EstadoCuota FROM  (SELECT pl.SecCuota, pl.DiasAtrCuota, pl.FechaVencimiento, pl.FechaPagoConcepto,  '
SET  @csql = @csql + ' pl.SecPago, pl.MontoCuota, pl.MontoDevengado,  pl.MontoPagado, pl.MontoCondonado, pl.MontoDevengado '
SET  @csql = @csql + ' - pl.MontoPagado + pl.MontoCondonado AS SaldoCuota, pl.EstadoCuota FROM tCspadronPlanCuotas pl with(nolock) INNER JOIN '
SET  @csql = @csql + ' tCsPadronCarteraDet pcd with(nolock) ON pl.CodPrestamo = pcd.CodPrestamo AND pl.CodUsuario = pcd.CodUsuario AND '
SET  @csql = @csql + ' pl.Fecha = pcd.FechaCorte WHERE      (pcd.CodPrestamo = '''+@CodPrestamo+''')  '

IF( len(@CodUsuario)<>0 ) SET  @csql = @csql + ' AND (pcd.CodUsuario = '''+@CodUsuario+''') '

SET  @csql = @csql + ' ) A GROUP BY SecCuota, DiasAtrCuota, FechaVencimiento, EstadoCuota '
SET  @csql = @csql + ' ORDER BY SecCuota '

exec (@csql )
GO