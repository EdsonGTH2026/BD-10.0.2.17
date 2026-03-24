SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fCoCadEnTabla] (@cadena      ntext)

RETURNS @tabla TABLE (listpos int IDENTITY(1, 1) NOT NULL,
                      str     varchar(4000),
                      nstr    nvarchar(2000)) 
WITH ENCRYPTION 
AS
BEGIN
      DECLARE @pos       int,
              @textpos   int,
              @chunklen  smallint,
              @tmpstr    nvarchar(4000),
              @leftover  nvarchar(4000),
              @tmpval    nvarchar(4000),
	      @separador nchar(1) 
      SET @separador=','
      SET @textpos = 1
      SET @leftover = ''
      WHILE @textpos <= datalength(@cadena) / 2
      BEGIN
         SET @chunklen = 4000 - datalength(@leftover) / 2
         SET @tmpstr = @leftover + substring(@cadena, @textpos, @chunklen)
         SET @textpos = @textpos + @chunklen

         SET @pos = charindex(@separador, @tmpstr)

         WHILE @pos > 0
         BEGIN
            SET @tmpval = ltrim(rtrim(left(@tmpstr, @pos - 1)))
            INSERT @tabla (str, nstr) VALUES(@tmpval, @tmpval)
            SET @tmpstr = substring(@tmpstr, @pos + 1, len(@tmpstr))
            SET @pos = charindex(@separador, @tmpstr)
         END

         SET @leftover = @tmpstr
      END

      INSERT @tabla(str, nstr) VALUES (ltrim(rtrim(@leftover)), ltrim(rtrim(@leftover)))
   RETURN
END

GO