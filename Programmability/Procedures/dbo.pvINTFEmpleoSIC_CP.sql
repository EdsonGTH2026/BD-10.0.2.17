SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pvINTFEmpleoSIC_CP]  
as  
truncate table tCsTblEmpleoCP  
insert into tCsTblEmpleoCP 
 
SELECT distinct --c.tipo,  
'' Tipo,  
c.codusuario,  
'' codprestamo,--c.codprestamo,  
isnull(case when upper(us.JurNumLibro)='TRABAJO INDEPENDIENT' then 'TRABAJADOR INDEPENDIENTE'   
   when upper(us.JurNumLibro)='RAZON SOCIAL' then 'TRABAJADOR INDEPENDIENTE'   
   else upper(us.JurNumLibro) end,'TRABAJADOR INDEPENDIENTE') as TipoEmpleo,  
'TRABAJADOR INDEPENDIENTE' as 'Empleador'  
--select count(distinct c.codusuario) x  
FROM finamigoconsolidado.dbo.tCsBuroxTblReInomVr14CP c with(nolock)  
inner join finamigoconsolidado.dbo.tcspadronclientes cl with(nolock) on c.codusuario=cl.codusuario  
left outer join [10.0.2.14].Finmas.dbo.tUsUsuarioSecundarios us on us.codusuario=cl.codorigen  
  
--32,496  
--29,901
GO