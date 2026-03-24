SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAhorrosResumenxMes] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20151207'

create table #ahtmp(
	fecha smalldatetime,
	sucursal varchar(15),
	Tnrocli int,
	Tnrocta int,
	TSaldoCuenta money,
	spnrocli int,
	spnrocta int,
	spsaldocuenta money,
	cpnrocli int,
	cpnrocta int,
	cpsaldocuenta money,
	cpnrocli1a30 int,
	cpnrocta1a30 int,
	cpsaldocuenta1a30 money,
	cpnrocli30a60 int,
	cpnrocta30a60 int,
	cpsaldocuenta30a60 money,
	cpnrocli60a120 int,
	cpnrocta60a120 int,
	cpsaldocuenta60a120 money,
	cpnrocli120a180 int,
	cpnrocta120a180 int,
	cpsaldocuenta120a180 money,
	cpnroclim180a365 int,
	cpnroctam180a365 int,
	cpsaldocuentam180a365 money,
	cpnroclim365 int,
	cpnroctam365 int,
	cpsaldocuentam365 money
)

declare @periodos table(
	i int identity(1,1),
	fecha smalldatetime
)
insert into @periodos (fecha)
select ultimodia 
from tclperiodo with(nolock)
where ultimodia>='20150101' and  ultimodia<=@fecha
union
select @fecha ultimodia

declare @i int
set @i=1

while(@i<=(select count(fecha) from @periodos))
begin

	select @fecha=fecha from @periodos where i=@i

	insert into #ahtmp
	select a.fecha,case when a.codoficina='98' then 'Of.Central' else 'Sucursales' end sucursal
	,count(distinct(a.codusuario)) Tnrocli
	,count(distinct(a.codcuenta)) Tnrocta
	,sum(a.saldocuenta + a.intacumulado) TSaldoCuenta

	,count(distinct(case when substring(a.codcuenta,5,1)=1 then a.codusuario else null end)) spnrocli
	,count(distinct(case when substring(a.codcuenta,5,1)=1 then a.codcuenta else null end)) spnrocta
	,sum(case when substring(a.codcuenta,5,1)=1 then a.saldocuenta + a.intacumulado else 0 end) spsaldocuenta

	,count(distinct(case when substring(a.codcuenta,5,1)=2 then a.codusuario else null end)) cpnrocli
	,count(distinct(case when substring(a.codcuenta,5,1)=2 then a.codcuenta else null end)) cpnrocta
	,sum(case when substring(a.codcuenta,5,1)=2 then a.saldocuenta + a.intacumulado else 0 end) cpsaldocuenta

	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=1 and a.plazo<=30 then a.codusuario else null end) else null end)) cpnrocli1a30
	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=1 and a.plazo<=30 then a.codcuenta else null end) else null end)) cpnrocta1a30
	,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=1 and a.plazo<=30 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuenta1a30

	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=31 and a.plazo<=60 then a.codusuario else null end) else null end)) cpnrocli30a60
	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=31 and a.plazo<=60 then a.codcuenta else null end) else null end)) cpnrocta30a60
	,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=31 and a.plazo<=60 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuenta30a60

	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=61 and a.plazo<=120 then a.codusuario else null end) else null end)) cpnrocli60a120
	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=61 and a.plazo<=120 then a.codcuenta else null end) else null end)) cpnrocta60a120
	,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=61 and a.plazo<=120 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuenta60a120

	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=121 and a.plazo<=180 then a.codusuario else null end) else null end)) cpnrocli120a180
	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=121 and a.plazo<=180 then a.codcuenta else null end) else null end)) cpnrocta120a180
	,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=121 and a.plazo<=180 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuenta120a180

	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=181 and a.plazo<=365 then a.codusuario else null end) else null end)) cpnroclim180a365
	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=181 and a.plazo<=365 then a.codcuenta else null end) else null end)) cpnroctam180a365
	,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=181 and a.plazo<=365 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuentam180a365

	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=366 then a.codusuario else null end) else null end)) cpnroclim365
	,count(distinct(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=366 then a.codcuenta else null end) else null end)) cpnroctam365
	,sum(case when substring(a.codcuenta,5,1)=2 then (case when a.plazo>=366 then a.saldocuenta + a.intacumulado else 0 end) else 0 end) cpsaldocuentam365

	from tcsahorros a with(nolock)
	inner join tcloficinas o with(nolock) on a.codoficina=o.codoficina
	where a.fecha=@fecha--'20151025'
	group by a.fecha,case when a.codoficina='98' then 'Of.Central' else 'Sucursales' end--replicate('0',2-len(a.codoficina)) + a.codoficina +' '+o.nomoficina

	set @i=@i+1
end

select * from #ahtmp

drop table #ahtmp
GO