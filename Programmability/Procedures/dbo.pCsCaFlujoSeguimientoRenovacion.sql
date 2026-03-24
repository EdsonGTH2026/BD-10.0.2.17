SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCaFlujoSeguimientoRenovacion] (@fecini smalldatetime, @fecfin smalldatetime, @codoficinas varchar(1000), @codpromotor varchar(20))
as
set nocount on

declare @codpromotor2 varchar(20)
/*
 --COMENTAR BLOQUE <<<<<<<<<<<<<
	declare @fecini smalldatetime
	declare @fecfin smalldatetime
	declare @codoficinas varchar(1000)
	declare @codpromotor varchar(20)
	
	set @fecini='20180501'
	set @fecfin='20180620'
	--set @codoficina='37,4'
	set @codoficinas = '302'
	set @codpromotor = '98MUE3003881'
--COMENTAR BLOQUE >>>>>>>>>>>>>>
	*/ 
	
	if rtrim(ltrim(@codpromotor)) = '' set @codpromotor = null
	--if rtrim(ltrim(@codoficina)) = '' set @codoficina = null

	select @codpromotor2 = CodUsuario from tCsPadronClientes where CodOrigen = @codpromotor
	if rtrim(ltrim(@codpromotor2)) = '' set @codpromotor2 = @codpromotor
	
	create table #Ptmos(
		Oficina varchar(50),
		codprestamo varchar(25),
		codusuario varchar(15),
		cancelacion smalldatetime,
		monto money,
		codpromotor varchar(15),
		codoficina varchar(4),
		fechanuevodesemb smalldatetime,
		MaxAtraso integer
	)
	
	insert into #Ptmos
	select 
		--(select NomOficina from tcloficinas where CodOficina = p.codoficina) as Oficina,
        o.NomOficina as Oficina,
		p.codprestamo,p.codusuario,p.cancelacion,p.monto,p.ultimoasesor,p.codoficina, max(a.desembolso) fecha,
		(select max(NroDiasAtraso) from tcscartera with(nolock) where codprestamo = p.codprestamo) as MaxAtraso
	from tcspadroncarteradet p with(nolock)
	left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and p.cancelacion<=a.desembolso
	left join tcloficinas as o with(nolock) on o.codoficina = p.codoficina
	where p.cancelacion>=@fecini
	and p.cancelacion<=@fecfin
	--and p.codoficina=@codoficina
	and p.codoficina in (select codigo from dbo.fduTablaValores(@codoficinas))
/*
	and (
	     (p.codoficina in (select codigo from dbo.fduTablaValores(@codoficina)) and len(@codoficina) >0)
		  or
		 (p.codoficina = p.codoficina and len(@codoficina) = 0)
	    )
*/
	--p.primerasesor='CGM891025M5RR3'
	and (p.ultimoasesor = isnull(@codpromotor, p.ultimoasesor) or p.ultimoasesor = isnull(@codpromotor2, p.ultimoasesor) )
	group by p.codprestamo,p.codusuario,p.cancelacion,p.monto,p.ultimoasesor,p.codoficina, o.NomOficina
	
	--select * from #Ptmos
	
	-------------------------------------------------
	select 
	p.codoficina,
	p.Oficina,
	p.cancelacion,
	p.codprestamo,
	cl.nombrecompleto as cliente,
	--0 as 'numero',
	p.MaxAtraso,
	p.monto,
	co.codusuario as CodPromotor,
	co.nombrecompleto as promotor,
	--isnull(n.codprestamo,isnull(x.CodSolicitud, '')) as CodPrestamoNew,
	isnull(n.codprestamo, '') as CodPrestamoNew,
	(case when isnull(n.desembolso,'') <> '19000101' then convert(varchar,isnull(n.desembolso,''), 103)
	 else '' 
	 end) as FecDesembolsoNew, 
	isnull(n.monto,0) as MontoDesembolsoNew,
	cl.codorigen as CodUsuarioCli,
	co.codorigen as CodUsuarioPro
	--,isnull(x.CodEstado, '') as Status
	,'   ' as Status
,isnull(pcs.SecuenciaProductivo, 0) as SecuenciaProductivo
,isnull(pcs.SecuenciaConsumo, 0) as SecuenciaConsumo
	--into #PrestamosTmp
	from #Ptmos p
	left outer join tcspadroncarteradet n with(nolock) on n.codusuario=p.codusuario and n.desembolso=p.fechanuevodesemb
	left outer join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
	left outer join tcspadronclientes co with(nolock) on co.codusuario=p.codpromotor
left join tCsPadronCarteraSecuen pcs with(nolock) on pcs.codprestamo = p.codprestamo

	------------------------------------------------- REGRESA EL RESULTADO
	--select * from #PrestamosTmp
	
	--drop table #PrestamosTmp
	drop table #Ptmos
	
GO