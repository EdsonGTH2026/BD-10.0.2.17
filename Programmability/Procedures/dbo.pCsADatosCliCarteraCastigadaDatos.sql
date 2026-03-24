SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsADatosCliCarteraCastigadaDatos]  @fecha smalldatetime,@codoficina varchar(4)
as
	select * from tCsADatosCliCarteraCastigada with(nolock)
GO