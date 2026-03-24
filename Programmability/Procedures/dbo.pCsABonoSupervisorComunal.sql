SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE procedure [dbo].[pCsABonoSupervisorComunal] @fecha SMALLDATETIME
as
--declare @fecha SMALLDATETIME
--set @fecha='20140630'
declare @fecactual smalldatetime
declare @fecanterior smalldatetime
set @fecactual=@fecha--'20140630'

select @fecanterior=ultimodia from tclperiodo where primerdia<=dateadd(month,-1,@fecha) and ultimodia>=dateadd(month,-1,@fecha)
--set @fecanterior='20140531'

create table #tmp(
  codoficina varchar(4),
  nomoficina varchar(100),
  nroactual int,
  nroanterior int,
  nrocrecimiento as nroactual-nroanterior,
  saldoactual decimal(16,2),
  saldoanterior decimal(16,2),
  saldom0actual decimal(16,2),
  saldom0anterior decimal(16,2),
  saldopico decimal(16,2) default(0),
  saldocrecimiento as case when saldoanterior>=saldopico then (case when saldoactual-saldoanterior<0 then 0 else saldoactual-saldoanterior end) 
                                                         else (case when saldoactual-saldopico<0 then 0 else saldoactual-saldopico end) end,
  saldoPorcrecimiento decimal(8,2),
  moraactual as cast((case when saldoactual=0 then 0 else saldom0actual/saldoactual end) as decimal(8,4))*100,
  moraanterior as cast((case when saldoanterior=0 then 0 else saldom0anterior/saldoanterior end) as decimal(8,4))*100
)

insert into #tmp (codoficina,nomoficina,nroactual,nroanterior,saldoactual,saldoanterior,saldom0actual,saldom0anterior)
SELECT ca.codoficina,o.nomoficina
,count(distinct(case when ca.fecha=@fecactual then cd.codusuario else null end)) nroactual
,count(distinct(case when ca.fecha=@fecanterior then cd.codusuario else null end)) nroanterior
,sum(case when ca.fecha=@fecactual then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) saldoactual
,sum(case when ca.fecha=@fecanterior then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) saldoanterior
,sum(case when ca.fecha=@fecactual then 
    case when ca.nrodiasatraso>0 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end
    else 0 end) saldom0actual
,sum(case when ca.fecha=@fecanterior then 
    case when ca.nrodiasatraso>0 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end
    else 0 end) saldom0anterior
FROM tCsCartera ca inner join tcscarteradet cd on cd.fecha=ca.fecha and cd.codprestamo=ca.codprestamo
inner join tcloficinas o on o.codoficina=ca.codoficina
where ca.fecha in (@fecactual,@fecanterior)
and ca.codproducto='164'
group by ca.codoficina,o.nomoficina

update #tmp
set saldopico=f.saldo
from #tmp t 
inner join (
  select codoficina,max(saldo) saldo
  from (
    SELECT ca.codoficina,ca.fecha
    ,sum(cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldo
    FROM tCsCartera ca inner join tcscarteradet cd on cd.fecha=ca.fecha and cd.codprestamo=ca.codprestamo
    where ca.fecha in (
      select ultimodia from tclperiodo where periodo>='201403' and periodo<dbo.fdufechaaperiodo(@fecactual)
    )
    and ca.codproducto='164'
    group by ca.codoficina,ca.fecha
  ) a
  group by codoficina
) f
on t.codoficina=f.codoficina

update #tmp
set saldoPorcrecimiento=case when saldoactual>=1000000 then
                        (case when saldoanterior>=saldopico then 
                        (case when saldoanterior=0 then 0 else saldocrecimiento/saldoanterior end)
                        else 
                        (case when saldopico=0 then 0 else saldocrecimiento/saldopico end)
                        end)*100
                        else 0 end

IF  EXISTS (SELECT * FROM tCsRptBonoSupervidorComunal) --dbo.sysobjects WHERE id = OBJECT_ID(N'[tCsRptBonoCartera]'))-- AND type = 'D')          
BEGIN
    DROP TABLE tCsRptBonoSupervidorComunal
END

select c.*,isnull(f1.varbono,0) BonoCreClientes,f2.varbono BonoCreCartera,f3.varbono FactorDeduMora
into tCsRptBonoSupervidorComunal
from #tmp c
LEFT OUTER JOIN tCsCaFactoresCalcBono f1 ON c.nrocrecimiento between f1.MtoMin and f1.MtoMax and f1.tipo = 18
LEFT OUTER JOIN tCsCaFactoresCalcBono f2 ON c.saldoporcrecimiento between f2.MtoMin and f2.MtoMax and f2.tipo = 19
LEFT OUTER JOIN tCsCaFactoresCalcBono f3 ON c.moraactual between f3.MtoMin and f3.MtoMax and f3.tipo = 20

drop table #tmp
GO