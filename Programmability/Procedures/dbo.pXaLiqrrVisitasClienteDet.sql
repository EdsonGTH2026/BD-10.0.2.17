SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaLiqrrVisitasClienteDet] @codusuario varchar(15)
as
select item, fecha, clasificacion, observacion, isnull(dbo.fdufechaatexto(fechareactivacion,'dd/MM/AAAA'),'') fechareactivacion, estado
from tCsCALIQRRVisitasDet
where codusuario=@codusuario--'ACB2207721'--
order by fecha desc
GO