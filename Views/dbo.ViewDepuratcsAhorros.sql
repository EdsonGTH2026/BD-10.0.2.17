SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[ViewDepuratcsAhorros] AS
SELECT A.[CodCuenta],A.[Renovado],MAX(FECHA) Fecha,COUNT(*) Registros FROM  [tCsAhorros] A (NOLOCK) 
INNER JOIN  (SELECT TOP 5000 [CodCuenta] FROM [tCsAhorros] (NOLOCK) 
WHERE IDEstadoCta='CI' GROUP BY [CodCuenta]) AH ON A.[CodCuenta]=AH.[CodCuenta]
--WHERE A.IDEstadoCta='CI'
GROUP BY A.[CodCuenta],A.[Renovado]
GO