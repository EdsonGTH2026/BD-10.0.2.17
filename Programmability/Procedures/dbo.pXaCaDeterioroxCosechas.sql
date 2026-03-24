SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCaDeterioroxCosechas] @oficina varchar(2000),@ciclo varchar(8)  
as  
--declare @oficina varchar(300)  
--set @oficina = '459,4,5,6,37'--@oficina  
--declare @ciclo varchar(8)  
--set @ciclo = '1,2,3,4'  
  
 --LA FECHA DE CORTE  
  declare @fecha smalldatetime  
  select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
   --set @fecha='20211027'   
  
  declare @fecini smalldatetime  
  --set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'  
  set @fecini=dbo.fdufechaaperiodo(dateadd(month,-12,@fecha))+'01'  
  declare @fecfin smalldatetime  
  set @fecfin=@fecha  
    
  --create table #oficinas (codoficina varchar(4),nomoficina varchar(30))  
  declare @oficinas table(codoficina varchar(4),nomoficina varchar(30))  
  insert into @oficinas  
  select codoficina, nomoficina     
  from tcloficinas with(nolock)  
  where codoficina in (select codigo from dbo.fduTablaValores(@oficina))  
    
 --  referencia en rango de ciclos  
  --  1 | ciclo 1  
  --  2 | ciclo 2  
  --  3 | ciclo 3-5  
  --  4 | ciclo 6+  
    
 --declare @refRango table (cod int,rango varchar (9))  
 --insert into @refRango values(1,'ciclo 1')  
 --insert into @refRango values(2,'ciclo 2')  
 --insert into @refRango values(3,'ciclo 3-5')  
 --insert into @refRango values(4,'ciclo 6+')  
   
   
 --create table #rango (ciclo varchar(9))  
 --declare @rango table (ciclo varchar(9))  
 --insert into #rango  
 --select rango ciclo  
 --from @refRango  
 --where cod in (select codigo from dbo.fduTablaValores(@ciclo))  
  
 --create table #ptmos (codprestamo varchar(20))  
 declare @ptmos table(codprestamo varchar(20))  
 insert into @ptmos  
 select distinct codprestamo  
 from tcspadroncarteradet pd with(nolock)  
 where pd.desembolso>=@fecini--'20210101' -- A PARTIR DE QUE FECHA QUIERES EVALUAR COSECHAS  
 and pd.desembolso<=@fecha  
 and pd.codoficina not in('97','230','231','98','999')   
 and pd.codoficina in(select codoficina from @oficinas) --and tiporeprog='SINRE'   
 --and pd.codprestamo not in (select codprestamo from tCsCarteraAlta)  
   
 --create table #base (   
 declare @base table(   
 cosecha varchar(6),cosecha_semanal int,rangoCiclo varchar(10)  
 ,montodesembolso money,saldocapital money  
 ,Castigadosaldo money,D8saldo money,D16saldo money, D31saldo money  
 ,deterioro8 money,deterioro16 money,deterioro31 money  
 ,D30saldo money  
 )  
 insert into @base  
 select   
  cosecha  
 ,cosecha_semanal   
 ,rangoCiclo  
 ,sum(montodesembolso) montodesembolso  
 ,sum(saldocapital) saldocapital  
 ,sum(Castigadosaldo) Castigadosaldo  
 ,sum(D8saldo) D8saldo  
 ,sum(D16saldo) D16saldo  
 ,sum(D31saldo) D31saldo   
 --,case when sum(montodesembolso)=0 then 0 else ((sum(D8saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100 end 'Deterioro8'  
 --,case when sum(montodesembolso)=0 then 0 else ((sum(D16saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100 end 'Deterioro16'  
 --,case when sum(montodesembolso)=0 then 0 else ((sum(D31saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100 end 'Deterioro31'  
 ,((sum(D8saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100  'Deterioro8'  
 ,((sum(D16saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100  'Deterioro16'  
 ,((sum(D31saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100  'Deterioro31'  
 ,sum(D30saldo) D30saldo  
 from (  
   SELECT   
   case when pd.secuenciacliente >= 6  then 4 --'ciclo 6+'  
       when pd.secuenciacliente >= 3 then 3 --'ciclo 3-5'  
       when pd.secuenciacliente = 2  then 2 --'ciclo 2'  
       else 1 --'ciclo 1'   
       end rangoCiclo  
   --,pd.CodProducto  
   --,z.Nombre  
   --,c.Fecha  
  --,cd.codusuario  
  --,pd.CodPrestamo  
  --, pd.EstadoCalculado  
   ,isnull(cd.saldocapital,0) saldocapital  
   , pd.monto montodesembolso  
   ,dbo.fdufechaaperiodo(pd.Desembolso) cosecha  
   ,DATEPART(ww,pd.Desembolso) cosecha_semanal   
 ,case when c.cartera= 'CASTIGADA' then (case when c.codfondo=20 then cd.saldocapital*0.30  else case when c.codfondo=21 then cd.saldocapital*0.25 else cd.saldocapital end end)  else 0 end Castigadosaldo  
 ---------------------------------  
 ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=8  then (case when c.codfondo=20 then cd.saldocapital*0.30 else case when c.codfondo=21 then cd.saldocapital*0.25 else cd.saldocapital end end) else 0 end else 0 end D8saldo  
 ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=16 then (case when c.codfondo=20 then cd.saldocapital*0.30 else case when c.codfondo=21 then cd.saldocapital*0.25 else cd.saldocapital end end)  else 0 end else 0 end D16saldo  
 ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=31 then (case when c.codfondo=20 then cd.saldocapital*0.30 else case when c.codfondo=21 then cd.saldocapital*0.25 else cd.saldocapital end end)  else 0 end else 0 end D31saldo  
   
 ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso<31 then (case when c.codfondo=20 then cd.saldocapital*0.30 else case when c.codfondo=21 then cd.saldocapital*0.25 else cd.saldocapital end end)  else 0 end else 0 end D30saldo  
  
   FROM tcspadroncarteradet pd with(nolock)  
   left outer join tcscarteradet cd with(nolock) on cd.fecha=@fecha and cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario  
   left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha  
   --inner join tcloficinas o with(nolock) on o.codoficina= pd.codoficina  
   --inner join tclzona z on z.zona=o.zona  
   where pd.codprestamo in(select codprestamo from @ptmos)  
 ) a   
   group by   
   cosecha  
   ,rangoCiclo  
   ,cosecha_semanal  
 --order by cosecha,cosecha_semanal ,rangoCiclo  
   
 select cosecha,cosecha_semanal  
 ,sum(montodesembolso) colocacion  
 ,((sum(D8saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100 'Deterioro8'  
 ,((sum(D16saldo)+ sum(Castigadosaldo))/sum(montodesembolso))*100 'Deterioro16'  
 ,((sum(D31saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100 'Deterioro31'  
 ,case when sum(montodesembolso)=0 then 0 else (sum(D30saldo)/sum(montodesembolso))*100 end Por30saldok  
 from @base --with(nolock)  
 where rangoCiclo in(select codigo from dbo.fduTablaValores(@ciclo))   
 group by cosecha,cosecha_semanal  
 union  
 select cosecha,99 as cosecha_semanal  
 ,sum(montodesembolso) colocacion  
 ,((sum(D8saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100 'Deterioro8'  
 ,((sum(D16saldo)+ sum(Castigadosaldo))/sum(montodesembolso))*100 'Deterioro16'  
 ,((sum(D31saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100 'Deterioro31'  
 ,case when sum(montodesembolso)=0 then 0 else (sum(D30saldo)/sum(montodesembolso))*100 end Por30saldok  
 from @base --with(nolock)  
 where rangoCiclo in(select codigo from dbo.fduTablaValores(@ciclo))   
 group by cosecha  
 union  
 select 'Total' as cosecha,999 as cosecha_semanal  
 ,isnull(sum(montodesembolso),0) colocacion  
 ,isnull(((sum(D8saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100,0) 'Deterioro8'  
 ,isnull(((sum(D16saldo)+ sum(Castigadosaldo))/sum(montodesembolso))*100,0) 'Deterioro16'  
 ,isnull(((sum(D31saldo)+sum(Castigadosaldo))/sum(montodesembolso))*100,0) 'Deterioro31'  
 ,case when sum(montodesembolso)=0 then 0 else (sum(D30saldo)/sum(montodesembolso))*100 end Por30saldok  
 from @base --with(nolock)  
 where rangoCiclo in(select codigo from dbo.fduTablaValores(@ciclo))    
 order by cosecha  
GO