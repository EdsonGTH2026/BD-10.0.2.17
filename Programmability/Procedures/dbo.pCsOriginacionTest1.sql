SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsOriginacionTest1] @fecini smalldatetime,@fecfin smalldatetime    
as    
set nocount on   
 --NOTAS  
 --USAR VARIABLES COMO TABLAS  declare  @clas_test1 table   
  
  
--begin tran  
--declare @fecini smalldatetime  
--declare @fecfin smalldatetime  
----declare @fecvencimiento smalldatetime  
--set @fecini='20221201'--'20191001'--  
--set @fecfin='20221231'  
----set @fecvencimiento= '20221124'  
  
  
declare  @clas_test1 table(CodPrestamo varchar(30),  
       CodUsuario varchar(30),CodOficina varchar(5),  
       codsolicitud varchar(15),CodProducto varchar(5),  
       FechaVencimiento smalldatetime,NroDiasAtraso int,  
       NroDiasAcumulado int,SecuenciaCliente int,  
       EstadoCalculado varchar(30),NroDiasMaximo int,  
       ModalidadPlazo varchar(30),NroCuotas int,  
       TasaIntCorriente money,Monto money,Desembolso smalldatetime,  
       TipoReprog varchar(10),clasCliente int,  
       fechacorte smalldatetime)  
insert into @clas_test1  
select p.CodPrestamo, p.CodUsuario, c.CodOficina,c.codsolicitud, p.CodProducto, c.FechaVencimiento , c.NroDiasAtraso , c.NroDiasAcumulado, p.SecuenciaCliente   
,p.EstadoCalculado, p.NroDiasMaximo, c.ModalidadPlazo , c.NroCuotas , c.TasaIntCorriente , p.Monto, p.Desembolso , p.TipoReprog   
,case when p.EstadoCalculado ='CASTIGADO' then 0  
      when p.EstadoCalculado ='CANCELADO' and p.NroDiasMaximo >= 31 then 0  
      when p.EstadoCalculado = 'CANCELADO' and p.NroDiasMaximo <= 30 then 1  
      when p.EstadoCalculado ='VENCIDO' then 0  
      when c.NroDiasAtraso >= 31 then 0  
      else 1 end clasCliente,p.fechacorte  
--into @clas_test1  
---select top 10*  
from tcspadroncarteradet p with(nolock)  
inner join tCsCartera c with(nolock) on c.CodPrestamo =p.CodPrestamo and p.FechaCorte = c.Fecha   
where p.Desembolso >=@fecini and p.Desembolso <= @fecfin and p.CodOficina not in ('97','231','230','999','98')  
--and c.FechaVencimiento < @fecvencimiento  
and p.estadocalculado='CANCELADO'  
  
  
  
  
--create table #CC(codprestamo varchar(20),creditomaximo decimal(16,2), ultmomonto decimal(16,2))  
--insert into #CC  
--exec [10.0.2.14].[FinamigoSIC].[dbo].pCsCACCMontos  
  
--select * from @clas_test1 with(nolock)  
--where codusuario='PCA0203791'  
  
----select * from @In_test1 with(nolock)  
----where codusuario like '%PCA0203791%'  
  
  
--select * from tcspadronclientes with(nolock)  
--where codusuario='PCA0203791'  
  
--select * from [10.0.2.14].[Finmas].[dbo].tUsUsuarioSecundarios   
--where codusuario like '%PCA0203791%'  
  
--select * from [10.0.2.14].[Finmas].[dbo].tcaprestamos   
--where codprestamo='004-170-06-06-04633'  
  
declare  @In_test1 table (codprestamo varchar(30),codusuario varchar(30),gasto money,ingreso money)  
insert into @In_test1  
select  codprestamo,u.codusuario,  
LabEgrBrutoMen+LabEgrFamiliarMen  Gasto,LabIngBrutoMen Ingreso--,*  
FROM [10.0.2.14].[Finmas].[dbo].tcaprestamos  c   
inner join [10.0.2.14].[Finmas].[dbo].tUsUsuarioSecundarios u on c.codusuario=u.codusuario  
--where codusuario in (select codusuario from @clas_test1 with(nolock))  
where codprestamo in (select codprestamo from @clas_test1)  
  
-------consulta score  
  
declare  @score_test1 table (codsolicitud varchar(30),codoficina varchar(5),idcc varchar(10),valorScore varchar(10))  
insert into @score_test1  
SELECT distinct cc.cuenta codsolicitud,cc.codoficina,sr.idcc,sr.valor valorScore  
--into @score_test1  
from @clas_test1 s   
inner join [10.0.2.14].[FinamigoSIC].[dbo].[tCcConsulta] cc on s.codsolicitud=cc.cuenta and s.codoficina=cc.codoficina  
inner join [10.0.2.14].[FinamigoSIC].[dbo].[tCcRespuestaScore] sr  on sr.idcc=cc.idcc  
  
  
---------------  
declare  @det_test1 table (idcc varchar(10),  
       creditomaximo decimal(16,3),  
       LimiteCredito decimal(16,3),  
       montoPagar decimal(16,3),  
       saldoactual decimal(16,3),  
       saldovencido decimal(16,3),  
       numeroPagosVencidos decimal(16,3))  
