SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE View [dbo].[vCsClientesServicios]
 As
SELECT DISTINCT 
                     Fecha, LTRIM(RTRIM(ISNULL(CodUsuario, ''))) AS CodUsuario, 
                     SG = CASE WHEN CharIndex('SEGUR', DescripcionTran, 1) > 0		THEN 1 Else 0 End,
                     RE = CASE WHEN CharIndex('REMESA', DescripcionTran, 1) > 0 
									OR CharIndex('DINERO', DescripcionTran, 1) > 0	THEN 1 Else 0 End,
					 NF = CASE WHEN CharIndex('SEGUR', DescripcionTran, 1) = 0 
									AND CharIndex('REMESA', DescripcionTran, 1) = 0 
									AND CharIndex('DINERO', DescripcionTran, 1) = 0 THEN 1 Else 0 End, 	
																
					 1 AS Titular, 1 AS Activo, dbo.fduRellena('0', CodOficina, 3, 'D') + '-' + dbo.fduFechaATexto(Fecha, 'AAAAMMDD') + '-' + dbo.fduRellena('0', TipoTransacNivel3, 3, 'D') + ': ' + DescripcionTran AS Referencia
FROM         dbo.tCsTransaccionDiaria
WHERE   LTRIM(RTRIM(ISNULL(CodUsuario, '')))<> ''  And (CodSistema = 'TC') AND (Extornado = 0) AND (DescripcionTran NOT LIKE '%RETENCION%') AND 
                      (DescripcionTran NOT LIKE '%COMISION%') AND (DescripcionTran NOT LIKE '%INGRESO%')
GO