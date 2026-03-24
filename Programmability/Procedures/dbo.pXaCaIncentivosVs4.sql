SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pXaCaIncentivosVs4] @CodAsesor varchar(15)      
as      
DECLARE @Fecha SMALLDATETIME      
 SELECT @Fecha = FechaConsolidacion FROM vCsFechaConsolidacion WITH (NOLOCK)      
 --SELECT @Fecha = '2021/08/31'      
    
--DECLARE  @CodAsesor varchar(15)     
--SELECT @CodAsesor='HHA991006F6PN6'    
    
select  *
from [FNMGConsolidado].[dbo].[tCaCartapromotor2] with(nolock)   
WHERE codasesor=@CodAsesor    
and fecha=@Fecha    

GO