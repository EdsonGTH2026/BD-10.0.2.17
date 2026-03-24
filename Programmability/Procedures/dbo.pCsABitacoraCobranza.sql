SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsABitacoraCobranza] @fecha smalldatetime, @codoficina varchar(5)
as
BEGIN	

	--declare @fecha smalldatetime 
	--set @fecha = '20170810'
	
	--limpia la tabla
	delete from tCsABitacoraCobranza
	
	--llena la tabla
	insert into tCsABitacoraCobranza
	select 
	p.Codprestamo,
	(select top 1 NroDiasAtraso from dbo.tCsCartera where Codprestamo = p.Codprestamo order by Fecha desc) as DiasAtraso,
	--p.CodUsuario,
	u.nombrecompleto as Cliente,
	b.Item,
	--b.Fecha,
	b.Hora,
	d.descripcion as Dictamen,
	(case b.Tipo
	 when 1 then 'Llamada'
	 when 2 then 'Visita'
	 when 3 then 'No aplica'
	 else ''
	 end ) as Tipo,
	--b.CodUsuarioReg, 
	us.nombrecompleto as Usuario,
	--b.Observacion,
replace(REPLACE(b.Observacion, Char(10), ' '), Char(13), ' '),
	isnull(b.Nombrecompleto,'') as Atencion,
	r.descripcion as Parentesco,
	'No' as Documento,

	p.CodOficina,
	o.NomOficina as Oficina,
	p.CodProducto,
	c.SaldoCapital,
	c.SaldoVencido,
	c.SaldoTotal
	--, c.fecha

	from [10.0.2.14].Finmas.dbo.tCaBitCob as b
	inner join [10.0.2.14].Finmas.dbo.tcaprestamos as p on p.CodPrestamo = b.CodPrestamo
	inner join [10.0.2.14].Finmas.dbo.tususuarios as u on u.CodUsuario = p.CodUsuario
	inner join [10.0.2.14].Finmas.dbo.tsgusuarios as us on us.codusuario = b.CodUsuarioReg
	inner join [10.0.2.14].Finmas.dbo.tCaBitDictamen as d on d.coddictamen = b.Dictamen
	inner join [10.0.2.14].Finmas.dbo.tCaBitRelacion as r on r.CodRelacion = b.CodRelacion
	inner join tcloficinas as o on o.CodOficina = p.CodOficina
	left join (
		select a.CodPrestamo, a.Fecha, a.SaldoCapital,a.SaldoEnMora as SaldoVencido,(a.SaldoCapital + a.SaldoInteresCorriente + a.SaldoEnMora) as SaldoTotal
		from dbo.tCsCartera as a 
		inner join [10.0.2.14].Finmas.dbo.tCaBitCob as b on a.CodPrestamo =  b.CodPrestamo
		where a.fecha = (select max(b.fecha) from tCsCartera as b where b.codprestamo = a.codprestamo )
	) as c on c.codprestamo = p.Codprestamo --and convert(varchar,c.fecha,112) = convert(varchar,hora,112)
	where 
	--convert(varchar,DATEPART(yyyy,b.Fecha)) + convert(varchar,DATEPART(mm,b.Fecha)) = '20178'
	convert(varchar,YEAR(b.Fecha)) + convert(varchar,MONTH( b.Fecha)) = convert(varchar,YEAR(@fecha)) + convert(varchar,MONTH( @fecha))
	--order by p.Codprestamo, b.Hora

	--Regresa la información
	select * from tCsABitacoraCobranza
	         
END
  
GO