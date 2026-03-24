SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRptTasaPonderadaCATotal] @fecha smalldatetime
as 
--declare @fecha smalldatetime
--set @fecha='20141031'

create table #sumxprod(
  --codproducto varchar(5),
  montototal     money
) 
insert into #sumxprod
select --codproducto,
sum(monto) monto from(
SELECT --isnull(op.codproducto,c.codproducto) codproducto,
c.Montodesembolso monto
FROM tCsCartera c with(nolock) 
--left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
where c.fecha=@fecha and c.codoficina<'97'
and c.cartera='ACTIVA') a
--group by codproducto

--select * from #sumxprod

select --p.NombreProdCorto,
sum(b.div) div 
from (
  select --a.codproducto,
  a.txm/mxp.montototal div 
  from (
    SELECT  --isnull(op.codproducto,c.codproducto) codproducto,
      c.tasaintcorriente*c.Montodesembolso txm
    FROM tCsCartera c with(nolock) 
    --left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
    where c.fecha=@fecha and c.codoficina<'97'
    and c.cartera='ACTIVA'
  ) a --inner join #sumxprod mxp on mxp.codproducto=a.codproducto
  cross join #sumxprod mxp
) b
--inner join tcaproducto p with(nolock) on p.codproducto=b.codproducto
--group by p.NombreProdCorto
--order by p.NombreProdCorto

drop table #sumxprod
GO