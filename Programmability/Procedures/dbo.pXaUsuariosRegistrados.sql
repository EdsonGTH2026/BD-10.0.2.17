SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pXaUsuariosRegistrados 'urbiza'
CREATE procedure [dbo].[pXaUsuariosRegistrados] @nombre varchar(200)
as
SELECT top 100 u.nickusuario usuario,cl.nombrecompleto,u.fechaalta
FROM tSgUsuariosCLine u with(nolock)
inner join tcspadronclientes cl with(nolock) on cl.codusuario=u.codusuario
where cl.nombrecompleto like '%'+@nombre+'%'
--where nickusuario<>'UIMC790918'

GO