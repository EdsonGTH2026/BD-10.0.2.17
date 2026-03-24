SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE procedure [dbo].[pCsFrptMovtoBoveda]

@Fecha smalldatetime   
as


SELECT     FechaPro, CodOficina, CodMoneda, SaldoIniSis, SaldoFinSis, SaldoFinUs
FROM         tTcBovedaSaldos

WHERE     (FechaPro = @Fecha)
GO