SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsPLD_ConsultaProcedenciaRecursos] (@fecahIni smalldatetime, @fecahFin smalldatetime)
as
BEGIN

	exec [10.0.2.14].Finmas.dbo.pTcPLD_ConsultaProcedenciaRecursos @fecahIni, @fecahFin

END
GO