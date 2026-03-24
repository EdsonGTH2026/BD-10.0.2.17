SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsRptDBTuberiaxsucursales] @periodo varchar(6), @codoficina varchar(200) AS

--declare @codoficina varchar(200)
--set @codoficina='2,3,4,5,6'

--declare @periodo varchar(6)
--set @periodo='201307'

declare @primerdiaant smalldatetime
declare @ultimodiaant smalldatetime
declare @primerdia smalldatetime
declare @ultimodia smalldatetime

select @primerdia=primerdia,@ultimodia=ultimodia from tclperiodo with(nolock) where periodo=@periodo
select @primerdiaant=primerdia,@ultimodiaant=ultimodia from tclperiodo with(nolock) where periodo=dbo.fduFechaAPeriodo(dateadd(month,-1,@ultimodia)) 

--1--domingo
--2--lunes
--3--martes
--4--miercoles
--5--jueves
--6--viernes
--7--sabado

create table #se(
  nrosemana int,
  fechaini smalldatetime,
  fechafin smalldatetime
)
declare @n int
set @n=4

insert into #se
values(datepart(week,@primerdia),@primerdia,dateadd(day,7 - datepart(dw, @primerdia) + 1,@primerdia))
--select datepart(week,'20130701')
--select datepart(dw, '20130701')
declare @pdtmp smalldatetime
set @pdtmp=@primerdia

while @n>0
 begin
  set @pdtmp=dateadd(day,7 - datepart(dw, @pdtmp) + 2,@pdtmp)
  insert into #se
  values(datepart(week,@pdtmp),@pdtmp,dateadd(day,7 - datepart(dw, @pdtmp) + 1,@pdtmp))
  --print @n 
  if(@n=1)
    begin
      update #se
      set fechafin=(select ultimodia from tclperiodo with(nolock) where periodo=dbo.fduFechaAPeriodo(@pdtmp))
      where fechaini=@pdtmp
    end
  set @n=@n-1
 end
--select * from #se

create table #cca(
  nrosemana int,
  periodo varchar(6),
  codoficina varchar(4),
  nro int,
  monto decimal(16,2)
)

insert into #cca
select -1 nrosemana, cast(year(@primerdiaant) as varchar(4))+'01' periodo,codoficina, count(codprestamo) nro, sum(monto) monto
from tcspadroncarteradet with(nolock)
where desembolso>=(select primerdia from tclperiodo with(nolock) where periodo=(cast(year(@primerdiaant) as varchar(4))+'01')) 
and desembolso<=@ultimodia--dateadd(day,-1,@primerdiaant)
and codoficina in (select codigo from dbo.fduTablaValores(@codoficina))
group by dbo.fduFechaAPeriodo(desembolso), codoficina

insert into #cca
select 0 nrosemana, dbo.fduFechaAPeriodo(desembolso) periodo,codoficina, count(codprestamo) nro, sum(monto) monto
from tcspadroncarteradet with(nolock)
where desembolso>=@primerdiaant and desembolso<=@ultimodiaant
and codoficina in (select codigo from dbo.fduTablaValores(@codoficina))
group by dbo.fduFechaAPeriodo(desembolso), codoficina

insert into #cca
select 100 nrosemana, dbo.fduFechaAPeriodo(desembolso) periodo,codoficina, count(codprestamo) nro, sum(monto) monto
from tcspadroncarteradet with(nolock)
where desembolso>=@primerdia and desembolso<=@ultimodia
and codoficina in (select codigo from dbo.fduTablaValores(@codoficina))
group by dbo.fduFechaAPeriodo(desembolso), codoficina

declare @ns int
declare @fi smalldatetime
declare @ff smalldatetime

DECLARE genxf CURSOR FOR 
  SELECT * FROM #se
OPEN genxf
FETCH NEXT FROM genxf 
INTO @ns,@fi,@ff

WHILE @@FETCH_STATUS = 0
BEGIN

  insert into #cca
  select @ns nrosemana, dbo.fduFechaAPeriodo(desembolso) periodo,codoficina, count(codprestamo) nro, sum(monto) monto
  from tcspadroncarteradet with(nolock)
  where desembolso>=@fi and desembolso<=@ff
  and codoficina in (select codigo from dbo.fduTablaValores(@codoficina))
  group by dbo.fduFechaAPeriodo(desembolso), codoficina

	FETCH NEXT FROM genxf 
  INTO @ns,@fi,@ff
END

CLOSE genxf
DEALLOCATE genxf
 
select c.nrosemana, c.periodo, c.codoficina, c.nro, c.monto, replicate('0',2-len(cast(c.codoficina as int))) + rtrim(c.codoficina) +' '+ o.nomoficina sucursal
,case when c.nrosemana>0  then 'MES ACTUAL' 
--when c.nrosemana=100 then 'TOTAL MES' 
when c.nrosemana=0 then 'ANTERIOR' ELSE '' END encprin
from #cca c
inner join tcloficinas o with(nolock) 
on c.codoficina=o.codoficina
 
drop table #se
drop table #cca
GO