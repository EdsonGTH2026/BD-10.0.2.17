SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create view [dbo].[vINTFEmpleo]
as
SELECT c.tipo,c.codusuario,c.codprestamo,us.JurNumLibro,us.JurGruposEcoVin
FROM tCsBuroxTblReINom c with(nolock)
inner join tcspadronclientes cl with(nolock) on c.codusuario=cl.codusuario
left outer join [10.0.2.14].Finmas.dbo.tUsUsuarioSecundarios us on us.codusuario=cl.codorigen


GO