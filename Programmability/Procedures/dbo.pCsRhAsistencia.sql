SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author     :	<jlmp>
-- Create date: <12,05,2014>
-- Description:	<Listado de asistencia por rango de fechas>
-- =============================================
CREATE PROCEDURE [dbo].[pCsRhAsistencia] @codoficina varchar(6), @codEmpleado varchar(6), @fecini smalldatetime, @fecfin smalldatetime
AS
BEGIN
	declare @cond1 varchar(10)
	declare @cond2 varchar(10)
	declare @cond3 varchar(10)
	declare @cond4 varchar(10)
        declare @SqlStr   varchar(3000)
	declare @dia      varchar(100)
	declare @FDiaIni  smallint
	declare @FDiaFin  smallint
	declare @i        smallint

        declare @empleado  varchar(10), @Dia1 varchar(10), @Dia2 varchar(10), @Dia3 varchar(10), @Dia4 varchar(10), @Dia5 varchar(10), @Dia6 varchar(10), 
				        @Dia7 varchar(10), @Dia8 varchar(10), @Dia9 varchar(10), @Dia10 varchar(10), @Dia11 varchar(10), @Dia12 varchar(10), 
				        @Dia13 varchar(10), @Dia14 varchar(10), @Dia15 varchar(10), @Dia16 varchar(10), @Dia17 varchar(10), @Dia18 varchar(10), 
				        @Dia19 varchar(10), @Dia20 varchar(10), @Dia21 varchar(10), @Dia22 varchar(10), @Dia23 varchar(10), @Dia24 varchar(10), 
				        @Dia25 varchar(10), @Dia26 varchar(10), @Dia27 varchar(10), @Dia28 varchar(10), @Dia29 varchar(10), @Dia30 varchar(10), @Dia31 varchar(10)


	SET NOCOUNT ON;

	select @fecini = convert(nvarchar(10), @fecini, 101)
	select @fecfin = convert(nvarchar(10), @fecfin, 101)

	-- Valida fechas
	if (datepart(mm,@fecini) > datepart(mm,@fecfin) )
		select @fecfin = @fecini

	if (datepart(mm,@fecini) <> datepart(mm,@fecfin) )
		begin
		if (datepart(mm,@fecini) =  datepart(mm,getdate()))
			begin
			select @fecfin = dateadd(mm, 1,@fecini)
			select @fecfin = convert(nvarchar(10), dateadd(dd, - datepart(d,@fecfin), @fecfin), 101)		
			end
		else
			if (datepart(mm,@fecfin) =  datepart(mm,getdate()))
				begin
				select @fecini = @fecfin				
				select @fecini = convert(nvarchar(10), dateadd(dd, -(datepart(d,@fecini) -1), @fecini), 101)
				end
			else
				begin
				select @fecini = convert(nvarchar(10), dateadd(dd, -(datepart(d,getdate()) -1), getdate()), 101)
				select @fecfin = dateadd(mm, 1,getdate())
				select @fecfin = convert(nvarchar(10), dateadd(dd, - datepart(d,@fecfin), @fecfin), 101)		
				end
		end

	select @fecini = convert(nvarchar(10), @fecini, 101)
	select @fecfin = convert(nvarchar(10), @fecfin, 101)


