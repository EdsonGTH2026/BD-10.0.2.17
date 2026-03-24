SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

Create Procedure [dbo].[pSATResultado]
@Estado Varchar(1)
As
Declare @Fecha SmallDateTime
Select  @Fecha = FechaConsolidacion From vCsFechaConsolidacion
SELECT      Fecha = @Fecha, tSATExentasPadron.Estado, tSATEstado.Nombre, tSATExentasPadron.RFC, tSATExentasPadron.CodUsuario, tCsPadronClientes.NombreCompleto, 
              dbo.fduCuentasActuales('AH', tSATExentasPadron.CodUsuario) AS Ahorros, dbo.fduCuentasActuales('CA', tSATExentasPadron.CodUsuario) AS Creditos
FROM          tSATExentasPadron INNER JOIN
              tSATEstado ON tSATExentasPadron.Estado = tSATEstado.Estado INNER JOIN
              tCsPadronClientes ON tSATExentasPadron.CodUsuario = tCsPadronClientes.CodUsuario
WHERE        (tSATExentasPadron.Estado = @Estado)
GO