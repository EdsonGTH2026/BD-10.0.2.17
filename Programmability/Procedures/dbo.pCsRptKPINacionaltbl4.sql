SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*RENOVACION KPI*/

create procedure [dbo].[pCsRptKPINacionaltbl4] @fecha smalldatetime
as   
set nocount on 

--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

--TABLA CON EL MONTO COLOCADO y METAS DE COLOCACION
declare @montoskpi table(zona varchar(30),montoliqui money,ptmosliqui int,montoRenov money,ptmosrenov int)
insert into @montoskpi
select region
,montoliqui,ptmsliqui,montoRenov,ptmosrenov
from fnmgconsolidado.dbo.tcareportekpi with(nolock)
where nomoficina='zz' and fecha=@fecha and region<>'Pro exito'

select zona,sum(montoliqui)montoliqui,sum(ptmosliqui)ptmosliqui,sum(montoRenov)montoRenov,sum(ptmosrenov)ptmosrenov

,isnull(sum(montoliqui),0)-isnull(sum(montoRenov),0) SinRenovarMonto
,isnull(sum(ptmosliqui),0)-isnull(sum(ptmosrenov),0) SinRenovarPtmos
,case when isnull(sum(montoliqui),0)=0 then 0 else (sum(montoRenov)/sum(montoliqui))*100 end PorAlcanceMonto
,case when isnull(sum(ptmosliqui),0)=0 then 0 else (sum(ptmosrenov)/cast(isnull(sum(ptmosliqui),0) as decimal(8,4)))*100 end PorAlcancePtmos
from @montoskpi  group by zona
union
select 'zTOTAL'
,sum(montoliqui)montoliqui,sum(ptmosliqui)ptmosliqui,sum(montoRenov)montoRenov,sum(ptmosrenov)ptmosrenov
,isnull(sum(montoliqui),0)-isnull(sum(montoRenov),0) SinRenovarMonto
,isnull(sum(ptmosliqui),0)-isnull(sum(ptmosrenov),0) SinRenovarPtmos
,case when isnull(sum(montoliqui),0)=0 then 0 else (sum(montoRenov)/sum(montoliqui))*100 end PorAlcanceMonto
,case when isnull(sum(ptmosliqui),0)=0 then 0 else (sum(ptmosrenov)/cast(isnull(sum(ptmosliqui),0) as decimal(8,4)))*100 end PorAlcancePtmos
from @montoskpi
GO