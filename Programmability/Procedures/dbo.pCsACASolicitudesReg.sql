SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACASolicitudesReg] @fecha smalldatetime
as
set nocount on
declare @cad varchar(8000)
--declare @fecha smalldatetime
--set @fecha='20171005'

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tCsASolicitudesRegistradas]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].tCsASolicitudesRegistradas

exec [10.0.2.14].finmas.dbo.pCsCASolicitudesRegistradasCols @fecha,@cad OUTPUT
print @cad
exec (@cad)

insert into tCsASolicitudesRegistradas
exec [10.0.2.14].finmas.dbo.pCsCASolicitudesRegistradas @fecha

update tCsASolicitudesRegistradas
set codoficina=o.codoficina
from tCsASolicitudesRegistradas s
inner join (
	select max(codoficina) codoficina,nomoficina from tcloficinas group by nomoficina
) o on o.nomoficina=s.nomoficina

--select * from tCsASolicitudesRegistradas


GO