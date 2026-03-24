SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsAGerentes] @oficinas varchar(200) AS

declare @s varchar(2000)

set @s = 'SELECT codusuario,codoficinanom,Correo '
set @s = @s + 'FROM tCsEmpleados '
set @s = @s + 'where estado=1  and codpuesto=41 '
set @s = @s + 'and correo is not null '
set @s = @s + 'and correo<>'''' '
if @oficinas<>'' set @s = @s + 'and codoficinanom in ('+@oficinas+')'

exec(@s)
GO