SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIUCAPlanCuotasDet] @Codusuario varchar(25), @CodPrestamo varchar(25), @Cuota int AS

DECLARE @csql  varchar(8000)

SET  @csql = ' '

IF( len(@CodUsuario)=0 )
	begin 
		SET  @csql = @csql + ' SELECT DescConcepto, SUM(MontoCuota) AS MontoCuota, SUM(MontoDevengado) AS MontoDevengado, SUM(MontoPagado) AS MontoPagado, '
		SET  @csql = @csql + ' SUM(MontoCondonado) AS MontoCondonado, SUM(SaldoCuota) AS SaldoCuota, EstadoConcepto FROM ( '
	end

SET  @csql = @csql + ' SELECT  tCaClConcepto.DescConcepto, pl.MontoCuota, pl.MontoDevengado, pl.MontoPagado, pl.MontoCondonado,  '
SET  @csql = @csql + ' pl.MontoDevengado - pl.MontoPagado + pl.MontoCondonado AS SaldoCuota, pl.EstadoConcepto, tCaClConcepto.Orden, pl.SecCuota '
SET  @csql = @csql + ' FROM tCspadronPlanCuotas pl with(nolock) LEFT OUTER JOIN tCaClConcepto ON pl.CodConcepto =  '
SET  @csql = @csql + ' tCaClConcepto.CodConcepto RIGHT OUTER JOIN tCsPadronCarteraDet pcd with(nolock) ON pl.CodPrestamo '
SET  @csql = @csql + ' = pcd.CodPrestamo AND pl.CodUsuario = pcd.CodUsuario AND pl.Fecha = pcd.FechaCorte '
SET  @csql = @csql + ' WHERE (pcd.CodPrestamo = '''+@CodPrestamo+''' ) '

if (@Cuota<>0) SET  @csql = @csql + ' AND (pl.SecCuota = '+Cast(@Cuota as varchar(2) )+') '

IF( len(@CodUsuario)<>0 ) SET  @csql = @csql + '  AND (pcd.CodUsuario = '''+@Codusuario+''')  '

IF( len(@CodUsuario)<>0 ) SET  @csql = @csql + ' and pl.MontoDevengado + pl.MontoPagado + pl.MontoCondonado <> 0  ORDER BY tCaClConcepto.Orden '

IF( len(@CodUsuario)=0 ) SET  @csql = @csql + ' ) A GROUP BY DescConcepto, EstadoConcepto, Orden ORDER BY Orden '

print @csql

exec (@csql)
GO