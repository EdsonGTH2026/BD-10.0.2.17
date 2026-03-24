SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pFMKDatosCobranzaMasivaMayor60

CREATE procedure [dbo].[pFMKDatosCobranzaMasivaMayor60] @fecha smalldatetime, @ControlInterno varchar(20)
as

--declare @fecha smalldatetime
--declare @ControlInterno varchar(20)
--set @fecha='20140915'
--set @ControlInterno = ''

create table #c(
  codprestamo varchar(25),
  montooriginal decimal(18,2),
  saldocapital decimal(18,2),
  saldocartera decimal(18,2),
  deudatotal decimal(18,2),
  cuotasporpagar int,
  cuotasatrasadas int,
  nrodiasatraso int,
  codusuario varchar(15),
  usuarioase varchar(15),
  codasesor varchar(15)
)

create table #avales(
  --avalid int identity(1,1),
  codprestamo varchar(25),
  codusuarioaval varchar(15)
)

create table #codeudor(
  --codeudorid int identity(1,1),
  codprestamo varchar(25),
  codusuariocode varchar(15)
)

insert into #c
select c.codprestamo
,d.montodesembolso MontoOriginal,d.saldocapital,d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido saldocartera
,d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden
+d.otroscargos+d.impuestos+d.cargomora deudatotal,c.nrocuotasporpagar, 0 Cuotasatrasadas,c.nrodiasatraso,d.codusuario
,u.usuario,c.codasesor
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
left outer join tsgusuarios u with(nolock) on u.codusuario=c.codasesor
where c.fecha=@fecha and c.nrodiasatraso>60 and c.nrodiasatraso<161
 
--Avales
insert into #avales
SELECT  g.codigo, max(codusuario) codusuario
FROM tCsGarantias g with(nolock)
inner join tcspadronclientes cl with(NOLOCK) on cl.codorigen=g.docpropiedad
where g.tipogarantia='IPN' 
and g.codigo in (select codprestamo from #c)
group by g.codigo
 
--CODEUDOR
insert into #codeudor
SELECT codprestamo,max(CodUsuario) CodUsuario
FROM tCsPrestamoCodeudor with(nolock)
where codprestamo in (select codprestamo from #c)
group by codprestamo

--select * from #c where codprestamo in ('003-158-06-09-00372','083-158-06-00-00006','079-123-06-08-00051') 
--select * from #avales where codprestamo in ('003-158-06-09-00372','083-158-06-00-00006','079-123-06-08-00051') order by codprestamo
--select codprestamo,max(codusuariocode) from #codeudor where codprestamo in ('003-158-06-09-00372','083-158-06-00-00006','079-123-06-08-00051')  group by codprestamo  

--Titulares
select 
	TI.*
,isnull(AV.AvalCodUsuario    ,'')  AvalCodUsuario
	,isnull(AV.AvalApPaterno    ,'')  AvalApPaterno    
	,isnull(AV.AvalApMaterno	,'')  AvalApMaterno	
	,isnull(AV.AvalNombres		,'')  AvalNombres		
	,isnull(AV.AvalTelDomicilio	,'')  AvalTelDomicilio	
	,isnull(AV.AvalTelNegocio	,'')  AvalTelNegocio	
	,isnull(AV.AvalTelCelular	,'')  AvalTelCelular	
	,isnull(AV.AvalCalle		,'')  AvalCalle		
	,isnull(AV.AvalNumeroExt	,'')  AvalNumeroExt	
	,isnull(AV.AvalNumeroInt	,'')  AvalNumeroInt	
	,isnull(AV.AvalColonia		,'')  AvalColonia		
	,isnull(AV.AvalCodigoPostal	,'')  AvalCodigoPostal	
	,isnull(AV.AvalMunicipio	,'')  AvalMunicipio	
	,isnull(AV.AvalEstado		,'')  AvalEstado		

,isnull(CO.CodeudorCodUsuario    ,'') CodeudorCodUsuario 
	,isnull(CO.CodeudorApPaterno    ,'') CodeudorApPaterno    
	,isnull(CO.CodeudorApMaterno	,'') CodeudorApMaterno	
	,isnull(CO.CodeudorNombres		,'') CodeudorNombres		
	,isnull(CO.CodeudorTelDomicilio	,'') CodeudorTelDomicilio	
	,isnull(CO.CodeudorTelNegocio	,'') CodeudorTelNegocio	
	,isnull(CO.CodeudorTelCelular	,'') CodeudorTelCelular	
	,isnull(CO.CodeudorCalle		,'') CodeudorCalle		
	,isnull(CO.CodeudorNumeroExt	,'') CodeudorNumeroExt	
	,isnull(CO.CodeudorNumeroInt	,'') CodeudorNumeroInt	
	,isnull(CO.CodeudorColonia		,'') CodeudorColonia		
	,isnull(CO.CodeudorCodigoPostal	,'') CodeudorCodigoPostal	
	,isnull(CO.CodeudorMunicipio	,'') CodeudorMunicipio	
	,isnull(CO.CodeudorEstado		,'') CodeudorEstado		
	 
from 
(select 
	  c.codprestamo											as CodPrestamo
, cl.codusuario											as TitularCodUsuario
	, cl.paterno											as TitularApPaterno
	, cl.materno											as TitularApMaterno
	, cl.nombres											as TitularNombres
	, replace(cl.telefonodirfampri,'_','')					as TitularTelDomicilio
	, replace(cl.telefonodirnegpri,'_','')					as TitularTelNegocio
	, replace(cl.telefonomovil,'_','')						as TitularTelCelular
	, c.MontoOriginal										as MontoOriginal
	, c.saldocapital										as SaldoCapital
	, c.saldocartera										as SaldoCartera
	, c.deudatotal											as DeudaTotal
	, c.cuotasporpagar										as CuotasRestantes
	, c.Cuotasatrasadas										as CuotasAtrasadas
	, c.nrodiasatraso										as DiasAcomuladosAtraso
	, isnull(cl.direcciondirfampri,cl.direcciondirnegpri)	as TitularCalle
	, replace(isnull(cl.numextfam,cl.numextneg),'_','')		as TitularNumeroExt
	, replace(isnull(cl.numintfam,cl.numintneg),'_','')		as TitularNumeroInt
	, u.colonia												as TitularColonia
	, replace(isnull(codpostalfam,codpostalneg),'_','')		as TitularCodigoPostal
	, u.municipio											as TitularMunicipio
	, u.estado												as TitularEstado
	, ltrim(rtrim(c.codusuario))							as EjecutorCobranza
	, c.usuarioase as username									--as username --,c.usuarioase username
	, @fecha												as FechaCorte
	, getdate()												as FechaCreacion
	, @ControlInterno										as ControlInterno
	--, substring(convert(varchar(11), @fecha,112),1,6) + '-' + ltrim(rtrim(c.codusuario)) + '-' + ltrim(rtrim(c.codprestamo))       as externalid
	, ltrim(rtrim(c.usuarioase)) + '-' + ltrim(rtrim(c.codprestamo))       as externalid
from #c c
inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
left outer join vCsUbigeoColonia u on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
--where c.codasesor not in(SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50))
) TI

--Avales
left outer join  
(
select 
	  'Aval' t
	, c.codprestamo 										as CodPrestamo
	, cl.codusuario 											as AvalCodUsuario
	, cl.paterno 											as AvalApPaterno
	, cl.materno											as AvalApMaterno
	, cl.nombres											as AvalNombres
	, replace(cl.telefonodirfampri,'_','')					as AvalTelDomicilio
	, replace(cl.telefonodirnegpri,'_','')					as AvalTelNegocio
	, replace(cl.telefonomovil,'_','')						as AvalTelCelular
	, c.MontoOriginal										as MontoOriginal
	, c.saldocapital										as SaldoCapital
	, c.saldocartera										as SaldoCartera
	, c.deudatotal											as DeudaTotal
	, c.cuotasporpagar										as CuotasRestantes
	, c.Cuotasatrasadas										as CuotasAtrasadas
	, c.nrodiasatraso										as DiasAcomuladosAtraso
	, isnull(cl.direcciondirfampri,cl.direcciondirnegpri)	as AvalCalle
	, replace(isnull(cl.numextfam,cl.numextneg),'_','') 	as AvalNumeroExt
	, replace(isnull(cl.numintfam,cl.numintneg),'_','') 	as AvalNumeroInt
	, u.colonia												as AvalColonia
	, replace(isnull(codpostalfam,codpostalneg),'_','') 	as AvalCodigoPostal
	, u.municipio											as AvalMunicipio
	, u.estado												as AvalEstado
from #avales a inner join #c c on a.codprestamo=c.codprestamo
inner join tcspadronclientes cl with(nolock) on cl.codusuario=a.codusuarioaval
left outer join vCsUbigeoColonia u on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
--where c.codasesor not in(SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50))
) AV on TI.CodPrestamo = AV.CodPrestamo

