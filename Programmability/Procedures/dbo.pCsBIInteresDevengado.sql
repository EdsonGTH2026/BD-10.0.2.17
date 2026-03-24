SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBIInteresDevengado]   
as  
  
--sp_helptext   
--exec [pCsBIInteresDevengado]  
  
declare @fecfin smalldatetime  
select @fecfin=fechaconsolidacion from vcsfechaconsolidacion  
  
declare @fechainicial smalldatetime  
select @fechainicial ='20190101' 
  
  
declare @inicio smalldatetime  
select @inicio =(select primerdia from tclperiodo with(nolock) where primerdia<=@fechainicial and ultimodia>=@fechainicial)  
  
select t.fecha  
--, t.CodOficina  
,sum(t.saldocapital) capitalTotal  
,sum(t.interesdevengado) intDevTotal  
,sum(case when c.codfondo=20 then t.saldocapital*0.7 else 0 end) capitalProgresemos  
,sum(case when c.codfondo=20 then t.interesdevengado*0.7 else 0 end) intDevProgresemos  
,sum(case when c.codfondo=21 then t.saldocapital*0.75 else 0 end) capitalFaccorp  
,sum(case when c.codfondo=21 then t.interesdevengado*0.75 else 0 end) intDevFaccorp  
,sum(case when c.codfondo=20 then t.saldocapital*0.3   
                                 when c.codfondo=21 then t.saldocapital*0.25  
else t.saldocapital end) capitalFinamigo  
,sum(case when c.codfondo=20 then t.interesdevengado*0.3   
          when c.codfondo=21 then t.interesdevengado*0.25  
else t.interesdevengado end) intDevFinamigo  
--,(sum(t.interesdevengado)  / sum(t.saldocapital) ) as  tasaDiaTotal  
--,(sum(case when c.codfondo=20 then t.interesdevengado*0.7 else 0 end) / sum(case when c.codfondo=20 then t.saldocapital*0.7 else 0 end) ) as tasaDiaProgresemos  
--,(sum(case when c.codfondo=21 then t.interesdevengado*0.75 else 0 end) / sum(case when c.codfondo=21 then t.saldocapital*0.75 else 0 end) ) as tasaDiaProgresemos  
--,sum(case when c.codfondo=20 then t.interesdevengado*0.3 else t.interesdevengado end) / sum(case when c.codfondo=20 then t.saldocapital*0.3 else t.saldocapital end) as tasaDiaFinamigo  
from tcscarteradet t with(nolock)  
inner join tcscartera c with(nolock) on c.fecha=t.fecha and c.codprestamo=t.codprestamo  
inner join tcspadroncarteradet p with(nolock) on p.CodPrestamo=c.CodPrestamo  
where c.NroDiasAtraso<=89 and c.codoficina <> 97 and c.codoficina <> 231 and c.estado='VIGENTE'  
and t.fecha>=@inicio and t.fecha<=@fecfin --t.codprestamo='005-170-06-01-01812'  
group by t.fecha--, t.CodOficina--, c.TasaIntCorriente   
order by t.fecha  
GO