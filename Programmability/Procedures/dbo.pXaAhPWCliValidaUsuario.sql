SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaAhPWCliValidaUsuario] @usuario varchar(15), @clave varchar(20)
as
--declare @clave varchar(20)
--set @clave='123456'
--declare @usuario varchar(15)
--set @usuario='5553223770'--'5519380980'--'curbiza'

if ((SELECT count(*)
	FROM tsgusuarioscline u with(nolock)
	where u.nickusuario=@usuario and u.activo=1
	--and u.fechavigencia>=getdate()
	)=0)
begin
	select 0 respuesta,'No vigente - inactivo' Usuario,'' CodUsuario,'' nombres,'' paterno
	return
end

declare @clave_tmp varchar(50)
--select @codusuario
SELECT @clave_tmp=u.claveacceso
from tsgusuarioscline u with(nolock) 
WHERE u.nickusuario=@usuario AND u.ACTIVO=1

if(@clave_tmp<>dbo.fdumd5(dbo.fdumd5(@clave)))
begin
	select 0 respuesta,'' CodUsuario,'' nombrecompleto,'' nombres,'' paterno,'' paterno
	return
end
--print '-------------------------->'
select 1 respuesta,ucl.codusuario,pc.nombrecompleto,isnull(pc.nombres,'') nombres,isnull(pc.paterno,'') paterno,isnull(pc.materno,'') materno
from tsgusuarioscline ucl with(nolock) 
inner join tcspadronclientes pc with(nolock) on ucl.codusuario=pc.codorigen
WHERE ucl.nickusuario=@usuario AND ucl.ACTIVO=1
--and ucl.fechavigencia>=getdate()

--select * from tsgusuarioscline with(nolock)
--where nickusuario='5553223770'
GO