SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAListadoAhs] @fecfin smalldatetime
as
--declare @fecfin smalldatetime
declare @fecini smalldatetime
declare @fecsem smalldatetime

--set @fecfin='20170112'
set @fecini=dbo.fdufechaatexto(@fecfin,'AAAAMM')+'01'
set @fecsem=@fecfin+7

truncate table tCsAAhAperturas
insert into tCsAAhAperturas
exec pCsAhAperturasDPF @fecini,@fecfin
--create procedure pCsAAhAperturasdatos as select * from tCsAAhAperturas

truncate table tCsAAhLiquidados
insert into tCsAAhLiquidados
exec pCsAhLiquidadosDPF @fecini,@fecfin
--create procedure pCsAAhLiquidadosDatos as select * from tCsAAhLiquidados

truncate table tCsAAhProxVencimientos
insert into tCsAAhProxVencimientos
exec pCsAhProxVencimientosDPF @fecfin,@fecsem
--create procedure pCsAAhProxVencimientosDatos as select * from tCsAAhProxVencimientos

truncate table tCsAAhDPFsVencidos
insert into tCsAAhDPFsVencidos
exec pCsAhDPFsVencidos
--create procedure pCsAAhDPFsVencidosDatos as select * from tCsAAhDPFsVencidos


GO