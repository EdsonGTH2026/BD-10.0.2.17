SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE  FUNCTION [dbo].[fduOficinas2] (@zona varchar(20))    
RETURNS varchar(800) AS    
BEGIN   
  
--declare @zona varchar(20)  
--set @zona  = 'Z02'  
  
DECLARE @cad varchar(800)   
SET @cad = ''   
DECLARE @cod varchar(20)   
DECLARE xcursor CURSOR FOR   
SELECT codoficina FROM tcloficinas with(nolock) where codoficina<100 and zona like @zona  
OPEN xcursor   
FETCH NEXT FROM xcursor   
INTO @cod   
WHILE @@FETCH_STATUS = 0   
 BEGIN   
 SET @cad = @cad + @cod + ','   
 FETCH NEXT FROM xcursor   
 INTO @cod   
END CLOSE xcursor   
DEALLOCATE xcursor     
 
--select @cad

if len(@cad) > 0
    begin 
	SET @cad = substring(@cad,1,len(@cad)-1)   
    end  

--select @cad
  
return (@cad )  
  
END 
GO