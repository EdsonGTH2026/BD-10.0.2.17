SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--EXEC pCAhMuestraSeguros '20100101','20111030','1,2,3,4,5,6,7,8,9,10,20'
CREATE PROCEDURE [dbo].[pCAhMuestraSeguros]
	@FIni		SMALLDATETIME,
	@FFin		SMALLDATETIME,
	@Oficinas	Varchar(1000)
AS BEGIN
	--select @FIni ='20101123',
	--@FFin= '20101123',
	--@Oficinas= CHAR(39) + '10' + CHAR(39) + ',' +CHAR(39) + '2' + CHAR(39)  

DECLARE @Query NVARCHAR(4000),
		@FIniC VARCHAR(10),
		@FFinC VARCHAR(10)

	SELECT @FIniC = dbo.fduFechaATexto(@FIni,'AAAAMMDD'), @FFinC = dbo.fduFechaATexto(@FFin,'AAAAMMDD')
	
	SET @Query = 'SELECT Oficina=CAST(S.CodOficina AS INT), O.NomOficina,'
	SET @Query = @Query + 'OficDesc=S.CodOficina + CHAR(32) +O.NomOficina,S.Fecha,'
	SET @Query = @Query + 'S.NumPoliza, Piliza_ACE=S.IdAce,'
	SET @Query = @Query + 'S.Fecha, Producto=P.Descripción,'
	SET @Query = @Query + 'P.SumaAsegurada, S.MontoSeguro,'
	SET @Query = @Query + 'S.MontoPrima, NombreCliente=S.NombreCompleto,'
	SET @Query = @Query + 'Nombre_Asegurado=S.NombreCliente '
	SET @Query = @Query + 'FROM TcsSeguros S JOIN TcsSegurosProd P ON S.CodAseguradora=P.CodAseguradora '
	SET @Query = @Query + 'AND S.CodProdSeguro=P.CodProdSeguro LEFT JOIN tClOficinas O ON S.CodOficina=O.CodOficina '
	SET @Query = @Query + 'WHERE S.Estado=2 AND S.Incorporado=1 AND S.CodOficina in ('
	SET @Query = @Query + @Oficinas + ') AND S.Fecha BETWEEN ' + CHAR(39) + @FIniC + CHAR(39) + ' AND ' + CHAR(39) + @FFinC + CHAR(39) 
	SET @Query = @Query + ' ORDER BY CAST(S.CodOficina AS INT), S.NumPoliza'

	EXEC (@Query)
	
END




--sp_helptext pCAhMuestraSeguros '20100101','20111123','1,2,3,4,5,6,10'


--select * from dbo.tClOficinas
GO