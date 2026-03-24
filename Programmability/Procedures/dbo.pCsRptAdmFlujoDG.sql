SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsRptAdmFlujoDG
create procedure [dbo].[pCsRptAdmFlujoDG] @periodo int
as
--declare @periodo int
--set @periodo=2015
select ac.anual,ac.orden,ac.nivel,case when ac.nivel=3 then '   '+ac.concepto when ac.nivel=2 then ' '+ac.concepto else ac.concepto end concepto
,an.mes1,an.mes2,an.mes3,an.mes4,an.mes5,an.mes6,an.mes7,an.mes8,an.mes9,an.mes10,an.mes11,an.mes12
,ac.mes1 mes1_ac,ac.mes2 mes2_ac,ac.mes3 mes3_ac,ac.mes4 mes4_ac,ac.mes5 mes5_ac,ac.mes6 mes6_ac,ac.mes7 mes7_ac
,ac.mes8 mes8_ac,ac.mes9 mes9_ac,ac.mes10 mes10_ac,ac.mes11 mes11_ac,ac.mes12 mes12_ac
from tCsRptAdmFlujo ac with(nolock) 
inner join tCsRptAdmFlujo an with(nolock) on an.concepto=ac.concepto and an.anual=(@periodo-1)
where ac.anual=@periodo
order by ac.orden
GO