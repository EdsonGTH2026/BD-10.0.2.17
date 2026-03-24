SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsADatosCliCarteraActivaDatos]  @fecha smalldatetime,@codoficina varchar(4)
as
	select * from tCsADatosCliCarteraActiva
GO