SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAArqueosCajasDatos] @fecha smalldatetime, @codoficina varchar(200)
as
	select * from tCsAArqueosRemotosCajas
GO