SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAAlertasCajaEfectivoParametro] @fecha smalldatetime, @codoficina varchar(5)
as
BEGIN	

	--declare @fecha smalldatetime 
	--set @fecha = '20171013'
	
	--limpia la tabla
	delete from tCsAAlertasCajasEfectivoParametro
	
	--llena la tabla
	insert into tCsAAlertasCajasEfectivoParametro

	select 
	--convert(varchar,al.FechaHora,103) as Fecha,
	al.FechaHora as Fecha,
	o.NomOficina,
	u.nombrecompleto as Cajero,
	al.SaldoCaja,
	--convert(varchar,al.FechaHora,108) as Hora
	al.FechaHora as hora
	from [10.0.2.14].finmas.dbo.tTcCajasEfectivoLog as al
	inner join [10.0.2.14].finmas.dbo.tsgusuarios as u on u.codusuario = al.CodCajero
	inner join [10.0.2.14].finmas.dbo.tcloficinas as o on o.CodOficina = al.CodOficina 
	where 
	convert(varchar,al.FechaHora,112) >= convert(varchar,@fecha,112) 
	and convert(varchar,al.FechaHora,112) <= convert(varchar,@fecha,112) 
	--order by al.FechaHora
	
--	convert(varchar,YEAR(b.Fecha)) + convert(varchar,MONTH( b.Fecha)) = convert(varchar,YEAR(@fecha)) + convert(varchar,MONTH( @fecha))
	--order by p.Codprestamo, b.Hora

	--Regresa la información
	select 
	convert(varchar,Fecha,103) as Fecha, NomOficina, Cajero, SaldoCaja, convert(varchar,Hora,108) as Hora 
	from tCsAAlertasCajasEfectivoParametro
	order by Fecha
    
END

GO