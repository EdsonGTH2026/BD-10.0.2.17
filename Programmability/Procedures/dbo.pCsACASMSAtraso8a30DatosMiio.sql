SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACASMSAtraso8a30DatosMiio] @fecha smalldatetime,@codoficina varchar(4) as select ustelefonomovil,nombrecompleto from tCsACaSMSAtraso8a30
GO