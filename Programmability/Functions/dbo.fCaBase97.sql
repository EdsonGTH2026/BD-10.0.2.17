SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE function [dbo].[fCaBase97] (
   @Sucursal    varchar(4),
   @Cuenta      varchar(7),
   @CodPrestamo	varchar(25)
)
RETURNS char(20)
--WITH ENCRYPTION
AS
BEGIN
    --declare @CodPrestamoR char(18)
    declare @Referencia varchar(20)
    declare @SumaS int
    declare @SumaC int
    declare @SumaR int
    declare @Total int
    declare @Residuo tinyint
    declare @DigitoVerificador tinyint
    
    set @Sucursal    = right('0000'    + @Sucursal, 4)
    set @Cuenta      = right('0000000' + @Cuenta  , 7)
    set @CodPrestamo = right('000000000000000000' + replace(@CodPrestamo, '-', ''), 18)

    set @SumaS = 0
    set @SumaS = @SumaS + 23 * cast(substring(@Sucursal, 1, 1) as tinyint)
    set @SumaS = @SumaS + 29 * cast(substring(@Sucursal, 2, 1) as tinyint)
    set @SumaS = @SumaS + 31 * cast(substring(@Sucursal, 3, 1) as tinyint)
    set @SumaS = @SumaS + 37 * cast(substring(@Sucursal, 4, 1) as tinyint)
    
    set @SumaC = 0
    set @SumaC = @SumaC + 13 * cast(substring(@Cuenta, 1, 1) as tinyint)
    set @SumaC = @SumaC + 17 * cast(substring(@Cuenta, 2, 1) as tinyint)
    set @SumaC = @SumaC + 19 * cast(substring(@Cuenta, 3, 1) as tinyint)
    set @SumaC = @SumaC + 23 * cast(substring(@Cuenta, 4, 1) as tinyint)
    set @SumaC = @SumaC + 29 * cast(substring(@Cuenta, 5, 1) as tinyint)
    set @SumaC = @SumaC + 31 * cast(substring(@Cuenta, 6, 1) as tinyint)
    set @SumaC = @SumaC + 37 * cast(substring(@Cuenta, 7, 1) as tinyint)

    set @SumaR = 0
    set @SumaR = @SumaR + 19 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 1, 1))
    set @SumaR = @SumaR + 23 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 2, 1))
    set @SumaR = @SumaR + 29 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 3, 1))
    set @SumaR = @SumaR + 31 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 4, 1))
    set @SumaR = @SumaR + 37 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 5, 1))
    set @SumaR = @SumaR +  1 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 6, 1))
    set @SumaR = @SumaR +  2 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 7, 1))
    set @SumaR = @SumaR +  3 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 8, 1))
    set @SumaR = @SumaR +  5 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 9, 1))
    set @SumaR = @SumaR +  7 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 10, 1))
    set @SumaR = @SumaR + 11 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 11, 1))
    set @SumaR = @SumaR + 13 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 12, 1))
    set @SumaR = @SumaR + 17 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 13, 1))
    set @SumaR = @SumaR + 19 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 14, 1))
    set @SumaR = @SumaR + 23 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 15, 1))
    set @SumaR = @SumaR + 29 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 16, 1))
    set @SumaR = @SumaR + 31 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 17, 1))
    set @SumaR = @SumaR + 37 * dbo.fCaBase97Conversion(substring(@CodPrestamo, 18, 1))
    
    set @Total = @SumaS + @SumaC + @SumaR
    set @Residuo = @Total % 97
    set @DigitoVerificador = 99 - @Residuo
    set @Referencia = SUBSTRING(@CodPrestamo, PATINDEX('%[^0]%', @CodPrestamo), LEN(@CodPrestamo)) + --ltrim(@CodPrestamo, '0') +
                      right('00' + CAST(@DigitoVerificador as varchar), 2)
    
    return (@Referencia)
END

GO

GRANT EXECUTE ON [dbo].[fCaBase97] TO [jmartinezc]
GO

GRANT EXECUTE ON [dbo].[fCaBase97] TO [jarriagaa]
GO