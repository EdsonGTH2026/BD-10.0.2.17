SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsCaProgramadoCapitalxPromotor] @fecha smalldatetime,@codoficina varchar(2000),@codasesor varchar(20)
as
--declare @fecha smalldatetime
--set @fecha='20210927'
--declare @codasesor varchar(20)
--set @codasesor='DMD941016M6JD11'
--declare @codoficina varchar(2000)
--set @codoficina='341'

declare @codusuario varchar(20)
select @codusuario=codusuario from tcspadronclientes with(nolock)
where codorigen=@codasesor--'DMD941016M6JD11'--

set nocount on

declare @oficinas table(codoficina varchar(4))
insert into @oficinas
select codigo
from dbo.fdutablavalores(@codoficina)

select c.codprestamo
into #ptmos
from tcscartera c with(nolock)
where c.fecha=@fecha-1
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and c.codoficina in(
					select codoficina from @oficinas
				)
and c.codoficina not in('97','230','231','999')				
and c.cartera='ACTIVA' 
and c.codasesor=@codusuario--@codasesor


select p.codprestamo,sum(p.montodevengado-p.montopagado-p.montocondonado) montodevengado
from tcspadronplancuotas p with(nolock)
inner join #ptmos c on c.codprestamo=p.codprestamo
where p.numeroplan=0 and p.seccuota>0 and p.codprestamo in(select codprestamo from #ptmos)
and p.fechavencimiento=@fecha and p.codconcepto='CAPI'
group by p.codprestamo

drop table #ptmos

GO