SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaCAPagosProgramados] @codusuario varchar(25)
as
set nocount on
	exec [10.0.2.14].finmas.dbo.pXaCAPagosProgramados @codusuario
GO