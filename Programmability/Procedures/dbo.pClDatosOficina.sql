SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pClDatosOficina] @codoficina varchar(4)
AS
BEGIN
	SET NOCOUNT ON;

SELECT 'Agencia Financiera ' + upper(substring(o.nomoficina,1,1)) + substring(lower(o.nomoficina),2,len(o.nomoficina)-1) descripcion,
o.direccion,ubi.col,ubi.muni,ubi.esta,ubi.codpostal,o.telefono
FROM [10.0.2.14].[Finmas].[dbo].[tClOficinas] o
inner join (SELECT u.codubigeo, u.descubigeo col,m.muni,e.esta,u.codpostal
  FROM [10.0.2.14].[Finmas].[dbo].[tClUbiGeo] u
  inner join (SELECT CodArbolConta, descubigeo muni FROM [10.0.2.14].[Finmas].[dbo].[tClUbiGeo] where codubigeotipo='MUNI') m 
  on m.CodArbolConta = substring(u.CodArbolConta,1,19)
  inner join (SELECT CodArbolConta, descubigeo esta FROM [10.0.2.14].[Finmas].[dbo].[tClUbiGeo] where codubigeotipo='ESTA') e 
  on e.CodArbolConta = substring(u.CodArbolConta,1,13)
) ubi on ubi.codubigeo = o.codubigeo
where codoficina=@codoficina
	
END
GO