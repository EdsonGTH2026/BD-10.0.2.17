SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaAhPWCliValCodVeri217] @Codusuario varchar(15),@clave varchar(10),@e INT OUTPUT  
as  
set nocount on  
  
---------------------- pruebas   
--declare @Codusuario varchar(15)  
--declare @clave varchar(10)  
--set @Codusuario='MEH730817M6075   '  
--set @clave='5fFgLX' 
-----------------------------

declare @fechahora datetime  
set @fechahora=getdate()--> Hora de la operacion valida x 10 minutos  
--declare @e int  

select @e=max(sec) --> el ultimo envio siempre es el valido, si existiese mas de 1 en 10 minutos --> esto significaria un error  
from tSgUsuariosCLineClaCon with(nolock)  
where Codusuario=@Codusuario and estado=1  
and @fechahora>=fechahora and @fechahora<=dateadd(minute,10,fechahora) --> 20 minutos  -->GDF-20250715: Se ajusta el tiempo de 5 minutos a 10 por solicitud de Héctor Lucas
and clave=@clave COLLATE Latin1_General_CS_AS  


return isnull(@e,0)
GO