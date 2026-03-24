SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create FUNCTION [dbo].[fduCAT_SplitString](@input varchar(8000))
	RETURNS @Result TABLE(campo decimal(30,10))
AS	  
begin
	  --declare @Result table(cod varchar(10))
	  --declare @input varchar(8000)
	  --set @input='1,2,3,5,6,7,8,9,0,4'

	  DECLARE @str VARCHAR(20)
      DECLARE @ind Int
      IF(@input is not null)
      BEGIN
            SET @ind = CharIndex(',',@input)
            WHILE @ind > 0
            BEGIN
                  SET @str = SUBSTRING(@input,1,@ind-1)
                  SET @input = SUBSTRING(@input,@ind+1,LEN(@input)-@ind)
                  INSERT INTO @Result values (@str)
                  SET @ind = CharIndex(',',@input)
            END

            SET @str = @input
            INSERT INTO @Result values (cast(@str as decimal(30,10)))
      END
      
	  --select * from @Result

RETURN

end
GO