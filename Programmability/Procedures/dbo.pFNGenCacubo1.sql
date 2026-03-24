SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pFNGenCacubo1]
as
set nocount on

declare @fcorte smalldatetime
--set @fcorte= '20210905'
select @fcorte=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini= cast((dbo.fdufechaaperiodo(@fcorte)+'01') as smalldatetime) -1 --'20210831'

declare @fmesini smalldatetime
declare @fmesfin smalldatetime
set @fmesini=dbo.fdufechaaperiodo(@fcorte)+'01' --'20210901'
set @fmesfin=@fcorte--'20210905'
--select @fcorte '@fcorte'
--select @fecini '@fecini'
--select @fmesini '@fmesini'
--select @fmesfin '@fmesini'

select codprestamo,nrodiasatraso, saldocapital, estado
into #cai
from tcscartera with(nolock)
where fecha=@fecini
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and codoficina not in('230','231','97')
and cartera='ACTIVA' 

insert into #cai
select codprestamo,-1 nrodiasatraso,monto saldocapital, estadocalculado
from tcspadroncarteradet with(nolock)
where desembolso>=@fmesini and desembolso<=@fmesfin

delete from FNMGConsolidado.dbo.tCACubos1 where fecfin=@fcorte
 
insert into FNMGConsolidado.dbo.tCACubos1
select @fmesini fecini,@fmesfin fecfin,j.nomoficina sucursal, z.nombre region
,case when j.EsVirtual=1 then 'VIRTUAL' else 'FISICA' end tipoSucursal
,count(pd.codprestamo) nroCreditos
,SUM(pd.monto) montoDesembolso
--, pd.desembolso
,dbo.fdufechaaperiodo(pd.desembolso) cosecha

,case when pd.Desembolso<='20200331' then 'CARTERA PRE-COVID' else 'CARTERA POST-COVID' end segmentoCartera
--,ca.CodFondo
,case when ca.ModalidadPlazo='M' then 'MENSUAL' else 'SEMANAL' end periodicidad

,case when ca.CodProducto='370' then 'CONSUMO' 
         when ca.CodProducto='168' then 'VIVIENDA' 
         when ca.MontoDesembolso >=500000 then 'EMPRESARIAL'
      when ca.MontoDesembolso >=30000 then 'PYME 30K-150K'
         when ca.CodProducto='172' then 'PYME 30K-150K' 
         when ca.CodProducto='170' then 'PRODUCTIVO'
         else 'Revisar' end Producto
--,ca.NroCuotas plazo
--,pd.SecuenciaCliente ciclo
,case when pd.secuenciacliente >= 15 then 'CICLO 15+'
         when pd.secuenciacliente >= 10 then 'CICLO 10-14'
      when pd.secuenciacliente >=5 then 'CICLO 5-9'
      when pd.secuenciacliente >=3  then 'CICLO 3-4'
      when pd.secuenciacliente >=2  then 'CICLO 2'
      else 'CICLO 1' end rangoCiclo
                  
,case when c.TasaIntCorriente>=134 then 'TASA 134+'
         when c.TasaIntCorriente>=124 then 'TASA 124+'
         when c.TasaIntCorriente>=114 then 'TASA 114+'
         when c.TasaIntCorriente>=104 then 'TASA 104+'
         when c.TasaIntCorriente>=90 then 'TASA 90+'
         when c.TasaIntCorriente>=60 then 'TASA 60+'
         else 'TASA MENOR 60' end rangoTasaInteres
--,co.FechaNacimiento 

,case when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=70 then '70+'
         when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=60 then '60+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=50 then '50+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=40 then '40+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=35 then '35+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=30 then '30+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=25 then '25+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=21 then '21+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=18 then '18+'
      else 'Revisar' end rangoEdadCliente
      
