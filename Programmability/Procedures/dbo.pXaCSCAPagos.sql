SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaCSCAPagos '332-170-06-06-00892'
CREATE procedure [dbo].[pXaCSCAPagos] @codprestamo varchar(25)
as

--#
--f.pago
--importe total
--capital
--interes
--iva
--comisionmora
--seguro
--origen
create table #t(
	item int identity(1,1),
	fecha varchar(10),
	total money,
	capital money,
	interes money,
	iva money,
	comision money,
	seguro money,
	origen varchar(20)
)

insert into #t (fecha,total,capital,interes,iva,comision,seguro,origen)
select dbo.fdufechaatexto(t.fecha,'DD-MM-')+cast(year(t.fecha) as char(4)) fecha,t.montototaltran total,t.montocapitaltran capital,t.montointerestran interes,t.montoimpuestos iva,t.montocargos comision,t.montootrostran seguro
,isnull(o.descripcion,'Sucursal') origen
from tcstransacciondiaria t with(nolock)
left outer join tcaclorigenpagos o with(nolock) on o.codorigenpago=t.coddestino
where t.codigocuenta=@codprestamo--'339-170-06-07-01977' 
and t.tipotransacnivel1='I'  --and tipotransacnivel1 in(103,105)
--order by t.fecha desc

select * from #t
order by item desc


drop table #t

GO