--CODEUDOR
left outer join (
select 
	'Codeudor' t
	, c.codprestamo																as CodPrestamo
	, cl.codusuario																as CodeudorCodUsuario
	, cl.paterno																as CodeudorApPaterno
	, cl.materno																as CodeudorApMaterno
	, cl.nombres																as CodeudorNombres
	, replace(cl.telefonodirfampri,'_','')										as CodeudorTelDomicilio
	, replace(cl.telefonodirnegpri,'_','')										as CodeudorTelNegocio
	, replace(cl.telefonomovil,'_','')											as CodeudorTelCelular
	, c.MontoOriginal															as MontoOriginal
	, c.saldocapital															as SaldoCapital
	, c.saldocartera															as SaldoCartera
	, c.deudatotal																as DeudaTotal
	,c.cuotasporpagar															as CuotasRestantes
	, c.Cuotasatrasadas															as CuotasAtrasadas
	,c.nrodiasatraso															as DiasAcomuladosAtraso
	,replace(isnull(cl.direcciondirfampri,cl.direcciondirnegpri),'_','')		as CodeudorCalle
	,replace(isnull(cl.numextfam,cl.numextneg),'_','')							as CodeudorNumeroExt
	,replace(isnull(cl.numintfam,cl.numintneg),'_','')  						as CodeudorNumeroInt
	,u.colonia																	as CodeudorColonia
	,replace(isnull(codpostalfam,codpostalneg),'_','') 							as CodeudorCodigoPostal
	,u.municipio																as CodeudorMunicipio
	,u.estado																	as CodeudorEstado
from #codeudor a inner join #c c on a.codprestamo=c.codprestamo
inner join tcspadronclientes cl with(nolock) on cl.codusuario=a.codusuariocode
left outer join vCsUbigeoColonia u on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
--where c.codasesor not in(SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50))
) CO on TI.CodPrestamo = CO.CodPrestamo

drop table #avales
drop table #codeudor
drop table #c
GO