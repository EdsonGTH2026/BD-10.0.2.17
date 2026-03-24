SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACaSolicitudes]
as
set nocount on
Declare @Fecha SmallDateTime
Select @Fecha=FechaConsolidacion From vCsFechaConsolidacion

Declare @Fecini SmallDateTime
set @Fecini=dateadd(day,(-1)*day(@Fecha),@Fecha)+1

truncate table tCaASolicitudes

insert into tCaASolicitudes
exec [10.0.2.14].finmas.dbo.pCsASolicitudes

update tCaASolicitudes
set codusuario=cl.codusuario
from tCaASolicitudes p with(nolock)
inner join tcspadronclientes cl with(nolock) on p.codusuario=cl.codorigen

update tCaASolicitudes
set codpromotor=cl.codusuario
from tCaASolicitudes p with(nolock)
inner join tcspadronclientes cl with(nolock) on p.codasesor=cl.codorigen
GO