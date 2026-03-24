SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACASolicitudesRegRegioDatos] @fecha smalldatetime, @codoficina varchar(200)
as
	select * from tCsASolicitudesRegistradas
	where codoficina in(select codigo from dbo.fduTablaValores(@codoficina))

GO