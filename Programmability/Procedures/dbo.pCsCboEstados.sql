SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCboEstados] @codoficina varchar(4)
AS
BEGIN
	SET NOCOUNT ON;

  select codestado,descubigeo from tclubigeo
  where codestado in (SELECT u.codestado
  FROM tClOficinas o inner join tclubigeo u on u.codubigeo=o.codubigeo
  where o.codoficina=@codoficina) and codubigeotipo='ESTA'

END
GO