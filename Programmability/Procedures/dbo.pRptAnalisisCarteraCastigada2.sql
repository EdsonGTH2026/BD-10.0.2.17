SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pRptAnalisisCarteraCastigada2] 
@FechaInicial smalldatetime,
@FechaFinal smalldatetime
as

select 
sum(c.SaldoCapital) as SaldoCapital, 
sum(c.CapitalVigente) as CapitalVigente, 
sum(c.CapitalVencido) as CapitalVencido, 
--sum(c.CapitalMonetizado) as CapitalMonetizado, 
sum(c.SaldoInteresCorriente) as SaldoInteresCorriente, 
--sum(c.SaldoINVE) as SaldoINVE, 
sum(c.SaldoINPE) as SaldoINPE, 
sum(c.SaldoEnMora) as SaldoEnMora, 
sum(c.CargoMora) as CargoMora, 
sum(c.OtrosCargos) as OtrosCargos, 
sum(c.Impuestos) as Impuestos,
c.cartera,
(case
 when c.codproducto = '164' then 'COMUNAL'
 when c.codproducto = '156' then 'SOLIDARIO'
 else 'INDIVIDUAL'
 end ) as Tipo,
year(fechacastigo) as anio
from tcscartera as c with(nolock)
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
where c.fecha = convert(varchar, dateadd(d,-1,getdate()), 112) 
and c.cartera='CASTIGADA' 
and c.fechacastigo >= @FechaInicial
and c.fechacastigo <= @FechaFinal
--and convert(varchar, c.fechacastigo,111) >= '2012/01/01' 
--and convert(varchar, c.fechacastigo,111) <= '2014/12/31'
group by 
year(fechacastigo), 
c.cartera,
(case
when c.codproducto = '164' then 'COMUNAL'
when c.codproducto = '156' then 'SOLIDARIO'
else 'INDIVIDUAL'
end )



GO