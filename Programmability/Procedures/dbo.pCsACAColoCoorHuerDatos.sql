SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACAColoCoorHuerDatos] @fecha smalldatetime, @codoficina varchar(5)
as
	select * from tCsACAColoCoorHuer
GO