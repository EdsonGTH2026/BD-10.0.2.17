SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptTasaPonderadaAHTotal] @fecha smalldatetime
as 
--declare @fecha smalldatetime
--set @fecha='20140930'

create table #sumxprod(
  montototal     money
) 
insert into #sumxprod
select sum(monto) monto from(
SELECT c.saldocuenta monto
FROM tCsahorros c with(nolock) 
where c.fecha=@fecha
) a

--select * from #sumxprod

select sum(b.div) TasaTotalPonderada 
from (
  select a.txm/mxp.montototal div 
  from (
    SELECT c.tasainteres*c.saldocuenta txm
    FROM tCsahorros c with(nolock) 
    where c.fecha=@fecha
  ) a cross join #sumxprod mxp
) b

drop table #sumxprod
GO