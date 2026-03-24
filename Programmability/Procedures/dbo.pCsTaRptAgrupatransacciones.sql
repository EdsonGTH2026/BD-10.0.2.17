SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsTaRptAgrupatransacciones] @fecini smalldatetime,@fecfin smalldatetime,@grupo varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--declare @grupo varchar(100)

--set @fecini='20110701'
--set @fecfin='20110731'
--set @grupo = 'm.consumo' --   t.Descripcion m.nombre m.fecha

declare @cad varchar(2000)

set @cad = 'select descripcion, sum(NCargos) NCargos, sum(NAbonos) NAbonos,sum(Cargos) Cargos, sum(Abonos) Abonos from ('
set @cad = @cad + 'SELECT '+@grupo+' as descripcion '
set @cad = @cad + ',case when t.operacion=''+'' then 1 else 0 end NCargos '
set @cad = @cad + ',case when t.operacion=''-'' then 1 else 0 end NAbonos '
set @cad = @cad + ',case when t.operacion=''+'' then m.Monto else 0 end Cargos '
set @cad = @cad + ',case when t.operacion=''-'' then m.Monto else 0 end Abonos '
set @cad = @cad + 'FROM tTaMovimientos m inner join tTaTipoMovimientos t '
set @cad = @cad + 'on m.codtipomov=t.codtipomov '
set @cad = @cad + 'where m.fecha>='''+dbo.fduFechaAAAAMMDD(@fecini)+''' and m.fecha<='''+dbo.fduFechaAAAAMMDD(@fecfin)+''') a '
set @cad = @cad + 'group by descripcion '
print @cad
exec (@cad)

END
GO