SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
--DROP PROCEDURE pCsCboOficinasSel
CREATE PROCEDURE [dbo].[pCsCboOficinasSel] @zona 	varchar(5), @oficina	varchar(5), @todas varchar(2) AS
--DECLARE @todas varchar(2)
--DECLARE @zona 	varchar(5)
--DECLARE @oficina	varchar(5)

--SET @todas=0
--SET @zona	= 'Z01'
--SET @oficina	= '8'

if(@todas='1')
	begin
		SELECT     CodOficina, NomOficina
		FROM         (SELECT     CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
		                       FROM          tClOficinas with(nolock)
		                       WHERE   codoficina<100 and   (Tipo in ('Operativo', 'Matriz', 'Servicio'))
		                     --  UNION
		                     --  SELECT   dbo.fduOficinas(zona), Nombre
		                     --  FROM         tClZona with(nolock)
				                   ----WHERE Nombre <> 'INACTIVO'
				                   --where activo=1
		                       --UNION
		                       --SELECT     dbo.fduOficinas('%'), Nombre = 'Todas las Oficinas'
													 ) Datos
		ORDER BY NomOficina
	end
else
	begin
		if(@zona = '')
			begin
				if(@oficina<>'')
					begin
							SELECT CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
				      FROM tClOficinas with(nolock) WHERE codoficina<100 and (Tipo in ('Operativo', 'Matriz', 'Servicio')) and codoficina=@oficina
							ORDER BY NomOficina
					end
			end
		
		if(@zona <> '')
			begin
				SELECT     CodOficina, NomOficina
				FROM         (SELECT     CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
				                       FROM          tClOficinas with(nolock)
				                       WHERE   codoficina<100 and   (Tipo in ('Operativo', 'Matriz', 'Servicio')) and zona = @zona
				            --           UNION
				            --           SELECT      dbo.fduOficinas(zona), Nombre
				            --           FROM         tClZona
															 --WHERE zona=@zona
															 ) Datos
				ORDER BY NomOficina
			end
end
GO