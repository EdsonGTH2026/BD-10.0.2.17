SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsRptObtieneRepoActivoPond](
	@GrupoReporte varchar(1),
	@Seccion varchar(3),
	@Fecha as smalldatetime,
	@ActivoPonderado as money output)

with encryption
AS
set nocount on -- <-- Noel. Optimizacion

declare @CodCta  varchar(25)
declare @CodFondo varchar(2)
declare @PorcPonderacion money 

declare @SaldoCta money
declare @SaldoCtaMes money

declare @ActivoPond money

	set @ActivoPond = 0

	declare cursorGrupo cursor fast_forward for
	select distinct CodCta, CodFondo, PorcPonderacion
	from tCsClPonderacionActivo
	where GrupoReporteRiesgo = @GrupoReporte
	and upper(SeccionReporte) = upper(@Seccion)
	
	open cursorGrupo
	fetch next from cursorGrupo into @CodCta, @CodFondo, @PorcPonderacion
	while @@fetch_status = 0
	begin
		set @SaldoCta = 0
		set @SaldoCtaMes = 0

--		exec pCoObtieneSaldoCta @CodCta, @CodFondo, @Fecha, @SaldoCta output , @SaldoCtaMes output
		exec pCsRptObtieneSaldoCta @CodCta, @CodFondo, @Fecha, @SaldoCta output , @SaldoCtaMes output

		set @ActivoPond = @ActivoPond + ((@SaldoCta * @PorcPonderacion) / 100)
		
		fetch next from cursorGrupo into @CodCta, @CodFondo, @PorcPonderacion
	end

	close cursorGrupo
	deallocate cursorGrupo

	set @ActivoPonderado = @ActivoPond
GO