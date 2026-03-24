SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsEstadoCuentaCarteraPAGO2022]  
    @CodPrestamo char(19),  
    @FechaIni datetime,  
    @FechaCorte datetime  
AS  
BEGIN

-------------------------------------------------------
--FECHA DE INICIO Y FINAL DEL PERIODO

declare @fechainfin table(fechafin datetime, fechain datetime, codprestamo varchar(20))
insert into @fechainfin
select  distinct(cancelacion),@FechaIni, codprestamo
from tcspadroncarteradet with(nolock)
where codprestamo=@CodPrestamo

declare @fechainfindet table(fechain datetime, fechafin datetime, codprestamo varchar(20))
insert into @fechainfindet
select case when fechain>fechafin and fechafin is not null then fechafin else fechain end 
       ,isnull(fechafin,@fechacorte)
       ,codprestamo
from @fechainfin

--------------------------------
--SALDO INICIAL Y FINAL DEL PERIODO

declare  @Fechasaldoini smalldatetime
set @Fechasaldoini=@FechaIni -1

declare @saldoin table(saldoinicial money, codprestamo varchar(20))
insert into @saldoin 
select saldocapital,
       codprestamo
FROM tcscarteradet   with(nolock)
where codprestamo=@CodPrestamo and fecha=@Fechasaldoini

declare @saldofin table(saldofinal money, codprestamo varchar(20))
insert into @saldofin
select saldocapital,
       codprestamo
FROM tcscarteradet   with(nolock)
where codprestamo=@CodPrestamo and fecha=@Fechacorte

-------------------------------------
-- PAGO DEL PERIODO

Declare @cuota table(cuota int)
insert into @cuota
select max(seccuota)
from tcspadronplancuotas with (nolock)  
where fechavencimiento>=@FechaIni and fechavencimiento<= @FechaCorte and codprestamo=@CodPrestamo 

declare @pagoperiodo table(montocapital money, montointeres money, montocomision money, otros money, total money, fehlimite datetime, codprestamo  varchar(20))
insert into @pagoperiodo
select isnull(sum(case when codconcepto = 'CAPI' then MontoCuota end),0) as montocapital,
       isnull(sum(case when codconcepto in ('INPE','IVAMO','INTE','IVAIT') then MontoCuota end),0) as montointeres,
       isnull(sum(case when codconcepto in ('PAGTA','MORA') then MontoCuota end),0) as comisiongen,
       isnull(sum(case when codconcepto not in ('CAPI','PAGTA','MORA','INPE','IVAMO','INTE','IVAIT') then MontoCuota end),0) as otros,
       isnull(sum(MontoCuota),0) as total,
       case when max(fechavencimiento) is null then '-' else  max(fechavencimiento) end as fechalimite,
       max(codprestamo) as codprestamo
from tcspadronplancuotas c with (nolock)
inner join @cuota as t on c.seccuota = t.cuota
where codprestamo=@CodPrestamo 


---------------------------------------
--Consulta de saldos - se tomo como base el procedimiento que ya estaba tomando solo las columnas a usar
 Declare @saldos table(estado varchar(20),
                       codprestamo varchar(20),
                       saldocapital money,
                       saldointeres money,
                       cargomora money,
                       saldomoratorio money,
                       iva money,
                       saldototal money)

 declare @CodOficina varchar(3)  
 declare @Estado varchar(20)  
 declare @UltimaFechaCartera datetime  
 if exists (select 1 from tcscartera with(nolock) where fecha = @FechaCorte and codprestamo = @Codprestamo)  
 begin  
     set @UltimaFechaCartera = @FechaCorte  
  
  select @Estado = Estado from tcscartera with(nolock)  
  where codprestamo = @Codprestamo  
  and Fecha = @UltimaFechaCartera  
  insert into @saldos 
  select @Estado as Estado,  
          CodPrestamo,  
          SaldoCapital,
         (InteresVigente + InteresVencido + InteresCtaOrden )as SaldoInteres, 
         CargoMora,
         (MoratorioVigente + MoratorioVencido + MoratorioCtaOrden) as SaldoMoratorio,
         Impuestos,
         (SaldoCapital + (InteresVigente + InteresVencido + InteresCtaOrden) + (MoratorioVigente + MoratorioVencido + MoratorioCtaOrden) +  Impuestos + CargoMora) + isnull(OtrosCargos,0) as 'SaldoTotal' 
  from tCsCarteraDet with(nolock)  
  where codprestamo = @Codprestamo  
  and Fecha = @UltimaFechaCartera  
 end  
 else  
    -- select @UltimaFechaCartera = max(Fecha) from tcscartera where codprestamo = @Codprestamo  
 begin  
  select @UltimaFechaCartera = max(Fecha) from tcscartera with(nolock) where codprestamo = @Codprestamo  
  select @Estado = estado from tcscartera with(nolock) where codprestamo = @Codprestamo and fecha = @UltimaFechaCartera  
  --set @Estado = 'PAGADO'  
  insert into @saldos 
  select @Estado as Estado,  
         @Codprestamo as CodPrestamo,
         0 as SaldoCapital, 
         0 as SaldoInteres, 
         0 as CargoMora,
         0 as SaldoMoratorio,  
          0 as Impuestos,
          0 as 'SaldoTotal'  
 end  
 
-------------
--CONSULTA FINAL
select p.codprestamo,
       p.montocapital,
       p.montointeres,
       p.montocomision,
       p.otros,
       p.total,
       p.fehlimite,
       f.fechafin,
       f.fechain,
       si.saldoinicial,
       sf.saldofinal,
       sa.estado,
       sa.saldocapital,
       sa.saldointeres,
       sa.cargomora,
       sa.saldomoratorio,
       sa.iva,
       sa.saldototal
from @pagoperiodo as p
inner join @fechainfindet as f on p.codprestamo = f.codprestamo
inner join @saldoin as si on p.codprestamo = si.codprestamo
inner join @saldofin as sf on p.codprestamo = sf.codprestamo
inner join @saldos as sa on p.codprestamo = sa.codprestamo

END
GO