SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACaSolicitudesPasaCredito]
as
set nocount on
truncate table tCaASolicitudesCredito

insert into tCaASolicitudesCredito
exec [10.0.2.14].finmas.dbo.pCsASolicitudesPasaCredito

update tCaASolicitudesCredito
set codusuario=cl.codusuario
from tCaASolicitudesCredito p with(nolock)
inner join tcspadronclientes cl with(nolock) on p.codusuario=cl.codorigen

update tCaASolicitudesCredito
set codpromotor=cl.codusuario
from tCaASolicitudesCredito p with(nolock)
inner join tcspadronclientes cl with(nolock) on p.codasesor=cl.codorigen
GO