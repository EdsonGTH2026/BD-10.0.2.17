SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCaComfirmaCelular172] @codusuario varchar(15), @usuario varchar(15),@accion char(1)
as

declare @codorigen varchar(15)
select @codorigen=codorigen
from tcspadronclientes with(nolock)
where codusuario=@codusuario

--exec [10.0.2.14].finmas.dbo.pCaActualizaCelularConfirmar '1',@codorigen,@usuario
exec [10.0.2.14].finmas.dbo.pCaActualizaCelularConfirmar @accion,@codorigen,@usuario
GO