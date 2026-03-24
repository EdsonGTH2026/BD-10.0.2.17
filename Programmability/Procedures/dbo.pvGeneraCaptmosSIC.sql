SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pvGeneraCaptmosSIC '20200531' ,'20200531'  
CREATE PROCEDURE [dbo].[pvGeneraCaptmosSIC] @fecha smalldatetime,@primerdia smalldatetime  
AS  
set nocount on  

--declare @fecha smalldatetime  --comentar  
--set @fecha='20230731'  --comentar  
  
--declare @primerdia smalldatetime  
--select @primerdia=primerdia from tclperiodo with(nolock) where ultimodia=@fecha  
    
/***************  vINTFNombreCartera  ******************/  
create table #ca(codprestamo varchar(20), codusuario varchar(15),codfondo int)  
insert into #ca  
select d.codprestamo,d.codusuario,c.codfondo  
FROM tCsCarteraDet d with(nolock)  
inner join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fecha  
where d.Fecha=@fecha  
and d.codprestamo not in (select codprestamo from tCsBuroDepuLey with(nolock))--='018-158-06-04-00037'  
and d.codprestamo not in (select codprestamo from tCaCtasLiqPago with(nolock))  
and d.codoficina not in ('230','231','999')  
and d.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
  
CREATE TABLE #CarTotal (TIPO VARCHAR(35),FECHA SMALLDATETIME,CODPRESTAMO VARCHAR(35),CODUSUARIO VARCHAR(35),CODFONDO VARCHAR(6)) 
  
  
----select * from ca#  
----drop table ca#  

INSERT INTO #CarTotal
SELECT 'Cartera' AS Tipo, @fecha Fecha, c.CodPrestamo, c.CodUsuario  ,c.codfondo  
from #ca c  


--/***************  vINTFNombreAvales  ******************/  
create table #ga(codprestamo varchar(20),codusuario varchar(15),codfondo int)  
insert into #ga  
SELECT g.Codigo AS CodPrestamo, x.CodUsuario,c.codfondo  
FROM tCsdiaGarantias g with(nolock)   
inner join #ca c on c.codprestamo=g.codigo  
INNER JOIN tCsPadronClientes x with(nolock) ON g.docpropiedad=x.CodOriginal   
WHERE g.Fecha=@fecha --'20201031'--  
and g.tipogarantia='IPN' and g.estado in('ACTIVO','MODIFICADO')  
  
insert into #CarTotal 
SELECT 'Aval' AS Tipo, @fecha as Fecha, g.CodPrestamo, g.CodUsuario  
,g.codfondo  
from #ga g with(nolock)  

  
drop table #ca  
drop table #ga  
  
--/***************  vINTFNombreCancelados  ******************/  
/*titulares*/  
create table #Li(codprestamo varchar(20), codusuario varchar(15), tipo varchar(20), fechacorte smalldatetime, codfondo int)  
insert into #Li  
SELECT d.CodPrestamo, d.CodUsuario,'CanceladosT' tipo,d.fechacorte,c.codfondo  
FROM tCsPadronCarteraDet d with(nolock)  
inner join tcscartera c with(nolock) on d.codprestamo=c.codprestamo and d.fechacorte=c.fecha  
WHERE d.EstadoCalculado='CANCELADO' and d.cancelacion>=@primerdia and d.cancelacion<=@fecha  
  
/*avales*/  
insert into #Li  
SELECT g.Codigo AS CodPrestamo, x.CodUsuario,'CanceladosA' tipo,p.fechacorte,p.codfondo  
FROM tCsdiaGarantias g with(nolock)  
inner join #Li p with(nolock) on p.codprestamo=g.codigo and p.fechacorte=g.fecha  
INNER JOIN tCsPadronClientes x with(nolock) ON g.docpropiedad=x.CodOriginal  
WHERE g.tipogarantia='IPN' and g.estado in('ACTIVO','MODIFICADO')  
  
insert into #CarTotal   
SELECT d.Tipo,@fecha Fecha, d.CodPrestamo, d.CodUsuario ,d.codfondo  
from #li d  
  
drop table #Li  

select * from #CarTotal with(nolock)

DROP TABLE #CarTotal 

---validar 
--select count(*) from tCsBuroxTblReInomVr14 with(nolock) 
---72,864
---72,802
GO