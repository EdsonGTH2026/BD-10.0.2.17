SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--exec pvINTFNombreSIC '20200531' 
--SP_HELPTEXT [pvINTFNombreSIC] 

  
CREATE PROCEDURE [dbo].[pvINTFNombreSIC] @fecha smalldatetime   
AS  
set nocount on  
--declare @fecha smalldatetime  --comentar  
--set @fecha='20201130'  --comentar  
  
declare @primerdia smalldatetime  
select @primerdia=primerdia from tclperiodo with(nolock) where ultimodia=@fecha  
  
truncate table tCsBuroxTblReInomVr14 --descomentar  
  
/***************  vINTFNombreCartera  ******************/  
create table #ca(codprestamo varchar(20), codusuario varchar(15),codfondo int)  
insert into #ca  
select distinct d.codprestamo,d.codusuario,c.codfondo  
FROM tCsCarteraDet d with(nolock)  
inner join tcscartera c with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fecha  
where d.Fecha=@fecha  
and d.codprestamo not in (select codprestamo from tCsBuroDepuLey with(nolock))--='018-158-06-04-00037'  
and d.codprestamo not in (select codprestamo from tCaCtasLiqPago with(nolock))  
and d.codoficina not in ('230','231')  
and d.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
  
----select * from ca#  
----drop table ca#  
insert into tCsBuroxTblReInomVr14   
SELECT 'Cartera' AS Tipo, @fecha Fecha, c.CodPrestamo, c.CodUsuario  
, (Case   
      when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') like '%XX%' Then ISNULL(RTRIM(LTRIM(cl.Materno)),'')   --2018/06/04  
      when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then ISNULL(RTRIM(LTRIM(cl.Materno)),'')   
      Else  ISNULL(RTRIM(LTRIM(cl.Paterno)),'')    
 End) AS Paterno  
, (Case   
     when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') like '%XX%' Then 'NO PROPORCIONADO'  --2018/06/04  
     when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then 'NO PROPORCIONADO'   
     Else ISNULL(RTRIM(LTRIM(cl.Materno)),'')    
 End) As Materno  
