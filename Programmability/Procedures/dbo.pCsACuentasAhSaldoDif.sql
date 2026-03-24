SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACuentasAhSaldoDif] @fecha smalldatetime, @codoficina varchar(5)
as
BEGIN	

	--declare @fecha smalldatetime 
	--set @fecha = '20190701'
	
	--limpia la tabla
	delete from tCsACuentasAhSaldoDif
	
	--llena la tabla
	insert into tCsACuentasAhSaldoDif

	select 
	@fecha,
	c.CodCuenta, c.FraccionCta, c.Renovado, c.idProducto, c.CodOficina,
	c.SaldoCuenta, c.MontoDPF,
	ip.Monto
	from [10.0.2.14].finmas.dbo.tahcuenta as c
	inner join [10.0.2.14].finmas.dbo.tahintperiodicos as ip on ip.CodCuenta = c.CodCuenta and ip.Renovado = c.Renovado 
	where
	c.idProducto like '2%' and c.idEstadoCta = 'CA' 
	and c.idProducto not in ('209')
	and ip.TipoPago = 'CAP'
	and c.SaldoCuenta <> ip.Monto


	--Regresa la información
	select 
	convert(varchar,Fecha,103) as Fecha, 
    CodCuenta, FraccionCta, Renovado, idProducto, CodOficina, SaldoCuenta, MontoDPF, Monto           
	from tCsACuentasAhSaldoDif
	order by Fecha
    
END
GO