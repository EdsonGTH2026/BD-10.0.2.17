SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaLiqrrVisitasClienteDetGuardar] @codusuario varchar(15),@clasificacion tinyint,@observacion varchar(250)
												,@fechareactivacion smalldatetime,@estado tinyint
as
--declare @codusuario varchar(15)
--declare @clasificacion tinyint
--declare @observacion varchar(250)
--declare @fechareactivacion smalldatetime
--declare @estado tinyint

declare @item int
declare @fecha datetime
set @fecha=getdate()

begin transaction
if(not exists(select 1 from tCsCALIQRRVisitas where codusuario=@codusuario))
	begin
	--	select * from tCsCALIQRRVisitas
		insert into tCsCALIQRRVisitas
		values(@codusuario,@fecha,@clasificacion,@estado)
	end
else
	begin
		update tCsCALIQRRVisitas
		set fecha=@fecha,clasificacion=@clasificacion,estado=@estado
		where codusuario=@codusuario
	end
if(@@error>0)
	begin
		rollback transaction
		RAISERROR ('Error: al insertar al usuario',16,-1)
	end

select @item=isnull(max(item),0)+1 from tCsCALIQRRVisitasDet where codusuario=@codusuario

insert into tCsCALIQRRVisitasDet 
values(@codusuario,@item,@fecha,@clasificacion,@observacion,@fechareactivacion,@estado)
if(@@error>0)
	begin
		rollback transaction
		RAISERROR ('Error: al insertar visita',16,-1)
	end

commit transaction

GO