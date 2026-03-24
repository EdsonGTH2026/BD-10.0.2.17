SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fSplit]  
   (  @DELIMITER VARCHAR(5),  
      @LIST      VARCHAR(500)  
   )  
   RETURNS @TABLEOFVALUES TABLE  
      (  ROWID   SMALLINT IDENTITY(1,1),  
         [VALUE] VARCHAR(500)  
      )  
AS  
   BEGIN 
     
      DECLARE @LENSTRING INT  

	set @LIST = rtrim(ltrim(@LIST))
  
      WHILE LEN( @LIST ) > 0  
         BEGIN  
          
            SELECT @LENSTRING =  
               (CASE CHARINDEX( @DELIMITER, @LIST )  
                   WHEN 0 THEN LEN( @LIST )  
                   ELSE ( CHARINDEX( @DELIMITER, @LIST ) -1 ) 
                END 
               )  
                                 
            INSERT INTO @TABLEOFVALUES  
               SELECT SUBSTRING( @LIST, 1, @LENSTRING ) 
                 
            SELECT @LIST =  
               (CASE ( LEN( @LIST ) - @LENSTRING )  
                   WHEN 0 THEN ''  
                   ELSE RIGHT( @LIST, LEN( @LIST ) - @LENSTRING - 1 )  
                END 
               )  
         END 
           
      RETURN  
       
   END



GO