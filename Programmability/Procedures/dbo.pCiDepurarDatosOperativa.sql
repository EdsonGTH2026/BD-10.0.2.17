SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCiDepurarDatosOperativa]
as
set nocount on
Declare @Fecha SmallDateTime
Select @Fecha = Max(FechaProceso)  from tclparametros

Exec pGrDepuracion

-- 2016 01 22 - Noel - Borra Tablas temporales que empiezan en 't99%'
Declare @Tabla varchar(500)
declare CU cursor for
	SELECT 'drop table ' + name FROM SYSOBJECTS WHERE NAME LIKE 't99%' order by 1
open CU
fetch next from CU into @Tabla
while @@fetch_status = 0
begin
   execute (@Tabla)
   fetch next from CU into @Tabla
end
close CU
deallocate CU
GO