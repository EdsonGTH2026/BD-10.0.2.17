SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsExMetasAsesor
CREATE procedure [dbo].[pCsExMetasAsesor] @fecha smalldatetime, @codasesor varchar(15)
as
--declare @fecha varchar(8)
--declare @codasesor varchar(15)
--set @fecha='20140501'
--set @codasesor='FTA2812731'

declare @fecfin smalldatetime
declare @fecprimerdia smalldatetime
select @fecfin=ultimodia, @fecprimerdia=primerdia from tclperiodo where primerdia<=@fecha and ultimodia>=@fecha

declare @fecini smalldatetime
set @fecini=dateadd(day,-1,@fecprimerdia)

select b.codasesor,s.saldocartera,b.CtesNvos,b.RenovacionxPrestamo,ms.MsValorProg,
Mcn.McnValorProg,Mcr.McrValorProg,isnull(sa.saldocarteraini,0) saldocarteraini,b.moraactual
--from tCsRptBonoCartera b
from 
	(select * from tCsRptBonoCartera 
	 union select * from tCsRptBonoComunal
	)b
inner join (
  SELECT c.codasesor,sum(cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocartera
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codasesor=@codasesor
  group by c.codasesor
) s on s.codasesor=b.codasesor
inner join (
  SELECT ncamvalor codasesor,ValorProg MsValorProg
  FROM tCsBsMetaxUEN with(nolock)
  where icodindicador=2 and icodtipobs=5 
  and fecha=@fecfin and ncamvalor=@codasesor
) ms on ms.codasesor=b.codasesor
inner join (
  SELECT ncamvalor codasesor,ValorProg McnValorProg
  FROM tCsBsMetaxUEN with(nolock)
  where icodindicador=11 and icodtipobs=5 
  and fecha=@fecfin and ncamvalor=@codasesor
) mcn on mcn.codasesor=b.codasesor
inner join (
  SELECT ncamvalor codasesor,ValorProg McrValorProg
  FROM tCsBsMetaxUEN with(nolock)
  where icodindicador=12 and icodtipobs=5 
  and fecha=@fecfin and ncamvalor=@codasesor
) mcr on mcr.codasesor=b.codasesor
left outer join (
  SELECT c.codasesor,sum(cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocarteraini
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fecini and c.cartera='ACTIVA'
  and c.codasesor=@codasesor
  group by c.codasesor
) sa on sa.codasesor=b.codasesor
where b.codasesor=@codasesor
GO