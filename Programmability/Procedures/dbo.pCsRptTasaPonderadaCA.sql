SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRptTasaPonderadaCA] @fecha smalldatetime
as 
--declare @fecha smalldatetime
--set @fecha='20150430'

create table #sumxprod(
  codproducto varchar(5),
  montototal     money
) 
insert into #sumxprod
select codproducto,sum(monto) monto from(
SELECT isnull(op.codproducto,c.codproducto) codproducto,c.Montodesembolso monto
FROM tCsCartera c with(nolock) 
left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
where c.fecha=@fecha and c.codoficina<'97'
and c.cartera='ACTIVA') a
group by codproducto

--select * from #sumxprod

--select p.NombreProd NombreProdCorto,sum(b.div) div 
select case when b.codproducto in('163','302') then 'Convenio amigo' when b.codproducto in('164','156') then 'Grupo Amigo / Solidario' else p.Nombreprod end NombreProdCorto
,sum(b.div) div 
from (
  select a.codproducto,a.txm/mxp.montototal div 
  from (
    SELECT  isnull(op.codproducto,c.codproducto) codproducto,c.tasaintcorriente*c.Montodesembolso txm
    FROM tCsCartera c with(nolock) 
    left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
    where c.fecha=@fecha and c.codoficina<'97'
    and c.cartera='ACTIVA'
  ) a inner join #sumxprod mxp on mxp.codproducto=a.codproducto
) b
inner join tcaproducto p with(nolock) on p.codproducto=b.codproducto
group by case when b.codproducto in('163','302') then 'Convenio amigo' when b.codproducto in('164','156') then 'Grupo Amigo / Solidario' else p.Nombreprod end
order by case when b.codproducto in('163','302') then 'Convenio amigo' when b.codproducto in('164','156') then 'Grupo Amigo / Solidario' else p.Nombreprod end

drop table #sumxprod
GO