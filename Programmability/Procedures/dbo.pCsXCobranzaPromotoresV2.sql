SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXCobranzaPromotoresV2] @codasesor varchar(15), 
												@codoficina varchar(1000), 
												@cliente varchar(30), 
												@codprestamo varchar(20), 
												@CA varchar(15), 
												@diaslim int, 
												@diasmin int
as
BEGIN

	if (@cliente <> '') set @cliente = '%' + @cliente + '%'
	if (@codprestamo <> '') set @codprestamo = '%' + @codprestamo + '%'
	if (@CA='') set @CA='Toda'
	if (@diaslim=0) set @diaslim=60

	declare @fechaProceso smalldatetime
	Select @fechaProceso = FechaConsolidacion From vCsFechaConsolidacion
	select 
		c.fecha, 
		c.CodPrestamo, 
		c.Estado, 
		c.CodOficina, 
		c.CodProducto, 
		c.CodUsuario, 
		pc.NombreCompleto as Cliente,
		c.FechaDesembolso, 
		c.FechaVencimiento, 
		cc.FechaVencimiento as FechaPago,
		c.MontoDesembolso, 
		c.NroDiasAtraso, 
		c.SaldoCapital, 
		c.ModalidadPlazo, 
		c.NroCuotas, 
		c.CuotaActual, 
		c.NroCuotasPagadas, 
		c.NroCuotasPorPagar, 
		c.CodAsesor, 
		pc.CodUbiGeoDirFamPri, 
		pc.DireccionDirFamPri, 
		pc.NumExtFam, 
		pc.NumIntFam, 
		pc.TelefonoDirFamPri, 
		pc.CodPostalFam, 
		vuc.Colonia, 
		vuc.Municipio, 
		vuc.estado, 
		cc.saldoatrasado, 
		d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovencido+d.moratoriovigente+d.moratorioctaorden+d.impuestos+d.cargomora+d.otroscargos deuda
	from dbo.tCsCartera  as c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	inner join tCsPadronClientes as pc with(nolock) on pc.CodUsuario =  c.CodUsuario
	inner join vCsUbigeoColonia as vuc with(nolock) on vuc.CodUbiGeo = pc.CodUbiGeoDirFamPri
	inner join (
		select 
			codprestamo, 
			sum(montodevengado-montopagado-montocondonado) saldoatrasado,
			max(FechaVencimiento) FechaVencimiento
		from tcspadronplancuotas with(nolock)
		where 
			estadocuota<>'CANCELADO' 
		and fechavencimiento<=@fechaProceso+1
		group by codprestamo
	) cc on cc.codprestamo=c.codprestamo
	where c.fecha = @fechaProceso 
		and ((c.CodPrestamo like '%'+@codprestamo+'%' and @codprestamo <> '') 
		or (c.CodPrestamo = c.CodPrestamo and @codprestamo = ''))
		and c.codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
		and cartera='ACTIVA' --and c.Estado = 'VENCIDO'
    	and c.NroDiasAtraso<@diaslim
	  	and c.NroDiasAtraso>=@diasmin
		and ((c.NroDiasAtraso=0 and @CA='Al corriente') 
		or (c.NroDiasAtraso>0 and @CA='Atrasada') 
		or (c.NroDiasAtraso>=0 and @CA='Toda') )
    	and ((pc.NombreCompleto like '%'+@cliente+'%' and @cliente <> '') 
		or (pc.NombreCompleto = pc.NombreCompleto and @cliente = ''))
    	and (c.codasesor=@codasesor or @codasesor='' or @codasesor is null)
		order by c.NroDiasAtraso desc
END
GO