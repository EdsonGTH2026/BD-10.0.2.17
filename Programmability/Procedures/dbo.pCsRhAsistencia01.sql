SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author     :	<jlmp>
-- Create date: <12,05,2014>
-- Description:	<Listado de asistencia por rango de fechas>
-- =============================================
CREATE PROCEDURE [dbo].[pCsRhAsistencia01] @codoficina varchar(6), @codEmpleado varchar(6), @fecini smalldatetime, @fecfin smalldatetime
AS
BEGIN
--	declare @fecfin smalldatetime
	declare @cond1 varchar(10)
	declare @cond2 varchar(10)
	declare @cond3 varchar(10)
	declare @cond4 varchar(10)

	SET NOCOUNT ON;

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



	SELECT codempleado, 	sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,0,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,0,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,0,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia1,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,1,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,1,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,1,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia2,
			      	sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,2,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,2,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,2,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia3,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,3,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,3,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,3,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia4,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,4,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,4,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,4,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia5,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,5,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,5,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,5,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia6,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,6,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,6,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,6,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia7,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,7,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,7,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,7,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia8,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,8,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,8,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,8,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia9,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,9,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,9,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,9,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia10,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,10,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,10,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,10,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia11,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,11,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,11,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,11,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia12,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,12,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,12,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,12,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia13,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,13,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,13,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,13,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia14,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,14,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,14,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,14,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia15,
				sum(CASE h.exismarca  WHEN 1  THEN (CASE h.Fecha  WHEN dateadd(day,15,@fecini )  THEN h.exismarca  ELSE 0 end)  ELSE (CASE f.FECHFERIADo when  null  then 0 else (CASE dateadd(day,15,@fecini ) when  f.FECHFERIADo  then 2 else (CASE datepart(weekday, h.Fecha) when  7  then (CASE h.Fecha  WHEN dateadd(day,15,@fecini )  THEN 7  ELSE 0 end) else 0 end ) end ) end ) END) dia16  -- , h.Fecha, f.fechferiado, datepart(weekday, h.Fecha)
	FROM tCsRhControl h  left join tclferiados f on h.fecha = f.fechferiado and   h.codoficina = f.codoficina 
				     inner join tCsEmpleados e on e.codusuario=h.codusuario        
        where  h.fecha >= @fecini AND h.fecha <= @fecfin   and  h.codoficina between @cond1 and @cond2  and  codempleado between @cond3 and @cond4
          and estado = 1
	GROUP BY codempleado
        order by codempleado

END


-- drop procedure pCsRhAsistencia01

GO