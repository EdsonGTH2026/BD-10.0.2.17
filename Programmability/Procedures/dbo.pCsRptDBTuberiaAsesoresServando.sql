SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[pCsRptDBTuberiaAsesoresServando] @primerdia smalldatetime, @ultimodia smalldatetime,@codoficina varchar(200) AS

declare @oficinas varchar(200)
--declare @codoficina varchar(200)
--set @codoficina='Todas las Oficinas'

--declare @primerdia smalldatetime
--declare @ultimodia smalldatetime
--set @primerdia='20130901'
--set @ultimodia='20131130'

create table #se(
  nrosemana int,
  fechaini smalldatetime,
  fechafin smalldatetime
)
declare @n int
set @n=53

insert into #se
values(datepart(week,@primerdia),@primerdia,dateadd(day,7 - datepart(dw, @primerdia) + 1,@primerdia))
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



select s.nrosemanarango as 'Semana',  pcd.codoficina as 'Sucursal',ase.nomasesor as 'Asesor',count(pcd.codprestamo) as '# Prestamos',sum(pcd.monto) as 'Monto', '# Nuevos'= count(case when  pcd.secuenciacliente ='1' then '1'  end), 
'# Represtamos'= count (case when pcd.secuenciacliente>'1' then '1'  end)  , dbo.fdufechaaperiodo(s.fechainirango) as 'Fecha'
from tcspadroncarteradet pcd with(nolock) inner join #serango s on pcd.desembolso
 between s.fechainirango and s.fechafinrango 
inner join tcsasesores ase on ase.codasesor =pcd.primerasesor
--and  pcd.codoficina in (select codigo from dbo.fduTablaValores(@codoficina)) group by ase.nomasesor,s.nrosemanarango,pcd.codoficina,s.fechainirango 
and  pcd.codoficina in (select codigo from dbo.fduTablaValores(@oficinas))

group by ase.nomasesor,s.nrosemanarango,pcd.codoficina,s.fechainirango      

                                    
order by pcd.codoficina,ase.nomasesor,s.nrosemanarango


drop table #se
drop table #serango


SELECT     CodOficina
FROM         (SELECT     CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
                       FROM          tClOficinas
                       WHERE      (Tipo in ('Operativo', 'Matriz', 'Servicio','Contable'))
                       UNION
                       SELECT     dbo.fduOficinas(zona), Nombre
                       FROM         tClZona
	          WHERE Nombre<>'INACTIVO'
                       UNION
                       SELECT     dbo.fduOficinas('%'), Nombre = 'Todas las Oficinas') Datos where nomoficina = @codoficina
GO