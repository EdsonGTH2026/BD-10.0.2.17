SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSucursalesSolicitudUsu] @usuario varchar(20)
as
set nocount on

----<<<<< COMENTAR PRUEBA
--declare @usuario varchar(20)
--set @usuario='jlopezb'
---->>>>> COMENTAR PRUEBA

create table #s (codigo varchar(3),sucursal varchar(250),nro int)
insert into #s exec pXaSucursalesSolicitud 

declare @sucursales varchar(1000)
--if (@usuario in ('abotellos','rbanosb','fmartineze','jlopezb','cchablec'))
--OSC, 26-09-18: se cambio para considerar todos los Gerentes Regionales
if exists(select Usuario from tSgUsSistema where CodSistema = 'MB' and CodGrupo = 'GEREG' and Usuario = @usuario )
begin
	select @sucursales=dbo.fduOfixZona(z.zona) --o
	FROM tclzona z with(nolock) inner join tsgusuarios u with(nolock) on u.codusuario=z.responsable
	where z.activo=1 and u.usuario=@usuario

	select * from #s
	where cast(codigo as int) in(select codigo from dbo.fduTablaValores(@sucursales))
end
else 
begin
	--if (@usuario in ('maristav','grazoc','curbiza','csanchezc','sabascal'))
	--OSC, 26-09-18: se cambio para considerar todos los Directivos y Admin Sistemas
	--OSC, 10-10-18: se cambio para adicionalmente considerar al grupo de Mesa
	--if exists(select * from tSgUsSistema where CodSistema = 'MB' and CodGrupo in ('ADM01','DIREC') and Usuario = @usuario)
	if exists(select * from tSgUsSistema where CodSistema = 'MB' and CodGrupo in ('ADM01','DIREC', 'MECRE') and Usuario = @usuario)
		begin
			select * from #s
		end
	else
		begin
			if((select count(codoficina) from [_CorreosLN]
				where codusuario in (select codusuario from tsgusuarios where usuario=@usuario))>0)
				begin
					select * from #s
					where cast(codigo as int) in(
					select c.codoficina
					from [_CorreosLN] c 
					where c.codusuario in (select codusuario from tsgusuarios where usuario=@usuario)
					)
				end
			else
			begin
				select '000' codigo,'Sin permiso para consultar' sucursal,0 nro
				union
				select '001' codigo,'Consultar su perfil con caja general' sucursal,0 nro
			end
		end
end

drop table #s
GO