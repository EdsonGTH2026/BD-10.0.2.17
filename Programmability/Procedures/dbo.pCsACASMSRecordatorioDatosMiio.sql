SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACASMSRecordatorioDatosMiio] @fecha smalldatetime,@codoficina varchar(4) as select ustelefonomovil,nombrecompleto from tCsACaSMSRecordatorio

GO