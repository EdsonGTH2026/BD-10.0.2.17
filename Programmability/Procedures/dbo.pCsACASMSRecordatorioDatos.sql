SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACASMSRecordatorioDatos] @fecha smalldatetime,@codoficina varchar(4) as select * from tCsACaSMSRecordatorio
GO