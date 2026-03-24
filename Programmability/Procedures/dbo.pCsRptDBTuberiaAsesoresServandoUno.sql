SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsRptDBTuberiaAsesoresServandoUno] @primerdia1 varchar(10), @ultimodia1 varchar(10),@codoficina varchar(200) AS

--declare @codoficina varchar(200)
declare @oficinas varchar(200)
declare @primerdia smalldatetime
declare @ultimodia smalldatetime
--declare @ultimodia1 varchar(10)
--declare @primerdia1 varchar(10)

--set @codoficina='06 Tenancingo'


--set @primerdia1='20131101'
--set @ultimodia1='20131130'

set @ultimodia = @ultimodia1
set @primerdia=@primerdia1

create table #se(
  nrosemana int,
  fechaini smalldatetime,
  fechafin smalldatetime
)
declare @n int
set @n=53

insert into #se
values(datepart(week,@primerdia),@primerdia1,dateadd(day,7 - datepart(dw, @primerdia) + 1,@primerdia))
--select datepart(week,'20130701')
--select datepart(dw, '20130701')
declare @pdtmp smalldatetime
set @pdtmp=@primerdia

while @n>0
 begin
  set @pdtmp=dateadd(day,7 - datepart(dw, @pdtmp) + 2,@pdtmp)
  insert into #se
  values(datepart(week,@pdtmp),@pdtmp,dateadd(day,7 - datepart(dw, @pdtmp) + 1,@pdtmp))
  --print @n 
  if(@n=1)
    begin
      update #se
      set fechafin=(select ultimodia from tclperiodo with(nolock) where periodo=dbo.fduFechaAPeriodo(@ultimodia))
      where fechaini=@ultimodia
    end
  set @n=@n-1
 end
--select * from #se

create table #serango(
  nrosemanarango int,
  fechainirango smalldatetime,
  fechafinrango smalldatetime
)

insert into #serango select * from #se where fechafin between @primerdia and @ultimodia

--select * from #serango


/*select s.nrosemana,  pcd.codoficina,pcd.primerasesor,count(pcd.codprestamo) as '# prestamos',sum(pcd.monto) as 'monto', 'Prestamos Nuevos'= count(case when  pcd.secuenciacliente ='1' then '1'  end), 
'Represtamos'= count (case when pcd.secuenciacliente>'1' then '1'  end)  from tcspadroncarteradet pcd with(nolock) inner join #se s on pcd.desembolso between s.fechaini and s.fechafin  
and  pcd.codoficina in (select codigo from dbo.fduTablaValores(@codoficina)) group by pcd.primerasesor,s.nrosemana,pcd.codoficina order by pcd.primerasesor*/

set @oficinas= 
(SELECT   CodOficina FROM         (SELECT     CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
                       FROM          tClOficinas
                       WHERE      (Tipo in ('Operativo', 'Matriz', 'Servicio','Contable'))
                       UNION
                       SELECT     dbo.fduOficinas(zona), Nombre
                       FROM         tClZona
              WHERE Nombre<>'INACTIVO'
                       UNION
                       SELECT     dbo.fduOficinas('%'), Nombre = 'Todas las Oficinas') Datos where nomoficina=@codoficina)

/*SELECT ('Semana '+ cast(x.Semana as varchar)) as Semana,( select nomoficina from tcloficinas where codoficina= x.Sucursal) as Sucursal, x.primerasesor, ase.nomasesor as Asesor,
       --pcd.codprestamo, pcd.monto monto, case when pcd.secuenciacliente>'1' then '1' else 0 end Represtamos,
       ('Prestamos: '+cast(count(x.codprestamo) as varchar)) as Prestamos,sum(x.monto) monto,('Nuevos: '+cast(count(case when x.secuenciacliente='1' then '1' end) as  varchar)) as Nuevos, 
       ('Represtamos: '+cast(count(case when x.secuenciacliente>'1' then '1' end) as varchar)) as Represtamos, 
       x.Fecha
       --select * from tcspadroncarteradet
  FROM (select distinct pcd.codoficina, s.nrosemanarango Semana, pcd.codoficina Sucursal, pcd.primerasesor, 
               codprestamo, monto, secuenciacliente, dbo.fdufechaaperiodo(s.fechainirango) Fecha
          from tcspadroncarteradet pcd with(nolock)
         inner join #serango s on pcd.desembolso between s.fechainirango and s.fechafinrango 
         where pcd.codoficina in (select codigo from dbo.fduTablaValores(@oficinas))
        ) x
 inner join tcsasesores ase on ase.codasesor =x.primerasesor and ase.codoficina =  x.codoficina   
 --select * from tcsasesores
  --(select codigo from dbo.fduTablaValores(@oficinas))       
 --group by Semana, Sucursal, primerasesor, ase.nomasesor, x.fecha,x.codoficina--, s.fechafinrango   
 --order by Semana, cast(x.sucursal as integer),PrimerAsesor

group by  Sucursal,Semana, primerasesor, ase.nomasesor, x.fecha,x.codoficina--, s.fechafinrango   
 order by cast(x.sucursal as integer),Semana,PrimerAsesor */

SELECT x.Semana ,( select nomoficina from tcloficinas where codoficina= x.Sucursal) as Sucursal, x.primerasesor, ase.nomasesor as Asesor,
       --pcd.codprestamo, pcd.monto monto, case when pcd.secuenciacliente>'1' then '1' else 0 end Represtamos,
       count(x.codprestamo) Prestamos, sum(x.monto) monto,count(case when x.secuenciacliente='1' then '1' end) Nuevos, count(case when x.secuenciacliente>'1' then '1' end) Represtamos, 
       x.Fecha
       --select * from tcspadroncarteradet
  FROM (select distinct pcd.codoficina, s.nrosemanarango Semana, pcd.codoficina Sucursal, pcd.primerasesor, 
               codprestamo, monto, secuenciacliente, dbo.fdufechaaperiodo(s.fechainirango) Fecha
          from tcspadroncarteradet pcd with(nolock)
         inner join #serango s on pcd.desembolso between s.fechainirango and s.fechafinrango 
         where pcd.codoficina in (select codigo from dbo.fduTablaValores(@oficinas))
        ) x
 inner join tcsasesores ase on ase.codasesor =x.primerasesor and ase.codoficina =  x.codoficina   
 --select * from tcsasesores
  --(select codigo from dbo.fduTablaValores(@oficinas))       
 --group by Semana, Sucursal, primerasesor, ase.nomasesor, x.fecha,x.codoficina--, s.fechafinrango   
 --order by Semana, cast(x.sucursal as integer),PrimerAsesor

group by  Sucursal,Semana, primerasesor, ase.nomasesor, x.fecha,x.codoficina--, s.fechafinrango   
 order by cast(x.sucursal as integer),Semana,PrimerAsesor 
 
 
 drop table #se
 drop table #seran
GO