SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaCosechasBaseVerificadorDatos] @fecha smalldatetime, @codoficina varchar(4)
as select * from tCsACaCosechasBaseVerificador with(nolock)
GO