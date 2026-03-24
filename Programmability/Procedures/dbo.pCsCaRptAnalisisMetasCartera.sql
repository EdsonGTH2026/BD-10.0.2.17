SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaRptAnalisisMetasCartera] @tipo varchar(5),@fecha smalldatetime, @codoficina varchar(5)
AS
BEGIN
	SET NOCOUNT ON;

--declare @fecha smalldatetime
--declare @codoficina varchar(5)
declare @fechaprimer smalldatetime
declare @fechacierre smalldatetime
declare @fechacierrefin smalldatetime

--set @codoficina='6'
--set @fecha='20110509'
select @fechacierre=dateadd(day,-1,primerdia),@fechaprimer=primerdia,@fechacierrefin=ultimodia from tclperiodo where periodo=dbo.fduFechaAPeriodo(@fecha)

create table #cartera (
  agrupador         varchar(200),
  codigo            varchar(25),
  descripcion       varchar(200),
  carteracierreant  decimal(16,2) default(0),
  cartera           decimal(16,2) default(0),
  recuperacion      decimal(16,2) default(0),
  desembolsos       decimal(16,2) default(0),
  carteracierre     decimal(16,2) default(0),
  mcreditonuevo     decimal(16,2) default(0),
  mcarteracierre    decimal(16,2) default(0),
  mtotaldesembolso  decimal(16,2) default(0),
  mporcencumple     decimal(16,2) default(0),
  mdiaria           decimal(16,2) default(0)
)

declare @descripcion varchar(200)
declare @monto decimal(16,2)

--cartera fin de mes anterior
insert #cartera (codigo,descripcion,carteracierreant)
SELECT codigo,asesor,sum(saldocartera) saldocartera from (
SELECT c.CodPrestamo,ase.codusuario codigo ,ase.nombrecompleto asesor,
cd.SaldoCapital + cd.InteresVigente + cd.InteresVencido + cd.MoratorioVigente + cd.MoratorioVencido saldocartera
FROM tCsCartera c inner join tcspadronclientes ase on ase.codusuario=c.codasesor
inner join tcscarteradet cd on cd.fecha=c.fecha and cd.codprestamo=c.codprestamo
where c.codoficina=@codoficina and c.estado not in('CANCELADO','CASTIGADO')
and c.fecha=@fechacierre) a
group by asesor,codigo

--cartera
DECLARE generarcar CURSOR FOR 
  SELECT asesor,sum(saldocartera) saldocartera from (
  SELECT c.CodPrestamo, ase.nombrecompleto asesor,
  cd.SaldoCapital + cd.InteresVigente + cd.InteresVencido + cd.MoratorioVigente + cd.MoratorioVencido saldocartera
  FROM tCsCartera c inner join tcspadronclientes ase on ase.codusuario=c.codasesor
  inner join tcscarteradet cd on cd.fecha=c.fecha and cd.codprestamo=c.codprestamo
  where c.codoficina=@codoficina and c.estado not in('CANCELADO','CASTIGADO')
  and c.fecha=@fecha) a
  group by asesor
OPEN generarcar

FETCH NEXT FROM generarcar
INTO @descripcion,@monto

WHILE @@FETCH_STATUS = 0
BEGIN

  if((SELECT count(*) from #cartera where descripcion=@descripcion)>0)
    begin
      update #cartera
      set cartera=@monto
      where descripcion=@descripcion
    end
  else
    begin
      insert into #cartera(descripcion,cartera)
      values (@descripcion,@monto)
    end

  FETCH NEXT FROM generarcar
  INTO @descripcion,@monto
END

CLOSE generarcar
DEALLOCATE generarcar
   
----recuperaciones
DECLARE generarcar CURSOR FOR 
  SELECT ase.nombrecompleto asesor, SUM(t.MontoCapitalTran + MontoInteresTran + MontoINVETran +MontoINPETran) AS Recuperacion
  FROM tCsTransaccionDiaria t INNER JOIN
  tCsCartera c ON t.Fecha = DATEADD([day], - 1, c.Fecha) AND t.CodigoCuenta = c.CodPrestamo
  inner join tcspadronclientes ase on ase.codusuario=c.codasesor
  WHERE (t.CodSistema = 'CA') AND (t.TipoTransacNivel1 = 'I') AND t.codoficina=@codoficina and
  (t.TipoTransacNivel3 IN ('104', '105', '106')) AND (t.Fecha>=@fechaprimer and t.Fecha<=@Fecha)
  GROUP BY ase.nombrecompleto
OPEN generarcar

FETCH NEXT FROM generarcar
INTO @descripcion,@monto

WHILE @@FETCH_STATUS = 0
BEGIN

  if((SELECT count(*) from #cartera where descripcion=@descripcion)>0)
    begin
      update #cartera
      set recuperacion=@monto
      where descripcion=@descripcion
    end
  else
    begin
      insert into #cartera(descripcion,recuperacion)
      values (@descripcion,@monto)
    end

  FETCH NEXT FROM generarcar
  INTO @descripcion,@monto
END

CLOSE generarcar
DEALLOCATE generarcar
   
----desembolsos
DECLARE generarcar CURSOR FOR 
  SELECT ase.nombrecompleto asesor, SUM(t.montototaltran) AS MontoDesembolso
  FROM tCsTransaccionDiaria t INNER JOIN
  tCsCartera c ON t.Fecha = DATEADD([day], - 1, c.Fecha) AND t.CodigoCuenta = c.CodPrestamo
  inner join tcspadronclientes ase on ase.codusuario=c.codasesor
  WHERE (t.CodSistema = 'CA') AND (t.TipoTransacNivel1 = 'E') AND t.codoficina=6 and
  (t.TipoTransacNivel3 IN ('102')) AND (t.Fecha>=@fechaprimer and t.Fecha<=@Fecha)
   GROUP BY ase.nombrecompleto
OPEN generarcar

FETCH NEXT FROM generarcar
INTO @descripcion,@monto

WHILE @@FETCH_STATUS = 0
BEGIN

  if((SELECT count(*) from #cartera where descripcion=@descripcion)>0)
    begin
      update #cartera
      set desembolsos=@monto
      where descripcion=@descripcion
    end
  else
    begin
      insert into #cartera(descripcion,desembolsos)
      values (@descripcion,@monto)
    end

  FETCH NEXT FROM generarcar
  INTO @descripcion,@monto
END

CLOSE generarcar
DEALLOCATE generarcar

declare @nomoficina varchar(200)
select @nomoficina = nomoficina from tcloficinas where codoficina=@codoficina

update #cartera
set agrupador= 'SUCURSAL: '+@nomoficina

update #cartera
set mcarteracierre=m.valorprog 
from #cartera c
inner join tCsBsMetaxUEN m on c.codigo=m.ncamvalor
where m.fecha=@fechacierrefin

update #cartera
set carteracierre=cartera-recuperacion+desembolsos

update #cartera
set mcreditonuevo=mcarteracierre-carteracierre

update #cartera
set mtotaldesembolso=desembolsos+mcreditonuevo

update #cartera
set mporcencumple=(carteracierre/(case when mcarteracierre=0 then 1 else mcarteracierre end))*100, mdiaria=mtotaldesembolso/day(@fecha)

select * from #cartera

drop table #cartera
END
GO