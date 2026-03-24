SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaCACobranzaPrograCartaPromotor] @FecIni smalldatetime,@FecFin smalldatetime, @codpromotor varchar(15), @cob_progra money out
as
--declare @FecIni smalldatetime
--declare @FecFin smalldatetime
--set @FecIni='20190501'
--set @FecFin='20190531'
--declare @codpromotor varchar(15)
--set @codpromotor='GCC3012991'

declare @Fecha smalldatetime
select @Fecha = fechaconsolidacion from vCsFechaConsolidacion

SELECT @cob_progra = sum(a.CAPI) --capital
FROM tCsCarteraDet d with(nolock)
INNER JOIN tCsCartera c with(nolock) ON d.Fecha = c.Fecha AND d.CodPrestamo = c.CodPrestamo
INNER JOIN (
	SELECT Fecha, FechaVencimiento, CodPrestamo, CodUsuario,sum(CASE CodConcepto WHEN 'capi' THEN MontoCuota  ELSE 0 END) AS CAPI
	FROM tCsPadronPlanCuotas with(nolock)
	WHERE (FechaVencimiento >=@FecIni) AND (FechaVencimiento <= @FecFin)
	GROUP BY Fecha, FechaVencimiento, CodPrestamo, CodUsuario
) a ON d.CodPrestamo=a.CodPrestamo AND d.CodUsuario=a.CodUsuario 
WHERE (d.Fecha=@Fecha) AND (c.cartera='ACTIVA')
and c.codasesor=@codpromotor and c.nrodiasatraso>=0 and c.nrodiasatraso<=30

GO