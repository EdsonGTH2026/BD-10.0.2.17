SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduTablaSemanaPeriodos] (@Tperiodo varchar(200))  
RETURNS @se TABLE (
      nrosemana int,
      fechaini smalldatetime,
      fechafin smalldatetime,
      periodo varchar(6)
  )
AS  
BEGIN 
--1--domingo
--2--lunes
--3--martes
--4--miercoles
--5--jueves
--6--viernes
--7--sabado
--declare @Tperiodo varchar(200)
--set @Tperiodo='201310,201311,201312,201401'

--declare @se table(
--  nrosemana int,
--  fechaini smalldatetime,
--  fechafin smalldatetime,
--  periodo varchar(6)
--)

declare @n int
declare @periodo varchar(6)
declare @primerdiaant smalldatetime
declare @ultimodiaant smalldatetime
declare @primerdia smalldatetime
declare @ultimodia smalldatetime
  
DECLARE genxgrupo CURSOR FOR 
  select codigo from dbo.fduTablaValores(@tperiodo)
OPEN genxgrupo

FETCH NEXT FROM genxgrupo 
INTO @periodo

WHILE @@FETCH_STATUS = 0
BEGIN
	if(substring(@periodo,5,2)='02')
	begin set @n=3 end else begin set @n=4 end
--  set @n=4
  
  select @primerdia=primerdia,@ultimodia=ultimodia from tclperiodo with(nolock) where periodo=@periodo
  select @primerdiaant=primerdia,@ultimodiaant=ultimodia from tclperiodo with(nolock) where periodo=dbo.fduFechaAPeriodo(dateadd(month,-1,@ultimodia)) 

  insert into @se
  values(datepart(week,@primerdia),@primerdia,dateadd(day,7 - datepart(dw, @primerdia) + 1,@primerdia),@periodo)
  --select datepart(week,'20130701')
  --select datepart(dw, '20130701')
  declare @pdtmp smalldatetime
  set @pdtmp=@primerdia

  while @n>0
   begin
    set @pdtmp=dateadd(day,7 - datepart(dw, @pdtmp) + 2,@pdtmp)
    insert into @se
    values(datepart(week,@pdtmp),@pdtmp,dateadd(day,7 - datepart(dw, @pdtmp) + 1,@pdtmp),@periodo)
    --print @n 
    if(@n=1)
      begin
        update @se
        set fechafin=(select ultimodia from tclperiodo with(nolock) where periodo=dbo.fduFechaAPeriodo(@pdtmp))
        where fechaini=@pdtmp
      end
    set @n=@n-1
   end

	FETCH NEXT FROM genxgrupo 
  INTO @periodo
END

CLOSE genxgrupo
DEALLOCATE genxgrupo

--select * from @se

return
END

GO

GRANT SELECT ON [dbo].[fduTablaSemanaPeriodos] TO [marista]
GO