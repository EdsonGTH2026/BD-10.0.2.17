SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACASMSAtraso1a7DatosMiio] @fecha smalldatetime,@codoficina varchar(4) as select ustelefonomovil,nombrecompleto from tCsACaSMSAtraso1a7
GO