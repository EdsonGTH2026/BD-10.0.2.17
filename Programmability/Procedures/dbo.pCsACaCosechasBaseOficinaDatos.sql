SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaCosechasBaseOficinaDatos] @fecha smalldatetime, @codoficina varchar(4)
as
	select * from tCsACaCosechasBaseOficina with(nolock)
GO