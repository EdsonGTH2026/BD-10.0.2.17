SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaPerfilMenu 'cricoor'  
CREATE procedure [dbo].[pXaPerfilMenu2] @codusuario varchar(15)  
as  
--declare @codusuario varchar(15)  
--set @codusuario='curbiza'--'ancruzs'  
----select * from tsgusuarios where codusuario='BME3101991'/ASEAG:promotor  
declare @perfil varchar(15)  
declare @menu varchar(200)  
declare @mnombre varchar(500)  
declare @mobjeto varchar(500)  
  
select @perfil=s.codgrupo  
FROM tSgUsSistema s with(nolock)  
where s.codsistema='MB' and s.activo=1 and s.usuario=@codusuario--'maristav'  
  
--ADM01 = Supervisor Admin.  
if(@perfil='ADM01')  
begin  
 select @menu=COALESCE(@menu+'|','')+opcion,@mnombre=COALESCE(@mnombre+'|','')+nombre,@mobjeto=COALESCE(@mobjeto+'|','')+objetoweb  
 FROM tSgOptions with(nolock)   
 where codsistema='MB' and activo=1  
end  
else  
begin  
 select @menu=COALESCE(@menu+'|','')+opcion  
 FROM tSgAcciones a with(nolock)   
 where codsistema='MB' and acceder=1 and codgrupo=@perfil  
  
 select @mnombre=COALESCE(@mnombre+'|','')+o.nombre  
 FROM tSgAcciones a with(nolock)  
 inner join tSgOptions o with(nolock) on o.opcion=a.opcion and o.codsistema=a.codsistema  
 where a.codsistema='MB' and a.acceder=1 and a.codgrupo=@perfil  
  
 select @mobjeto=COALESCE(@mobjeto+'|','')+o.objetoweb  
 FROM tSgAcciones a with(nolock)  
 inner join tSgOptions o with(nolock) on o.opcion=a.opcion and o.codsistema=a.codsistema  
 where a.codsistema='MB' and a.acceder=1 and a.codgrupo=@perfil  
end  
  
declare @zona varchar(4)  
set @zona=''  
declare @codoficina varchar(4)  
set @codoficina=''  
declare @codusuariosis varchar(15)  
declare @codusuarioorigen varchar(15)  
select @codoficina=codoficina,@codusuariosis=codusuario from tsgusuarios where usuario=@codusuario  
select @codusuarioorigen=codorigen from tcspadronclientes with(NOLOCK) where codusuario=@codusuariosis  
/*  
'ADM01' = Supervisor Admin.  
'DIREC' = Directores  
'GESCO' = Gestores de cobranza  
'AUDIT' = Auditoria  
'CONTA' = Contabilidad  
'MECRE' = Mesa de control  
'GERA'  = Gerentes Agencias  
'GEREG' = Gerentes regionales 
'GESCD' = Gestores de cobranza Despacho
*/  
  
declare @todas char(1)  
set @todas=0  
if(@perfil in('ADM01','DIREC','GESCO','AUDIT', 'CONTA', 'MECRE','ASI01', 'GESCD')) set @todas=1  
  
if(@perfil in ('GEREG','GRREG'))  
 begin  
  select @zona=zona from tclzona  
  where activo=1 and responsable in (select codusuario from tsgusuarios where usuario=@codusuario)  
 end  
if(@perfil='GERA')   
 begin  
  select @codoficina=codoficina from [_CorreosLN]  
  where codusuario in (select codusuario from tsgusuarios where usuario=@codusuario)  
 end  
declare @oficinas varchar(2000)   
declare @nomsucursal varchar(100)   
if(@todas='1')  
 begin  
  if (@perfil in('ADM01','DIREC'))  
  begin  
   SELECT @oficinas=dbo.fduOficinas4('%'),@nomsucursal='Nacional' --CodOficina, NomOficina = '00 Todas las Oficinas'  
  end  
  else  
  begin  
   SELECT @oficinas=dbo.fduOficinas3('%'),@nomsucursal='Nacional' --CodOficina, NomOficina = '00 Todas las Oficinas'  
  end  
 end  
else  
 begin  
  if(@zona = '')  
   begin  
    if(@codoficina<>'')  
     begin  
      SELECT @oficinas = case when CodOficina in(430,431) then codoficina   
         when codoficina='37' then '37' --'37,131'  
         when codoficina='25' then '25' --'25,114'  
       else  
        CodOficina --+ case when cast(CodOficina as int)>=300 then ',' + cast((cast(CodOficina as int)-200) as varchar(4))  else '' end   
       end --CodOficina   
      ,@nomsucursal=dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina --NomOficina  
      FROM tClOficinas with(nolock) WHERE (Tipo in ('Operativo', 'Matriz', 'Servicio')) and codoficina=@codoficina --codoficina<100 and  
      ORDER BY NomOficina  
     end  
   end  
  if(@zona <> '')  
   begin  
    SELECT @oficinas=dbo.fduOficinas3(zona) ,@nomsucursal=Nombre--codoficina, Nombre NomOficina   
    FROM tClZona WHERE zona=@zona      
    ORDER BY Nombre  
   end  
end  
--select @oficinas  
select p.perfil,p.menu,p.nombre,p.objeto,s.ultvermayor vma,s.ultvermenor vme,s.ultverrevision vre,@oficinas oficinas,@nomsucursal nomsucursal  
,@codusuarioorigen codusuarioorigen,@codusuariosis codusuariosis  
from tSgSistemas s  
cross join (  
 select @perfil perfil,@menu menu,@mnombre nombre,@mobjeto objeto  
) p  
where s.codsistema='MO'  
  
  
GO