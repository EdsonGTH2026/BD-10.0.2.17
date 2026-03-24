SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSucursalesxPerfilxUsu] @usuario varchar(15),@perfil varchar(10)  
as  
--declare @usuario varchar(15)  
--Declare @perfil varchar(10)  
--set @perfil='GESCO'  
--set @usuario='jlmartinezr'  
  
declare @zona varchar(4)  
set @zona=''  
declare @codoficina varchar(4)  
set @codoficina=''  
  
select @codoficina=codoficina from tsgusuarios where usuario=@usuario  
  
declare @todas char(1)  
set @todas=0  
if(@perfil in('ADM01','DIREC','GESCO','AUDIT', 'CONTA', 'ASI01', 'GESCD')) set @todas=1  
  
--if(@perfil='GEREG')   
if(@perfil in ('GEREG','GRREG'))  --OSC: 070818, se modifico para que soportara el perfil de FINMAS  
 begin  
  select @zona=zona from tclzona  
  where activo=1 and responsable in (select codusuario from tsgusuarios where usuario=@usuario)  
 end  
  
if(@perfil='GERA')   
 begin  
  select @codoficina=codoficina from [_CorreosLN]  
  where codusuario in (select codusuario from tsgusuarios where usuario=@usuario)  
 end  
  
exec pCsCboOficinasyZonasVs2 @zona,@codoficina,@todas  
  
  
GO