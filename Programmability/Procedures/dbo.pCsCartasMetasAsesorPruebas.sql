SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE procedure [dbo].[pCsCartasMetasAsesorPruebas] @fecha varchar(8),@codasesor varchar(15)
as

--declare @fecha varchar(8)
--declare @codasesor varchar(15)
--set @fecha='20140501'
----set @codasesor='FTA2812731'
--set @codasesor='HPA2505811'

declare @fecfin smalldatetime
declare @fecprimerdia smalldatetime
select @fecfin=ultimodia, @fecprimerdia=primerdia from tclperiodo where primerdia<=@fecha and ultimodia>=@fecha

declare @fecini smalldatetime
set @fecini=dateadd(day,-1,@fecprimerdia)

select b.codasesor,
			(select paterno + ' ' + materno+' ' + nombres  from tcsempleados where codusuario=b.codasesor ) as nombre,
			s.saldocartera,
			b.CtesNvos,
			b.RenovacionxPrestamo,
			ms.MsValorProg,
			Mcn.McnValorProg
			,Mcr.McrValorProg,isnull(sa.saldocarteraini,0) saldocarteraini
			,b.moraactual,
			dbo.fduCambiarFormato(cast(DAY(getdate()) as varchar(2)) + ' DE ' +                                               
       case 
			when month(getdate()) = '1' then 'ENERO'                                               
			when month(getdate()) = '2' then 'FEBRERO'                                              
            when month(getdate()) = '3' then 'MARZO'                                              
            when month(getdate()) = '4' then 'ABRIL'                                              
            when month(getdate()) = '5' then 'MAYO'                                       
            when month(getdate()) = '6' then 'JUNIO'                                              
            when month(getdate()) = '7' then 'JULIO'                                              
            when month(getdate()) = '8' then 'AGOSTO'                                              
            when month(getdate()) = '9' then 'SEPTIEMBRE'                                              
            when month(getdate()) = '10' then 'OCTUBRE'                                              
            when month(getdate()) = '11' then 'NOVIEMBRE'                                              
            when month(getdate()) = '12' then 'DICIEMBRE' end                                              
       + ' DEL ' + cast(YEAR(getdate()) as varchar(4))) as fecha,
       dbo.fduCambiarFormato(cast(DAY((select ingreso from tcsempleados where codusuario=b.codasesor )) as varchar(2)) + ' DE ' +                                               
       case 
			when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '1' then 'ENERO'                                               
			when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '2' then 'FEBRERO'                                              
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '3' then 'MARZO'                                              
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '4' then 'ABRIL'                                              
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '5' then 'MAYO'                                       
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '6' then 'JUNIO'                                              
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '7' then 'JULIO'                                              
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '8' then 'AGOSTO'                                              
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '9' then 'SEPTIEMBRE'                                              
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '10' then 'OCTUBRE'                                              
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '11' then 'NOVIEMBRE'                                              
            when month((select ingreso from tcsempleados where codusuario=b.codasesor )) = '12' then 'DICIEMBRE' end                                              
       + ' DEL ' + cast(YEAR((select ingreso from tcsempleados where codusuario=b.codasesor )) as varchar(4)))  as Ingreso,
       (select descoficina from tcloficinas where codoficina=(select codoficina from tcsempleados where codusuario=b.codasesor)) as oficina,
        ( select paterno + ' ' + materno+' ' + nombres  from tcsempleados where codusuario like
       (SELECT  case when len(para.codencargadoca)=12 then substring(para.codencargadoca,3,10)
										when len(para.codencargadoca)=11 then substring(para.codencargadoca,2,10) end
       
        FROM [10.0.2.14].[Finmas].dbo.tCaClParametros para where para.codoficina=
       (select codoficina from tcloficinas where codoficina=(select codoficina from tcsempleados where codusuario=b.codasesor)))
       ) as gerente,
       (SELECT count(distinct(p.codusuario))
FROM [FinamigoConsolidado].[dbo].[tCsPadronCarteraDet] p
inner join tcscartera c on p.fechacorte=c.fecha and p.codprestamo=c.codprestamo
--where dbo.fdufechaaperiodo(desembolso)=substring('20140401',0,7)
--and c.codasesor='MGM2602111'  and p.secuenciacliente=1) as clientesnuevos
where dbo.fdufechaaperiodo(desembolso)=substring(@fecha,0,7)
and c.codasesor=@codasesor  and p.secuenciacliente=1) as clientesnuevos,
(SELECT count(distinct(p.codusuario))
FROM [FinamigoConsolidado].[dbo].[tCsPadronCarteraDet] p
inner join tcscartera c on p.fechacorte=c.fecha and p.codprestamo=c.codprestamo
--where dbo.fdufechaaperiodo(desembolso)=substring('20140401',0,7)
--and c.codasesor='MGM2602111'  and p.secuenciacliente=1) as clientesnuevos
where dbo.fdufechaaperiodo(desembolso)=substring(@fecha,0,7)
and c.codasesor=@codasesor  and p.secuenciacliente<>1) as clientesrenovados,
(select 100-((sum(case when d.nrodiasatraso<>0 then d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido
else 0 end)/sum(d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido))*100) normalidad
from(
SELECT c.codasesor,c.nrodiasatraso,cd.saldocapital, cd.interesvigente,cd.interesvencido,cd.moratoriovigente,cd.moratoriovencido
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fecha and c.cartera='ACTIVA' 
  and c.codasesor=@codasesor ) d) as normalidad,
  case 
			when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '1' then 'Enero'                                               
			when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '2' then 'Febrero'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '3' then 'Marzo'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '4' then 'Abril'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '5' then 'Mayo'                                       
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '6' then 'Junio'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '7' then 'Julio'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '8' then 'Agosto'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '9' then 'Septiembre'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '10' then 'Octubre'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '11' then 'Noviembre'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,getdate())+1,0)) )) = '12' then 'Diciembre' end as messiguiente,
           
           case 
			when month(getdate()) = '1' then 'Enero'                                               
			when month(getdate()) = '2' then 'Febrero'                                              
            when month(getdate()) = '3' then 'Marzo'                                              
            when month(getdate()) = '4' then 'Abril'                                              
            when month(getdate()) = '5' then 'Mayo'                                       
            when month(getdate()) = '6' then 'Junio'                                              
            when month(getdate()) = '7' then 'Julio'                                              
            when month(getdate()) = '8' then 'Agosto'                                              
            when month(getdate()) = '9' then 'Septiembre'                                              
            when month(getdate()) = '10' then 'Octubre'                                              
            when month(getdate()) = '11' then 'Noviembre'                                              
            when month(getdate()) = '12' then 'Diciembre' end  as mesactual ,
           (select valorprog from tcsbsmetaxUEn  where icodtipobs='5' and icodindicador='11' and fecha=@fecfin and ncamvalor=@codasesor)  as metasnuevos,
           (select valorprog from tcsbsmetaxUEn  where icodtipobs='5' and icodindicador='12' and fecha=@fecfin and ncamvalor=@codasesor ) as metasrenovados,
           (select valorprog from tcsbsmetaxUEn  where icodtipobs='5' and icodindicador='3' and fecha=@fecfin  and ncamvalor=@codasesor) as metasrecuperacion
           
          
      
