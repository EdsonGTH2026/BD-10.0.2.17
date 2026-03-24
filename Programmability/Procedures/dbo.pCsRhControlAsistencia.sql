SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Christofer Urbizagastegui Montoya>
-- Create date: <06,08,2010>
-- Description:	<Listados de asistencia por oficina>
-- =============================================
CREATE PROCEDURE [dbo].[pCsRhControlAsistencia] @codoficina varchar(4),@fecini smalldatetime,@fecfin smalldatetime
AS
BEGIN
	SET NOCOUNT ON;
  SELECT h.Fecha,c.nombrecompleto,e.codoficinanom codoficina,h.idsecuencia,h.Entrada,h.Salida,h.idobsentrada
      ,h.idobssalida,h.codhorario,h.codturno,h.iddia,h.exismarca,h.ttrabajo,h.tatrazo,h.idianomarca,h.codpuesto,o.nomoficina,e.codempleado
  FROM tCsRhControl h 
  inner join tcspadronclientes c on c.codusuario=h.codusuario
  inner join tCsEmpleados e on e.codusuario=h.codusuario
  inner join tcloficinas o on o.codoficina = e.codoficinanom
  where e.codoficinanom=@codoficina and h.fecha>=@fecini and h.fecha<=@fecfin
END
GO