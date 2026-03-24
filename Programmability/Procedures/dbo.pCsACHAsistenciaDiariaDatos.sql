SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACHAsistenciaDiariaDatos] @fecha smalldatetime, @codoficina varchar(300)
as
  select * from tCsRptCHAsistenciaDiaria
GO