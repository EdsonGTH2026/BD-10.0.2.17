SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaRptProximosVencimientos]  @Fecha smalldatetime, @FecIni smalldatetime, @FecFin smalldatetime, @Cartera varchar(100), @CodOficina varchar(100) as

--SET @Fecha = '20080831'
--SET @FecIni = '20080901'
--SET @FecFin = '20080930'
--SET @Cartera = '''ACTIVA'''
--SET @CodOficina = '0'


--select @Fecha = fechaconsolidacion from vCsFechaConsolidacion

DECLARE @csql varchar(8000)

SET @csql = 'SELECT ''1'' + REPLICATE(''0'', 2 - LEN(CAST(tClOficinas.CodOficina AS int))) + tClOficinas.CodOficina + ''  '' + tClOficinas.NomOficina AS Oficina, '
SET @csql = @csql + 'tCaClTecnologia.NombreTec, tCsPadronClientes.NombreCompleto AS Asesor, tCsCartera.CodPrestamo, CuotasVenc.FechaVencimiento, '
SET @csql = @csql + 'CuotasVenc.CAPI, '
SET @csql = @csql + 'CuotasVenc.INTE, '
SET @csql = @csql + 'CuotasVenc.INPE, '
SET @csql = @csql + ' + CuotasVenc.CAPI + CuotasVenc.INTE + CuotasVenc.INPE MontoCuota , Cliente.NomCliente '
SET @csql = @csql + 'FROM tCsCarteraDet INNER JOIN tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo INNER JOIN '
SET @csql = @csql + 'tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina INNER JOIN tCsPadronCarteraDet ON tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND '
SET @csql = @csql + 'tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario INNER JOIN tCaProducto ON tCsCartera.CodProducto = tCaProducto.CodProducto INNER JOIN '
SET @csql = @csql + 'tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia INNER JOIN (SELECT Fecha, CodPrestamo, CodUsuario, FechaVencimiento, '
SET @csql = @csql + 'SUM(CAPI) AS CAPI, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(INVE) AS INVE FROM (SELECT Fecha, FechaVencimiento, CodPrestamo, CodUsuario, '
SET @csql = @csql + 'CASE CodConcepto WHEN ''capi'' THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS CAPI, CASE CodConcepto WHEN ''inte'' '
SET @csql = @csql + 'THEN MontoDevengado - ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INTE, CASE CodConcepto WHEN ''inpe'' THEN MontoDevengado - '
SET @csql = @csql + 'ISNULL(MontoPagado, 0) - ISNULL(MontoCondonado, 0) ELSE 0 END AS INPE, CASE CodConcepto WHEN ''inve'' THEN MontoDevengado - ISNULL(MontoPagado, 0) '
SET @csql = @csql + '- ISNULL(MontoCondonado, 0) ELSE 0 END AS INVE FROM tCsPadronPlanCuotas WHERE (EstadoCuota <> ''cancelado'') AND '
SET @csql = @csql + '(FechaVencimiento >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') AND (FechaVencimiento <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''')) A '
SET @csql = @csql + 'GROUP BY Fecha, FechaVencimiento, CodPrestamo, CodUsuario) CuotasVenc ON tCsCarteraDet.Fecha = CuotasVenc.Fecha AND '
SET @csql = @csql + 'tCsCarteraDet.CodPrestamo = CuotasVenc.CodPrestamo COLLATE Modern_Spanish_CI_AI AND tCsCarteraDet.CodUsuario = CuotasVenc.CodUsuario '
SET @csql = @csql + 'COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN tCsPadronClientes ON tCsCartera.CodAsesor = tCsPadronClientes.CodUsuario '
SET @csql = @csql + ' COLLATE Modern_Spanish_CI_AI LEFT OUTER JOIN '
SET @csql = @csql + ' (SELECT codusuario,nombrecompleto nomcliente FROM tcspadronclientes) Cliente ON tCsCarteradet.CodUsuario = Cliente.CodUsuario '
SET @csql = @csql + 'WHERE (tCsCarteraDet.Fecha = '''+dbo.fduFechaAAAAMMDD(@Fecha)+''') AND (tCsCartera.cartera IN('+@Cartera+')) '

--if(@CodOficina<>'0') 
SET @csql = @csql + ' AND (tCsCartera.CodOficina IN('+@CodOficina+')) '



exec (@csql)
GO