/*	if (datepart(dd,@fecini) <= 15)
		begin
		if (datepart(dd,@fecini) <> 1)
			select @fecini = convert(nvarchar(10), dateadd(dd, -(datepart(d,@fecini) -1), @fecini), 101)
		select @fecfin = convert(nvarchar(10), dateadd(dd, 15 - datepart(d,@fecini), @fecini), 101)	
		end
        else
		begin
		if (datepart(dd,@fecini) <> 16)
			select @fecini = convert(nvarchar(10), dateadd(dd, -(datepart(d,@fecini) -16), @fecini), 101)
	        select @fecfin = dateadd(mm, 1,@fecini)
		select @fecfin = convert(nvarchar(10), dateadd(dd, - datepart(d,@fecfin), @fecfin), 101)	
		end
*/

	-- Crea tabla temporal
	CREATE TABLE #Asistencia(Empleado varchar(10), 
                      DIA1 varchar(3), DIA2 varchar(3), DIA3 varchar(3),DIA4 varchar(3),DIA5 varchar(3),DIA6 varchar(3),DIA7 varchar(3),DIA8 varchar(3),
		      DIA9 varchar(3),DIA10 varchar(3), DIA11 varchar(3),DIA12 varchar(3),DIA13 varchar(3),DIA14 varchar(3),DIA15 varchar(3),DIA16 varchar(3),
		      DIA17 varchar(3),DIA18 varchar(3), DIA19 varchar(3),DIA20 varchar(3),DIA21 varchar(3),DIA22 varchar(3),DIA23 varchar(3),DIA24 varchar(3),DIA25 varchar(3),
		      DIA26 varchar(3),DIA27 varchar(3), DIA28 varchar(3),DIA29 varchar(3),DIA30 varchar(3),DIA31 varchar(3))

	--Valida parametros
        select @cond1 = ''
        select @cond2 = ''
        select @cond3 = ''
        select @cond4 = ''
	if (ltrim(@codoficina) = '' or @codoficina = null)
		begin
	  	select @cond1 = '' 
	  	select @cond2 = 'zzzzzzz' 
		end
	else
		begin
	  	select @cond1 = @codoficina
	  	select @cond2 = @codoficina 
		end

	if (ltrim(@codEmpleado) = '' or @codEmpleado = null)
		begin
	  	select @cond3 = '' 
	  	select @cond4 = 'zzzzzzz' 
		end
	else
		begin
	  	select @cond3 = @codempleado
	  	select @cond4 = @codempleado
		end

	-- Genera datos
      	insert into #Asistencia
	SELECT codempleado, 	sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,0,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,0,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,0,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,0,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,0,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia1,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,1,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,1,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,1,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,1,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,1,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia2,
			      	sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,2,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,2,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,2,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,2,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,2,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia3,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,3,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,3,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,3,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,3,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,3,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia4,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,4,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,4,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,4,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,4,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,4,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia5,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,5,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,5,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,5,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,5,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,5,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia6,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,6,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,6,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,6,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,6,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,6,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia7,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,7,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,7,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,7,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,7,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,7,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia8,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,8,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,8,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,8,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,8,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,8,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia9,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,9,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,9,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,9,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,9,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,9,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia10,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,10,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,10,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,10,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,10,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,10,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia11,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,11,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,11,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,11,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,11,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,11,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia12,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,12,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,12,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,12,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,12,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,12,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia13,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,13,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,13,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,13,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,13,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,13,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia14,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,14,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,14,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,14,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,14,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,14,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia15,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,15,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,15,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,15,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,15,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,15,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia16,  -- , h.Fecha, f.fechferiado, datepart(weekday, h.Fecha)  
	  			sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,16,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,16,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,16,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,16,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,16,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia17,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,17,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,17,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,17,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,17,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,17,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia18,
			      	sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,18,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,18,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,18,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,18,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,18,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia19,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,19,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,19,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,19,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,19,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,19,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia20,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,20,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,20,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,20,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,20,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,20,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia21,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,21,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,21,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,21,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,21,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,21,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia22,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,22,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,22,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,22,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,22,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,22,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia23,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,23,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,23,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,23,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,23,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,23,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia24,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,24,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,24,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,24,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,24,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,24,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia25,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,25,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,25,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,25,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,25,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,25,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia26,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,26,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,26,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,26,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,26,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,26,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia27,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,27,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,27,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,27,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,27,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,27,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia28,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,28,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,28,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,28,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,28,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,28,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia29,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,29,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,29,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,29,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,29,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,29,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia30,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,31,@fecini )  THEN h.exismarca  ELSE (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,31,@fecini )  THEN	7 ELSE 0 end) else 0 end ) end)  ELSE (CASE f.FECHFERIADo when  null  then (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,31,@fecini )  THEN 7 ELSE 0 end) else 0 end ) else (CASE dateadd(day,31,@fecini ) when  f.FECHFERIADo  then 2 else (CASE when datepart(weekday, h.Fecha) in (1,7)  then (CASE h.Fecha  WHEN dateadd(day,31,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia31  -- , h.Fecha, f.fechferiado, datepart(weekday, h.Fecha)
	FROM tCsRhControl h  left join tclferiados f on h.fecha = f.fechferiado and   h.codoficina = f.codoficina 
				     inner join tCsEmpleados e on e.codusuario=h.codusuario        
        where  h.fecha >= @fecini AND h.fecha <= @fecfin   and  h.codoficina between @cond1 and @cond2  and  codempleado between @cond3 and @cond4
          and estado = 1
	GROUP BY codempleado
        order by codempleado


  -- Modifica valores de acuerdo a incidencias

  declare Asis_cursor cursor for	
	select empleado, Dia1, Dia2, Dia3, Dia4, Dia5, Dia6, Dia7, Dia8, Dia9, Dia10, Dia11, Dia12, Dia13, Dia14, Dia15,
	       Dia16, Dia17, Dia18, Dia19, Dia20, Dia21, Dia22, Dia23, Dia24, Dia25, Dia26, Dia27, Dia28, Dia29, Dia30, Dia31
        from #Asistencia

  open Asis_cursor
  fetch next from Asis_cursor into @empleado, @Dia1, @Dia2, @Dia3, @Dia4, @Dia5, @Dia6, @Dia7, @Dia8, @Dia9, @Dia10, @Dia11, @Dia12, @Dia13, @Dia14, @Dia15,
				   @Dia16, @Dia17, @Dia18, @Dia19, @Dia20, @Dia21, @Dia22, @Dia23, @Dia24, @Dia25,@Dia26,@Dia27,@Dia28,@Dia29,@Dia30, @Dia31
  WHILE @@FETCH_STATUS = 0
	BEGIN
        if @dia1 = '2' or @dia1 = '7'  select @dia1 = 'D'  else    if @dia1 = '1' select @dia1 = 'X'   else if @dia1 = '0' select @dia1 = 'F'  else select @dia1 = 'ND'
        if @dia2 = '2' or @dia2 = '7'  select @dia2 = 'D'  else    if @dia2 = '1' select @dia2 = 'X'   else if @dia2 = '0' select @dia2 = 'F'  else select @dia2 = 'ND'
        if @dia3 = '2' or @dia3 = '7'  select @dia3 = 'D'  else    if @dia3 = '1' select @dia3 = 'X'   else if @dia3 = '0' select @dia3 = 'F'  else select @dia3 = 'ND'
        if @dia4 = '2' or @dia4 = '7'  select @dia4 = 'D'  else    if @dia4 = '1' select @dia4 = 'X'   else if @dia4 = '0' select @dia4 = 'F'  else select @dia4 = 'ND'
        if @dia5 = '2' or @dia5 = '7'  select @dia5 = 'D'  else    if @dia5 = '1' select @dia5 = 'X'   else if @dia5 = '0' select @dia5 = 'F'  else select @dia5 = 'ND'
        if @dia6 = '2' or @dia6 = '7'  select @dia6 = 'D'  else    if @dia6 = '1' select @dia6 = 'X'   else if @dia6 = '0' select @dia6 = 'F'  else select @dia6 = 'ND'
        if @dia7 = '2' or @dia7 = '7'  select @dia7 = 'D'  else    if @dia7 = '1' select @dia7 = 'X'   else if @dia7 = '0' select @dia7 = 'F'  else select @dia7 = 'ND'
        if @dia8 = '2' or @dia8 = '7'  select @dia8 = 'D'  else    if @dia8 = '1' select @dia8 = 'X'   else if @dia8 = '0' select @dia8 = 'F'  else select @dia8 = 'ND'
        if @dia9 = '2' or @dia9 = '7'  select @dia9 = 'D'  else    if @dia9 = '1' select @dia9 = 'X'   else if @dia9 = '0' select @dia9 = 'F'  else select @dia9 = 'ND'
        if @dia10 = '2' or @dia10 = '7' select @dia10= 'D'  else    if @dia10= '1' select @dia10= 'X'   else if @dia10= '0' select @dia10= 'F'  else select @dia10= 'ND'
        if @dia11 = '2' or @dia11= '7'  select @dia11= 'D'  else    if @dia11= '1' select @dia11= 'X'   else if @dia11= '0' select @dia11= 'F'  else select @dia11= 'ND'
        if @dia12 = '2' or @dia12= '7'  select @dia12= 'D'  else    if @dia12= '1' select @dia12= 'X'   else if @dia12= '0' select @dia12= 'F'  else select @dia12= 'ND'
        if @dia13 = '2' or @dia13= '7'  select @dia13= 'D'  else    if @dia13= '1' select @dia13= 'X'   else if @dia13= '0' select @dia13= 'F'  else select @dia13= 'ND'
        if @dia14 = '2' or @dia14= '7'  select @dia14= 'D'  else    if @dia14= '1' select @dia14= 'X'   else if @dia14= '0' select @dia14= 'F'  else select @dia14= 'ND'
        if @dia15 = '2' or @dia15= '7'  select @dia15= 'D'  else    if @dia15= '1' select @dia15= 'X'   else if @dia15= '0' select @dia15= 'F'  else select @dia15= 'ND'
        if @dia16 = '2' or @dia16= '7'  select @dia16= 'D'  else    if @dia16= '1' select @dia16= 'X'   else if @dia16= '0' select @dia16= 'F'  else select @dia16= 'ND'
        if @dia17 = '2' or @dia17= '7'  select @dia17= 'D'  else    if @dia17= '1' select @dia17= 'X'   else if @dia17= '0' select @dia17= 'F'  else select @dia17= 'ND'
        if @dia18 = '2' or @dia18= '7'  select @dia18= 'D'  else    if @dia18= '1' select @dia18= 'X'   else if @dia18= '0' select @dia18= 'F'  else select @dia18= 'ND'
        if @dia19 = '2' or @dia19= '7'  select @dia19= 'D'  else    if @dia19= '1' select @dia19= 'X'   else if @dia19= '0' select @dia19= 'F'  else select @dia19= 'ND'
        if @dia20 = '2' or @dia20= '7'  select @dia20= 'D'  else    if @dia20= '1' select @dia20= 'X'   else if @dia20= '0' select @dia20= 'F'  else select @dia20= 'ND'
        if @dia21 = '2' or @dia21= '7'  select @dia21= 'D'  else    if @dia21= '1' select @dia21= 'X'   else if @dia21= '0' select @dia21= 'F'  else select @dia21= 'ND'
        if @dia22 = '2' or @dia22= '7'  select @dia22= 'D'  else    if @dia22= '1' select @dia22= 'X'   else if @dia22= '0' select @dia22= 'F'  else select @dia22= 'ND'
        if @dia23 = '2' or @dia23= '7'  select @dia23= 'D'  else    if @dia23= '1' select @dia23= 'X'   else if @dia23= '0' select @dia23= 'F'  else select @dia23= 'ND'
        if @dia24 = '2' or @dia24= '7'  select @dia24= 'D'  else    if @dia24= '1' select @dia24= 'X'   else if @dia24= '0' select @dia24= 'F'  else select @dia24= 'ND'
        if @dia25 = '2' or @dia25= '7'  select @dia25= 'D'  else    if @dia25= '1' select @dia25= 'X'   else if @dia25= '0' select @dia25= 'F'  else select @dia25= 'ND'
        if @dia26 = '2' or @dia26= '7'  select @dia26= 'D'  else    if @dia26= '1' select @dia26= 'X'   else if @dia26= '0' select @dia26= 'F'  else select @dia26= 'ND'
        if @dia27 = '2' or @dia27= '7'  select @dia27= 'D'  else    if @dia27= '1' select @dia27= 'X'   else if @dia27= '0' select @dia27= 'F'  else select @dia27= 'ND'
        if @dia28 = '2' or @dia28= '7'  select @dia28= 'D'  else    if @dia28= '1' select @dia28= 'X'   else if @dia28= '0' select @dia28= 'F'  else select @dia28= 'ND'
        if @dia29 = '2' or @dia29= '7'  select @dia29= 'D'  else    if @dia29= '1' select @dia29= 'X'   else if @dia29= '0' select @dia29= 'F'  else select @dia29= 'ND'
        if @dia30 = '2' or @dia30= '7'  select @dia30= 'D'  else    if @dia30= '1' select @dia30= 'X'   else if @dia30= '0' select @dia30= 'F'  else select @dia30= 'ND'
        if @dia31 = '2' or @dia31= '7'  select @dia31= 'D'  else    if @dia31= '1' select @dia31= 'X'   else if @dia31= '0' select @dia31= 'F'  else select @dia31= 'ND'


	update #Asistencia set   dia1 = @dia1,  dia2 = @dia2,  dia3 = @dia3,  dia4 = @dia4,  dia5 = @dia5,  dia6 = @dia6,  dia7 = @dia7,  dia8 = @dia8, 
				 dia9 = @dia9,  dia10 = @dia10,  dia11 = @dia11,  dia12 = @dia12,  dia13 = @dia13,  dia14 = @dia14,  dia15 = @dia15,  dia16 = @dia16, 
				 dia17 = @dia17,  dia18 = @dia18,  dia19 = @dia19,  dia20 = @dia20,  dia21 = @dia21,  dia22 = @dia22,  dia23 = @dia23,  dia24 = @dia24, 
				 dia25 = @dia25,  dia26 = @dia26,  dia27 = @dia27,  dia28 = @dia28,  dia29 = @dia29,  dia30 = @dia30,  dia31 = @dia31 
         where empleado = @empleado        
      
        fetch next from Asis_cursor into  @empleado, @Dia1, @Dia2, @Dia3, @Dia4, @Dia5, @Dia6, @Dia7, @Dia8, @Dia9, @Dia10, @Dia11, @Dia12, @Dia13, @Dia14, @Dia15,
			@Dia16, @Dia17, @Dia18, @Dia19, @Dia20, @Dia21, @Dia22, @Dia23, @Dia24, @Dia25,@Dia26,@Dia27,@Dia28,@Dia29,@Dia30, @Dia31

  end

 CLOSE Asis_cursor
 DEALLOCATE Asis_cursor

   -- Arma query para consulta final
   select @SqlStr = ''
   select @FDiaIni = datepart(dd,@fecini)
   select @FDiaFin = datepart(dd,@fecfin)
   select @i = 1

   while (@FdiaIni <= @FDiaFin )
   	begin
	

        select @dia = 'dia' + cast(@i as varchar(3))
	if (@FdiaIni = @FDiaFin )
		select @SqlStr = @SqlStr + @dia + ' as DIA' + cast(@FDiaIni as varchar(3)) 
        else
		select @SqlStr = @SqlStr + @dia + ' as DIA' + cast(@FDiaIni as varchar(3)) + ','
        select @FDiaIni = @FDiaIni + 1
        select @i = @i + 1
        end

   select @SqlStr = ' Select empleado,' + @SqlStr + ' from #Asistencia '


   exec (@SqlStr)        

   drop table #Asistencia

end

-- drop procedure pCsRhAsistencia

GO