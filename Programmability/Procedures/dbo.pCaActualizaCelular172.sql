SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCaActualizaCelular172] @codusuario varchar(15), @nrocelular varchar(10),@usuario varchar(15)
as

--declare @nrocelular varchar(10)
--declare @codusuario varchar(15)
--set @nrocelular='5538774833'
--set @codusuario='UMC1809791'

declare @codorigen varchar(15)
select @codorigen=codorigen
from tcspadronclientes with(nolock)
where codusuario=@codusuario
/*
select ustelefonomovil
from [10.0.2.14].finmas.dbo.tususuariosecundarios
where codusuario='98UMC1809791   '--@codorigen
*/
exec [10.0.2.14].finmas.dbo.pCaActualizaCelular2 @codorigen,@nrocelular,@usuario
--update [10.0.2.14].finmas.dbo.tususuariosecundarios
--set ustelefonomovil=@nrocelular
--where codusuario=@codorigen

GO