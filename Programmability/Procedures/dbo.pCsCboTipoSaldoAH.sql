SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE Procedure [dbo].[pCsCboTipoSaldoAH]

As 
SELECT     TipoSaldo as Codigo, Nombre
FROM         tCsPrTipoSaldo
Where Activo = 1 And Sistema = 'AH'
GO