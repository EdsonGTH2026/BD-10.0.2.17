SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsEstadoCuentaCartera2016PorPagar]
    @CodPrestamo char(19),
    @FechaIni datetime,
    @FechaCorte datetime
AS
/*
    Noel Paricollo - 2016 10 06
*/

SET NOCOUNT ON

select FechaVencimiento, SecCuota, Saldo = sum(MontoDevengado - MontoPagado - MontoCOndonado)
from tCsPlanCuotas C
where CodPrestamo = @CodPrestamo
and Fecha = @FechaCorte
and FechaVencimiento between @FechaIni and @FechaCorte
and MontoDevengado > MontoPagado + MontoCondonado
group by FechaVencimiento, SecCuota
union all
select top 1 FechaVencimiento, SecCuota, Saldo = sum(MontoDevengado - MontoPagado - MontoCOndonado)
from tCsPlanCuotas C
where CodPrestamo = @CodPrestamo
and Fecha = @FechaCorte
and FechaVencimiento > @FechaCorte
and MontoDevengado > MontoPagado + MontoCondonado
group by FechaVencimiento, SecCuota

--ORDER BY PD.Fecha, PD.SecPago
GO