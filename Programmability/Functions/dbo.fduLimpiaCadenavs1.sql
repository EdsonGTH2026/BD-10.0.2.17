SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
  
/*LIMPIA UNA CADENA, QUITANDO CARACTERES ESPECIALES Y QUITANDO ACENTOS*/  
  
CREATE FUNCTION [dbo].[fduLimpiaCadenavs1] (@CADENA VARCHAR(255))   
RETURNS varchar(255)    
AS      
BEGIN   
 DECLARE @Caracteres VARCHAR(100)  
 --DECLARE @Cadena VARCHAR(255)  
 SET @Caracteres = '-;,.´()&\¡!?:$%[_*@{}' -- Caracteres a Quitar  
 --SET @Cadena = 'Probán(do élimi,nación* &de l$a Cad;ena}'  
  
 -- Quitar Caracteres  
 WHILE @Cadena LIKE '%[' + @Caracteres + ']%'  
 BEGIN  
  SELECT @Cadena = REPLACE(@Cadena,SUBSTRING(@Cadena,PATINDEX('%[' + @Caracteres + ']%',@Cadena),1),'')  
 END  
  
 SELECT @Cadena = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(@Cadena),'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U')  
  
-- PRINT @Cadena  
RETURN (@Cadena)     
END    
    
GO

GRANT EXECUTE ON [dbo].[fduLimpiaCadenavs1] TO [Rie_jaguilarr]
GO

GRANT EXECUTE ON [dbo].[fduLimpiaCadenavs1] TO [rie_sbravoa]
GO

GRANT EXECUTE ON [dbo].[fduLimpiaCadenavs1] TO [rie_ldomingueze]
GO

GRANT EXECUTE ON [dbo].[fduLimpiaCadenavs1] TO [rie_jalvarezc]
GO

GRANT EXECUTE ON [dbo].[fduLimpiaCadenavs1] TO [rie_blozanob]
GO