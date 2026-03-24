SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pRptAnalisisCarteraCastigada1] 
@FechaInicial smalldatetime,
@FechaFinal smalldatetime
as

select 
c.fecha,
o.nomoficina, c.codproducto, c.codprestamo,
c.nrodiasatraso,
c.SaldoCapital, c.CapitalVigente, c.CapitalVencido, c.CapitalMonetizado, c.SaldoInteresCorriente, c.SaldoINVE, c.SaldoINPE, c.SaldoEnMora, c.CargoMora, c.OtrosCargos, c.Impuestos,
c.fechacastigo,
c.fechadesembolso,
c.fechaultimomovimiento ,
c.fechacastigo,
c.cartera,
(case
when c.codproducto = '164' then 'COMUNAL'
when c.codproducto = '156' then 'SOLIDARIO'
else 'INDIVIDUAL'
end ) as Tipo,
year(fechacastigo) as anio
from tcscartera as c with(nolock)
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
where c.fecha = convert(varchar, dateadd(d,-1,getdate()), 112) --'20150520'  
and c.cartera='CASTIGADA' 
and c.fechacastigo >= @FechaInicial
and c.fechacastigo <= @FechaFinal
GO