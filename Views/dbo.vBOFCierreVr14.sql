SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vBOFCierreVr14] -- Original (12)
AS
SELECT 'EOF' AS 'INISEG',COUNT(codprestamo) as 'Registro',SUM(convert(int,saldoactual)) as 'SaldoActual',SUM(convert(int,saldovencido)) as 'SaldoVencido','**|' as 'FINSEG'
FROM tBOFCuentaEnvio with(nolock)
GO