--,ca.FechaUltimoMovimiento
--,pd.PrimerAsesor,co.NombreCompleto,i.estado estadoinicial ,c.estado estadofechacorte            
--,pd.estadocalculado estadoactual
--,pd.cancelacion fcancelacion
--, dbo.fdufechaaperiodo(pd.cancelacion) cosechaCancelacion
--,i.nrodiasatraso nrodiasatraso_ini,c.nrodiasatraso nrodiasatraso_fin
,SUM(i.saldocapital) capitalInicial
,sum(case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fcorte then 0 else d.saldocapital end) capitalFin
,sum(case when d.interesvigente is null then 0 else d.interesvigente end ) intVigenteFin
,sum(case when d.interesvencido is null then 0 else d.interesvencido end) intVencFin
,sum(case
          when ca.CodFondo=20 then i.saldocapital*.3
          when ca.CodFondo=21 then i.saldocapital*.25
          else i.saldocapital end) capitalInicialFA --> aqui cambie
,sum(case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fcorte then 0
            else
                    case when ca.CodFondo=20 then d.saldocapital*.3
                               when ca.CodFondo=21 then d.saldocapital*.25
                               else d.saldocapital end
            end) capitalFinFA
           
,sum(case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fcorte then 0
            else
            case when ca.CodFondo=20 then (d.InteresVigente+d.InteresVencido)*.3
            when ca.CodFondo=21 then (d.InteresVigente+d.InteresVencido)*.25
            else (d.InteresVigente+d.InteresVencido) end
            end) interesFinFA      
            
,(sum(case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fcorte then 0
            else
                    case when ca.CodFondo=20 then d.saldocapital*.3
                               when ca.CodFondo=21 then d.saldocapital*.25
                               else d.saldocapital end
            end)) + (sum(case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fcorte then 0
            else
            case when ca.CodFondo=20 then (d.InteresVigente+d.InteresVencido)*.3
            when ca.CodFondo=21 then (d.InteresVigente+d.InteresVencido)*.25
            else (d.InteresVigente+d.InteresVencido) end
            end)) saldoTotalFA
           
            
,sum(case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fcorte then 0
                    else
                              case when ca.CodFondo=20 then d.saldocapital*.7 else 0 end
          end) capitalFinProgresemos --> aqui cambie
,sum(case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fcorte then 0
                    else
                              case when ca.CodFondo=21 then d.saldocapital*.75 else 0 end
                    end) capitalFinCubo --> aqui cambie                           
                               
, case when i.nrodiasatraso = -1 then 'Nuevo'
                                 when i.nrodiasatraso = 0 then '0dm'
                                 when i.nrodiasatraso <=7 then '1-7dm'
                                 when i.nrodiasatraso <=15 then '8-15dm'
                                 when i.nrodiasatraso <=30 then '16-30dm'
                                 when i.nrodiasatraso <=60 then '31-60dm'
                                 when i.nrodiasatraso <=89 then '61-89dm'
                                 when i.nrodiasatraso <=120 then '90-120dm'
                                 when i.nrodiasatraso <=150 then '121-150dm'
                                 when i.nrodiasatraso <=180 then '151-180dm'
                                 when i.nrodiasatraso <=210 then '181-210dm'
                                 when i.nrodiasatraso <=240 then '211-240dm'
                                 when i.nrodiasatraso >=241 then '241+dm'
else '?' end bucketInicio
,case
                      when c.estado ='CASTIGADO'then 'CASTIGADO'            
           when c.nrodiasatraso is null then 'LIQUIDADO'
                      when c.nrodiasatraso = -1 then 'NUEVO'
                                 when c.nrodiasatraso = 0 then '0dm'
                                 when c.nrodiasatraso <=7 then '1-7dm'
                                 when c.nrodiasatraso <=15 then '8-15dm'
                                 when c.nrodiasatraso <=30 then '16-30dm'
                                 when c.nrodiasatraso <=60 then '31-60dm'
                                 when c.nrodiasatraso <=89 then '61-89dm'
                                 when c.nrodiasatraso <=120 then '90-120dm'
                                 when c.nrodiasatraso <=150 then '121-150dm'
                                 when c.nrodiasatraso <=180 then '151-180dm'
                                 when c.nrodiasatraso <=210 then '181-210dm'
                                 when c.nrodiasatraso <=240 then '211-240dm'
                                 when c.nrodiasatraso >=241 then '241+dm'
else '?' end bucketFin
,case when i.nrodiasatraso = -1 then 'NUEVO'
                               when i.nrodiasatraso<=30 then 'VIGENTE 0-30'
                               when i.nrodiasatraso<=89 then 'ATRASADO 31-89'
