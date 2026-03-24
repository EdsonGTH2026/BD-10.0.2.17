SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACASMSAtraso31a90DatosMiio] @fecha smalldatetime,@codoficina varchar(4) as select ustelefonomovil,nombrecompleto from tCsACaSMSAtraso31a90
GO