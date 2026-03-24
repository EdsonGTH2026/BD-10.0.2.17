SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCboOficinasyZonasVs2] @zona varchar(5), @oficina varchar(5), @todas varchar(2) 
AS
--declare @todas varchar(2)
--set @todas='1'
--DECLARE @zona 	varchar(5)
--DECLARE @oficina	varchar(5)
--SET @zona	= 'ZZZ'
--SET @oficina	= '37'

if(@todas='1' or @zona = 'ZZZ')
	begin
		SELECT     CodOficina, NomOficina
		FROM         (SELECT 
							case when CodOficina in(430,431) then codoficina 
								 when codoficina='37' then '37,131'
								 when codoficina='25' then '25,114'
							else
								CodOficina + case when cast(CodOficina as int)>=300 then ',' + cast((cast(CodOficina as int)-200) as varchar(4))  else '' end 
							end codoficina 
							, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
							,tClOficinas.NomOficina nombre
						FROM          tClOficinas with(nolock)
						WHERE   (Tipo in ('Operativo', 'Matriz', 'Servicio'))
							   and (codoficina<=100 or codoficina>=300)
							   and codoficina not in('99','97','98')
		                UNION
		                SELECT   dbo.fduOficinas3(zona), Nombre NomOficina,'ZZZZ ' + Nombre Nombre
		                FROM tClZona with(nolock)
				        where activo=1 and zona<>'ZSC'
		                UNION
		                SELECT     dbo.fduOficinas3('%'), NomOficina = '00 Todas las Oficinas', '00 Todas las Oficinas' Nombre
		) Datos
		ORDER BY Nombre
	end
else
	begin
		if(@zona = '')
			begin
				if(@oficina<>'')
					begin
						SELECT case when CodOficina in(430,431) then codoficina 
								 when codoficina='37' then '37,131'
								 when codoficina='25' then '25,114'
							else
								CodOficina + case when cast(CodOficina as int)>=300 then ',' + cast((cast(CodOficina as int)-200) as varchar(4))  else '' end 
							end CodOficina 
						, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
						FROM tClOficinas with(nolock) WHERE (Tipo in ('Operativo', 'Matriz', 'Servicio')) and codoficina=@oficina --codoficina<100 and
						ORDER BY NomOficina
					end
			end
		if(@zona <> '')
			begin
				SELECT CodOficina ,NomOficina
				FROM (
						SELECT case when CodOficina in(430,431) then codoficina 
								 when codoficina='37' then '37,131'
								 when codoficina='25' then '25,114'
								else
									CodOficina + case when cast(CodOficina as int)>=300 then ',' + cast((cast(CodOficina as int)-200) as varchar(4))  else '' end 
								end codoficina 
						,dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
						FROM          tClOficinas with(nolock)
						WHERE    (Tipo in ('Operativo', 'Matriz', 'Servicio')) and zona = @zona 
						and (codoficina<=100 or codoficina>=300)
						UNION
						SELECT      dbo.fduOficinas3(zona), Nombre
						FROM         tClZona
						WHERE zona=@zona
				) Datos
				ORDER BY NomOficina
			end
end
GO