SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCASolRegPromotor] @fecha smalldatetime
as
set nocount on
declare @cad varchar(8000)
--declare @fecha smalldatetime
--set @fecha='20180228'

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tCsASolRegPromotor]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].tCsASolRegPromotor

exec [10.0.2.14].finmas.dbo.pCsCASolRegPromotorCols @fecha,@cad OUTPUT
print @cad
exec (@cad)

insert into tCsASolRegPromotor
exec [10.0.2.14].finmas.dbo.pCsCASolRegPromotor @fecha

update tCsASolRegPromotor
set codoficina=o.codoficina
from tCsASolRegPromotor s
inner join (
	select max(codoficina) codoficina,nomoficina from tcloficinas group by nomoficina
) o on o.nomoficina=s.nomoficina

--select * from tCsASolRegPromotor
GO