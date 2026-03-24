SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaCSCATabla '339-170-06-07-01977'
CREATE procedure [dbo].[pXaCSCATabla] @codprestamo varchar(25)
as
--#
--fecha
--amortizacion
--capital
--interes
--iva
--saldo capital
select seccuota,dbo.fdufechaatexto(fechavencimiento,'DD-MM-')+cast(year(fechavencimiento) as char(4)) fecha,capital+interes+iva amortiza
,capital,interes,iva,cast(0 as money) saldo
into #pl
from (
	select seccuota,fechavencimiento
	,sum(case when codconcepto='CAPI' then montocuota else 0 end) capital
	,sum(case when codconcepto='INTE' then montocuota else 0 end) interes
	,sum(case when codconcepto='IVAIT' then montocuota else 0 end) iva
	from tcspadronplancuotas with(nolock)
	where codprestamo='339-170-06-07-01977' --@codprestamo--
	and codconcepto in('CAPI','INTE','IVAIT')
	group by seccuota,fechavencimiento
) a
order by seccuota

insert into #pl
select 0,dbo.fdufechaatexto(desembolso,'DD-MM-')+cast(year(desembolso) as char(4)),0,0,0,0,monto
from tcspadroncarteradet with(nolock)
where codprestamo='339-170-06-07-01977' --@codprestamo--

update #pl
set saldo=a.ca
from (
	select p.seccuota,isnull(sum(a.capital),0) ca
	from #pl p
	left outer join #pl a on a.seccuota>p.seccuota
	where p.seccuota<>0
	group by p.seccuota
) a inner join  #pl p on p.seccuota=a.seccuota

select * from #pl

drop table #pl
GO