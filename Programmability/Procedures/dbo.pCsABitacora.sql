SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsABitacora] @fecha smalldatetime
as

exec pCsAArqueosCajasGenera

truncate table tCsABitacoraCobranza
insert into tCsABitacoraCobranza
exec [10.0.2.14].finmas.dbo.pCaBitacora @fecha

--select * from tCsABitacoraCobranza
GO