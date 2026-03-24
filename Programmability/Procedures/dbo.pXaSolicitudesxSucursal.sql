SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaSolicitudesxSucursal] @codoficina varchar(4)
as
	exec [10.0.2.14].finmas.dbo.pXaSolicitudesxSucursal @codoficina
GO