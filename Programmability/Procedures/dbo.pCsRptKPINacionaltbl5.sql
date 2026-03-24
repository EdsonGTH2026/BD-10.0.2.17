SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*RENOVACION KPI*/  
  
CREATE procedure [dbo].[pCsRptKPINacionaltbl5] @fecha smalldatetime  
as     
set nocount on     

declare @fecosecha smalldatetime --A PARTIR DE QUE FECHA QUIERES EVALUAR COSECHAS  
set @fecosecha=dbo.fdufechaaperiodo(dateadd(month,-11,@fecha))+'01'  
  
declare @fecante smalldatetime  
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  -- '20211130'--fecha de termino del mes anterior  


------------------- DETERIORO  
 declare @ptmos table(codprestamo varchar(20))  
 insert into @ptmos  
 select distinct codprestamo  
 from tcspadroncarteradet pd with(nolock)  
 where pd.desembolso>=@fecosecha -- A PARTIR DE QUE FECHA COSECHAS SE EVALUA  
 and pd.desembolso<=@fecha       -- fecha corte  
 and pd.codoficina not in('97','230','231','98','999')   
 and codprestamo not in (select codprestamo from tCsCarteraAlta)  
   
declare @cos table (ID int IDENTITY(1,1),cosecha varchar(6))  
insert into @cos(cosecha)   
select DISTINCT dbo.fdufechaaperiodo(pd.desembolso)cosecha  
FROM tcspadroncarteradet pd with(nolock)  
where pd.codprestamo in(select codprestamo from @ptmos)  
order by dbo.fdufechaaperiodo(pd.desembolso)  
  
  
/*--- Mostrar un periodo de  12 cosechas */  
  
declare @deterioro table (montodesembolso money  
      ,recuperado money  
      ,cosecha varchar(6)  
      ,D0saldo money  
      ,D0a15saldo money  
      ,D16saldo money  
      ,Castigadosaldo money)  
insert into @deterioro       
select sum(montodesembolso) montodesembolso  
 ,sum(montodesembolso)-sum(D0saldo)-sum(Castigadosaldo) recuperado  
 ,cosecha cosecha  
 ,sum(D0saldo)D0saldo  
 ,sum(D0a15saldo)D0a15saldo  
 ,sum(D16saldo)D16saldo  
 ,sum(Castigadosaldo)Castigadosaldo  
 from (  
   SELECT o.zona,  
  o.codoficina ,  
  isnull(cd.saldocapital,0) saldocapital  
   ,pd.monto montodesembolso  
   ,dbo.fdufechaaperiodo(pd.Desembolso) cosecha    
 ,case when c.cartera= 'CASTIGADA' then   cd.saldocapital   else 0 end Castigadosaldo  
 ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=16 then  cd.saldocapital  else 0 end else 0 end D16saldo  
    ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=15  then  cd.saldocapital  else 0 end else 0 end D0a15saldo  
  ,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 then cd.saldocapital  else 0 end else 0 end D0saldo  
   FROM tcspadroncarteradet pd with(nolock)  
   left outer join tcscarteradet cd with(nolock) on cd.fecha=@fecha and cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario  
   left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha  
   inner join tcloficinas o with(nolock) on o.codoficina=pd.codoficina  
   where pd.codprestamo in(select codprestamo from @ptmos)   
 ) a   
   group by cosecha  
   order by cosecha  

     
declare @idCosecha1 varchar(6)  
select @idCosecha1 =  cosecha from @cos  where id=1  
declare @idCosecha2 varchar(6)  
select @idCosecha2 =  cosecha from @cos  where id=2  
declare @idCosecha3 varchar(6)  
select @idCosecha3 =  cosecha from @cos  where id=3  
declare @idCosecha4 varchar(6)  
select @idCosecha4 =  cosecha from @cos  where id=4  
declare @idCosecha5 varchar(6)  
select @idCosecha5 =  cosecha from @cos  where id=5  
declare @idCosecha6 varchar(6)  
select @idCosecha6 =  cosecha from @cos  where id=6  
declare @idCosecha7 varchar(6)  
select @idCosecha7 =  cosecha from @cos  where id=7  
declare @idCosecha8 varchar(6)  
select @idCosecha8 =  cosecha from @cos  where id=8  
declare @idCosecha9 varchar(6)  
select @idCosecha9 =  cosecha from @cos  where id=9  
declare @idCosecha10 varchar(6)  
select @idCosecha10 =  cosecha from @cos  where id=10  
declare @idCosecha11 varchar(6)  
select @idCosecha11 =  cosecha from @cos  where id=11  
declare @idCosecha12 varchar(6)  
select @idCosecha12 =  cosecha from @cos  where id=12  
 
