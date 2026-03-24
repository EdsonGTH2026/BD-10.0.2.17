SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsADesembolsosCuGen] @fecha smalldatetime
as
set nocount on
declare @cad varchar(8000)
--declare @fecha smalldatetime
--set @fecha='20171004'

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tCsADesembolsosCU]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tCsADesembolsosCU]

exec pCsADesembolsosCuCols @fecha,@cad OUTPUT
--print @cad
exec (@cad)

insert into tCsADesembolsosCU
exec pCsADesembolsosCu @fecha
GO