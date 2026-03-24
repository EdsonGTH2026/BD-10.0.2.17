SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaAhPWCliValidaUsuarioV2] @usuario varchar(15), @claveMD5 varchar(200)  
as  
----declare @claveMD5 varchar(200)  
----set @claveMD5='d806ee42516db15792daef19062070f3'  
----declare @usuario varchar(15)  
----set @usuario='5520682204'--'5519380980'--'curbiza'  
  
if ((SELECT count(*)  
 FROM tsgusuarioscline u with(nolock)  
 where u.nickusuario=@usuario and u.activo=1  
 )=0)  
begin  
 select 0 respuesta,'No vigente - inactivo' Usuario,'' CodUsuario,'' nombres,'' paterno  
 return  
end  
  
declare @clave_tmp varchar(200)  
--select @codusuario  
SELECT @clave_tmp=u.claveacceso  
from tsgusuarioscline u with(nolock)   
WHERE u.nickusuario=@usuario AND u.ACTIVO=1  
  
if(@clave_tmp<>@claveMD5)  ---Valida claves cifradas: la clave cifrada que se recibe contra la clabe cifrada en base//se puede quitar
begin  
 ----SELECT @clave_tmp,@claveMD5
 select 0 respuesta,'' CodUsuario,'' nombrecompleto,'' nombres,'' paterno,'' paterno  
 return  
end  

--print '-------------------------->'  
select 1 respuesta,ucl.codusuario,pc.nombrecompleto,isnull(pc.nombres,'') nombres,isnull(pc.paterno,'') paterno,isnull(pc.materno,'') materno  
from tsgusuarioscline ucl with(nolock)   
inner join tcspadronclientes pc with(nolock) on ucl.codusuario=pc.codorigen  
WHERE ucl.nickusuario=@usuario AND ucl.ACTIVO=1 
and ucl.claveacceso=@claveMD5 
GO