SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaCrecimientoPromotorDatos] @fecha smalldatetime, @codoficina varchar(2000)
as
set nocount on

declare @oficinas table(codoficina varchar(4))
insert into @oficinas
select codigo
from dbo.fdutablavalores(@codoficina)

select * from tCsACrecimientoPromotor 
where codoficina in(select codoficina from @oficinas)
	or @codoficina='%'

	
GO