,  '' as Adicional  
, ISNULL(RTRIM(LTRIM(cl.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(cl.Nombre2)), '')   
+ ' ' + ISNULL(RTRIM(LTRIM(cl.Nombre3)), '') AS Nombre2  
,dbo.fduFechaATexto(cl.FechaNacimiento, 'DDMMAAAA') AS Nacimiento  
,(case when len(cl.UsRFCBD) > 0 then cl.UsRFCBD  
 else dbo.f_Calcula_RFC(cl.Nombre1 + ' ' +isnull(cl.Nombre2,'') ,cl.Paterno, cl.Materno, cl.FechaNacimiento)  
 end) as UsRFCBD  
,'' AS Prefijo, '' AS Sufijo  
, dbo.tClPaises.INTF AS Nacionalidad, dbo.tUsClTipoPropiedad.INTF AS Residencia  
,CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir  
,dbo.tUsClEstadoCivil.INTF AS EstadoCivil, dbo.tUsClSexo.INTF AS Sexo, '' AS CedulaProfesional  
, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE  
, CASE cl.coddociden WHEN 'CURP' THEN cl.DI ELSE '' END AS CURP--'' AS ImpuestoOtroPais  
, '' AS ClaveOtroPais, cl.UsNDependientes AS NumeroDependientes, '' AS EdadesDependientes,   
'' AS DefuncionFecha, '' AS DefuncionIndicador  
,c.codfondo  
from #ca c  
INNER JOIN tCsPadronClientes cl with(nolock) ON cl.CodUsuario=c.CodUsuario  
LEFT OUTER JOIN tUsClTipoPropiedad with(nolock) ON ISNULL(cl.TipoPropiedadDirFam, cl.TipoPropiedadDirNeg)=tUsClTipoPropiedad.CodTipoPro   
LEFT OUTER JOIN tUsClSexo with(nolock) ON cl.Sexo = tUsClSexo.Sexo   
LEFT OUTER JOIN tUsClEstadoCivil with(nolock) ON cl.CodEstadoCivil = tUsClEstadoCivil.CodEstadoCivil   
LEFT OUTER JOIN tClPaises with(nolock) ON cl.CodPais = tClPaises.CodPais   
  
--/***************  vINTFNombreAvales  ******************/  
create table #ga(codprestamo varchar(20),codusuario varchar(15),codfondo int)  
insert into #ga  
SELECT g.Codigo AS CodPrestamo, x.CodUsuario,c.codfondo  
FROM tCsdiaGarantias g with(nolock)   
inner join #ca c on c.codprestamo=g.codigo  
INNER JOIN tCsPadronClientes x with(nolock) ON g.docpropiedad=x.CodOriginal   
WHERE g.Fecha=@fecha --'20201031'--  
and g.tipogarantia='IPN' and g.estado in('ACTIVO','MODIFICADO')  
  
insert into tCsBuroxTblReInomVr14   
SELECT 'Aval' AS Tipo, @fecha as Fecha, g.CodPrestamo, g.CodUsuario  
,Case when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then  ISNULL(RTRIM(LTRIM(cl.Materno)),'') Else  ISNULL(RTRIM(LTRIM(cl.Paterno)),'')  End AS Paterno  
,Case when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then  'NO PROPORCIONADO' Else ISNULL(RTRIM(LTRIM(cl.Materno)),'')  End As Materno, '' AS Adicional  
, ISNULL(RTRIM(LTRIM(cl.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(cl.Nombre2)), '')   
+ ' ' + ISNULL(RTRIM(LTRIM(cl.Nombre3)), '') AS Nombre2, dbo.fduFechaATexto(cl.FechaNacimiento, 'DDMMAAAA') AS Nacimiento  
--,cl.UsRFCBD 
,(case when len(cl.UsRFCBD) > 0 then cl.UsRFCBD  
else dbo.f_Calcula_RFC(cl.Nombre1 + ' ' +isnull(cl.Nombre2,'') ,cl.Paterno, cl.Materno, cl.FechaNacimiento)  
end) as UsRFCBD
,'' AS Prefijo, '' AS Sufijo, tClPaises.INTF AS Nacionalidad, tUsClTipoPropiedad.INTF AS Residencia  
,CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir  
,tUsClEstadoCivil.INTF AS EstadoCivil,tUsClSexo.INTF AS Sexo  
,'' AS CedulaProfesional, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE  
,CASE cl.coddociden WHEN 'CURP' THEN cl.DI ELSE '' END AS CURP--'' AS ImpuestoOtroPais  
,'' AS ClaveOtroPais  
,cl.UsNDependientes AS NumeroDependientes  
,'' AS EdadesDependientes, '' AS DefuncionFecha, '' AS DefuncionIndicador  
,g.codfondo  
from #ga g with(nolock)  
INNER JOIN tCsPadronClientes cl with(nolock) on cl.codusuario=g.codusuario  
LEFT OUTER JOIN tUsClTipoPropiedad with(nolock) ON ISNULL(cl.TipoPropiedadDirFam, cl.TipoPropiedadDirNeg) = tUsClTipoPropiedad.CodTipoPro   
LEFT OUTER JOIN tUsClSexo with(nolock) ON cl.Sexo=tUsClSexo.Sexo   
LEFT OUTER JOIN tUsClEstadoCivil with(nolock) ON cl.CodEstadoCivil=tUsClEstadoCivil.CodEstadoCivil   
LEFT OUTER JOIN tClPaises with(nolock) ON cl.CodPais=tClPaises.CodPais   
  
drop table #ca  
drop table #ga  
  
--/***************  vINTFNombreCancelados  ******************/  
/*titulares*/  
create table #Li(codprestamo varchar(20), codusuario varchar(15), tipo varchar(20), fechacorte smalldatetime, codfondo int)  
insert into #Li  
SELECT distinct d.CodPrestamo, d.CodUsuario,'CanceladosT' tipo,d.fechacorte,c.codfondo  
FROM tCsPadronCarteraDet d with(nolock)  
inner join tcscartera c with(nolock) on d.codprestamo=c.codprestamo and d.fechacorte=c.fecha  
WHERE d.EstadoCalculado='CANCELADO' and d.cancelacion>=@primerdia and d.cancelacion<=@fecha  
--WHERE EstadoCalculado='CANCELADO' and cancelacion>='20201001' and cancelacion<='20201031'  
  
/*avales*/  
insert into #Li  
SELECT g.Codigo AS CodPrestamo, x.CodUsuario,'CanceladosA' tipo,p.fechacorte,p.codfondo  
FROM tCsdiaGarantias g with(nolock)  
inner join #Li p with(nolock) on p.codprestamo=g.codigo and p.fechacorte=g.fecha  
INNER JOIN tCsPadronClientes x with(nolock) ON g.docpropiedad=x.CodOriginal  
WHERE g.tipogarantia='IPN' and g.estado in('ACTIVO','MODIFICADO')  
  
insert into tCsBuroxTblReInomVr14   
SELECT d.Tipo,@fecha Fecha, d.CodPrestamo, d.CodUsuario  
,Case when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then  ISNULL(RTRIM(LTRIM(cl.Materno)),'') Else  ISNULL(RTRIM(LTRIM(cl.Paterno)),'')  End AS Paterno  
,Case when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then  'NO PROPORCIONADO' Else ISNULL(RTRIM(LTRIM(cl.Materno)),'')  End As Materno  
,'' AS Adicional  
, ISNULL(RTRIM(LTRIM(cl.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(cl.Nombre2)), '')   
+ ' ' + ISNULL(RTRIM(LTRIM(cl.Nombre3)), '') AS Nombre2,   
dbo.fduFechaATexto(cl.FechaNacimiento, 'DDMMAAAA') AS Nacimiento  
--,cl.UsRFCBD  
,(case when len(cl.UsRFCBD) > 0 then cl.UsRFCBD  
 else dbo.f_Calcula_RFC(cl.Nombre1 + ' ' +isnull(cl.Nombre2,'') ,cl.Paterno, cl.Materno, cl.FechaNacimiento)  
 end) as UsRFCBD
,'' AS Prefijo, '' AS Sufijo  
,tClPaises.INTF AS Nacionalidad, tUsClTipoPropiedad.INTF AS Residencia, CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir  
,isnull(tUsClEstadoCivil.INTF,'S') AS EstadoCivil, tUsClSexo.INTF AS Sexo, '' AS CedulaProfesional, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE  
,CASE cl.coddociden WHEN 'CURP' THEN cl.DI ELSE '' END AS CURP  
,'' AS ClaveOtroPais, isnull(cl.UsNDependientes,0) AS NumeroDependientes, '' AS EdadesDependientes  
,'' AS DefuncionFecha, '' AS DefuncionIndicador  
,d.codfondo  
from #li d  
INNER JOIN tCsPadronClientes cl with(nolock) ON cl.codusuario=d.codusuario  
LEFT OUTER JOIN tUsClTipoPropiedad with(nolock) ON ISNULL(cl.TipoPropiedadDirFam,cl.TipoPropiedadDirNeg)=tUsClTipoPropiedad.CodTipoPro   
LEFT OUTER JOIN tUsClSexo with(nolock) ON cl.Sexo=tUsClSexo.Sexo  
LEFT OUTER JOIN tUsClEstadoCivil with(nolock) ON cl.CodEstadoCivil=tUsClEstadoCivil.CodEstadoCivil   
LEFT OUTER JOIN tClPaises with(nolock) ON cl.CodPais=tClPaises.CodPais   
  
drop table #Li  


--select * from tCsBuroxTblReInomVr14 with(nolock)
update tCsBuroxTblReInomVr14
set Paterno='XXXX'
where Paterno='x'  

  
--select count(*) from tCsBuroxTblReInomVr14 with(nolock)
GO