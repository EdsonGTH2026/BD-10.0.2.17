SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsGridClientesxModulo] @Modulo varchar(2), @NombreCompleto varchar(100), @Codoficina varchar(50), @NroDiasIni int = 0, @NroDiasFin int = 0, @TipoFiltro int AS
SET NOCOUNT ON

--SET @Modulo = 'CA'
--SET @NombreCompleto = '002-115-06-03-00142'
--SET @Codoficina = '2,3,4'
--SET @NroDiasIni = 0
--SET @NroDiasFin = 0
--SET @TipoFiltro = 2

DECLARE @csql varchar(500)

SET @csql = 'SELECT  DISTINCT  TOP 10 a.CodUsuario, a.NombreCompleto, a.ClienteDe, a.Activo, o.nomoficina '
SET @csql = @csql + 'FROM  tCsPadronClientes a ' 
--JOIN'S
IF @Modulo = 'CA' 
BEGIN
	SET @csql = @csql + 'INNER JOIN tCsPadronCarteraDet b ON a.CodUsuario = b.CodUsuario INNER JOIN ' 
	SET @csql = @csql + 'tCsCartera c ON b.FechaCorte = c.Fecha AND b.CodPrestamo = c.CodPrestamo ' 
END

IF @Modulo = 'AH'
BEGIN
	SET @csql = @csql + 'INNER JOIN tCsPadronAhorros ah ON a.CodUsuario = ah.CodUsuario '
END

SET @csql = @csql + ' inner join tClOficinas o on a.codoficina= o.codoficina ' 


--WHERE'S
SET @csql = @csql + 'WHERE ' 

IF (@Modulo = 'SM') 
BEGIN
	SET @csql = @csql + ' (a.NombreCompleto LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@Codoficina<>'') SET @csql = @csql + ' AND (a.CodOficina IN ('+@Codoficina+')) ' 	
END

IF @Modulo = 'CA'
BEGIN

	IF (@TipoFiltro=0) SET @csql = @csql + ' (a.NombreCompleto LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@TipoFiltro=1) SET @csql = @csql + ' (a.codusuario LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@TipoFiltro=2) SET @csql = @csql + ' (c.codprestamo LIKE '''+@NombreCompleto+'%'')  ' 

	IF (@NroDiasIni<>0 AND @NroDiasFin<>0) 
	BEGIN
		SET @csql = @csql + ' AND (c.NroDiasAtraso >= '+cast( @NroDiasIni as varchar(4) ) +')  ' 
		SET @csql = @csql + ' AND (c.NroDiasAtraso < '+cast( @NroDiasFin as varchar(4) ) +')  ' 
	END
	IF (@Codoficina<>'') SET @csql = @csql + ' AND (c.CodOficina IN ('+@Codoficina+')) ' 
END

IF @Modulo = 'AH'
BEGIN

	IF (@TipoFiltro=0) SET @csql = @csql + ' (a.NombreCompleto LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@TipoFiltro=1) SET @csql = @csql + ' (a.codusuario LIKE '''+@NombreCompleto+'%'')  ' 
	IF (@TipoFiltro=2) SET @csql = @csql + ' (ah.codcuenta LIKE '''+@NombreCompleto+'%'')  ' 

	IF (@Codoficina<>'') SET @csql = @csql + ' AND (ah.CodOficina IN ('+@Codoficina+')) ' 
END

print @csql
exec (@csql)

SET NOCOUNT OFF
GO