SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsAhPLD_ConsultaPropietarioProveedorRecursos] (@FechaIni smalldatetime, @FechaFin smalldatetime)
as
BEGIN

	exec [10.0.2.14].finmas.dbo.pAhPLD_ConsultaPropietarioProveedorRecursos @FechaIni, @FechaFin
	--exec [10.0.2.14].alta14.dbo.pAhPLD_ConsultaPropietarioProveedorRecursos @FechaIni, @FechaFin  --PRUEBAS
END

GO