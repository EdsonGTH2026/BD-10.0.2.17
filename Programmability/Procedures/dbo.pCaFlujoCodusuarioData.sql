SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCaFlujoCodusuarioData] @codusuario varchar(15)
as
select codusuario from tcspadronclientes with(nolock) where codorigen=@codusuario
GO