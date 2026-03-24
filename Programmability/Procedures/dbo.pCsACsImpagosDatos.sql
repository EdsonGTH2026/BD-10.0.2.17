SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACsImpagosDatos] @fecha smalldatetime, @codoficina varchar(500)
as
--declare @codoficina varchar(200)
--set @codoficina='2,3,4,5,6,7,8'

declare @oficinas table(codoficina varchar(4))
insert into @oficinas
select codigo
from dbo.fdutablavalores(@codoficina)

select *
from tCsACAImpagos
where codoficina in(
	select codoficina from @oficinas
)
GO