declare @det table (zona varchar(4)  
,cosecha1 varchar(6),colocacionC1 money,porRecuperaC1 money,Deterioro0a15C1 money,Deterioro16C1 money  
,cosecha2 varchar(6),colocacionC2 money,porRecuperaC2 money,Deterioro0a15C2 money,Deterioro16C2 money  
,cosecha3 varchar(6),colocacionC3 money,porRecuperaC3 money,Deterioro0a15C3 money,Deterioro16C3 money  
,cosecha4 varchar(6),colocacionC4 money,porRecuperaC4 money,Deterioro0a15C4 money,Deterioro16C4 money  
,cosecha5 varchar(6),colocacionC5 money,porRecuperaC5 money,Deterioro0a15C5 money,Deterioro16C5 money  
,cosecha6 varchar(6),colocacionC6 money,porRecuperaC6 money,Deterioro0a15C6 money,Deterioro16C6 money  
,cosecha7 varchar(6),colocacionC7 money,porRecuperaC7 money,Deterioro0a15C7 money,Deterioro16C7 money  
,cosecha8 varchar(6),colocacionC8 money,porRecuperaC8 money,Deterioro0a15C8 money,Deterioro16C8 money  
,cosecha9 varchar(6),colocacionC9 money,porRecuperaC9 money,Deterioro0a15C9 money,Deterioro16C9 money  
,cosecha10 varchar(6),colocacionC10 money,porRecuperaC10 money,Deterioro0a15C10 money,Deterioro16C10 money  
,cosecha11 varchar(6),colocacionC11 money,porRecuperaC11 money,Deterioro0a15C11 money,Deterioro16C11 money  
,cosecha12 varchar(6),colocacionC12 money,porRecuperaC12 money,Deterioro0a15C12 money,Deterioro16C12  money  
)   

