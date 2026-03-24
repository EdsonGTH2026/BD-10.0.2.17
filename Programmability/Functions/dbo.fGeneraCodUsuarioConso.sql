SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--ALTER  FUNCTION fGeneraCodUsuarioConso(@CodUsuario varchar(15))
CREATE FUNCTION [dbo].[fGeneraCodUsuarioConso](@CodUsuario varchar(15)) 
-- funcion que quita los digitos de oficina del codusuario 
RETURNS char(15) 
AS 
BEGIN 
    DECLARE @CodUsuarioR char(15)
    set @CodUsuarioR = 
        case when left(@CodUsuario, 1) between 'A' and 'Z' then @CodUsuario
             else case when isnumeric(left(@CodUsuario, 3)) = 1 then substring(@CodUsuario, 4, 15)
                       when isnumeric(left(@CodUsuario, 2)) = 1 then substring(@CodUsuario, 3, 15)
                       when isnumeric(left(@CodUsuario, 1)) = 1 then substring(@CodUsuario, 2, 15)
                       else @CodUsuario
                  end
        end
    RETURN @CodUsuarioR
END 
GO