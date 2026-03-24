SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE function [dbo].[fCaBase97Conversion] (
   @Llave char(1)
)
RETURNS tinyint
--WITH ENCRYPTION
AS
BEGIN
    declare @Valor tinyint
    set @Valor = 0

    if @Llave = 'A' set @Valor = 2
    if @Llave = 'B' set @Valor = 2
    if @Llave = 'C' set @Valor = 2
    if @Llave = 'D' set @Valor = 3
    if @Llave = 'E' set @Valor = 3
    if @Llave = 'F' set @Valor = 3
    if @Llave = 'G' set @Valor = 4
    if @Llave = 'H' set @Valor = 4
    if @Llave = 'I' set @Valor = 4
    if @Llave = 'J' set @Valor = 5
    if @Llave = 'K' set @Valor = 5
    if @Llave = 'L' set @Valor = 5
    if @Llave = 'M' set @Valor = 6
    if @Llave = 'Ñ' set @Valor = 0
    if @Llave = 'N' set @Valor = 6
    if @Llave = 'O' set @Valor = 6
    if @Llave = 'P' set @Valor = 7
    if @Llave = 'Q' set @Valor = 7
    if @Llave = 'R' set @Valor = 7
    if @Llave = 'S' set @Valor = 8
    if @Llave = 'T' set @Valor = 8
    if @Llave = 'U' set @Valor = 8
    if @Llave = 'V' set @Valor = 9
    if @Llave = 'W' set @Valor = 9
    if @Llave = 'X' set @Valor = 9
    if @Llave = 'Y' set @Valor = 0
    if @Llave = 'Z' set @Valor = 0
    if @Llave = '0' set @Valor = 0
    if @Llave = '1' set @Valor = 1
    if @Llave = '2' set @Valor = 2
    if @Llave = '3' set @Valor = 3
    if @Llave = '4' set @Valor = 4
    if @Llave = '5' set @Valor = 5
    if @Llave = '6' set @Valor = 6
    if @Llave = '7' set @Valor = 7
    if @Llave = '8' set @Valor = 8
    if @Llave = '9' set @Valor = 9

    return (@Valor)
END

--------------------------------------------------------------------------------


GO