SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsNumCiclosPorUsuario]( @CodUsuario varchar(20), @CodProducto varchar(3))
as
BEGIN
/*
	--select isnull(max(SecuenciaCliente),0) as NumCiclos 
	select (isnull(max(SecuenciaCliente),0) + 1) as NumCiclos 
	from tCsPadronCarteraDet where CodUsuario = @CodUsuario --'VAM761015F9680'
*/

	select (isnull(max(pcd.SecuenciaCliente),0) + 1) as NumCiclos 
	from tCsPadronCarteraDet as pcd 
	inner join tCsPadronclientes as pc on pc.CodUsuario = pcd.CodUsuario
	where 
	pc.CodUsuario = @CodUsuario or pc.CodOrigen = @CodUsuario 
	--pc.CodUsuario = 'AGJ0806941' or pc.CodOrigen = 'AGJ0806941' 

END
GO