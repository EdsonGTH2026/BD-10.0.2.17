SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
--Exec pCsCaRptPrestamosPrimerCiclo '20110501', '20110609', '17', '>=1'
CREATE PROCEDURE [dbo].[pCsCaRptPrestamosPrimerCiclo] 

	@FecIni smalldatetime, 
	@FecFin smalldatetime, 
	@CodOficina varchar(200), 
	@Secuencia Varchar(10)

AS

Declare @CUbicacion		Varchar(500)
Declare @OtroDato		Varchar(100)

Exec pGnlCalculaParametros 1, @CodOficina, 	@CUbicacion 	Out, 	@CodOficina 	Out,  @OtroDato Out

Declare @csql varchar(8000)


SET @csql = 'SELECT  a.CodPrestamo, cl.NombreCompleto AS Cliente, tCsCarteraGrupos.NombreGrupo, tCaProducto.NombreProdCorto,  '
SET @csql = @csql +  'ad.MontoDesembolso, a.NroCuotas, ad.CodUsuario, apd.Desembolso, tCsPadronAsesores.NomAsesor, tcloficinas.nomoficina, apd.EstadoCalculado, apd.SecuenciaCliente '
SET @csql = @csql +  ' FROM  tCsCartera a INNER JOIN tCsCarteraDet ad ON a.Fecha = ad.Fecha AND '
SET @csql = @csql +  '  a.CodPrestamo = ad.CodPrestamo INNER JOIN tCsPadronCarteraDet apd ON ad.CodPrestamo = apd.CodPrestamo AND ad.CodUsuario = '
SET @csql = @csql +  ' apd.CodUsuario AND ad.Fecha = apd.FechaCorte LEFT OUTER JOIN tCsPadronAsesores ON a.CodAsesor = tCsPadronAsesores.CodAsesor '
SET @csql = @csql +  ' AND a.CodOficina = tCsPadronAsesores.CodOficina LEFT OUTER JOIN tCaProducto ON a.CodProducto  '
SET @csql = @csql +  ' = tCaProducto.CodProducto LEFT OUTER JOIN tCsPadronClientes cl ON ad.CodUsuario = cl.CodUsuario LEFT OUTER JOIN '
SET @csql = @csql +  ' tCsCarteraGrupos ON a.CodOficina = tCsCarteraGrupos.CodOficina AND a.CodGrupo = tCsCarteraGrupos.CodGrupo '
SET @csql = @csql +  ' INNER JOIN tcloficinas on a.codoficina = tcloficinas.codoficina '
SET @csql = @csql +  ' WHERE  (a.CodOficina in ('+ @CUbicacion +')) AND (apd.Desembolso >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') AND (apd.Desembolso <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''') AND  '
SET @csql = @csql +  ' (apd.SecuenciaCliente ' + @Secuencia + ' ) '
SET @csql = @csql +  ''


Print @csql
Exec (@csql)
GO