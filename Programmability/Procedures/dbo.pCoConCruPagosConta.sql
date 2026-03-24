SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCoConCruPagosConta] @fecha smalldatetime
as
	truncate table tCoConPagosCAOP
	insert into tCoConPagosCAOP
	exec [10.0.2.14].finmas.dbo.pCoConPagosCartera @fecha--'20170102'--
GO