SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduTablaSemanaPeriodosFuturos] (@Tperiodo varchar(200))  
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
--set nocount on
--declare @Tperiodo varchar(200)
--set @Tperiodo='201501,201502,201503,201504'

declare @tb_periodo table(
	periodo	varchar(6),
	PrimerDia as cast(periodo+'01' as smalldatetime),
	UltimoDia as dateadd(d,-1,dateadd(m,1, CAST (periodo+'01' as smalldatetime)))
)

insert into @tb_periodo
select periodo from tclperiodo with(nolock)
where periodo collate Modern_Spanish_CI_AI in(select codigo from dbo.fduTablaValores(@tperiodo)) 

insert into @tb_periodo
select codigo from dbo.fduTablaValores(@tperiodo)
where codigo collate Modern_Spanish_CI_AI not in (
select periodo from tclperiodo with(nolock) )

--select * from @tb_periodo

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

--select * from tclperiodo with(nolock)
--where periodo in(select codigo from dbo.fduTablaValores(@tperiodo))

DECLARE genxgrupo CURSOR FOR 
  select codigo from dbo.fduTablaValores(@tperiodo)
OPEN genxgrupo

FETCH NEXT FROM genxgrupo 
INTO @periodo

WHILE @@FETCH_STATUS = 0
BEGIN
	if(substring(@periodo,5,2)='02')
	begin set @n=3 end else begin set @n=4 end
  --set @n=4
	--print substring(@periodo,5,2)
  --print '@n' + str(@n) 
  select @primerdia=primerdia,@ultimodia=ultimodia from @tb_periodo where periodo=@periodo
  --select @primerdiaant=primerdia,@ultimodiaant=ultimodia from @tb_periodo where periodo=dbo.fduFechaAPeriodo(dateadd(month,-1,@ultimodia)) 
	--print '---->>>>>>'
  insert into @se
  values(datepart(week,@primerdia),@primerdia,dateadd(day,7 - datepart(dw, @primerdia) + 1,@primerdia),@periodo)
	--select * from @se
  declare @pdtmp smalldatetime
  set @pdtmp=@primerdia
	--print @periodo
  while @n>0
   begin
    set @pdtmp=dateadd(day,7 - datepart(dw, @pdtmp) + 2,@pdtmp)
		
		--print datepart(week,@pdtmp)
		--print @pdtmp 
		--print dateadd(day,7 - datepart(dw, @pdtmp) + 1,@pdtmp)

    insert into @se
    values(datepart(week,@pdtmp),@pdtmp,dateadd(day,7 - datepart(dw, @pdtmp) + 1,@pdtmp),@periodo)
    --print @n
    if(@n=1)
      begin
        update @se
        set fechafin=(select ultimodia from @tb_periodo where periodo=dbo.fduFechaAPeriodo(@pdtmp))
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