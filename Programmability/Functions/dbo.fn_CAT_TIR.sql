SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CAT_TIR]
(
    @str varchar(8000),
    @precision DECIMAL(30,10)
)
RETURNS DECIMAL(30, 10)
AS 
BEGIN
    declare  @AdjValue decimal(30,10)
            ,@guess Decimal(30,10)
            ,@guess_new Decimal(30,10)

    Select @AdjValue = 0.1, @guess=0

    DECLARE @t_IDs TABLE (
        id INT IDENTITY(0, 1),
        value DECIMAL(30, 10)
    )
    Declare @NPV DECIMAL(30, 10)
           ,@iter_cnt int

    INSERT INTO @t_IDs 
        select * from dbo.fduCAT_SplitString(@str)

    SET @guess = CASE WHEN ISNULL(@guess, 0) <= 0 THEN 0 ELSE @guess END

    SELECT @NPV = SUM(value / POWER(1 + @guess, id)) FROM @t_IDs
    WHILE ((@NPV > 0 or @AdjValue > @precision) and (isnull(@iter_cnt,0) < 8192))
    BEGIN
        SET @guess_new = @guess + @AdjValue
        SELECT @NPV = SUM(value / POWER(1 + @guess_new, id)) FROM @t_IDs
        set @iter_cnt = isnull(@iter_cnt,0) + 1
        if (@NPV > 0)
            select @guess=@guess_new
        else
            select @AdjValue=@AdjValue/10
    END
    RETURN @guess
END

GO