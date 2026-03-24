SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE function [dbo].[Proper]
(
--The string to be converted to proper case
@input varchar(8000)
)
returns varchar(8000)

--This function returns the proper case string of varchar type
AS
BEGIN
    declare @OutPut varchar(8000)
	IF @input IS NULL 
	BEGIN
		--Just return NULL if input string is NULL
		RETURN NULL
	END
	
	--Integer variable declarations
	DECLARE @ctr int, @len int, @found_at int
	--Constant declarations
	DECLARE @LOWER_CASE_a int, @LOWER_CASE_z int, @Delimiter char(3), @UPPER_CASE_A int, @UPPER_CASE_Z int
	
	--Variable/Constant initializations
	SET @ctr = 1
	SET @len = LEN(@input)
	SET @output = ''
	SET @LOWER_CASE_a = 97
	SET @LOWER_CASE_z = 122
	SET @Delimiter = ' ,-'
	SET @UPPER_CASE_A = 65
	SET @UPPER_CASE_Z = 90
	
	WHILE @ctr <= @len
	BEGIN
		--This loop will take care of reccuring white spaces
		WHILE CHARINDEX(SUBSTRING(@input,@ctr,1), @Delimiter) > 0
		BEGIN
			SET @output = @output + SUBSTRING(@input,@ctr,1)
			SET @ctr = @ctr + 1
		END

		IF ASCII(SUBSTRING(@input,@ctr,1)) BETWEEN @LOWER_CASE_a AND @LOWER_CASE_z
		BEGIN
			--Converting the first character to upper case
			SET @output = @output + UPPER(SUBSTRING(@input,@ctr,1))
		END
		ELSE
		BEGIN
			SET @output = @output + SUBSTRING(@input,@ctr,1)
		END
		
		SET @ctr = @ctr + 1

		WHILE CHARINDEX(SUBSTRING(@input,@ctr,1), @Delimiter) = 0 AND (@ctr <= @len)
		BEGIN
			IF ASCII(SUBSTRING(@input,@ctr,1)) BETWEEN @UPPER_CASE_A AND @UPPER_CASE_Z
			BEGIN
				SET @output = @output + LOWER(SUBSTRING(@input,@ctr,1))
			END
			ELSE
			BEGIN
				SET @output = @output + SUBSTRING(@input,@ctr,1)
			END
			SET @ctr = @ctr + 1
		END
		
	END
    return @OutPut
END
GO