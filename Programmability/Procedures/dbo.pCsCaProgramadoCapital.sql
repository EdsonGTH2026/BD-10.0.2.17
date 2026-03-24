SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsCaProgramadoCapital] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20210405'

select c.codprestamo
into #ptmos
from tcscartera c with(nolock)
where c.fecha=@fecha-1
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and c.codoficina not in('97','230','231','999')
and c.cartera='ACTIVA' 



select p.codprestamo,sum(p.montodevengado-p.montopagado-p.montocondonado) montodevengado
from tcspadronplancuotas p with(nolock)
inner join #ptmos c on c.codprestamo=p.codprestamo
where p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos)
and p.fechavencimiento=@fecha and p.codconcepto='CAPI'
group by p.codprestamo

GO