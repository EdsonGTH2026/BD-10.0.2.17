SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXCobranzaDatosPrestamo](@codprestamo varchar(20) )
as
BEGIN

	declare @fechaProceso smalldatetime
	--select @fechaProceso = max(fecha) from tCsCartera --??? esto tarda una eternidad
	select @fechaProceso = fechaconsolidacion from vCsFechaConsolidacion

	--declare	@codprestamo varchar(20)
	--set @codprestamo='315-170-06-08-04846'
	select  
	c.fecha, c.CodPrestamo, c.Estado as EstadoPrestamo, c.CodOficina, o.NomOficina, c.CodProducto,
	c.CodUsuario, pc.NombreCompleto as Cliente, c.FechaDesembolso, c.FechaVencimiento, c.MontoDesembolso,
	c.NroDiasAtraso, c.SaldoCapital,c.ModalidadPlazo, c.NroCuotas, 
	c.CuotaActual, c.NroCuotasPagadas, c.NroCuotasPorPagar,
	pc.CodUbiGeoDirFamPri, pc.DireccionDirFamPri,  pc.NumExtFam,  pc.NumIntFam,  pc.TelefonoDirFamPri, pc.CodPostalFam,
	vuc.Colonia, vuc.Municipio, vuc.estado
	,dbo.fCaBase97('7006', '1448746',replace(c.codprestamo,'-','')) Ref_BANAMEX
	,dbo.fCaBancomerReferencia(replace(c.codprestamo,'-','')) Ref_BANCOMER
	from dbo.tCsCartera  as c with(nolock)
	inner join tCsPadronClientes as pc with(nolock) on pc.CodUsuario =  c.CodUsuario
	inner join vCsUbigeoColonia as vuc with(nolock) on vuc.CodUbiGeo = pc.CodUbiGeoDirFamPri
	inner join tcloficinas as o with(nolock) on o.CodOficina = c.CodOficina 
	where c.fecha = @fechaProceso
	and c.CodPrestamo = @codprestamo

END

GO