SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaQAPerfilSucursales 'CSA1010881'
CREATE procedure [dbo].[pXaQAPerfilSucursales] @codusuario varchar(15)
as
--declare @codusuario varchar(15)
--set @codusuario='98UMC1809791'--'curbiza'--'ancruzs'
----select * from tsgusuarios where usuario like '%ancruzs%' codusuario='BME3101991'/ASEAG:promotor

declare @codusuarioorigen varchar(15)
set @codusuarioorigen=@codusuario
declare @usuario varchar(25)

select @codusuario=codusuario from tcspadronclientes with(nolock) where codorigen=@codusuarioorigen
select @usuario=usuario from tsgusuarios with(nolock) where codusuario=@codusuario and usuario not in('supercnbv','admin')

declare @perfil varchar(15)
select @perfil=s.codgrupo
FROM tSgUsSistema s with(nolock)
inner join tsgusuarios u with(nolock) on s.usuario=u.usuario
where s.codsistema='MB' and s.activo=1 and u.codusuario=@codusuario--s.usuario=@codusuario--'maristav'

declare @zona varchar(4)
set @zona=''
declare @codoficina varchar(4)
set @codoficina=''

/*
'ADM01' = Supervisor Admin.
'DIREC' = Directores
'GESCO' = Gestores de cobranza
'AUDIT' = Auditoria
'CONTA' = Contabilidad
'MECRE' = Mesa de control
'GERA'  = Gerentes Agencias
'GEREG' = Gerentes regionales 
*/

declare @todas char(1)
set @todas=0
if(@perfil in('ADM01','DIREC','GESCO','AUDIT', 'CONTA', 'MECRE','ASI01')) set @todas=1

if(@perfil in ('GEREG','GRREG'))
	begin
		select @zona=zona from tclzona
		where activo=1 and responsable=@codusuario
	end
if(@perfil='GERA') 
	begin
		select @codoficina=codoficina from [_CorreosLN]
		where codusuario=@codusuario
	end
if (@perfil in('ASEAG','COOR2'))
	begin
		select @codoficina=codoficinanom from tcsempleados with(nolock)
		where codusuario=@codusuario
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
								 when codoficina='37' then '37,131'
								 when codoficina='25' then '25,114'
							else
								CodOficina + case when cast(CodOficina as int)>=300 then ',' + cast((cast(CodOficina as int)-200) as varchar(4))  else '' end 
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

select @oficinas sucursales,@codusuario codusuario, @usuario usuario
GO