SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE procedure [dbo].[pCsCartasMetasAsesor] @fecha smalldatetime,@codasesor varchar(15)

as 

--pCsCartasMetasAsesor '2014-05-01 00:00:00','FTA2812731'

--declare @fecha smalldatetime
--declare @codasesor varchar(15)
--set @fecha='20140528'
------set @codasesor='FTA2812731'
--set @codasesor='HPA2505811'


declare @fecfin smalldatetime
declare @fecprimerdia smalldatetime
select @fecfin=ultimodia, @fecprimerdia=primerdia from tclperiodo where primerdia<=@fecha and ultimodia>=@fecha

print @fecha
print @fecfin
print @fecprimerdia

declare @fecini smalldatetime
set @fecini=dateadd(day,-1,@fecprimerdia)

select b.codasesor,(select paterno + ' ' + materno+' ' + nombres  from tcsempleados where codusuario=b.codasesor ) as nombre,isnull(s.saldocartera,0) saldocartera,b.CtesNvos,b.RenovacionxPrestamo,ms.MsValorProg,
Mcn.McnValorProg,Mcr.McrValorProg,isnull(sa.saldocarteraini,0) saldocarteraini,b.moraactual,dbo.fduCambiarFormato(cast(DAY(@fecha) as varchar(2)) + ' DE ' +                                               
       case 
			when month(@fecha) = '1' then 'ENERO'                                               
			when month(@fecha) = '2' then 'FEBRERO'                                              
            when month(@fecha) = '3' then 'MARZO'                                              
            when month(@fecha) = '4' then 'ABRIL'                                              
            when month(@fecha) = '5' then 'MAYO'                                       
            when month(@fecha) = '6' then 'JUNIO'                                              
            when month(@fecha) = '7' then 'JULIO'                                              
            when month(@fecha) = '8' then 'AGOSTO'                                              
            when month(@fecha) = '9' then 'SEPTIEMBRE'                                              
            when month(@fecha) = '10' then 'OCTUBRE'                                              
            when month(@fecha) = '11' then 'NOVIEMBRE'                                              
            when month(@fecha) = '12' then 'DICIEMBRE' end                                              
       + ' DEL ' + cast(YEAR(@fecha) as varchar(4))) as fecha, 
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
       (select substring(NomOficina,1,1) + LOWER(substring(NomOficina,2,len(NomOficina))) from tcloficinas where codoficina=(select codoficina from tcsempleados where codusuario=b.codasesor)) as oficina,
       ( select paterno + ' ' + materno+' ' + nombres  from tcsempleados where codusuario like
       (SELECT  case when len(para.codencargadoca)=12 then substring(para.codencargadoca,3,10)
										when len(para.codencargadoca)=11 then substring(para.codencargadoca,2,10) end
       
        FROM [10.0.2.14].[Finmas].dbo.tCaClParametros para where para.codoficina=
       (select codoficina from tcloficinas where codoficina=(select codoficina from tcsempleados where codusuario=b.codasesor)))
       ) as gerente,
       (SELECT count(distinct(p.codusuario))
FROM [FinamigoConsolidado].[dbo].[tCsPadronCarteraDet] p
inner join tcscartera c on p.fechacorte=c.fecha and p.codprestamo=c.codprestamo
where desembolso between @fecprimerdia and @fecfin
and c.codasesor=@codasesor  and p.secuenciacliente=1) as clientesnuevos,
(SELECT count(distinct(p.codusuario))
FROM [FinamigoConsolidado].[dbo].[tCsPadronCarteraDet] p
inner join tcscartera c on p.fechacorte=c.fecha and p.codprestamo=c.codprestamo
--where dbo.fdufechaaperiodo(desembolso)=substring('20140401',0,7)
--and c.codasesor='MGM2602111'  and p.secuenciacliente=1) as clientesnuevos
where desembolso between @fecprimerdia and @fecfin
and c.codasesor=@codasesor  and p.secuenciacliente<>1) as clientesrenovados,
(select 100-((sum(case when d.nrodiasatraso<>0 then d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido
else 0 end)/sum(d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido))*100) normalidad
from(
SELECT c.codasesor,c.nrodiasatraso,cd.saldocapital, cd.interesvigente,cd.interesvencido,cd.moratoriovigente,cd.moratoriovencido
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fecha and c.cartera='ACTIVA'  AND  c.nrodiasatraso<61
  and c.codasesor=@codasesor ) d) as normalidad,
  case 
			when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '1' then 'ENERO'                                               
			when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '2' then 'FEBRERO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '3' then 'MARZO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '4' then 'ABRIL'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '5' then 'MAYO'                                       
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '6' then 'JUNIO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '7' then 'JULIO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '8' then 'AGOSTO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '9' then 'SEPTIEMBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '10' then 'OCTUBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '11' then 'NOVIEMBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)+1,0)) )) = '12' then 'DICIEMBRE' end as messiguiente,
                      case 
			when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '1' then 'ENERO'                                               
			when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '2' then 'FEBRERO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '3' then 'MARZO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '4' then 'ABRIL'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '5' then 'MAYO'                                       
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '6' then 'JUNIO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '7' then 'JULIO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '8' then 'AGOSTO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '9' then 'SEPTIEMBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '10' then 'OCTUBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '11' then 'NOVIEMBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-2,0)))) = '12' then 'DICIEMBRE' end  as mes1ER3ERCARTA,
           case 
			when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '1' then 'ENERO'                                               
			when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '2' then 'FEBRERO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '3' then 'MARZO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '4' then 'ABRIL'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '5' then 'MAYO'                                       
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '6' then 'JUNIO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '7' then 'JULIO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '8' then 'AGOSTO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '9' then 'SEPTIEMBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '10' then 'OCTUBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '11' then 'NOVIEMBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-3,0)))) = '12' then 'DICIEMBRE' end  as mes4TACARTA, 
           CASE 
           when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '1' then 'ENERO'                                               
			when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '2' then 'FEBRERO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '3' then 'MARZO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '4' then 'ABRIL'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '5' then 'MAYO'                                       
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '6' then 'JUNIO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '7' then 'JULIO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '8' then 'AGOSTO'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '9' then 'SEPTIEMBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '10' then 'OCTUBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '11' then 'NOVIEMBRE'                                              
            when month((SELECT DATEADD(s,0,DATEADD(mm, DATEDIFF(m,0,@fecha)-0,0)))) = '12' then 'DICIEMBRE' end  as mesCIERRE,
           
            (select sum(montototaltran) monto 
from tcstransacciondiaria t with(nolock)
where codsistema='CA' and tipotransacnivel1='I' and extornado=0
and fecha between @fecprimerdia and @fecfin
and codigocuenta in(
select c.codprestamo
from  tcscartera c with(nolock)
where c.fecha=@fecha
and c.codasesor=@codasesor and c.nrodiasatraso<61)) AS cobranza,
isnull((select valorprog from tcsbsmetaxUEn  where icodtipobs='5' and icodindicador='11' and fecha=@fecfin and ncamvalor=@codasesor),0)  as metasnuevos,
isnull((select valorprog from tcsbsmetaxUEn  where icodtipobs='5' and icodindicador='12' and fecha=@fecfin and ncamvalor=@codasesor),0) as metasrenovados,
isnull((select valorprog from tcsbsmetaxUEn  where icodtipobs='5' and icodindicador='3' and fecha=@fecfin  and ncamvalor=@codasesor),0) as metasrecuperacion,
isnull(mdesem.desembolsado,0) desembolsado,
(select sum(d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido) saldocartera
from  tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.fecha=@fecha
and c.codasesor=@codasesor
and c.nrodiasatraso<90) as saldocarteravigente
           
                   
--from tCsRptBonoCartera b
from 
	(select * from tCsHRptBonoCartera  where fecha=@fecha
	 union select * from tCsHRptBonoComunal where fecha=@fecha
	)b
left outer join (
  SELECT c.codasesor,sum(cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido) saldocartera
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fecha and c.cartera='ACTIVA'
  and c.codasesor=@codasesor
  group by c.codasesor
) s on s.codasesor=b.codasesor
left outer join (
SELECT c.codasesor,sum(p.monto) desembolsado ,sum(case when secuenciacliente<>1 then p.monto else 0 end) mdrenova
FROM [FinamigoConsolidado].[dbo].[tCsPadronCarteraDet] p
inner join tcscartera c on p.fechacorte=c.fecha and p.codprestamo=c.codprestamo
where p.desembolso between @fecprimerdia and @fecfin
group by c.codasesor
) mdesem on mdesem.codasesor=b.codasesor
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
GO