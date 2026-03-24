SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

      
CREATE procedure [dbo].[pXaSucursalesxUsu2] @usuario varchar(15)        
as        
--declare @usuario varchar(15)        
--set @usuario='cfloresl'--'zchavezu'--      
        
Declare @perfil varchar(10)        
declare @codoficina varchar(4)        
set @codoficina=''        
declare @todas char(1)        
set @todas=0        
select @codoficina=codoficina,@todas=todasoficinas from tsgusuarios where usuario=@usuario        
select @perfil=codgrupo from tsgussistema where usuario=@usuario and codsistema='DC'        
        
--if(@perfil in('ADM01','DIREC','GESCO','AUDIT', 'CONTA', 'ASI01')) set @todas=1        
      
if (@usuario in('curbiza','mchavezs','zchavezu','lvegav'))           
begin          
 select codoficina, nomoficina sucursal        
    from tcloficinas with(nolock)        
    where tipo<>'Cerrada'        
    and (cast(codoficina as int)<100 or cast(codoficina as int)>300)        
    and codoficina not in('97','98','99','999')        
    order by nomoficina       
end      
if (@usuario in('tlunab'))   -------------> Solicitado por Laura, para asignar las sucursales de las regiones de veracruz                
begin          
 select codoficina, nomoficina sucursal        
    from tcloficinas with(nolock)        
    where tipo<>'Cerrada'   and zona IN ('Z11','Z17')      
    --and (cast(codoficina as int)<100 or cast(codoficina as int)>300)        
    --and codoficina not in('97','98','99','999')        
    order by nomoficina       
end 
        
else          
begin          
if @todas=1         
 begin        
  if(@perfil in ('GEREG','GRREG'))        
   begin        
    select codoficina, nomoficina sucursal        
    from tcloficinas with(nolock)        
    where tipo<>'Cerrada'        
    and zona in(        
     select Zona        
     from tclzona with(nolock)        
     where activo=1 and responsable in (select codusuario from tsgusuarios where usuario=@usuario)        
    )        
    and (cast(codoficina as int)<100 or cast(codoficina as int)>300)        
    and codoficina not in('97','98','99','999')        
    order by nomoficina        
   end       
  else        
   begin        
    select codoficina, nomoficina sucursal        
    from tcloficinas with(nolock)        
    where tipo<>'Cerrada'        
    and (cast(codoficina as int)<100 or cast(codoficina as int)>300)        
    and codoficina not in('97','98','99','999')        
    order by nomoficina        
   end        
 end        
else        
 begin        
  if(@perfil in ('GEREG','GRREG'))        
   begin        
    select codoficina, nomoficina sucursal        
    from tcloficinas with(nolock)        
    where tipo<>'Cerrada'        
    and zona in(        
     select Zona        
     from tclzona with(nolock)        
     where activo=1 and responsable in (select codusuario from tsgusuarios where usuario=@usuario)        
    )        
    and (cast(codoficina as int)<100 or cast(codoficina as int)>300)        
    and codoficina not in('97','98','99','999')        
    order by nomoficina        
   end        
 if(@perfil='GERA')         
   begin        
    select codoficina, sucursal        
    from [_CorreosLN]        
    where codusuario in (select codusuario from tsgusuarios where usuario=@usuario)        
    order by sucursal        
   end 
if (@perfil in('GEVOL'))  ------------>  gerentes volantes        
   begin        
    select codoficina, nomoficina sucursal        
    from tcloficinas with(nolock)        
    where tipo<>'Cerrada'        
    and zona in(        
     select Zona        
     from tclzona with(nolock)        
     where activo=1 and codvolante in (select codusuario from tsgusuarios where usuario=@usuario))        
    and (cast(codoficina as int)<100 or cast(codoficina as int)>300)        
    and codoficina not in('97','98','99','999')        
    order by nomoficina        
   end        
 end        
 end      
GO