else 'VENCIDO 90+' end estadoInicial
              
,case when c.nrodiasatraso is null then 'LIQUIDADO'           
                  when c.estado ='CASTIGADO'then 'CASTIGADO'
                  when c.nrodiasatraso <=30 then 'VIGENTE 0-30'
                  when c.nrodiasatraso <=89 then 'ATRASADO 31-89'
else 'VENCIDO 90+' end estadoFinal
              
,case when pd.monto>=60000 then '60mil+'
      when pd.monto>=30000 then '30mil+'
      when pd.monto>=15000 then '15mil+'
      when pd.monto>=12000 then '12mil+'
      when pd.monto>=10000 then '10mil+'
      when pd.monto>=7500 then '7.5mil+'
      when pd.monto>=5000 then '5mil+'
      when pd.monto>=3000 then '3mil+'
      when pd.monto<3000 then '3mil menos'
      else '?' end rangoMonto
              
,case when c.tiporeprog='REEST' then 'REESTRUCTURA'
                                 when c.tiporeprog='RENOV' then 'R.ANTICIPADA'
                                 when c.tiporeprog is null then 'LIQUIDADO'
                                 else 'ORGANICO' end tipoCredito
--,c.FechaReprog
,dbo.fdufechaaperiodo(c.FechaReprog) cosechaReprog
--,pr.calificacion, pr.calificapromotor, pr.calificacioncapacidadpago
--into FNMGConsolidado.dbo.tCACubos1
from tcspadroncarteradet pd with(nolock)
left outer join tcscarteradet d with(nolock) on d.fecha=@fcorte and pd.codprestamo=d.codprestamo
left outer join tcscartera c with(nolock) on d.codprestamo=c.codprestamo and d.fecha=c.fecha
inner join #cai i with(nolock) on i.codprestamo=pd.codprestamo
inner join tcloficinas j with(nolock) on j.codoficina=pd.codoficina
inner join tclzona z  with(nolock) on z.zona=j.zona
--left outer join tcspadronclientes co on co.codusuario=pd.primerasesor
left outer join tcspadronclientes co with(nolock) on co.codusuario=pd.CodUsuario 
--LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tCaSolicitudproce pr on pr.CodOficina=c.CodOficina and pr.CodSolicitud=c.CodSolicitud
left outer join tcscartera ca with(nolock) on pd.codprestamo=ca.codprestamo and pd.fechacorte=ca.fecha
where pd.codoficina not in('230','231','97')

group by j.NomOficina,z.Nombre
,dbo.fdufechaaperiodo(pd.desembolso)
,case when pd.Desembolso<='20200331' then 'CARTERA PRE-COVID' else 'CARTERA POST-COVID' end 
,case when j.EsVirtual=1 then 'VIRTUAL' else 'FISICA' end

,case when ca.ModalidadPlazo='M' then 'MENSUAL' else 'SEMANAL' end

,case when ca.CodProducto='370' then 'CONSUMO' 
         when ca.CodProducto='168' then 'VIVIENDA' 
         when ca.MontoDesembolso >=500000 then 'EMPRESARIAL'
      when ca.MontoDesembolso >=30000 then 'PYME 30K-150K'
         when ca.CodProducto='172' then 'PYME 30K-150K' 
         when ca.CodProducto='170' then 'PRODUCTIVO'
         else 'Revisar' end 
        
,case when pd.secuenciacliente >= 15 then 'CICLO 15+'
         when pd.secuenciacliente >= 10 then 'CICLO 10-14'
      when pd.secuenciacliente >=5 then 'CICLO 5-9'
      when pd.secuenciacliente >=3  then 'CICLO 3-4'
      when pd.secuenciacliente >=2  then 'CICLO 2'
      else 'CICLO 1' end 
       

                  
,case when c.TasaIntCorriente>=134 then 'TASA 134+'
         when c.TasaIntCorriente>=124 then 'TASA 124+'
         when c.TasaIntCorriente>=114 then 'TASA 114+'
         when c.TasaIntCorriente>=104 then 'TASA 104+'
         when c.TasaIntCorriente>=90 then 'TASA 90+'
         when c.TasaIntCorriente>=60 then 'TASA 60+'
         else 'TASA MENOR 60' end 