insert into @det
 select 'NAC'
   ,sum(case when c.id=1 then d.cosecha else 0 end )cosecha1   
   ,sum(case when c.id=1 then montodesembolso else 0 end )colocacionC1   
   ,case when sum(case when c.id=1 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=1 then recuperado else 0 end )  
   /sum(case when c.id=1 then montodesembolso else 0 end )*100 end porRecuperaC1  
      ,case when sum(case when c.id=1 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=1 then(D0a15saldo) else 0 end)/sum(case when c.id=1 then montodesembolso else 0 end)*100 end Deterioro0a15C1  
      ,case when sum(case when c.id=1 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=1 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=1 then montodesembolso else 0 end)*100 end Deterioro16C1  
   --,@idCosecha2 cosecha2  
   ,sum(case when c.id=2 then d.cosecha else 0 end )cosecha2   
   ,sum(case when c.id=2 then montodesembolso else 0 end )colocacionC2  
    ,case when sum(case when c.id=2 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=2 then recuperado else 0 end )  
   /sum(case when c.id=2 then montodesembolso else 0 end )*100 end porRecuperaC2  
      ,case when sum(case when c.id=2 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=2 then(D0a15saldo) else 0 end)/sum(case when c.id=2 then montodesembolso else 0 end)*100 end Deterioro0a15C2  
      ,case when sum(case when c.id=2 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=2 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=2 then montodesembolso else 0 end)*100 end Deterioro16C2  
   --,@idCosecha3 cosecha3  
   ,sum(case when c.id=3 then d.cosecha else 0 end )cosecha3
   ,sum(case when c.id=3 then montodesembolso else 0 end )colocacionC3   
   ,case when sum(case when c.id=3 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=3 then recuperado else 0 end )  
   /sum(case when c.id=3 then montodesembolso else 0 end )*100 end porRecuperaC3  
      ,case when sum(case when c.id=3 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=3 then(D0a15saldo) else 0 end)/sum(case when c.id=3 then montodesembolso else 0 end)*100 end Deterioro0a15C3  
      ,case when sum(case when c.id=3 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=3 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=3 then montodesembolso else 0 end)*100 end Deterioro16C3  
   --,@idCosecha4 cosecha4  
   ,sum(case when c.id=4 then d.cosecha else 0 end )cosecha4
   ,sum(case when c.id=4 then montodesembolso else 0 end )colocacionC4   
   ,case when sum(case when c.id=4 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=4 then recuperado else 0 end )  
   /sum(case when c.id=4 then montodesembolso else 0 end )*100 end porRecuperaC4  
      ,case when sum(case when c.id=4 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=4 then(D0a15saldo) else 0 end)/sum(case when c.id=4 then montodesembolso else 0 end)*100 end Deterioro0a15C4  
      ,case when sum(case when c.id=4 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=4 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=4 then montodesembolso else 0 end)*100 end Deterioro16C4  
   --,@idCosecha5 cosecha5  
   ,sum(case when c.id=5 then d.cosecha else 0 end )cosecha5
   ,sum(case when c.id=5 then montodesembolso else 0 end )colocacionC5   
   ,case when sum(case when c.id=5 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=5 then recuperado else 0 end )  
   /sum(case when c.id=5 then montodesembolso else 0 end )*100 end porRecuperaC5  
      ,case when sum(case when c.id=5 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=5 then(D0a15saldo) else 0 end)/sum(case when c.id=5 then montodesembolso else 0 end)*100 end Deterioro0a15C5  
      ,case when sum(case when c.id=5 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=5 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=5 then montodesembolso else 0 end)*100 end Deterioro16C5  
   --,@idCosecha6 cosecha6 
   ,sum(case when c.id=6 then d.cosecha else 0 end )cosecha6 
   ,sum(case when c.id=6 then montodesembolso else 0 end )colocacionC6   
   ,case when sum(case when c.id=6 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=6 then recuperado else 0 end )  
   /sum(case when c.id=6 then montodesembolso else 0 end )*100 end porRecuperaC6  
      ,case when sum(case when c.id=6 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=6 then(D0a15saldo) else 0 end)/sum(case when c.id=6 then montodesembolso else 0 end)*100 end Deterioro0a15C6  
      ,case when sum(case when c.id=6 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=6 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=6 then montodesembolso else 0 end)*100 end Deterioro16C6  
   --,@idCosecha7 cosecha7  
   ,sum(case when c.id=7 then d.cosecha else 0 end )cosecha7
   ,sum(case when c.id=7 then montodesembolso else 0 end )colocacionC7   
   ,case when sum(case when c.id=7 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=7 then recuperado else 0 end )  
   /sum(case when c.id=7 then montodesembolso else 0 end )*100 end porRecuperaC7  
      ,case when sum(case when c.id=7 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=7 then(D0a15saldo) else 0 end)/sum(case when c.id=7 then montodesembolso else 0 end)*100 end Deterioro0a15C7  
      ,case when sum(case when c.id=7 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=7 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=7 then montodesembolso else 0 end)*100 end Deterioro16C7  
   --,@idCosecha8 cosecha8  
   ,sum(case when c.id=8 then d.cosecha else 0 end )cosecha8
   ,sum(case when c.id=8 then montodesembolso else 0 end )colocacionC8   
   ,case when sum(case when c.id=8 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=8 then recuperado else 0 end )  
   /sum(case when c.id=8 then montodesembolso else 0 end )*100 end porRecuperaC8  
      ,case when sum(case when c.id=8 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=8 then(D0a15saldo) else 0 end)/sum(case when c.id=8 then montodesembolso else 0 end)*100 end Deterioro0a15C8  
      ,case when sum(case when c.id=8 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=8 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=8 then montodesembolso else 0 end)*100 end Deterioro16C8  
   --,@idCosecha9 cosecha9  
   ,sum(case when c.id=9 then d.cosecha else 0 end )cosecha9
   ,sum(case when c.id=9 then montodesembolso else 0 end )colocacionC9   
   ,case when sum(case when c.id=9 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=9 then recuperado else 0 end )  
   /sum(case when c.id=9 then montodesembolso else 0 end )*100 end porRecuperaC9  
      ,case when sum(case when c.id=9 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=9 then(D0a15saldo) else 0 end)/sum(case when c.id=9 then montodesembolso else 0 end)*100 end Deterioro0a15C9  
      ,case when sum(case when c.id=9 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=9 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=9 then montodesembolso else 0 end)*100 end Deterioro16C9  
   --,@idCosecha10 cosecha10
   ,sum(case when c.id=10 then d.cosecha else 0 end )cosecha10  
   ,sum(case when c.id=10 then montodesembolso else 0 end )colocacionC10  
   ,case when sum(case when c.id=10 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=10 then recuperado else 0 end )  
   /sum(case when c.id=10 then montodesembolso else 0 end )*100 end porRecuperaC10  
      ,case when sum(case when c.id=10 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=10 then(D0a15saldo)else 0 end)/sum(case when c.id=10 then montodesembolso else 0 end)*100 end Deterioro0a15C10  
      ,case when sum(case when c.id=10 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=10 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=10 then montodesembolso else 0 end)*100 end Deterioro16C10  
   --,@idCosecha11 cosecha11
   ,sum(case when c.id=11 then d.cosecha else 0 end )cosecha11 
   ,sum(case when c.id=11 then montodesembolso else 0 end )colocacionC11  
   ,case when sum(case when c.id=11 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=11 then recuperado else 0 end )  
   /sum(case when c.id=11 then montodesembolso else 0 end )*100 end porRecuperaC11  
      ,case when sum(case when c.id=11 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=11 then(D0a15saldo) else 0 end)/sum(case when c.id=11 then montodesembolso else 0 end)*100 end Deterioro0a15C11  
      ,case when sum(case when c.id=11 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=11 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=11 then montodesembolso else 0 end)*100 end Deterioro16C11  
   --,@idCosecha12 cosecha12
   ,sum(case when c.id=12 then d.cosecha else 0 end )cosecha12  
   ,sum(case when c.id=12 then montodesembolso else 0 end )colocacionC12   
   ,case when sum(case when c.id=12 then montodesembolso else 0 end )=0 then 0 else sum(case when c.id=12 then recuperado else 0 end )  
   /sum(case when c.id=12 then montodesembolso else 0 end )*100 end porRecuperaC12  
      ,case when sum(case when c.id=12 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=12 then(D0a15saldo)else 0 end)/sum(case when c.id=12 then montodesembolso else 0 end)*100 end Deterioro0a15C12  
      ,case when sum(case when c.id=12 then montodesembolso else 0 end )=0 then 0 else   
      sum(case when c.id=12 then(D16saldo)+(Castigadosaldo) else 0 end)/sum(case when c.id=12 then montodesembolso else 0 end)*100 end Deterioro16C12  
    FROM @cos c   
    left outer join @deterioro d on d.cosecha=c.cosecha 
      


  
