SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--PXaCliente 'OQM641219F9MR9'
CREATE procedure [dbo].[PXaCliente] @codusuario varchar(15)
as
--declare @codusuario varchar(15)
--set @codusuario='OQM641219F9MR9'

declare @nombre varchar(300)
declare @numero varchar(20)

select @nombre=nombres+'|'+nombrecompleto --nombres
from tcspadronclientes with(nolock) 
where codusuario=@codusuario

SELECT @numero=NroCelular
FROM tSgUsuariosCLine where codusuario=@codusuario

select @nombre +'|'+ isnull(@numero,'') nombres
GO