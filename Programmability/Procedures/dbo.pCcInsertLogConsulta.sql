SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCcInsertLogConsulta](@IdCC int, @Tipo varchar(1),@NumProducto varchar(3), @Estado varchar(10), @Comentario varchar(100))
as
begin
	set nocount on
	declare @IdLogNew int
	insert into tCcConsultaLog (IdCC, Fecha, Tipo,NumProducto, Estado, Comentario)values (@IdCC, getdate(), @Tipo, @NumProducto,@Estado, @Comentario)
	
	select @IdLogNew = max(IdLog) from tCcConsultaLog
	
	select @IdLogNew as 'IdLogNew'
end
GO