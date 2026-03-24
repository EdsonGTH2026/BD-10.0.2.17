SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsADesembolsosCuGenRegDatos] @fecha smalldatetime, @codoficina varchar(200)
as
	select * from tCsADesembolsosCU
	where codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
GO