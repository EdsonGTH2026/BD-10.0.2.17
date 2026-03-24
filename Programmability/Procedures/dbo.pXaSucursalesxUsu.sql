SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSucursalesxUsu] @usuario varchar(15)
as
--declare @usuario varchar(15)
--set @usuario='abotellos'--'curbiza'--'ereyesg'--

Declare @perfil varchar(10)
declare @codoficina varchar(4)
set @codoficina=''
declare @todas char(1)
set @todas=0
select @codoficina=codoficina,@todas=todasoficinas from tsgusuarios where usuario=@usuario
select @perfil=codgrupo from tsgussistema where usuario=@usuario and codsistema='DC'

--if(@perfil in('ADM01','DIREC','GESCO','AUDIT', 'CONTA', 'ASI01')) set @todas=1

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
	end



GO