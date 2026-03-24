SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaEstadoFlujoAppPoliticas](@CodProducto varchar(3),@Ciclo int
)
as
begin
/*
	declare @CodProducto varchar(3)
	declare @Ciclo int
	set @Ciclo = 1
	set @CodProducto = '170'
*/
	declare @SegundaVisitaVF int
	declare @Estado int
	
	select 
	@SegundaVisitaVF = SegundaVisitaVF
	from tCsCaAppPoliticas 
	where CodProducto = @CodProducto 
	and CicloMin <= @Ciclo and CicloMax >= @Ciclo

    select @Estado = (case @SegundaVisitaVF
                      when 1 then 1  --solicitud
                      when 0 then 3  --credito
                      else 1         --solicitud
                      end)
                      
	select isnull(@Estado,1) as EstadoFlujo
END
GO