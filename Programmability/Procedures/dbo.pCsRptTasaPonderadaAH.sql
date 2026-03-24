SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptTasaPonderadaAH] @fecha smalldatetime
as 
--declare @fecha smalldatetime
--set @fecha='20140930'

create table #sumxprod(
  codproducto varchar(5),
  montototal     money
) 
insert into #sumxprod
select codproducto,sum(monto) monto from(
SELECT c.codproducto,c.saldocuenta monto
FROM tCsahorros c with(nolock) 
where c.fecha=@fecha
--and c.cartera='ACTIVA'
) a
group by codproducto

--select * from #sumxprod

select p.Nombre,sum(b.div) div 
from (
  select a.codproducto,a.txm/mxp.montototal div 
  from (
    SELECT c.codproducto,c.tasainteres*c.saldocuenta txm
    FROM tCsahorros c with(nolock) 
    where c.fecha=@fecha
    --and c.cartera='ACTIVA'
  ) a inner join #sumxprod mxp on mxp.codproducto=a.codproducto
) b
inner join tAhProductos p with(nolock) on p.idproducto=b.codproducto
group by p.Nombre
order by p.Nombre

drop table #sumxprod
GO