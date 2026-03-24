SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboTipoSaldoCA]

As 
SELECT     TipoSaldo as Codigo, Nombre
FROM         tCsPrTipoSaldo
Where Activo = 1 And Sistema = 'CA'
GO