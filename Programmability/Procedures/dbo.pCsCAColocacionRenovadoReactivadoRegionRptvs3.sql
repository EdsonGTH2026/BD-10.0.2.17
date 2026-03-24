SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCAColocacionRenovadoReactivadoRegionRptvs3] @fecfin smalldatetime  
as  
set nocount on  
--declare @fecfin smalldatetime  
--set @fecfin='20250112'  
  
declare @fecini smalldatetime  
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'--'20180901'  
  
declare @fecini_t smalldatetime  
declare @fecfin_t smalldatetime  
set @fecini_t=@fecini  
set @fecfin_t=@fecfin  
  
create table #co(  
 periodo varchar(50),  
 region varchar(100),  
 montototal money,  
 nrototal money,  
 renovadomonto money, 
 renovadomontoAnticipa money,  
 renovadomontoAnticipaAuto money,  
 renovadomontoAnticipaAPP money,  
 renovadonro money,  
 reactivadomonto money,  
 reactivadonro money,  
 renovadoActivo money,  
 renovadohuerfano money,  
 renovadoReasignado money,  
 reactivadoActivo money,  
 reactivadohuerfano money,  
 reactivadoReasignado money  
)  
  
declare @nro int  
declare @n int  
set @nro=3--4  
set @n=1  
  
while(@nro+1<>@n)  
begin  
 --select @fecini_t,@fecfin_t  
 --select @n '@n'  
 insert into #co  
 --exec pCsCAColocacionRenovadoReactivado @fecini_t,@fecfin_t  
 exec pCsCAColocacionRenovadoReactivadoRegionvs3 @fecini_t,@fecfin_t  
  
 set @fecini_t=dateadd(month,-@n,@fecini)  
 set @fecfin_t=dateadd(month,-@n,@fecfin)  
   
 set @n=@n+1  
end  
--set @n=0  
--while(@nro<>@n)  
--begin  
-- set @fecini_t=dateadd(year,-1,dateadd(month,-@n,@fecini))  
-- set @fecfin_t=dateadd(year,-1,dateadd(month,-@n,@fecfin))  
  
-- --select @fecini_t,@fecfin_t  
-- --select @n '@n'  
-- insert into #co  
-- --exec pCsCAColocacionRenovadoReactivado @fecini_t,@fecfin_t  
-- exec pCsCAColocacionRenovadoReactivadoRegionvs2 @fecini_t,@fecfin_t  
    
-- set @n=@n+1  
--end  
  
select *,montototal-renovadomonto-renovadomontoAnticipa-reactivadomonto nuevo  
--,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado  
into #cx  
from #co  
  
insert into #cx(periodo,region,montototal,renovadomonto,renovadomontoAnticipa,renovadomontoAnticipaAuto,renovadomontoAnticipaAPP,reactivadomonto,nuevo,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado)  
select 'Promedio' Titulo,region,avg(montototal) montototal,avg(renovadomonto) renovadomonto,avg(renovadomontoAnticipa),AVG(renovadomontoAnticipaAuto),AVG(renovadomontoAnticipaAPP),avg(reactivadomonto) reactivadomonto,avg(nuevo) nuevo  
,avg(renovadoActivo) renovadoActivo,avg(renovadohuerfano) renovadohuerfano,avg(renovadoReasignado) renovadoReasignado  
,avg(reactivadoActivo) reactivadoActivo,avg(reactivadohuerfano) reactivadohuerfano,avg(reactivadoReasignado) reactivadoReasignado  
from #cx  
where periodo<>dbo.fdufechaaperiodo(@fecfin)  
and substring(periodo,1,4)=substring(dbo.fdufechaaperiodo(@fecfin),1,4)  
group by region  
  
insert into #cx(periodo,region,montototal,renovadomonto,renovadomontoAnticipa,renovadomontoAnticipaAuto,renovadomontoAnticipaAPP,reactivadomonto,nuevo,renovadoActivo,renovadohuerfano,renovadoReasignado,reactivadoActivo,reactivadohuerfano,reactivadoReasignado)  
select 'diferencia' periodo,a.region  
,a.montototal-b.montototal montototal  
,a.renovadomonto-b.renovadomonto renovadomonto  
,a.renovadomontoAnticipa-b.renovadomontoAnticipa renovadomontoAnticipa
,a.renovadomontoAnticipaAuto-b.renovadomontoAnticipaAuto renovadomontoAnticipaAuto
,a.renovadomontoAnticipaAPP-b.renovadomontoAnticipaAPP renovadomontoAnticipaAPP  
,a.reactivadomonto-b.reactivadomonto reactivadomonto  
,a.nuevo-b.nuevo nuevo  
,a.renovadoActivo-b.renovadoActivo renovadoActivo  
,a.renovadohuerfano-b.renovadohuerfano renovadohuerfano  
,a.renovadoReasignado-b.renovadoReasignado renovadoReasignado  
,a.reactivadoActivo-b.reactivadoActivo reactivadoActivo  
,a.reactivadohuerfano-b.reactivadohuerfano reactivadohuerfano  
,a.reactivadoReasignado-b.reactivadoReasignado reactivadoReasignado  
from #cx a  
inner join #cx b on a.region=b.region and b.periodo='promedio'  
where a.periodo=dbo.fdufechaaperiodo(@fecfin)  
  
  
set @fecfin_t=dateadd(year,-1,@fecfin)  
set @fecini_t=dbo.fdufechaaperiodo(@fecfin_t)+'01'--'20180901'  
  
truncate table #co  
insert into #co  
exec pCsCAColocacionRenovadoReactivadoRegionvs3 @fecini_t,@fecfin_t  
  
insert into #cx  
select --*  
'Anterior' periodo,region,montototal,nrototal,renovadomonto,renovadomontoAnticipa,renovadomontoAnticipaAuto,renovadomontoAnticipaAPP,renovadonro,reactivadomonto,reactivadonro,renovadoActivo,renovadohuerfano,renovadoReasignado  
,reactivadoActivo,reactivadohuerfano,reactivadoReasignado  
,montototal-renovadomonto-renovadomontoAnticipa-reactivadomonto nuevo  
from #co  
  
select * from #cx  
  
drop table #co  
drop table #cx  
GO