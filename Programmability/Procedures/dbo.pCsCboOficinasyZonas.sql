SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure [pCsCboOficinasyZonas]
CREATE PROCEDURE [dbo].[pCsCboOficinasyZonas] @zona 	varchar(5), @oficina	varchar(5), @todas varchar(2) AS
--declare @todas varchar(2)
--set @todas='1'
--DECLARE @zona 	varchar(5)
--DECLARE @oficina	varchar(5)
--SET @zona	= 'Z01'
--SET @oficina	= '8'

if(@todas='1')
	begin
		SELECT     CodOficina, NomOficina
		FROM         (SELECT     CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
		                       FROM          tClOficinas with(nolock)
		                       WHERE   (Tipo in ('Operativo', 'Matriz', 'Servicio','Cerrada'))--codoficina<100 and 
							   and (codoficina<=100 or codoficina>=300)
		                       UNION
		                       SELECT   dbo.fduOficinas(zona), Nombre
		                       FROM         tClZona with(nolock)
				                   --WHERE Nombre <> 'INACTIVO'
				                   where activo=1 and zona<>'ZRA'
		                       UNION
		                       SELECT     dbo.fduOficinas('%'), Nombre = 'Todas las Oficinas') Datos
		ORDER BY NomOficina
	end
else
	begin
		if(@zona = '')
			begin
				if(@oficina<>'')
					begin
							SELECT CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
				      FROM tClOficinas with(nolock) WHERE (Tipo in ('Operativo', 'Matriz', 'Servicio','Cerrada')) and codoficina=@oficina --codoficina<100 and
							ORDER BY NomOficina
					end
			end
		if(@zona <> '')
			begin
				SELECT     CodOficina, NomOficina
				FROM         (SELECT     CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
				                       FROM          tClOficinas with(nolock)
				                       WHERE    (Tipo in ('Operativo', 'Matriz', 'Servicio','Cerrada')) and zona = @zona --codoficina<100 and  
				                       UNION
				                       SELECT      dbo.fduOficinas(zona), Nombre
				                       FROM         tClZona
															 WHERE zona=@zona) Datos
				ORDER BY NomOficina
			end
end

GO