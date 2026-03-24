SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*------ 
VER. ZCCU_2026.01.12 
*/ 
CREATE PROCEDURE [dbo].[psControlBajas] 
AS 

BEGIN  
SET NOCOUNT ON    

DECLARE @FECHA SMALLDATETIME  
--SELECT @FECHA=FECHACONSOLIDACION FROM VCSFECHACONSOLIDACION           
SET @FECHA='20260101'        
       
DECLARE @FECHAINI  SMALLDATETIME        
SET @FECHAINI = dbo.fdufechaaperiodo(@fecha)+'01'      
      
        
SELECT 
---'USUARIO: '+ us.USUARIO +' CODUSUARIO: '+e.codusuario
CASE WHEN US.activo=0 THEN '' ELSE 'USUARIO: '+ us.USUARIO +' CODUSUARIO: '+e.codusuario END  'Resumen'

, CASE WHEN US.activo=0 THEN 'USUARIO DESHABILITADO' ELSE 'USUARIO ACTIVO' END ESTATUS   
, CASE WHEN US.activo=0 THEN '#AFECAA' ELSE 'orange' END color   
FROM TCSEMPLEADOS E WITH(NOLOCK)        
left outer join tsgusuarios us    WITH(NOLOCK) ON us.codusuario=e.codusuario --and  activo=0 and not  us.codusuario='' 
WHERE  SALIDA>=@FECHAINI 

END;
GO