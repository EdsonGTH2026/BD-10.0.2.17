SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vCsResumenConsolidacion]
with encryption
AS
	select top 1000 * from (
	select 'Cartera' Tabla, convert(varchar(10), Fecha, 111) Fecha, CodOficina, count(1) Cantidad from tCsCartera
	where datediff(d, Fecha, getdate()) between -100 and 100
	group by Fecha, CodOficina 
	--order by Fecha desc, CodOficina
	union all
	select 'Ahorros' Tabla, convert(varchar(10), Fecha, 111) Fecha, CodOficina, count(1)  Cantidad from tCsAhorros
	where datediff(d, Fecha, getdate()) between -100 and 100
	group by Fecha, CodOficina 
	--order by Fecha desc, CodOficina
	union all
	select 'Transacciones' Tabla, convert(varchar(10), Fecha, 111) Fecha, CodOficina, count(1) from tCsTransaccionDiaria
	where datediff(d, Fecha, getdate()) between -100 and 100
	group by Fecha, CodOficina 
	--order by Fecha desc, CodOficina
	union all
	select 'Giros' Tabla, convert(varchar(10), Fecha, 111) Fecha, CodOficina, count(1) from tCsGiros
	where datediff(d, Fecha, getdate()) between -100 and 100
	group by Fecha, CodOficina 
	--order by Fecha desc, CodOficina
-- 	union all
-- 	select 'Solicitudes' Tabla, convert(varchar(10), Fecha, 111) Fecha, CodOficina, count(1) from tCsSolicitudes
-- 	where datediff(d, Fecha, getdate()) between 0 and 100
-- 	group by Fecha, CodOficina
-- 	order by Fecha desc, CodOficina
	union all
	select 'InterAgencias' Tabla, convert(varchar(10), Fecha, 111) Fecha, CodOficina, count(1) from tCsInteragencias
	where datediff(d, Fecha, getdate()) between -100 and 100
	group by Fecha, CodOficina
	--order by Fecha desc, CodOficina
	union all
	select 'Cheques' Tabla, convert(varchar(10), Fecha, 111) Fecha, CodOficina, count(1) from tCsCheques
	where datediff(d, Fecha, getdate()) between -100 and 100
	group by Fecha, CodOficina
	--order by Fecha desc, CodOficina
) a order by  Tabla ,Fecha desc,CodOficina
GO