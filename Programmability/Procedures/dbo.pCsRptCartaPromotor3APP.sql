SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--exec pCsRptCartaPromotor2 {?@fecha},'{?@codoficina}'


create procedure [dbo].[pCsRptCartaPromotor3APP]   @fecha smalldatetime,@codoficina varchar(5)  
as  
set nocount on   
  
--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
--declare @codoficina varchar(5)  
--set @codoficina='309'  
  
select * 
from FNMGConsolidado.dbo.TCACARTAPROMOTOR3APP with(nolock)  
where fechaConsulta=@fecha  
and codoficina=@codoficina


GO