declare  @CubetaIni table(zona varchar(4)
     ,sal1a7ini money  
     ,sal8a15ini money  
     ,sal16a30ini money  
     ,sal31ini money  
     ,salTotalini money  
     ,ptmos1a7ini money  
     ,ptmos8a15ini money  
     ,ptmos16a30ini money  
     ,ptmos31ini money  
     ,ptmosTotalini money)     
insert into @CubetaIni   
select 'NAC' 
--saldo   
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)cubeta1a7  
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then c.saldocapital else 0 end)cubeta8a15  
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then c.saldocapital else 0 end)cubeta16a30  
,sum(case when c.nrodiasatraso>=31 then c.saldocapital else 0 end)cubeta31  
,sum(case when c.nrodiasatraso>=1 then c.saldocapital else 0 end)cubetaTotal  
--ptmos  
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then 1 else 0 end)ptmos1a7  
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then 1 else 0 end)ptmos8a15  
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then 1 else 0 end)ptmos16a30  
,sum(case when c.nrodiasatraso>=31 then 1 else 0 end)ptms31  
,sum(case when c.nrodiasatraso>=1 then 1 else 0 end)ptmosTotal  
from tcscartera c with(nolock)    
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
where c.fecha=@fecante --fecha fin de mes anterior  
and c.codoficina not in('97','231','230','999')and o.tipo<>'Cerrada'  
and cartera='ACTIVA' and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
 
 declare  @CubetaFin table(zona varchar(4)
     ,sal1a7fin money  
     ,sal8a15fin money  
     ,sal16a30fin money  
     ,sal31fin money  
     ,salTotalfin money  
     ,ptmos1a7fin money  
     ,ptmos8a15fin money  
     ,ptmos16a30fin money  
     ,ptmos31fin money  
     ,ptmosTotalfin money  
    )     
