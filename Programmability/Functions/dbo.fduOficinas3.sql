SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduOficinas3] (@zona varchar(20))    
RETURNS varchar(2000) AS    
BEGIN   
  
--declare @zona varchar(20)  
----set @zona  = 'Z01'  
--set @zona  = '%'  
  
DECLARE @cad varchar(2000)   
SET @cad = ''   
DECLARE @cod varchar(20)   
DECLARE xcursor CURSOR FOR   
 SELECT case when CodOficina in(430,431) then codoficina   
    when codoficina='37' then '37,131'  
    when codoficina='25' then '25,114'  
    when cast(CodOficina as int)>=510 then CodOficina ----2025.11.28 
    else  
     CodOficina + case when cast(CodOficina as int)>=300 then ',' + cast((cast(CodOficina as int)-200) as varchar(4))  else '' end   
    end   
 FROM tcloficinas with(nolock)   
 where --codoficina<100 and   
 (codoficina<=100 or codoficina>=300) and  
 zona like @zona  
 and tipo<>'CERRADA'  
 and codoficina not in('99','97','98')  
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
  
--SELECT @cad   
 
--SET @cad = substring(@cad,1,len(@cad)-1)   
--OSC 21042016: se valido la longitud de la variable para que no marcara error   
if len(@cad) > 0  
    begin   
 SET @cad = substring(@cad,1,len(@cad)-1)     
    end    
  
--print @cad   
return (@cad )  
  
END  
  
GO