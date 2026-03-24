SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACartaPC_DetalleRiesgo] @fecha smalldatetime,@codpromotor varchar(15),@codoficina varchar(4)
as
set nocount on

--COMENTAR
/*
Declare @fecha smalldatetime
declare @codpromotor varchar(15)
declare @codoficina varchar(4)

set @fecha='20180515'
set @codpromotor='CGM891025M5RR3'
set @codoficina='37'
*/

Declare @fecini smalldatetime
Declare @fecini2 smalldatetime
Declare @fecano smalldatetime

declare @ncreBM decimal(8,2)
declare @ncreAM decimal(8,2)

set @fecha = convert(varchar,@fecha,112)
set @fecini = dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'
set @fecano = dbo.fdufechaatexto(dateadd(year,-1,@fecha),'AAAAMM')+'01'

set @fecini2 = dateadd(day,-1,@fecini)

print '###################################################################################################'
print '################################### Detalle Riesgo  ##############################################'
print '###################################################################################################'
--############################################ Detalle creditos afectan calidad de cartera


create table #DetCredMora
(
item int,
Descripcion varchar(25),
Prestamos varchar(1000) default('')
)
--select * from #DetCredMora

insert into #DetCredMora (item, Descripcion, Prestamos ) values (1, '4 a 6 días en mora', '')
insert into #DetCredMora (item, Descripcion, Prestamos ) values (2, '7 a 29 días en mora', '')
insert into #DetCredMora (item, Descripcion, Prestamos ) values (3, '30 a 60 días en mora', '')
insert into #DetCredMora (item, Descripcion, Prestamos ) values (4, '61+ días en mora', '')

--insert into #PtmoCER (item,descripcion) values(1,'Cartera en riesgo')

declare @valores varchar(1000)
set @valores=''

select @valores= c.codprestamo+ ', '+@valores 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha=@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.NroDiasAtraso >=4 and c.NroDiasAtraso <= 6

if len(@valores)>0
begin
	update #DetCredMora
	set Prestamos = substring(@valores,1,len(@valores)-1)
	where item=1
end

set @valores=''

select @valores= c.codprestamo+ ', '+@valores 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha=@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.NroDiasAtraso >=7 and c.NroDiasAtraso <= 29

if len(@valores)>0
begin
	update #DetCredMora
	set Prestamos = substring(@valores,1,len(@valores)-1)
	where item=2
end

set @valores=''

select @valores= c.codprestamo+ ', '+@valores 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha=@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.NroDiasAtraso >=30 and c.NroDiasAtraso <= 60

if len(@valores)>0
begin
	update #DetCredMora
	set Prestamos = substring(@valores,1,len(@valores)-1)
	where item=3
end

set @valores=''

select @valores= c.codprestamo+ ', '+@valores 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha=@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.NroDiasAtraso > 60

if len(@valores)>0
begin
	update #DetCredMora
	set Prestamos = substring(@valores,1,len(@valores)-1)
	where item=4
end


--OSC
delete from tCsRptEMIPC_DetalleRiesgo where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_DetalleRiesgo (Fecha, CodPromotor, CodOficina, Tipo, item, Descripcion, Prestamos )
select @fecha, @codpromotor, @codoficina, 'DETALLECALIDAD', item, Descripcion, Prestamos from #DetCredMora

--select * from #DetCredMora
drop table #DetCredMora

--regresa el resultado
--select * from tCsRptEMIPC_DetalleRiesgo where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina
GO