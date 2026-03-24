SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PXaCartaPromotoresxSuc] @codoficina varchar(3)         
as    
--declare @codoficina varchar(3)    
--set @codoficina=4    
declare @fecha smalldatetime    
select @fecha=fechaconsolidacion from vcsfechaconsolidacion    
    
SELECT codasesor,nombrepromotor AS coordinador   
FROM [FNMGConsolidado].[dbo].[tCaCartapromotor2]   
where fecha=@fecha and codoficina=@codoficina    
  
GO