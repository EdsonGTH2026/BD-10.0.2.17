SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[Split1](@input AS Varchar(4000) )
RETURNS
      @Result TABLE(Value BIGINT)
AS

BEGIN
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
            INSERT INTO @Result values (@str)
      END
      RETURN
END 
GO

GRANT SELECT ON [dbo].[Split1] TO [FINAMIGO\Administrador]
GO

GRANT SELECT ON [dbo].[Split1] TO [public]
GO