insert into @det_test1  
SELECT idcc  
,max(cast(isnull(creditomaximo,0) as decimal(16,3))) creditomaximo    
,max(cast((case when isnull(limiteCredito,0)=0 then 0 else limiteCredito end) as decimal(16,3))) LimiteCredito   
,max(cast((case when isnull(montoPagar,0)=0 then  0 else montoPagar end) as decimal(16,3))) montoPagar   
,max(cast((case when isnull(saldoactual,0)=0 then  0 else saldoactual end)as decimal(16,3))) saldoactual ------- saldo actual = deuda -> servicios / entidades financieras  
,sum(cast((case when isnull(saldovencido,0)=0 then 0 else  saldovencido end) as decimal(16,3)))saldovencido --> en el ultimo año  
,max(cast((case when isnull(numeroPagosVencidos,0)=0 then 0 else numeroPagosVencidos end) as decimal(16,3))) numeroPagosVencidos --> en el ultimo año  
--into @det_test1  
FROM [10.0.2.14].[FinamigoSIC].[dbo].[tCcRespuestaCuenta]   
where idcc in(select idcc from @score_test1) and isnull(creditomaximo,0)<>0    
group by idcc    
    
--------Municipio  
--declare @codMuni_test1 table (DescUbiGeo varchar(10),codmunicipio varchar(10),campo1 varchar(8))  
--insert into @codMuni_test1  
--select DescUbiGeo,codmunicipio,campo1  
--from tclubigeo u with(nolock)  
--where codubigeotipo='muni'  
  
  
  
  
  
  
select distinct cl.codprestamo,isnull(e.tiporeprog,0)tiporeprog  
   
--, e.codsolicitud  
, cl.codoficina  
--, e.fechasolicitud  
, cl.Desembolso  
,e.FechaEvaluacion FechaEvaluacion  
--, e.score_valor  
,s.valorScore valorScore--- agregado  
,e.Calificacion Calificacion  
--, e.ingreso   
--,c.ingresoMensual  
,i.ingreso ingreso  
--,e.gasto  
,i.gasto gasto  
--, e.imorpromotor, e.imorsucursal, e.montopagomensual, e.nrodiasmaximo  
,cl.codusuario  
--, c.paterno, c.Materno, c.Nombres, c.Nombre1, c.Nombre2 , c.NombreCompleto,c.usCURP, c.UsRFC  
, c.FechaNacimiento  
,(CONVERT(int,CONVERT(char(8),GETDATE(),112))-CONVERT(char(8),c.FechaNacimiento,112)) / 10000  Edad  
,c.CodEstadoCivil, c.Sexo , c.CodUbiGeoDirFamPri  
,u.nomubigeo  
,u.codmunicipio  
--,muni.DescUbiGeo  
--, c.CodPostalFam   
--,c.TelefonoMovil, c.LabCodActividad  
, a.Nombre --, a.Descripcion, cl.Desembolso, cl.tiporeprog  
--,ci.*  
,cl.clasCliente,isnull(cl.NroDiasAtraso,0)NroDiasAtraso ,isnull(cl.NroDiasAcumulado,0)NroDiasAcumulado   
--, cl.estadocalculado, cl.NroDiasMaximo, cl.FechaVencimiento,cl.ModalidadPlazo   
,isnull(cl.NroCuotas,0)NroCuotas, cl.TasaIntCorriente , cl.Monto,cl.SecuenciaCliente   
------------------  
,creditomaximo    
,LimiteCredito   
,montoPagar   
,saldoactual   
,saldovencido   
,numeroPagosVencidos   
from @clas_test1 cl   
left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e with (nolock) on cl.codprestamo=e.codprestamo   
inner join tcspadronclientes c with(nolock) on c.CodUsuario = cl.CodUsuario    
inner join tclactividad a with (nolock) on a.CodActividad = c.LabCodActividad  
inner join tclubigeo u with (nolock) on u.codubigeo=c.codubigeodirfampri  
left outer join @In_test1 i  on i.CodUsuario = c.Codorigen   
left outer join @score_test1 s  on s.codsolicitud = cl.codsolicitud and s.codoficina=cl.codoficina  
left outer join @det_test1 det  on s.idcc=det.idcc  
--inner join @codMuni_test1 muni with (nolock) on u.CodMunicipio=muni.codmunicipio and u.codubigeotipo='muni' and c.CodPostalFam=muni.campo1  
Where e.tiporeprog is not null  
  
--left outer join #CC ci with(nolock) on ci.codprestamo=cl.codprestamo  
--left outer join #cr_ante cr_an with(nolock) on cr_an.codprestamo=cl.codprestamo  
--drop table #ca  
--drop table #CC  
--drop table @clas_test1  
----drop table #cr_ante  
--drop table @In_test1  
--drop table @score_test1  
--drop table @det_test1  
--drop table @codMuni_test1  
----T:40seg-  
  
--rollback tran
GO