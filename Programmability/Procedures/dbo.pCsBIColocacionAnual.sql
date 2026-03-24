SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBIColocacionAnual] 
as

--sp_helptext [pCsBIColocacionAnual]
--exec [pCsBIColocacionAnual]

declare @fecha smalldatetime  
select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
  
declare @inimes smalldatetime  
select @inimes=dateadd(day,((-1)*day(@fecha))+1,@fecha)  
  
declare @mesant smalldatetime  
select @mesant=dateadd(month,-1,@inimes)  
  
declare @fecini smalldatetime  
select @fecini =dateadd(year,-1,@mesant)  
  
CREATE TABLE #Colocados
(codprestamo varchar(100)
,MontoFinamigo money
,MontoProgresemos money
,MontoCubo money
,Fondeador Varchar (50)
,nombre Varchar(100)
,nomoficina varchar(200)
,tipo varchar(100)
,producto varchar(100)
,monto money
,RangoMonto varchar(50)
,rangociclo varchar(20)
,tipo2 varchar(50)
,Cosecha varchar(50)
,Dia integer)

Insert into #Colocados
 
 
 
  
select pcd.codprestamo  
,case when p.codfondo=20 then (pcd.monto)*0.30  
        when p.codfondo=21 then (pcd.monto)*0.25  
        else pcd.monto end 'MontoFinamigo'  
,case when p.codfondo=20 then (pcd.monto)*0.70  
        when p.codfondo=21 then 0  
        else 0 end 'MontoProgresemos'  
,case when p.codfondo=20 then 0  
        when p.codfondo=21 then (pcd.monto)*0.75  
        else 0 end 'MontoCubo'  
,case when p.codfondo='01' then 'Propio'  
     when p.codfondo='20' then 'Progresemos'  
     when p.codfondo='21' then 'CUBO'  
     else null end Fondeador,  
     z.nombre, ofi.nomoficina
     ,case when ofi.esvirtual = 1 then 'Virtual' else 'Fisica' end Tipo   
,case when pcd.codproducto='170' then 'Productivo'  
     when pcd.codproducto='370' then 'Consumo'  
     else 'Null' end Producto, pcd.monto,  
case when pcd.monto>=50000 then 'h.50mil+'  
                      when pcd.monto>=40000 then 'g.40mil+'  
                      when pcd.monto>=30000 then 'f.30mil+'  
                      when pcd.monto>=20000 then 'e.20mil+'  
                      when pcd.monto>=15000 then 'd.15mil+'  
                      when pcd.monto>=10000 then 'c.10mil+'  
                      when pcd.monto>=5000 then 'b.5mil+'  
                      when pcd.monto<50000 then 'a.5mil-'  
                else '?' end rangoMonto  
                 ,case when pcd.secuenciacliente >= 10 then 'e10+'   
                      when pcd.secuenciacliente >= 7 then 'd7-9'  
                      when pcd.secuenciacliente >= 4 then 'c4-6'  
                      when pcd.secuenciacliente >= 2 then 'b2-3'  
                      when pcd.secuenciacliente = 1 then 'a1'  
                else '?' end rangoCiclo,  
                case when pcd.cancelacionanterior is null then 'Nuevo'   
       when ((convert(varchar,month(pcd.cancelacionanterior)))+ (convert(varchar,year(pcd.cancelacionanterior)))) = ((convert(varchar,month(pcd.desembolso)))+ (convert(varchar,year(pcd.desembolso)))) then 'Renovacion' --MES COMPLETO  
       else 'Reactivacion' end Tipo2,  
       ((convert(varchar,year(pcd.desembolso)))+ '-' + (right( '0' + (Convert(VARCHAR,( DATEPART ( mm , pcd.desembolso )))) ,2))) Cosecha   
       ,Day(pcd.desembolso) Dia
from tcspadroncarteradet pcd with(nolocK)   
inner join tcloficinas ofi with(nolock) on ofi.codoficina=pcd.codoficina  
inner join tclzona z with(nolock) on z.zona=ofi.zona  
inner join tcscartera p with(nolock) on p.codprestamo=pcd.codprestamo and p.fecha=pcd.fechacorte  
where desembolso >=@fecini and pcd.codoficina not in('230','231','97')  
  
  select *,
  case when tipo2='Nuevo' then monto else 0 end Nuevos
 , case when tipo2='Renovacion' then monto else 0 end Renovados
  ,case when tipo2='Reactivacion' then monto else 0 end Reactivados
   from #Colocados
  
  
  drop table #colocados
  
  
GO