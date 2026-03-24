SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaAhPWValidaUsuario 'ealcantarav', '179328'  
CREATE procedure [dbo].[pXaAhPWValidaUsuarioV2] @usuario varchar(15), @claveMB5 varchar(200)  
as  
set nocount on  
----declare @claveMB5 varchar(200)  
----set @claveMB5='e7bf132ac4b1499a48b3dba232c62427'--'525390'  
----declare @usuario varchar(15)  
------set @usuario='5519380980'--'curbiza'  
----set @usuario='ealcantarav'  
  
declare @codusuario varchar(15)  
select @codusuario=codusuario  
from tcsempleados  
where estado=1  
and (datanegocio=@usuario or celular=@usuario)  
  
if ((SELECT count(*)  
 FROM tSgUsuarios u with(nolock)  
 where u.codusuario=@codusuario and u.activo=1  
 and u.fechavigencia>=getdate()  
 )=0)  
begin  
 select 0 respuesta,'No vigente - inactivo' Usuario,'' CodUsuario,'' nombres,'' paterno  
 return  
end  
  
declare @clave_tmp varchar(50)  
--select @codusuario  
SELECT @clave_tmp=u.Contrasena  
FROM tSgUsuarios u with(nolock)  
where u.codusuario=@codusuario and u.activo=1  
  
if(@clave_tmp<>@claveMB5)  ---Valida claves cifradas: la clave cifrada que se recibe contra la clabe cifrada en base//se puede quitar
begin  
 select 0 respuesta,'Incorrecto' Usuario,'' CodUsuario,'' nombres,'' paterno  
 return  
end  
  
--Sistema: HP  
--Grupos: AHO01 --> Promotor Ahorros  
--   GERAH --> Gerente de captacion  
declare @codgrupo varchar(5)  
select @codgrupo=codgrupo from tSgUsSistema with(nolock) where usuario=@usuario and codsistema='HP' and activo=1 --> H:ahorro P:portal promotores  
  
declare @opciones varchar(200)  
declare @nombres varchar(200)  
declare @objetos varchar(200)  
declare @permisos varchar(200)  
select @opciones=coalesce(@opciones+ '|','')+a.opcion   
,@nombres=coalesce(@nombres+'|','')+o.nombre  
,@objetos=coalesce(@objetos+'|','')+o.ObjetoWeb  
,@permisos=coalesce(@permisos+'|','')+(cast(a.Acceder as char(1))+cast(a.Anadir as char(1))+cast(a.Editar as char(1))+cast(a.Grabar as char(1))+cast(a.Cancelar as char(1))+cast(a.Eliminar as char(1))  
+cast(a.Imprimir as char(1))+cast(a.Cerrar as char(1)))  
from tSgAcciones a with(nolock)   
inner join tsgoptions o with(nolock) on o.opcion=a.opcion  
where a.codgrupo=@codgrupo and a.codsistema='HP'  
  
SELECT 1 respuesta,u.Usuario,n.codorigen CodUsuario,n.nombres,n.paterno,@codgrupo perfil,@opciones opciones,@nombres nombresopcion,@objetos objetos,@permisos permisos  
FROM tSgUsuarios u with(nolock)  
inner join tcspadronclientes n with(nolock) on n.codusuario=u.codusuario  
where u.codusuario=@codusuario and u.activo=1  
and u.fechavigencia>=getdate()
GO