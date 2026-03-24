SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pSgCorreosEmpleados] @codusuarios varchar(500)
as
--declare @codusuarios varchar(500)
--set @codusuarios='DTB1209861,AGI820422FH300'

declare @correos varchar(1000)

select @correos=coalesce(@correos,'')+';'+correo from tcsempleados with(nolock)
where codusuario in( select Codigo from dbo.fduTablaValores(@codusuarios))
set @correos=substring(@correos,2,len(@correos))
select @correos correos
GO