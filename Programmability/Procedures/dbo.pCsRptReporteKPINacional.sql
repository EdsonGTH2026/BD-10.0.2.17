SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsRptReporteKPINacional] @fecha smalldatetime
as   
set nocount on 

--declare @fecha smalldatetime
--set @fecha='20220805'


select 
case when nomoficina='zz' then region else nomoficina end Nombre 
,case when nomoficina='zz' then 'REGION' else 'SUCURSAL' end CATEGORIA
,case when nomoficina='zz' then 'REGIONAL' else tiposucursal end tiposucursal2 ,* 

from fnmgconsolidado.dbo.tcareporteKPI
where nomoficina='zz' and region<>'Pro exito'
and fecha=@fecha 
GO