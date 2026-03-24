SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  View dbo.vINTFEmpleoVr14    Script Date: 08/03/2023 09:06:02 pm ******/

CREATE view [dbo].[vINTFEmpleoVr14]
as
--00:00:07
SELECT c.tipo,
c.codusuario,
c.codprestamo,
isnull(us.JurNumLibro,'TRABAJADOR INDEPENDIENTE') as TipoEmpleo,
--us.JurGruposEcoVin as EmpleadorX,
/*
(
case 
when len(isnull(us.JurGruposEcoVin,'')) = 0 then 'TRABAJADOR INDEPENDIENTE'
else isnull(us.JurGruposEcoVin, 'TRABAJADOR INDEPENDIENTE')
end
) as 'Empleador'
*/
'TRABAJADOR INDEPENDIENTE' as 'Empleador'
FROM finamigoconsolidado.dbo.tCsBuroxTblReInomVr14 c with(nolock)
inner join finamigoconsolidado.dbo.tcspadronclientes cl with(nolock) on c.codusuario=cl.codusuario
left outer join [10.0.2.14].Finmas.dbo.tUsUsuarioSecundarios us on us.codusuario=cl.codorigen



GO