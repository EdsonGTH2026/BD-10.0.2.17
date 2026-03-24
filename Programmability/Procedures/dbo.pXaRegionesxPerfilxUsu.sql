SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pXaRegionesxPerfilxUsu] @usuario varchar(15),@perfil varchar(10)
as
--OSC, 21-09-2018

--declare @usuario varchar(15)
--Declare @perfil varchar(10)
--set @perfil='ADM01'
--set @usuario='curbiza'

declare @zona varchar(4)
set @zona=''
declare @codoficina varchar(4)
set @codoficina=''

select @codoficina=codoficina from tsgusuarios where usuario=@usuario

declare @todas char(1)
set @todas=0
if(@perfil in('ADM01','DIREC','GESCO','AUDIT', 'CONTA', 'ASI01')) set @todas=1

if @todas=1 
	begin
		--regresa todas las regiones
		select Zona, Nombre, Responsable from tclzona where Activo = 1 and Zona <> 'ZSC'
		union
		select 'ZZZ' as Zona, 'TODOS' as Nombre, '' as Responsable
		order by Zona desc
	end
else
	begin
		--if(@perfil='GEREG') 
		if(@perfil in ('GEREG','GRREG'))  --OSC: 070818, se modifico para que soportara el perfil de FINMAS
			begin
				select --@zona=zona 
				Zona, Nombre, Responsable
				from tclzona
				where activo=1 and responsable in (select codusuario from tsgusuarios where usuario=@usuario)
			end
		
		if(@perfil='GERA') 
			begin
				select --@codoficina=codoficina 
				'' as Zona, Nombre, codusuario as Responsable
				from [_CorreosLN]
				where codusuario in (select codusuario from tsgusuarios where usuario=@usuario)
			end
	end



GO