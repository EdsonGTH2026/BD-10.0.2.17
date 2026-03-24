SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[RemoveExtraSpaces](@Input VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
------ Se usa para quitarle los espacios extras a Paterno, Materno, Nombre en tususuarios 
----------------------------------------(correcion requerida para las transferencias STP)
    DECLARE @Output VARCHAR(50)
    SET @Output = @Input

    -- Reemplazar múltiples espacios consecutivos con un solo espacio
    WHILE CHARINDEX('  ', @Output) > 0
        SET @Output = REPLACE(@Output, '  ', ' ')

    -- Eliminar espacios al principio y al final
    SET @Output = LTRIM(RTRIM(@Output))

    RETURN @Output
END
GO