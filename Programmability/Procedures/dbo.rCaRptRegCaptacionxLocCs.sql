SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rCaRptRegCaptacionxLocCs](
		 @Fecha as smalldatetime,
		 @Sesion as varchar(12),
		 @Saldo as money output,
		 @Nro as int output)

with encryption
AS
set nocount on 

declare @Grupo as char(1)	-- 1: Depósitos a la vista
DECLARE @FechaCierre as DateTime
DECLARE @FechaProceso as DateTime
DECLARE @FechaProm smalldatetime
DECLARE @Mes int
DECLARE @Anio int

	IF Month(@Fecha)= 1 
		BEGIN
			SET @Mes = 12
			SET @Anio = Year(@Fecha) -1
		END
	ELSE
		BEGIN
			SET @Mes = Month(@Fecha) -1
			SET @Anio = Year(@Fecha)
		END
	
	set @FechaProm = convert(smalldatetime , cast(@Mes as varchar) + '/' + '1' + '/' + cast(@anio as varchar), 101)	
	SET @FechaProceso = DateAdd(Month,1,@FechaProm) --primer dia de mes despues del cierre
	SET @FechaCierre = DateAdd(Day, -1, @FechaProceso) --fecha de cierre, ultimo dia de mes


	set @Grupo = '1'

	-- Obtiene los depositos a la vista y los inserta en la tabla auxiliar para el reporte
	insert into tCoAuxRepoCapLoc (Sesion, Grupo, Secuencial, Localidad, Monto, NroCuentas)
	select @Sesion, @Grupo , 0, CodUbiGeo, isnull( sum(MontoGiro), 0 ), isnull( count(MontoGiro), 0)
	from  tClOficinas O
	left join (Select CodOficinaOrigen, MontoGiro
		from tCsGiros
		where FechaPago is null
		and TipoGiro = 'R'
		and (EstadoGiro = 'P' or EstadoGiro = 'U')
		union all
		Select CodOficinaOrigen, MontoGiro
		from tCsGiros
		where FechaPago <= @FechaCierre
		and TipoGiro = 'R'
		and EstadoGiro = 'G') G
	on G.CodOficinaOrigen = O.CodOficina
	group by CodUbiGeo
	
	update tCoAuxRepoCapLoc set Secuencial = O.Orden
	from tClOficinas O
	where tCoAuxRepoCapLoc.Localidad = O.CodUbigeo
	and Sesion = @Sesion
	and Grupo = @Grupo

	-- Devuelve la suma de los saldos
	select @Saldo = isnull( sum(MontoGiro), 0 ), @Nro = isnull( count(MontoGiro), 0)
	from (Select CodOficinaOrigen, MontoGiro
		from tCsGiros
		where FechaPago is null
		and TipoGiro = 'R'
		and (EstadoGiro = 'P' or EstadoGiro = 'U')
		union all
		Select CodOficinaOrigen, MontoGiro
		from tCsGiros
		where FechaPago <= @FechaCierre
		and TipoGiro = 'R'
		and EstadoGiro = 'G') G
GO