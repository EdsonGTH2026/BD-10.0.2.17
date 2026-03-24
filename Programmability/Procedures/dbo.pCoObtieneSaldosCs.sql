SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[pCoObtieneSaldosCs](
		 @Fecha as smalldatetime,
		 @Tipo As integer,
                 @TipoInstFin As varchar(3),
		 @Grupo as char(1)
		 )

with encryption
AS
set nocount on 

DECLARE @FechaCierre as DateTime
DECLARE @FechaProceso as DateTime
DECLARE @FechaProm smalldatetime
DECLARE @Mes int
DECLARE @Anio int

DECLARE @Tabla table (Grupo char(1), Secuencial int, Localidad varchar(6), 
                      NroCuentas int, Monto money) 

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
	
-- 	SET @FechaProm = convert(smalldatetime , cast(@Mes as varchar) + '/' + '1' + '/' + cast(@anio as varchar), 101)	
-- 	SET @FechaProceso = DateAdd(Month,1,@FechaProm) --primer dia de mes despues del cierre
-- 	SET @FechaCierre = DateAdd(Day, -1, @FechaProceso) --fecha de cierre, ultimo dia de mes

	SET @FechaProm = @Fecha
	SET @FechaProceso = @Fecha
	SET @FechaCierre = @Fecha

	if @tipo=1
	begin
		-- Obtiene los depositos a la vista y los inserta en la tabla auxiliar para el reporte
		insert into @Tabla (Grupo, Secuencial, Localidad, Monto, NroCuentas)
		select @Grupo , O.Orden, CodUbiGeo, isnull( sum(MontoGiro), 0 ), isnull( count(MontoGiro), 0)
		from  tCsClOficinas O
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
			and EstadoGiro = 'G') G	on G.CodOficinaOrigen = O.CodOficina
		group by CodUbiGeo, O.Orden
	end
	
	if @tipo=2
	begin
		-- Obtiene los depositos de ahorro y los inserta en la tabla auxiliar para el reporte
		insert into @Tabla (Grupo, Secuencial, Localidad, Monto, NroCuentas)
		select @Grupo, O.orden, CodUbiGeo, isnull( sum(SaldoCuenta), 0 ), isnull( count(SaldoCuenta), 0 )
		from  tCsClOficinas O
		left join (select CodOficina, SaldoCuenta from tCsAhorros
				where CodProducto not like '2%'
				and IdEstadoCta <> 'CC'
				and Fecha = @FechaCierre) A
		on O.CodOficina = A.CodOficina
		group by CodUbiGeo, O.Orden
	end

	if @tipo=3
	begin
		-- Obtiene los depositos rtirables y los inserta en la tabla auxiliar para el reporte
		insert into @Tabla (Grupo, Secuencial, Localidad, Monto, NroCuentas)
		select @Grupo , O.Orden, CodUbiGeo,  isnull( sum(SaldoCuenta), 0 ), isnull(count(SaldoCuenta) ,0)
		from tCsClOficinas O
		left join (select CodOficina, SaldoCuenta
			   from tCsAhorros
			   where CodProducto like '2%'
			         and (FechaCierre <= @FechaCierre or FechaCierre is null)
			         and FechaVencimiento >= @FechaCierre
			         AND CodCuenta + FraccionCta + Cast(Renovado as VArChar(100)) IN 
								(SELECT CodCuenta + FraccionCta + Cast(Renovado As VarChar(100))
							   	 FROM tCsAhorros
								 WHERE Fecha = @FechaCierre AND CodProducto like '2%'
								       AND IdEstadoCta <> 'CC' AND IdEstadoCta <> 'CV')) D
		on O.CodOficina = D.CodOficina
		group by CodUbiGeo, O.Orden

	end

	if @tipo=4
	begin
		-- Obtiene los saldos de financiamiento - inversión y los inserta en la tabla auxiliar para el reporte
		insert into @Tabla (Grupo, Secuencial, Localidad, Monto, NroCuentas)
		select @Grupo, O.Orden, CodUbiGeo, isnull(sum(MontoCapital), 0), isnull(count(MontoCapital), 0)
		from tCsClOficinas O
		left join (select F.CodOficina, F.CodPrestFin, sum(MontoCapital) as MontoCapital
			from tCsPrestFin F, tCsPrestFinDet D
			where F.CodPrestFin = D.CodPrestFin
			and CodTipoInstFin = @TipoInstFin
			and Estado = '1'
			and Categoria = '2'
			and D.FechaVencimiento >= @FechaCierre
			group by F.CodOficina, F.CodPrestFin) F
		on O.CodOficina = F.COdOficina
		group by O.CodUbiGeo, O.Orden
	end

	select * from @Tabla

GO