insert into @CubetaFin   
select 'NAC'  
--saldo   
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)cubeta1a7  
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then c.saldocapital else 0 end)cubeta8a15  
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then c.saldocapital else 0 end)cubeta16a30  
,sum(case when c.nrodiasatraso>=31 then c.saldocapital else 0 end)cubeta31  
,sum(case when c.nrodiasatraso>=1 then c.saldocapital else 0 end)cubetaTotal  
--ptmos  
,sum(case when c.nrodiasatraso>=1 and c.nrodiasatraso<=7 then 1 else 0 end)ptmos1a7  
,sum(case when c.nrodiasatraso>=8 and c.nrodiasatraso<=15 then 1 else 0 end)ptmos8a15  
,sum(case when c.nrodiasatraso>=16 and c.nrodiasatraso<=30 then 1 else 0 end)ptmos16a30  
,sum(case when c.nrodiasatraso>=31 then 1 else 0 end)ptms31  
,sum(case when c.nrodiasatraso>=1 then 1 else 0 end)ptmosTotal  
from tcscartera c with(nolock)    
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
where c.fecha=@fecha --fecha corte   
and c.codoficina not in('97','231','230','999')  and o.tipo<>'Cerrada'  
and cartera='ACTIVA' and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
  
   
declare @CubetasxSuc table (zona varchar(4),sal1a7ini money,sal8a15ini money,sal16a30ini money,sal31ini money  
,salTotalini money,ptmos1a7ini int,ptmos8a15ini int,ptmos16a30ini int,ptmos31ini int,ptmosTotalini int,sal1a7fin money,sal8a15fin money  
,sal16a30fin money,sal31fin money,salTotalfin money,ptmos1a7fin int,ptmos8a15fin int,ptmos16a30fin int,ptmos31fin int,ptmosTotalfin int  
,varSaldo1a7 money,varSaldo8a15 money,varSaldo16a30 money,varSaldo31 money,varSaldoTotal money,varPtmos1a7 money,varPtmos8a15 money  
,varPtmos16a30 money,varPtmos131 money,varPtmosTotal money)  
insert into @CubetasxSuc  
select i.zona  
  -- cubetas de saldo  
,sal1a7ini,sal8a15ini,sal16a30ini,sal31ini ,salTotalini,ptmos1a7ini,ptmos8a15ini,ptmos16a30ini,ptmos31ini,ptmosTotalini  
,sal1a7fin,sal8a15fin ,sal16a30fin,sal31fin,salTotalfin,ptmos1a7fin,ptmos8a15fin,ptmos16a30fin,ptmos31fin,ptmosTotalfin  
,isnull(sal1a7fin,0)- isnull(sal1a7ini,0) varSaldo1a7  
,isnull(sal8a15fin,0) -isnull(sal8a15ini,0)  varSaldo8a15  
,isnull(sal16a30fin,0) -isnull(sal16a30ini,0)  varSaldo16a30  
,isnull(sal31fin,0) -isnull(sal31ini,0)   varSaldo31  
,isnull(salTotalfin,0) -isnull(salTotalini,0) varSaldoTotal  
,isnull(ptmos1a7fin,0) -isnull(ptmos1a7ini,0) varPtmos1a7  
,isnull(ptmos8a15fin,0) -isnull(ptmos8a15ini,0) varPtmos8a15  
,isnull(ptmos16a30fin,0) -isnull(ptmos16a30ini,0) varPtmos16a30  
,isnull(ptmos31fin,0) -isnull(ptmos31ini,0) varPtmos131  
,isnull(ptmosTotalfin,0) -isnull(ptmosTotalini,0) varPtmosTotal  
from @CubetaIni i  
left outer join @CubetaFin f on i.zona=f.zona  

select @fecha as fecha,* 
from @CubetasxSuc c
inner join @det d on c.zona=d.zona






GO