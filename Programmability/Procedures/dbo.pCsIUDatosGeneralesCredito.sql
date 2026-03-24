SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsIUDatosGeneralesCredito] @CodCliente varchar(25), @CodPrestamo varchar(25) AS

declare  @csql varchar(8000)

SET  @csql = ''

IF( len(@CodCliente)=0 )
begin
	SET  @csql = @csql + ' SELECT     Fecha, SUM(deuda) AS deuda, SUM(MontoDesembolso) AS MontoDesembolso, SUM(SaldoCapital) AS SaldoCapital, SUM(Interes) AS Interes,  '
	SET  @csql = @csql + ' SUM(Moratorio) AS Moratorio, SUM(OtrosCargos) AS OtrosCargos, UltimoMovimiento, TipoCredito, Estado, Calificacion, SUM(Reserva) AS Reserva,  '
	SET  @csql = @csql + ' TipoReprog, PrestamoReprog, Cancelacion, NomAsesor, NemFuenteFin, NombreProdCorto, Destino, CodSolicitud, FechaSolicitud, NivelAprobacion, '
	SET  @csql = @csql + ' FechaDesembolso, FechaVencimiento, NroCuotas, SUM(saldoatrasado) AS saldoatrasado, SUM(saldovencido) AS saldovencido, TipoPlazo, Plazo,  '
	SET  @csql = @csql + ' TasaIntCorriente, TasaINPE, SUM(GarantiaLiquidaMonetizada) AS GarantiaLiquidaMonetizada, SUM(GarantiaPreferidaMonetizada)  '
	SET  @csql = @csql + ' AS GarantiaPreferidaMonetizada, SUM(GarantiaMuyRapidaRealizacion) AS GarantiaMuyRapidaRealizacion, SUM(TotalGarantia) AS TotalGarantia,  '
	SET  @csql = @csql + ' NroDiasAtraso, SUM(DeudaAtrasada) AS DeudaAtrasada, NombreGrupo FROM ( '
	SET  @csql = @csql + ''
end

SET  @csql = @csql + 'SELECT     tCsCarteraDet.Fecha, case tCsPadronCarteraDet.EstadoCalculado when ''CANCELADO'' then 0 else '
SET  @csql = @csql + ' tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido + tCsCarteraDet.MoratorioCtaOrden + '
SET  @csql = @csql +  ' tCsCarteraDet.OtrosCargos + tCsCarteraDet.Impuestos + tCsCarteraDet.CargoMora end AS deuda, tCsCarteraDet.MontoDesembolso, case tCsPadronCarteraDet.EstadoCalculado when ''CANCELADO'' then 0 else tCsCarteraDet.SaldoCapital end SaldoCapital,  '
SET  @csql = @csql +  ' case tCsPadronCarteraDet.EstadoCalculado when ''CANCELADO'' then 0 else tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.InteresCtaOrden end AS Interes,  '
SET  @csql = @csql +  ' case tCsPadronCarteraDet.EstadoCalculado when ''CANCELADO'' then 0 else tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido + tCsCarteraDet.MoratorioCtaOrden end AS Moratorio,  '
SET  @csql = @csql +  ' case tCsPadronCarteraDet.EstadoCalculado when ''CANCELADO'' then 0 else tCsCarteraDet.OtrosCargos + tCsCarteraDet.Impuestos + tCsCarteraDet.CargoMora end AS OtrosCargos,  '
SET  @csql = @csql +  ' tCsCarteraDet.UltimoMovimiento, tCaProdPerTipoCredito.Descripcion AS TipoCredito, tCsPadronCarteraDet.EstadoCalculado AS Estado, '''' AS Calificacion, case tCsPadronCarteraDet.EstadoCalculado when ''CANCELADO'' then 0 else '
SET  @csql = @csql +  ' ISNULL(tCsCarteraDet.SReservaCapital, 0) + ISNULL(tCsCarteraDet.SReservaInteres, 0)  end AS Reserva, tCsCartera.TipoReprog, tCsCartera.PrestamoReprog, tCsPadronCarteraDet.Cancelacion, tCsPadronAsesores.NomAsesor, tClFuenteFin.NemFuenteFin,  '
SET  @csql = @csql +  'tCaProducto.NombreProdCorto, '''' AS Destino, tCsCartera.CodSolicitud, tCsCartera.FechaSolicitud, tCsCartera.NivelAprobacion,  tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento, tCsCartera.NroCuotas, 0 AS saldoatrasado, 0 AS saldovencido, '''' AS TipoPlazo, '
SET  @csql = @csql +  ' '''' AS Plazo, tCsCartera.TasaIntCorriente, tCsCartera.TasaINPE, tCsCartera.GarantiaLiquidaMonetizada, tCsCartera.GarantiaPreferidaMonetizada, tCsCartera.GarantiaMuyRapidaRealizacion, tCsCartera.TotalGarantia, tCsCartera.NroDiasAtraso '

SET  @csql = @csql +  ' , tCsCarteraDet.CapitalVencido + tCsCarteraDet.InteresVencido + tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioVencido + tCsCarteraDet.MoratorioCtaOrden '
SET  @csql = @csql +  '  + tCsCarteraDet.OtrosCargos + tCsCarteraDet.Impuestos + tCsCarteraDet.CargoMora AS DeudaAtrasada, tCsCarteraGrupos.NombreGrupo '

SET  @csql = @csql +  ' FROM         tCsCartera INNER JOIN tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN '
SET  @csql = @csql +  ' tCsPadronCarteraDet ON tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND  tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario AND tCsCarteraDet.Fecha = tCsPadronCarteraDet.FechaCorte LEFT OUTER JOIN '
SET  @csql = @csql +  ' tClFuenteFin ON tCsCartera.CodFondo = tClFuenteFin.CodFuenteFin LEFT OUTER JOIN tCsPadronAsesores ON tCsCartera.CodAsesor = tCsPadronAsesores.CodAsesor LEFT OUTER JOIN '
SET  @csql = @csql +  ' tCaProdPerTipoCredito ON tCsCartera.CodTipoCredito = tCaProdPerTipoCredito.CodTipoCredito LEFT OUTER JOIN tCaProducto ON tCsCartera.CodProducto = tCaProducto.CodProducto '

SET  @csql = @csql +  ' LEFT OUTER JOIN tCsCarteraGrupos ON tCsCartera.CodOficina = tCsCarteraGrupos.CodOficina AND tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo '

SET  @csql = @csql +  ' WHERE  (tCsCarteraDet.CodPrestamo = '''+@CodPrestamo+''')    '

IF( len(@CodCliente)>0 ) SET  @csql = @csql +  ' AND  (tCsCarteraDet.CodUsuario = '''+@CodCliente+''')  '


IF( len(@CodCliente)=0 )
begin
	SET  @csql = @csql + ' ) a GROUP BY Fecha, UltimoMovimiento, TipoCredito, Estado, Calificacion, TipoReprog, PrestamoReprog, Cancelacion, NomAsesor, NemFuenteFin,  '
	SET  @csql = @csql + ' NombreProdCorto, Destino, CodSolicitud, FechaSolicitud, NivelAprobacion, FechaDesembolso, FechaVencimiento, NroCuotas, TipoPlazo, Plazo,  '
	SET  @csql = @csql + ' TasaIntCorriente, TasaINPE, NroDiasAtraso, NombreGrupo '
end

--print @csql
exec (@csql)
GO