--from tCsRptBonoCartera b
from 
	(select * from tCsRptBonoCartera 
	 union select * from tCsRptBonoComunal
	)b
inner join (
  SELECT c.codasesor,sum(cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocartera
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codasesor=@codasesor
  group by c.codasesor
) s on s.codasesor=b.codasesor
inner join (
  SELECT ncamvalor codasesor,ValorProg MsValorProg
  FROM tCsBsMetaxUEN with(nolock)
  where icodindicador=2 and icodtipobs=5 
  and fecha=@fecfin and ncamvalor=@codasesor
) ms on ms.codasesor=b.codasesor
inner join (
  SELECT ncamvalor codasesor,ValorProg McnValorProg
  FROM tCsBsMetaxUEN with(nolock)
  where icodindicador=11 and icodtipobs=5 
  and fecha=@fecfin and ncamvalor=@codasesor
) mcn on mcn.codasesor=b.codasesor
inner join (
  SELECT ncamvalor codasesor,ValorProg McrValorProg
  FROM tCsBsMetaxUEN with(nolock)
  where icodindicador=12 and icodtipobs=5 
  and fecha=@fecfin and ncamvalor=@codasesor
) mcr on mcr.codasesor=b.codasesor
left outer join (
  SELECT c.codasesor,sum(cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocarteraini
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fecini and c.cartera='ACTIVA'
  and c.codasesor=@codasesor
  group by c.codasesor
) sa on sa.codasesor=b.codasesor
where b.codasesor=@codasesor

 print @fecha
print  @fecfin
GO