SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptCartaPromxPromo]  @fecha smalldatetime,@codusuario varchar(20)  
as  
set nocount on   
  
--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
--declare @codusuario varchar(20)  
--set @codusuario='DLR890221F0221' 
  
select * from FNMGConsolidado.dbo.tcaCartaPromotor2 with(nolock)  
where fecha=@fecha  
and codasesor=@codusuario
GO