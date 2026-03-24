SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
CREATE procedure [dbo].[pCsRptReporteKPIxReg] @fecha smalldatetime,@zona varchar(5)  
as     
set nocount on   
  
--declare @fecha smalldatetime  
--set @fecha='20221012'  
  
--declare @zona varchar(5)  
--set @zona='z11'  
  
declare @region varchar(30)  
select @region = nombre from tclzona where zona=(@zona)   
  
select   
case when nomoficina='zz' then region else nomoficina end Nombre   
,case when nomoficina='zz' then 'REGION' else 'SUCURSAL' end CATEGORIA  
,case when nomoficina='zz' then 'REGIONAL' else tiposucursal end tiposucursal2 ,*   
into #base  
from fnmgconsolidado.dbo.tcareporteKPI with(nolock)  
where fecha=@fecha  
and region=@region  
  
  
select *  
,case when saldo0a30ini=0 then 0 else ((varCapVencido+saldocastigado)/saldo0a30ini)*100 end PasoAvencida  
from #base with(nolock)  
---Calcular saldo castigado  
  
drop table #base
GO