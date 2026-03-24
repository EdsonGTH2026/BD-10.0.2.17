SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsExLiquidadosAsesor
create procedure [dbo].[pCsExLiquidadosAsesor] @fecha smalldatetime,@codasesor varchar(15),@t int
as

--declare @t int
--set @t=3
--Declare @fecha smalldatetime
--set @fecha='20150615'
--declare @codasesor varchar(15)
--set @codasesor='VSG0406881'

Declare @quin tinyint
set @quin= case when day(@fecha)<=15 then 1 else 2 end

DECLARE @fec_1ra SMALLDATETIME
DECLARE @fec_2da SMALLDATETIME

DECLARE @FechaIni1 SMALLDATETIME
DECLARE @FechaIni2 SMALLDATETIME

DECLARE @fec_1ra_UltimoDia SMALLDATETIME
SET @fec_1ra   = @fecha
if (@quin=1)
	begin
		SET @FechaIni1 = DateAdd(Day,1,DateAdd(Day, -1, Cast(dbo.fduFechaATexto(@fec_1ra, 'AAAAMM') + '01' As SmallDateTime)))
		set @fec_1ra_UltimoDia=Cast(dbo.fduFechaATexto(@fec_1ra, 'AAAAMM') + '15' As SmallDateTime)		
	end
else
	begin
		SET @FechaIni1 = Cast(dbo.fduFechaATexto(@fec_1ra, 'AAAAMM') + '16' As SmallDateTime)
		select @fec_1ra_UltimoDia=ultimodia from tclperiodo where periodo=dbo.fduFechaATexto(@fec_1ra, 'AAAAMM')
	end

SET @fec_2da   = DateAdd(d,-1,@FechaIni1)
if (@quin=1)
	begin
		SET @FechaIni2 = Cast(dbo.fduFechaATexto(@fec_2da, 'AAAAMM') + '16' As SmallDateTime)
	end
else
	begin
		SET @FechaIni2 = DateAdd(Day,1,DateAdd(Day, -1, Cast(dbo.fduFechaATexto(@fec_2da, 'AAAAMM') + '01' As SmallDateTime)))
	end

--select @fec_1ra '@fec_1ra'
--select @fec_2da '@fec_2da'
--select @FechaIni1 '@FechaIni1'
--select @FechaIni2 '@FechaIni2'

declare @codproducto table(codproducto varchar(3))
if (@t=1)
begin
	insert into @codproducto
	select codproducto from tcaproducto where codproducto not in ('156','164')
end
if (@t=2)
begin
	insert into @codproducto values('156')	
end
if (@t=3)
begin
	insert into @codproducto values('164')
end

select an.codprestamo,cl.nombrecompleto cliente,an.saldocartera,p.cancelacion
from(
  SELECT c.fecha, c.codprestamo, c.codasesor, sum(cd.saldocapital) saldocapital
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario
  where c.fecha=@fec_1ra
  and c.cartera='ACTIVA'
  and c.codproducto in (select codproducto from @codproducto)
  and c.codasesor=@codasesor
  group by c.fecha, c.codprestamo, c.codasesor
) ac
right outer join (
  SELECT c.fecha, c.codprestamo,c.codasesor
  ,cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido saldocartera
  FROM tCsCartera c with(nolock) inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fec_2da
  and c.cartera='ACTIVA'
  and c.codproducto in (select codproducto from @codproducto)
  and c.codasesor=@codasesor
) an
on ac.codprestamo=an.codprestamo and ac.codasesor=an.codasesor
left outer join (--liquidado
    select codprestamo, codusuario,cancelacion from tcspadroncarteradet with(nolock)
    where estadocalculado='CANCELADO'  and codproducto in (select codproducto from @codproducto)
		and cancelacion>=@FechaIni1 and cancelacion<=@fec_1ra
) p on p.codprestamo=an.codprestamo
inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
where ac.fecha is null
and p.cancelacion>=@FechaIni1 and p.cancelacion<=@fec_1ra
GO