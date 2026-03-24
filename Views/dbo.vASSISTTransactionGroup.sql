SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create View [dbo].[vASSISTTransactionGroup]
As
SELECT        CodigoGrupo, Descripcion
FROM            tBsiTransaccionGrupo
GO