SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaPerfilMenu] @codusuario varchar(15)  
as  
--declare @codusuario varchar(15)  
--set @codusuario='curbiza'--'ancruzs'--'josem'--'abotellos'--
----select * from tsgusuarios where codusuario='BME3101991'/ASEAG:promotor  
declare @perfil varchar(15)
declare @nomperfil varchar(100)
declare @menu varchar(2000)
declare @mnombre varchar(4000)  
declare @mobjeto varchar(4000)  

declare @menu_pare varchar(2000)
declare @id_pare varchar(2000)

select @perfil=s.codgrupo,@nomperfil=grupo
FROM tSgUsSistema s with(nolock)
inner join tsggrupos g with(nolock) on s.codgrupo=g.codgrupo
where s.codsistema='MB' and s.activo=1 and s.usuario=@codusuario--'maristav'  

--ADM01 = Supervisor Admin.  
if(@perfil='ADM01')  
begin  
 select @menu=COALESCE(@menu+'|','')+s.opcion,@mnombre=COALESCE(@mnombre+'|','')+s.nombre,@mobjeto=COALESCE(@mobjeto+'|','')+s.objetoweb
 ,@menu_pare=COALESCE(@menu_pare+'|','')+p.padre
 ,@id_pare=COALESCE(@id_pare+'|','')+s.opcionpare
 FROM tSgOptions s with(nolock)
 inner join (
	select opcion,nombre padre
	FROM tSgOptions with(nolock)
	where codsistema='MB' and activo=1 and esterminal=0 and activo=1
 ) p on p.opcion=s.opcionpare
 where codsistema='MB' and activo=1 and esterminal=1 and activo=1
 order by s.opcionpare
end  
else  
begin  
 select @menu=COALESCE(@menu+'|','')+a.opcion,@menu_pare=COALESCE(@menu_pare+'|','')+p.padre
 ,@id_pare=COALESCE(@id_pare+'|','')+opcionpare
 ,@mnombre=COALESCE(@mnombre+'|','')+o.nombre
 ,@mobjeto=COALESCE(@mobjeto+'|','')+o.objetoweb  
 FROM tSgAcciones a with(nolock)   
 inner join tSgOptions o with(nolock) on o.opcion=a.opcion and o.codsistema=a.codsistema and o.esterminal=1 and o.activo=1
 inner join (
	select opcion,nombre padre
	FROM tSgOptions with(nolock)   
	where codsistema='MB' and activo=1 and esterminal=0 and activo=1
 ) p on p.opcion=o.opcionpare
 where a.codsistema='MB' and a.acceder=1 and a.codgrupo=@perfil  and o.activo=1
 order by o.opcionpare
 
 --select @mnombre=COALESCE(@mnombre+'|','')+o.nombre  
 --FROM tSgAcciones a with(nolock)  
 --inner join tSgOptions o with(nolock) on o.opcion=a.opcion and o.codsistema=a.codsistema and o.esterminal=1 and o.activo=1  
 --where a.codsistema='MB' and a.acceder=1 and a.codgrupo=@perfil and o.activo=1
   
 --select @mobjeto=COALESCE(@mobjeto+'|','')+o.objetoweb  
 --FROM tSgAcciones a with(nolock)  
 --inner join tSgOptions o with(nolock) on o.opcion=a.opcion and o.codsistema=a.codsistema  and o.esterminal=1 and o.activo=1
 --where a.codsistema='MB' and a.acceder=1 and a.codgrupo=@perfil and o.activo=1
end  
  
declare @zona varchar(4)  
set @zona=''
declare @codmicro varchar(1)
set @zona=''
declare @codoficina varchar(4)  
set @codoficina=''  
declare @codusuariosis varchar(15)  
declare @codusuarioorigen varchar(15)  
declare @nombreusuario varchar(100)
select @codoficina=codoficina,@codusuariosis=codusuario from tsgusuarios with(nolock) where usuario=@codusuario  
select @codusuarioorigen=codorigen,@nombreusuario=nombres+' '+paterno from tcspadronclientes with(NOLOCK) where codusuario=@codusuariosis  
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
'MICRO' = Gerentes Microregionales
*/  
  
declare @todas char(1)  
set @todas=0  
if(@perfil in('ADM01','DIREC','GESCO','AUDIT', 'CONTA', 'MECRE','ASI01', 'GESCD')) set @todas=1  
  
if(@perfil in ('GEREG','GRREG'))  -->Gerentes regionales
 begin  
  select @zona=zona from tclzona  
  where activo=1 and responsable in (select codusuario from tsgusuarios with(nolock) where usuario=@codusuario)  
 end
if(@perfil in ('MICRO'))  -->Gerentes micro-regionales  
 begin  
  select @codmicro=cast(codmicro as varchar(2)) from tClZonaMicro  
  where activo=1 and responsable in (select codusuario from tsgusuarios with(nolock) where usuario=@codusuario)  
 end
if(@perfil='GERA')   
 begin  
  select @codoficina=codoficina from [_CorreosLN]  
  where codusuario in (select codusuario from tsgusuarios with(nolock) where usuario=@codusuario)  
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
		--Micro regional
		if(@codmicro<>'')  
			begin
				SELECT @oficinas=dbo.fduOficinasMicro(codmicro) ,@nomsucursal=Nombremicro--codoficina, Nombre NomOficina   
				FROM tClZonamicro with(nolock) WHERE codmicro=@codmicro
				ORDER BY Nombremicro
			end
		else
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
   end
  else
   begin  
    SELECT @oficinas=dbo.fduOficinas3(zona) ,@nomsucursal=Nombre--codoficina, Nombre NomOficina   
    FROM tClZona with(nolock) WHERE zona=@zona      
    ORDER BY Nombre  
   end  
end

declare @tmp varchar(2000)
set @tmp = replace(@id_pare,'|',',')

declare @orden table(opcion varchar(20), orden int identity(1,1))
insert into @orden (opcion)
select opcion
from tSgOptions with(nolock)
where codsistema='MB' and opcion in (select distinct codigo from dbo.fduTablaValores(@tmp))
order by teclaacceso

declare @idorden varchar(1000)
select @idorden=COALESCE(@idorden+'|','')+x
from (
	select opcion+':'+cast(orden as varchar(3)) x from @orden
) a

--GDF-20260105 Begin (Devuelve el perfil de gerente GERA para evitar modificar la app)
IF LTRIM(RTRIM(@perfil)) = 'GERA2'
BEGIN
	SET @perfil = 'GERA'
END
--GDF-20260105 End

select p.perfil,p.menu,p.nombre,p.objeto,s.ultvermayor vma,s.ultvermenor vme,s.ultverrevision vre,@oficinas oficinas,@nomsucursal nomsucursal  
,@codusuarioorigen codusuarioorigen,@codusuariosis codusuariosis,p.menu_pare,p.id_pare,p.idorden,@nomperfil nomperfil,@nombreusuario nombreusuario
from tSgSistemas s with(nolock)
cross join (  
 select @perfil perfil,@menu menu,@mnombre nombre,@mobjeto objeto,@menu_pare menu_pare,@id_pare id_pare, @idorden idorden
) p  
where s.codsistema='MO'
GO