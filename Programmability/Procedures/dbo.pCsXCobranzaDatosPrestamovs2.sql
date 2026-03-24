SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsXCobranzaDatosPrestamovs2] @codprestamo varchar(20)
as
set nocount on
--BEGIN
	--declare	@codprestamo varchar(20)
	--set @codprestamo='004-170-06-05-03642'

	--select top 10 * from  tCsCarteradet  as d with(nolock)
	declare @fechaProceso smalldatetime
	select @fechaProceso = fechaconsolidacion from vCsFechaConsolidacion

	declare @garantia money
	declare @ahcuenta varchar(25)
	select @garantia=garantia,@ahcuenta=docpropiedad
	from tcsdiagarantias with(nolock)
	where codigo=@codprestamo and fecha=@fechaProceso and tipogarantia='GARAH'

	set @garantia=isnull(@garantia,0)

	declare @saldoah money
	select @saldoah=saldocuenta
	from tcsahorros with(nolock)
	where codcuenta=@ahcuenta and fecha=@fechaProceso

	select c.CodPrestamo, c.SecCuota, c.FechaInicio, c.FechaVencimiento, c.CodConcepto,c.MontoCuota,            
	c.MontoDevengado,c.MontoPagado,c.MontoCondonado,(c.MontoDevengado - MontoPagado - MontoCondonado) as Saldo,
	(case 
		when (FechaVencimiento <= @fechaProceso) then 'ANTERIOR'
		when (c.FechaInicio <= @fechaProceso and FechaVencimiento >= @fechaProceso) then 'VIGENTE'
		when (c.FechaInicio >= @fechaProceso ) then 'SIGUIENTE'
		else  '' end) as Cuota
	into #Saldos
	from tcspadronplancuotas c with(nolock)
	where c.seccuota>0 and c.numeroplan=0
	and c.codprestamo=@codprestamo

	select codprestamo,sum(monto) monto
	into #PagoHoy
	from (
		select codprestamo, isnull(sum(Saldo),0) monto
		from #Saldos with(nolock)
		where cuota = 'VIGENTE' and CodConcepto in ('MORA', 'IVACM','INTE', 'IVAIT') and Saldo > 0
		group by codprestamo
		union all
		select codprestamo,isnull(sum(Saldo),0) monto
		from #Saldos with(nolock)
		where cuota = 'VIGENTE'
		and CodConcepto in ('CAPI', 'SDV','SDM')
		and Saldo > 0
		and FechaVencimiento = @fechaProceso 
		group by codprestamo
		union all
		select codprestamo,isnull(sum(Saldo),0) monto
		from #Saldos with(nolock)
		where cuota <> 'VIGENTE'
		and Saldo > 0
		and FechaVencimiento <= @fechaProceso
		group by codprestamo
	) a
	group by codprestamo


	select  c.fecha, c.CodPrestamo, c.Estado as EstadoPrestamo, c.CodOficina, o.NomOficina, c.CodProducto,
	c.CodUsuario, cl.NombreCompleto as Cliente, c.FechaDesembolso, c.FechaVencimiento, c.MontoDesembolso,
	c.NroDiasAtraso,c.SaldoCapital
	,d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden
	+d.otroscargos+d.cargomora+d.impuestos saldototal
	,+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden intereses
	,case when @saldoah<@garantia then 0 else @garantia end garantia
	,c.ModalidadPlazo, c.NroCuotas,c.CuotaActual, c.NroCuotasPagadas, c.NroCuotasPorPagar
	--pc.CodUbiGeoDirFamPri, pc.DireccionDirFamPri,  pc.NumExtFam,  pc.NumIntFam,  pc.TelefonoDirFamPri, pc.CodPostalFam,
	--vuc.Colonia, vuc.Municipio, vuc.estado
	--,dbo.fCaBase97('7006', '1448746',replace(c.codprestamo,'-','')) Ref_BANAMEX
	,dbo.fCaBancomerReferencia(replace(c.codprestamo,'-','')) Ref_BANCOMER
	,dbo.fCaBanorteReferencia(replace(c.codprestamo,'-',''),'') Ref_Banorte
	,direcciondirfampri+' '+ numextfam+' '+numintfam+', Col. '+ul.DescUbiGeo+' Mun. '+ um.DescUbiGeo + ' Edo. ' + ue.DescUbiGeo direccion
	,isnull(telefonodirfampri,telefonodirnegpri) Telefono
	,cl.telefonomovil
	,(case cl.Sexo when 1 then 'MASCULINO' else 'FEMENINO' end) as Sexo
	,(case CodEstadoCivil 
 when 'C' then 'CASADO' 
 when 'S' then 'SOLTERO' 
 when 'U' then 'UNION LIBRE' 
 else 'DESCONOCIDO' end) as EstadoCivil
 ,isnull(ph.monto,0) 'SaldoPonerCorriente'
	from tCsCartera  as c with(nolock)
	inner join tCsCarteradet  as d with(nolock) on d.codprestamo=c.codprestamo and d.fecha=c.fecha
	inner join tCsPadronClientes as cl with(nolock) on cl.CodUsuario =  c.CodUsuario
	--inner join vCsUbigeoColonia as vuc with(nolock) on vuc.CodUbiGeo = pc.CodUbiGeoDirFamPri
	inner join tcloficinas as o with(nolock) on o.CodOficina = c.CodOficina
	left outer join tclubigeo uL with(nolock) on uL.codubigeo=cl.CodUbiGeodirfampri
	left outer join tclubigeo uM with(nolock) on uM.codubigeotipo='MUNI' and uM.codarbolconta=substring(uL.codarbolconta,1,19) 
	left outer join tclubigeo uE with(nolock) on uE.codubigeotipo='ESTA' and uE.codarbolconta=substring(uL.codarbolconta,1,13) 
	left outer join #PagoHoy ph with(nolock) on ph.codprestamo=c.codprestamo
	where c.fecha = @fechaProceso
	and c.CodPrestamo = @codprestamo

--END
GO