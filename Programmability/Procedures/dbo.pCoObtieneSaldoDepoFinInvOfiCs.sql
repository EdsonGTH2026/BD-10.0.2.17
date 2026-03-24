SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCoObtieneSaldoDepoFinInvOfiCs](
		 @TipoInstFin as varchar(3),
		 @Categoria as char(1),
		 @Fecha as smalldatetime,
		 @Grupo as varchar(1),	 -- Grupo al que pertenecerán los datos del reporte
                 @Saldo money out,
                 @Nro int out
		 )

with encryption
AS
set nocount on 

declare @Monto as money
declare @NroCuentas as int

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
	
	set @FechaProm = convert(smalldatetime , cast(@Mes as varchar) + '/' + '1' + '/' + cast(@anio as varchar), 101)	
	SET @FechaProceso = DateAdd(Month,1,@FechaProm) --primer dia de mes despues del cierre
	SET @FechaCierre = DateAdd(Day, -1, @FechaProceso) --fecha de cierre, ultimo dia de mes

	-- Obtiene los saldos de financiamiento - inversión y los inserta en la tabla auxiliar para el reporte
	insert into @Tabla (Grupo, Secuencial, Localidad, Monto, NroCuentas)
	select @Grupo, O.Orden, CodUbiGeo, isnull(sum(MontoCapital), 0), isnull(count(MontoCapital), 0)
	from tCsClOficinas O
	left join (select F.CodOficina, F.CodPrestFin, sum(MontoCapital) as MontoCapital
		from tCsPrestFin F, tCsPrestFinDet D
		where F.CodPrestFin = D.CodPrestFin
		and CodTipoInstFin = @TipoInstFin
		and Estado = '1'
		and Categoria = @Categoria
		and D.FechaVencimiento >= @FechaCierre
		group by F.CodOficina, F.CodPrestFin) F
	on O.CodOficina = F.COdOficina
	group by O.CodUbiGeo, O.Orden

	-- Devuelve la suma de los saldos
	select @Saldo = isnull(sum(MontoCapital), 0) , @Nro = isnull(count(MontoCapital) , 0)
	from (select F.CodOficina, F.CodPrestFin, sum(MontoCapital) as MontoCapital
		from tCsPrestFin F, tCsPrestFinDet D
		where F.CodPrestFin = D.CodPrestFin
		and CodTipoInstFin = @TipoInstFin
		and Estado = '1'
		and Categoria = @Categoria
		and D.FechaVencimiento >= @FechaCierre
		group by F.CodOficina, F.CodPrestFin) F		
	

GO