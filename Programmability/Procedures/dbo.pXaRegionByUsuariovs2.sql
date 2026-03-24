SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
          
CREATE procedure [dbo].[pXaRegionByUsuariovs2] (@usuario varchar(20))            
as            
            
--- se usa para el reporte kpi regional, carta regional            
            
--declare @usuario varchar(20)            
--set @usuario='cfloresl'  

Declare @perfil varchar(10)        
select @perfil=codgrupo from tsgussistema where usuario=@usuario and codsistema='DC'        
        
 --select @perfil
         
 set nocount on            
            
 if (@usuario in('curbiza','mchavezs','zchavezu','lvegav','maristav','grazoc')) ----Se agrega a Laura y Mercedes para poder ver el kpi por regiones            
 begin                   --- Se agrega a Guillermo Razo para ver el kpi por regiones y la carta Regional    
  select Zona, Nombre, Responsable,*            
  from tclzona with(nolock)            
  where activo=1            
 end    
  if (@usuario in('tlunab'))  -------------> Solicitado por Laura, para asignar las regiones de veracruz          
 begin                    
  select Zona, Nombre, Responsable,*            
  from tclzona with(nolock)            
  where activo=1  and zona IN ('Z11','Z17')          
 end
 if (@perfil in('GEVOL'))  ------------>  gerentes volantes        
 begin            
  select         
  Zona, Nombre, 
  codvolante  Responsable        
  from tclzona with(nolock)            
  where activo=1 and codvolante in (select codusuario from tsgusuarios where usuario=@usuario )
end  
  else            
 begin            
  select          
  Zona, Nombre, Responsable            
  from tclzona with(nolock)            
  where activo=1 and responsable in (select codusuario from tsgusuarios where usuario=@usuario)            
 end 
GO