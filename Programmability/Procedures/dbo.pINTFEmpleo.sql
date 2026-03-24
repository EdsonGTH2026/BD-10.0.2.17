SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.pINTFEmpleo    Script Date: 08/03/2023 09:06:02 pm ******/
CREATE procedure [dbo].[pINTFEmpleo]
as
truncate table tCsTblEmpleo

insert into tCsTblEmpleo
SELECT distinct --c.tipo,
'' Tipo,
c.codusuario,
'' codprestamo,--c.codprestamo,
isnull(case when upper(us.JurNumLibro)='TRABAJO INDEPENDIENT' then 'TRABAJADOR INDEPENDIENTE' 
			when upper(us.JurNumLibro)='RAZON SOCIAL' then 'TRABAJADOR INDEPENDIENTE' 
			else upper(us.JurNumLibro) end,'TRABAJADOR INDEPENDIENTE') as TipoEmpleo,
'TRABAJADOR INDEPENDIENTE' as 'Empleador'
--into tCsTblEmpleo
--select count(distinct c.codusuario) x
FROM finamigoconsolidado.dbo.tCsBuroxTblReInomVr14 c with(nolock)
inner join finamigoconsolidado.dbo.tcspadronclientes cl with(nolock) on c.codusuario=cl.codusuario
left outer join [10.0.2.14].Finmas.dbo.tUsUsuarioSecundarios us on us.codusuario=cl.codorigen

--32,496
--29,901
GO