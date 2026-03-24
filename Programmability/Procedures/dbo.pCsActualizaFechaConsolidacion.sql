SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsActualizaFechaConsolidacion]
as
SET NOCOUNT ON
Declare @Fecha SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion
--Exec pCsCierreLog @Fecha, '360 Actualizar Fecha de Consolidacion'

begin transaction
UPDATE tClOficinas
SET    consolidadoahorros = DERIVEDTBL.Consolidado
FROM (
	SELECT CodOficina, MAX(Fecha) AS Consolidado
      FROM   tCsAhorros with(nolock)
      where fecha >= dateadd(day, -5, @Fecha)
      GROUP BY CodOficina
) DERIVEDTBL 
INNER JOIN tClOficinas ON DERIVEDTBL.CodOficina = tClOficinas.CodOficina
if(@@error<>0)
begin
	rollback transaction
	RAISERROR ('Error al actualizar ahorro', 16, -1)
	return
end

UPDATE tClOficinas
SET    consolidadocartera = DERIVEDTBL.Consolidado
FROM (SELECT CodOficina, MAX(Fecha) AS Consolidado
      FROM tCscartera with(nolock)
      where fecha >= dateadd(day,-5,@Fecha)
      GROUP BY CodOficina
) DERIVEDTBL 
INNER JOIN tClOficinas ON DERIVEDTBL.CodOficina = tClOficinas.CodOficina
if(@@error<>0)
begin
	rollback transaction
	RAISERROR ('Error al actualizar cartera', 16, -1)
	return
end

commit transaction


GO