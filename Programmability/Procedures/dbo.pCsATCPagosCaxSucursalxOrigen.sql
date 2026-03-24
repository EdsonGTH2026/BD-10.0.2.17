SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsATCPagosCaxSucursalxOrigen
CREATE procedure [dbo].[pCsATCPagosCaxSucursalxOrigen] @fecha smalldatetime
as
	declare @fecini smalldatetime
	declare @fecfin smalldatetime

	select @fecini=primerdia from tclperiodo where primerdia<=@fecha and ultimodia>=@fecha
	set @fecfin=@fecha

	exec [10.0.2.14].finmas.dbo.pCsTCPagosCaxSucursalxOrigen @fecini,@fecfin

	truncate table tCsRptTCPagosxSucursalxOrigen
	insert into tCsRptTCPagosxSucursalxOrigen
	select *
	from [10.0.2.14].finmas.dbo.tCsRptTCPagosxSucursalxOrigen

	truncate table tCsRptTCPagosxSucursal
	insert into tCsRptTCPagosxSucursal
	select @fecha,sucursal
	,sum(case when day(fecha)=1 then monto else 0 end) d1
	,sum(case when day(fecha)=2 then monto else 0 end) d2
	,sum(case when day(fecha)=3 then monto else 0 end) d3
	,sum(case when day(fecha)=4 then monto else 0 end) d4
	,sum(case when day(fecha)=5 then monto else 0 end) d5
	,sum(case when day(fecha)=6 then monto else 0 end) d6
	,sum(case when day(fecha)=7 then monto else 0 end) d7
	,sum(case when day(fecha)=8 then monto else 0 end) d8
	,sum(case when day(fecha)=9 then monto else 0 end) d9
	,sum(case when day(fecha)=10 then monto else 0 end) d10
	,sum(case when day(fecha)=11 then monto else 0 end) d11
	,sum(case when day(fecha)=12 then monto else 0 end) d12
	,sum(case when day(fecha)=13 then monto else 0 end) d13
	,sum(case when day(fecha)=14 then monto else 0 end) d14
	,sum(case when day(fecha)=15 then monto else 0 end) d15
	,sum(case when day(fecha)=16 then monto else 0 end) d16
	,sum(case when day(fecha)=17 then monto else 0 end) d17
	,sum(case when day(fecha)=18 then monto else 0 end) d18
	,sum(case when day(fecha)=19 then monto else 0 end) d19
	,sum(case when day(fecha)=20 then monto else 0 end) d20
	,sum(case when day(fecha)=21 then monto else 0 end) d21
	,sum(case when day(fecha)=22 then monto else 0 end) d22
	,sum(case when day(fecha)=23 then monto else 0 end) d23
	,sum(case when day(fecha)=24 then monto else 0 end) d24
	,sum(case when day(fecha)=25 then monto else 0 end) d25
	,sum(case when day(fecha)=26 then monto else 0 end) d26
	,sum(case when day(fecha)=27 then monto else 0 end) d27
	,sum(case when day(fecha)=28 then monto else 0 end) d28
	,sum(case when day(fecha)=29 then monto else 0 end) d29
	,sum(case when day(fecha)=30 then monto else 0 end) d30
	,sum(case when day(fecha)=31 then monto else 0 end) d31
	from tCsRptTCPagosxSucursalxOrigen
	group by sucursal
GO