--,co.FechaNacimiento 
--,co.FechaNacimiento 

,case when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=70 then '70+'
         when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=60 then '60+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=50 then '50+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=40 then '40+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=35 then '35+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=30 then '30+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=25 then '25+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=21 then '21+'
      when (datediff (day, co.FechaNacimiento, c.FechaDesembolso)/365) >=18 then '18+'
      else 'Revisar' end 
      
--,pd.EstadoCalculado
--,pd.Cancelacion
--,ca.CodFondo
--,case when pd.estadocalculado='CANCELADO' and pd.cancelacion <= @fcorte then 0 else sum(d.saldocapital) end
                           
, case when i.nrodiasatraso = -1 then 'Nuevo'
                                 when i.nrodiasatraso = 0 then '0dm'
                                 when i.nrodiasatraso <=7 then '1-7dm'
                                 when i.nrodiasatraso <=15 then '8-15dm'
                                 when i.nrodiasatraso <=30 then '16-30dm'
                                 when i.nrodiasatraso <=60 then '31-60dm'
                                 when i.nrodiasatraso <=89 then '61-89dm'
                                 when i.nrodiasatraso <=120 then '90-120dm'
                                 when i.nrodiasatraso <=150 then '121-150dm'
                                 when i.nrodiasatraso <=180 then '151-180dm'
                                 when i.nrodiasatraso <=210 then '181-210dm'
                                 when i.nrodiasatraso <=240 then '211-240dm'
                                 when i.nrodiasatraso >=241 then '241+dm'
else '?' end
,case
                      when c.estado ='CASTIGADO'then 'CASTIGADO'            
           when c.nrodiasatraso is null then 'LIQUIDADO'
                      when c.nrodiasatraso = -1 then 'NUEVO'
                                 when c.nrodiasatraso = 0 then '0dm'
                                 when c.nrodiasatraso <=7 then '1-7dm'
                                 when c.nrodiasatraso <=15 then '8-15dm'
                                 when c.nrodiasatraso <=30 then '16-30dm'
                                 when c.nrodiasatraso <=60 then '31-60dm'
                                 when c.nrodiasatraso <=89 then '61-89dm'
                                 when c.nrodiasatraso <=120 then '90-120dm'
                                 when c.nrodiasatraso <=150 then '121-150dm'
                                 when c.nrodiasatraso <=180 then '151-180dm'
                                 when c.nrodiasatraso <=210 then '181-210dm'
                                 when c.nrodiasatraso <=240 then '211-240dm'
                                 when c.nrodiasatraso >=241 then '241+dm'
else '?' end
,case when i.nrodiasatraso = -1 then 'NUEVO'
                               when i.nrodiasatraso<=30 then 'VIGENTE 0-30'
                               when i.nrodiasatraso<=89 then 'ATRASADO 31-89'
else 'VENCIDO 90+' end
               
,case when c.nrodiasatraso is null then 'LIQUIDADO'           
                  when c.estado ='CASTIGADO'then 'CASTIGADO'
                  when c.nrodiasatraso <=30 then 'VIGENTE 0-30'
                  when c.nrodiasatraso <=89 then 'ATRASADO 31-89'
else 'VENCIDO 90+' end
,case when c.tiporeprog='REEST' then 'REESTRUCTURA'
                                 when c.tiporeprog='RENOV' then 'R.ANTICIPADA'
                                 when c.tiporeprog is null then 'LIQUIDADO'
                                 else 'ORGANICO' end 
  
,case when pd.monto>=60000 then '60mil+'
      when pd.monto>=30000 then '30mil+'                                 
      when pd.monto>=15000 then '15mil+'
      when pd.monto>=12000 then '12mil+'
      when pd.monto>=10000 then '10mil+'
      when pd.monto>=7500 then '7.5mil+'
      when pd.monto>=5000 then '5mil+'
      when pd.monto>=3000 then '3mil+'
      when pd.monto<3000 then '3mil menos'
      else '?' end
                   
,dbo.fdufechaaperiodo(c.FechaReprog)
        
drop table #cai

GO