SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*colocacion dispersa y etregado*/

CREATE procedure [dbo].[pCsRptKPINacionaltbl3] @fecha smalldatetime
as   
set nocount on 

--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

--TABLA CON EL MONTO COLOCADO y METAS DE COLOCACION
declare @montoskpi table(zona varchar(30),RenovAntDisper money,ReactivacionDisper money,RenovDisper money,nuevoDisper money,montoDispersion	money
,RenovAntEnt money,ReactEnt money,RenovEnt money,nuevoEnt money,montoEntrega money
,metacolocacion money)
insert into @montoskpi
select region,RenovAntDisper,ReactivacionDisper,RenovDisper,nuevoDisper,montoDispersion	
,RenovAntEnt,ReactEnt,RenovEnt,nuevoEnt,montoEntrega
,montocolocacion
from fnmgconsolidado.dbo.tcareportekpi with(nolock)
where nomoficina='zz' and fecha=@fecha and region<>'Pro exito'

select zona,sum(RenovAntDisper)RenovAntDisper,sum(ReactivacionDisper)ReactivacionDisper,sum(RenovDisper)RenovDisper,sum(nuevoDisper)nuevoDisper,sum(montoDispersion)montoDispersion
,sum(RenovAntEnt)RenovAntEnt,sum(ReactEnt)ReactEnt,sum(RenovEnt)RenovEnt,sum(nuevoEnt)nuevoEnt,sum(montoEntrega)montoEntrega,sum(metacolocacion)metacolocacion
,case when isnull(sum(metacolocacion),0)=0 then 0 else (sum(montoDispersion)/sum(metacolocacion))*100 end PorDispersion
,case when isnull(sum(metacolocacion),0)=0 then 0 else (sum(montoEntrega)/sum(metacolocacion))*100 end PorEntrega
from @montoskpi  group by zona
union
select 'zTOTAL',sum(RenovAntDisper),sum(ReactivacionDisper),sum(RenovDisper),sum(nuevoDisper),sum(montoDispersion)
,sum(RenovAntEnt),sum(ReactEnt),sum(RenovEnt),sum(nuevoEnt),sum(montoEntrega),sum(metacolocacion)
,case when isnull(sum(metacolocacion),0)=0 then 0 else (sum(montoDispersion)/sum(metacolocacion))*100 end PorDispersion
,case when isnull(sum(metacolocacion),0)=0 then 0 else (sum(montoEntrega)/sum(metacolocacion))*100 end PorEntrega
from @montoskpi
GO