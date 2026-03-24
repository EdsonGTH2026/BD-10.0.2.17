SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pRIEEnviaSMS]
as

set nocount on
create table #ba(sec int identity(1,1),codusuario varchar(20),msj varchar(160))
insert into #ba
select codusuario,msj
from riebasesms with(nolock)
where estado=0

declare @msj varchar(160)
declare @codusuario varchar(20)

declare @i int
declare @n int
set @i=1
select @n=count(codusuario) from #ba
while(@i<=@n)
begin
	select @codusuario=codusuario,@msj=msj from #ba where sec=@i
	INSERT INTO [10.0.2.14].finamigows.dbo.tWAVYEnvioSMS
				(FechaHora , Sistema, CodCliente   , Telefono       , MensajeSMS, consultado, Activo)
	select getdate(), 'RI', @codusuario,u.telefonomovil, @msj , '0'       , 1
	from tcspadronclientes u 
	where len(u.telefonomovil)=10 and codusuario=@codusuario

	update riebasesms
	set estado=1
	where codusuario=@codusuario and msj=@msj

	set @i=@i+1
end

drop table #ba 
GO

GRANT EXECUTE ON [dbo].[pRIEEnviaSMS] TO [ayescasc]
GO