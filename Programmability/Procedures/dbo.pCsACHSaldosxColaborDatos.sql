SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACHSaldosxColaborDatos] @fecha smalldatetime, @codoficina varchar(300)
as
  select * from tCsRptCHSaldosxColabor
GO