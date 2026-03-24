SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptCartaPromxProm2]   @fecha smalldatetime,@codusuario varchar(30)  
as  
set nocount on   
  
--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
--declare @codusuario varchar(30)  
--set @codusuario='HMR790625FM400'  
  
select * from FNMGConsolidado.dbo.tcaCartaPromotor2 with(nolock)  
where fecha=@fecha  
and codasesor=@codusuario
GO