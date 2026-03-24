SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACOAhTransaccionesDatos] @fecha smalldatetime,@codoficina varchar(4)
as
select *
from [10.0.2.15].finamigo_conta_pro.dbo.tCsCoAHTransacciones
GO