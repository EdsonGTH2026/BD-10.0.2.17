SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pRptAnalisisCarteraCastigadaSobreSaldoInsoluto] 
as

select x.fecha,x.anio, x.tipo, 
sum(x.SaldoCapital) as Saldo, sum(x.SaldoCastigado) as SaldoCasticado, 
--((100 / sum(x.SaldoCapital)) * sum(x.SaldoCastigado)) as '% Castigado / Saldo Insoluto'
((100 /
(select sum(c.SaldoCapital) from tcscartera as c where year(c.fechaestado) = x.anio and c.fecha = x.fecha and c.cartera in ('ACTIVA','CASTIGADA')) 
)* sum(x.SaldoCastigado)) as '% Castigado / Saldo Insoluto'
from
(
	select 
	fecha,
	year(fechaestado ) as anio,
	cartera,
	(  case
	   when codproducto = '164' then 'COMUNAL'
	   when codproducto = '156' then 'SOLIDARIO'
	   else 'INDIVIDUAL'
	   end ) as Tipo,
	SaldoCapital,
	(case 
	when cartera = 'castigada' then SaldoCapital
	else 0
	end 
	) as SaldoCastigado
	from tcscartera where fecha = '20121231'
	and cartera in ('ACTIVA','CASTIGADA')
	and year(fechaestado) = '2012'
 union all
	select 
	fecha,
	year(fechaestado ) as anio,
	cartera,
	(  case
	   when codproducto = '164' then 'COMUNAL'
	   when codproducto = '156' then 'SOLIDARIO'
	   else 'INDIVIDUAL'
	   end ) as Tipo,
	SaldoCapital,
	(case 
	when cartera = 'castigada' then SaldoCapital
	else 0
	end 
	) as SaldoCastigado
	from tcscartera where fecha = '20131231' --and year(fechaestado ) = '2013'
	and cartera in ('ACTIVA','CASTIGADA')
	and year(fechaestado) = '2013'
union all
	select 
	fecha,
	year(fechaestado ) as anio,
	cartera,
	(  case
	   when codproducto = '164' then 'COMUNAL'
	   when codproducto = '156' then 'SOLIDARIO'
	   else 'INDIVIDUAL'
	   end ) as Tipo,
	SaldoCapital,
	(case 
	when cartera = 'castigada' then SaldoCapital
	else 0
	end 
	) as SaldoCastigado
	from tcscartera where fecha = '20141231' --and year(fechaestado ) = '2014'
	and cartera in ('ACTIVA','CASTIGADA')
	and year(fechaestado) = '2014'

) as x
where 
x.anio in ('2012','2013','2014')
--x.anio = '2012'
group by x.fecha, x.anio , x.tipo
order by x.anio


GO