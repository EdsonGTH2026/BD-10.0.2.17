SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create View [dbo].[vASSISTTransactionCode]
As
SELECT        CodigoTransaccion, Descripcion, CodigoTipo, ReporteExepcion, CodigoGrupo
FROM            tBsiTransaccionCodigo
GO