SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCcUpdateLogConsulta] (@IdCC int, @Estado varchar(10), @Comentario varchar(100))
as
begin
	set nocount on
	declare @IdLogNew int
	select @IdLogNew = max(IdLog) from tCcConsultaLog where idcc = @IdCC	
	update tCcConsultaLog set
	Estado = @Estado , 
	Comentario = Comentario
	where IdLog = @IdLogNew	
end	
	
GO