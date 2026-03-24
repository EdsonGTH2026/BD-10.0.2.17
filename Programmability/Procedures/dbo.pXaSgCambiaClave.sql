SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSgCambiaClave] @usuario varchar(25),@clave varchar(10)
as
set nocount on
--declare @usuario varchar(25)
--set @usuario='curbiza'

--declare @clave varchar(10)
--set @clave='525390'

--select * from tsgusuarios with(nolock) where usuario=@usuario
declare @md5 varchar(500)
set @md5=dbo.fdumd5(dbo.fdumd5(@clave))

update tsgusuarios
set contrasena=@md5
where usuario=@usuario

--select * from tsgusuarios with(nolock) where usuario=@usuario
GO