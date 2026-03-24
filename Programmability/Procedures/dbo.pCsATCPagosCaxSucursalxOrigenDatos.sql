SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsATCPagosCaxSucursalxOrigenDatos] @fecha smalldatetime,@codoficina varchar(4)
as
	select * from tCsRptTCPagosxSucursal

GO