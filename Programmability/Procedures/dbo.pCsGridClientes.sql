SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCsGridClientes] @Modulo varchar(2), @NombreCompleto varchar(100), @Codoficina varchar(2000), @TipoFiltro int
AS
BEGIN
SET NOCOUNT ON
--SET @Modulo = 'CA'
--SET @NombreCompleto = '002-115-06-03-00142'
--SET @Codoficina = '2,3,4'
--SET @TipoFiltro = 2

DECLARE @csql varchar(5000)

SET @csql = 'SELECT  DISTINCT  TOP 10 a.CodUsuario, a.NombreCompleto, a.ClienteDe, a.Activo, o.nomoficina '
SET @csql = @csql + 'FROM  tCsPadronClientes a ' 
--JOIN'S
IF @Modulo = 'CA' 
BEGIN
	SET @csql = @csql + 'INNER JOIN tCsPadronCarteraDet b ON a.CodUsuario = b.CodUsuario INNER JOIN ' 
	SET @csql = @csql + 'tCsCartera c ON b.FechaCorte = c.Fecha AND b.CodPrestamo = c.CodPrestamo ' 
	IF (@TipoFiltro=3) SET @csql = @csql + 'left outer join tCsCarteraGrupos g on g.codoficina=c.codoficina and g.codgrupo=c.codgrupo '
END
IF @Modulo = 'AH'
BEGIN
	SET @csql = @csql + 'INNER JOIN tCsPadronAhorros ah ON a.CodUsuario = ah.CodUsuario '
END
SET @csql = @csql + ' inner join tClOficinas o on a.codoficina= o.codoficina ' 


--WHERE'S
SET @csql = @csql + 'WHERE ' 

IF (@Modulo = 'TO') 
BEGIN
	SET @csql = @csql + ' (a.NombreCompleto LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@Codoficina<>'') SET @csql = @csql + ' AND (a.CodOficina IN ('+@Codoficina+')) ' 	
END

IF @Modulo = 'CA'
BEGIN
	IF (@TipoFiltro=0) SET @csql = @csql + ' (a.NombreCompleto LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@TipoFiltro=1) SET @csql = @csql + ' (a.codusuario LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@TipoFiltro=2) SET @csql = @csql + ' (c.codprestamo LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@TipoFiltro=3) SET @csql = @csql + ' (g.NombreGrupo LIKE '''+@NombreCompleto+'%'')  ' 
	
	IF (@Codoficina<>'') SET @csql = @csql + ' AND (c.CodOficina IN ('+@Codoficina+')) ' 
END

IF @Modulo = 'AH'
BEGIN
	IF (@TipoFiltro=0) SET @csql = @csql + ' (a.NombreCompleto LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@TipoFiltro=1) SET @csql = @csql + ' (a.codusuario LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@TipoFiltro=2) SET @csql = @csql + ' (ah.codcuenta LIKE '''+@NombreCompleto+'%'')  ' 
  IF (@TipoFiltro=3) SET @csql = @csql + ' (a.NombreCompleto LIKE '''+@NombreCompleto+'%'')  ' 

	IF (@Codoficina<>'') SET @csql = @csql + ' AND (ah.CodOficina IN ('+@Codoficina+')) ' 
END

--print @csql
exec (@csql)

END
GO