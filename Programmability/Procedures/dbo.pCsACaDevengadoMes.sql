SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaDevengadoMes] @fecha smalldatetime,@codoficina varchar(4)
as
--declare @fecha smalldatetime
--set @fecha='20210703'

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'

select t.fecha
,sum(t.saldocapital) capitalTotal
,sum(t.interesdevengado) intDevTotal
,sum(case when c.codfondo=20 then t.saldocapital*0.7 else 0 end) capitalProgresemos
,sum(case when c.codfondo=20 then t.interesdevengado*0.7 else 0 end) intDevProgresemos
,sum(case when c.codfondo=20 then t.saldocapital*0.3 else t.saldocapital end) capitalFinamigo
,sum(case when c.codfondo=20 then t.interesdevengado*0.3 else t.interesdevengado end) intDevFinamigo
,(case when sum(t.saldocapital)=0 then 0 else sum(t.interesdevengado)  / sum(t.saldocapital) end) as  tasaDiaTotal
,(case when sum(case when c.codfondo=20 then t.saldocapital*0.7 else 0 end)=0 then 0
	else sum(case when c.codfondo=20 then t.interesdevengado*0.7 else 0 end) / sum(case when c.codfondo=20 then t.saldocapital*0.7 else 0 end) end) as tasaDiaProgresemos
,sum(case when c.codfondo=20 then t.interesdevengado*0.3 else t.interesdevengado end) / sum(case when c.codfondo=20 then t.saldocapital*0.3 else t.saldocapital end) as tasaDiaFinamigo
from tcscarteradet t with(nolock)
inner join tcscartera c with(nolock) on c.fecha=t.fecha and c.codprestamo=t.codprestamo
where c.NroDiasAtraso<=89 and t.fecha>=@fecini and t.fecha<=@fecha
and c.codoficina not in('97','231') and c.estado='VIGENTE'
group by t.fecha 
order by t.fecha
GO