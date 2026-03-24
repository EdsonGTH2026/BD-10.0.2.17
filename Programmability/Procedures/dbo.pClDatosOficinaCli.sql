SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pClDatosOficinaCli] @codusuario varchar(20)
AS
BEGIN
	
	SET NOCOUNT ON;

select 'Direccion cliente' descripcion,direccion + ' ' + numexterno + ' ' + numinterno direccion,
ubi.col,ubi.muni,ubi.esta,u.codpostal,'' telefono
from  [10.0.2.14].[Finmas].[dbo].tUsUsuarioDireccion u
inner join (SELECT u.codubigeo, u.descubigeo col,m.muni,e.esta,u.codpostal
  FROM [10.0.2.14].[Finmas].[dbo].[tClUbiGeo] u
  inner join (SELECT CodArbolConta, descubigeo muni FROM [10.0.2.14].[Finmas].[dbo].[tClUbiGeo] where codubigeotipo='MUNI') m 
  on m.CodArbolConta = substring(u.CodArbolConta,1,19)
  inner join (SELECT CodArbolConta, descubigeo esta FROM [10.0.2.14].[Finmas].[dbo].[tClUbiGeo] where codubigeotipo='ESTA') e 
  on e.CodArbolConta = substring(u.CodArbolConta,1,13)
) ubi on ubi.codubigeo = u.codubigeo
where codusuario=@codusuario and FamiliarNegocio='N'

END
GO