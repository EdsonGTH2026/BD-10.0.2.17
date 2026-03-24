SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pInsertRegistroHoras](
	@CodOficina varchar(3), 
	@CodUsuario char(15), 
	@CodHorario int, 
	@Coddia int, 
	@FechaHora datetime, 
	@Idturno int, 
	@ES bit, 
	@IdObservacion int, 
	@IdMinutos as int	= 0,
	@IdMotivoExtra as int	= 0,
  @Secuencial Int --OUTPUT
)

with encryption  
AS
set nocount on -- 
    -- Calcular el secuencial
    -- Select  @Secuencial = dbo.fSecNormal(@CodOficina, @CodUsuario, @ES)

 		Insert Into tRhRegistroHoras 
 						( CodOficina,  CodUsuario,  CodHorario,  FechaHora,  Idturno,  EntradaSalida,  IdObservacion,  IdSecuencia, Procesado,iddia )
 		Values 	(@CodOficina, @CodUsuario, @CodHorario, @FechaHora, @Idturno, @ES, @IdObservacion, @Secuencial, 0,@Coddia)


	--diferencia de horas
		if not exists(Select codusuario from tRhDifHoras 
					where codoficina = @CodOficina and CodUsuario = @CodUsuario and idSecuencia = @Secuencial)
			begin
				INSERT INTO 
				tRhDifHoras( CodOficina,  CodUsuario,  idSecuencia,  Fecha, 		 Entrada,   Salida, Procesado, 
         IdObsEntrada,   CodHorario,  IdTurno, iddia) 
				VALUES 		 (@CodOficina, @CodUsuario, @Secuencial, cast(dbo.fduFechaAAAAMMDD(@FechaHora) as smalldatetime), @FechaHora, NULL, 	0,
        @IdObservacion, @CodHorario, @Idturno, @Coddia )
			end
		else
			begin
				Update tRhDifHoras set 
						Salida = @FechaHora,  
						Procesado = 0,
            IdObsSalida = @IdObservacion
				Where CodOficina = @CodOficina
						AND CodUsuario = @CodUsuario
						AND IdSecuencia = @Secuencial
				--Minutos trabajados
        Update tRhDifHoras SET DIFERENCIA = datediff(minute,entrada,salida)								
				Where CodOficina = @CodOficina
						AND CodUsuario = @CodUsuario
						AND IdSecuencia = @Secuencial
						AND Procesado = 0
			end	
	--Graba minutos extra, pasados de la hora de marcado
		if @IdMotivoExtra>0
			begin
				INSERT INTO 
				tRhMinutosExtra(CodOficina,  CodUsuario,  CodHorario,  FechaHora,  IdTurno,  EntradaSalida,  Secuencia,     Minutos,     Motivo) 
				VALUES 		    (@CodOficina, @CodUsuario, @CodHorario, @FechaHora, @Idturno, @ES, @Secuencial,  @IdMinutos, 	@IdMotivoExtra)
			end

GO