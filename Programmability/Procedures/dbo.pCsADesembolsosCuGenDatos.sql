SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsADesembolsosCuGenDatos] @fecha smalldatetime, @codoficina varchar(3)
as
	select * from tCsADesembolsosCU
GO