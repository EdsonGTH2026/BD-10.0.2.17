SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACACoReReLqCoDatos] @fecha smalldatetime, @codoficina varchar(500)
as
set nocount on
	select * from tCsACACoReReLqCo
GO