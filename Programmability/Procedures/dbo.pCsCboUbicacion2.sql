SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsCboUbicacion2]
@Usuario Varchar(50)
As 

--Set @Usuario = 'kvalera'

Declare @Todas Bit 

Select @Todas = TodasOficinas from tSgUsuarios 
Where Usuario  = @Usuario

If @Todas = 1
Begin
	SELECT     CodOficina, NomOficina
	FROM         (SELECT     CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
						   FROM          tClOficinas
						   WHERE  codoficina<100 and    (Tipo in ('Operativo', 'Matriz', 'Servicio'))
						   UNION
						   SELECT     Zona, Nombre
						   FROM         tClZona
						   where zona<>'ZRA'
						   UNION
						   SELECT     Codigo = 'ZZZ', Nombre = 'Todas las Oficinas') Datos
	ORDER BY dbo.fduRellena('0', CodOficina, 3, 'D')
End
If @Todas = 0
Begin 
	SELECT     CodOficina, NomOficina
	FROM         (SELECT        tClOficinas.CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(tClOficinas.CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
					FROM            tSgUsuarios INNER JOIN
											 tClOficinas ON tSgUsuarios.CodOficina = tClOficinas.CodOficina
					WHERE        (tSgUsuarios.Usuario = @Usuario)
					UNION
					SELECT        tClOficinas.CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(tClOficinas.CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
					FROM            tSgUsuarios INNER JOIN
											 tClZona ON tSgUsuarios.CodUsuario = tClZona.Responsable INNER JOIN
											 tClOficinas ON tClZona.Zona = tClOficinas.Zona
					WHERE        (tSgUsuarios.Usuario = @Usuario)
					UNION
					SELECT        tClZona.Zona, tClZona.Nombre
					FROM            tSgUsuarios INNER JOIN
											 tClZona ON tSgUsuarios.CodUsuario = tClZona.Responsable
					WHERE        (tSgUsuarios.Usuario = @Usuario)
					) Datos
	ORDER BY dbo.fduRellena('0', CodOficina, 3, 'D')
End

GO