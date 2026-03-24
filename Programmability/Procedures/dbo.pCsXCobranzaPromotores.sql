SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

----pCsXCobranzaPromotores '3','','','Al corriente',0,0
CREATE procedure [dbo].[pCsXCobranzaPromotores] @codoficina varchar(1000), @cliente varchar(30)
	,@codprestamo varchar(20),@CA varchar(15),@diaslim int,@diasmin int
as
BEGIN

	--comentar
/*	
	declare @cliente varchar(30)
	declare @codprestamo varchar(20)
	declare @codoficina varchar(1000)
	declare @CA varchar(15)
	declare @diaslim int
	declare @diasmin int

	set @cliente = ''--'%sanchez%'
	set @codprestamo = ''--'008-170-06-05-00767'
	set @codoficina='3'
	set @CA=''
	set @diaslim=0
	set @diasmin=0
*/
	if (@cliente <> '') set @cliente = '%' + @cliente + '%'
	if (@codprestamo <> '') set @codprestamo = '%' + @codprestamo + '%'
	if (@CA='') set @CA='Toda'
	if (@diaslim=0) set @diaslim=60

	declare @fechaProceso smalldatetime
	Select @fechaProceso = FechaConsolidacion From vCsFechaConsolidacion
	--top 30 
	select c.fecha, c.CodPrestamo, c.Estado,c.CodOficina, c.CodProducto,c.CodUsuario, pc.NombreCompleto as Cliente,
	c.FechaDesembolso, c.FechaVencimiento, c.MontoDesembolso,c.NroDiasAtraso, c.SaldoCapital,c.ModalidadPlazo, c.NroCuotas, 
	c.CuotaActual, c.NroCuotasPagadas, c.NroCuotasPorPagar,c.CodAsesor,	pc.CodUbiGeoDirFamPri, pc.DireccionDirFamPri,  pc.NumExtFam,  pc.NumIntFam,  pc.TelefonoDirFamPri, pc.CodPostalFam
	,vuc.Colonia, vuc.Municipio, vuc.estado
	,cc.saldoatrasado,d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovencido+d.moratoriovigente+d.moratorioctaorden+d.impuestos+d.cargomora+d.otroscargos deuda
	from dbo.tCsCartera  as c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	inner join tCsPadronClientes as pc with(nolock) on pc.CodUsuario =  c.CodUsuario
	inner join vCsUbigeoColonia as vuc with(nolock) on vuc.CodUbiGeo = pc.CodUbiGeoDirFamPri
	inner join (
		select codprestamo,sum(montodevengado-montopagado-montocondonado) saldoatrasado
		from tcspadronplancuotas with(nolock)
		where estadocuota<>'CANCELADO' and fechavencimiento<=@fechaProceso+1
		--where codprestamo='003-166-06-00-01076'
		--and fechainicio<='20180416'
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
	
	order by c.NroDiasAtraso desc
	--258 --> toda
	--234 --> menor a 60
END

--15.52
--select codprestamo
--,sum(case when codconcepto='CAPI' then
--		case when fechainicio<'20180416' then montodevengado-montopagado-montocondonado
--		else 0 end
--	else 
--		montodevengado-montopagado-montocondonado
--	end) saldoatrasado
--from tcspadronplancuotas with(nolock)
--where codprestamo='003-166-06-00-01076'
--and estadocuota<>'CANCELADO'
--and fechainicio<='20180416'
--group by codprestamo


--select *
--from tcscarteradet
--where codprestamo='003-166-06-00-01076'
--and fecha='20180416'


GO