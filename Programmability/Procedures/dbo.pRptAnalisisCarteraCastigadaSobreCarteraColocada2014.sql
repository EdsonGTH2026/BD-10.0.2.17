SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pRptAnalisisCarteraCastigadaSobreCarteraColocada2014] 
as

select x.fecha,x.anio, x.tipo, 
sum(x.SaldoCapital) as Saldo, sum(x.SaldoCastigado) as SaldoCasticado,
((100 /
(select sum(MontoDesembolso) from tcscartera where fecha = x.fecha and year(fechadesembolso) = x.anio)
)* sum(x.SaldoCastigado)) as '% Castigado / Cartera Colocada'
from (
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
	from tcscartera where fecha = '20141231' 
	and cartera in ('CASTIGADA')
	and year(fechaestado) = '2014'
) as x
group by x.fecha, x.anio , x.tipo
order by x.anio
GO