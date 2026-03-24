SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCiPrepararPadronPlanCuotas2]
as
set nocount on
Declare @Fecha SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

UPDATE tCsCartera
SET    CuotaActual = Z.SecCuota
--select tCsCartera.codprestamo,tCsCartera.cuotaactual,Z.SecCuota
FROM   tCsPadronPlanCuotas Z with(nolock) 
inner join tCsCartera with(nolock) on tCsCartera.CodPrestamo = Z.CodPrestamo
AND    tCsCartera.Fecha >= Z.FechaInicio 
AND    tCsCartera.Fecha <= Z.FechaVencimiento
Where  tCsCartera.Fecha = @Fecha --'20220420'--
And CuotaActual Is null
and tCsCartera.codoficina not in('230','231')

--set @T2 = getdate()
--print 'Tiempo 4 - '+ cast( datediff(millisecond, @T1, @T2) as varchar(10))
--set @T1 = getdate()

UPDATE tCsCartera
SET    CuotaActual = NroCuotas
WHERE  CuotaActual IS NULL AND Fecha > FechaVencimiento
and    Fecha between dateadd(d, -1 , @Fecha) and @Fecha
and codoficina not in('230','231')

--set @T2 = getdate()
--print 'Tiempo 5 - '+ cast( datediff(millisecond, @T1, @T2) as varchar(10))
--set @T1 = getdate()

UPDATE tCsCartera
SET    CuotaActual = 0
WHERE  CuotaActual IS NULL AND Fecha = FechaDesembolso
and    Fecha between dateadd(d, -1 , @Fecha) and @Fecha
and codoficina not in('230','231')

--set @T2 = getdate()
--print 'Tiempo 6 - '+ cast( datediff(millisecond, @T1, @T2) as varchar(10))
--set @T1 = getdate()

UPDATE tCsCartera
SET    CuotaActual = 0
WHERE  CuotaActual IS NULL AND NroDiasAtraso = 0 AND NroCuotasPagadas = 0 AND Fecha >= FechaDesembolso
and    Fecha between dateadd(d, -1 , @Fecha) and @Fecha
and codoficina not in('230','231')

--set @T2 = getdate()
--print 'Tiempo 7 - '+ cast( datediff(millisecond, @T1, @T2) as varchar(10))
--set @T1 = getdate()

UPDATE tCsCartera
SET   CuotaActual = Z.SecCuota
FROM  tCsPadronPlanCuotas Z with(nolock) 
WHERE tCsCartera.CuotaActual IS NULL 
And   tCsCartera.Fecha = @Fecha
AND   tCsCartera.CodPrestamo = Z.CodPrestamo 
AND   tCsCartera.ProximoVencimiento = Z.FechaVencimiento
and tCsCartera.codoficina not in('230','231')

--set @T2 = getdate()
--print 'Tiempo 8 - '+ cast( datediff(millisecond, @T1, @T2) as varchar(10))
--set @T1 = getdate()
GO