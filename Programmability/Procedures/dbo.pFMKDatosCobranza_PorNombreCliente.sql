SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pFMKDatosCobranza_PorNombreCliente] @ControlInterno varchar(20), @nombrecliente varchar(30), @CodAsesor varchar(20)
as

/*
--declare @fecha smalldatetime
declare @ControlInterno varchar(20)
declare @nombrecliente varchar(20)
declare @codasesor varchar(15)
--set @fecha='20141003'
set @ControlInterno = ''
set @nombrecliente = 'cardenas lopez j'
set @codasesor = '' --'OCF2312901'
*/

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
  codprestamo varchar(25),
  codusuarioaval varchar(15)
)

create table #codeudor(
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
where 
--c.fecha=@fecha 
c.fecha = (select max(c1.fecha) from tcscartera as c1 where c1.codprestamo = c.codprestamo)
and c.codprestamo = (select top 1 codprestamo from tcscartera where codusuario = d.codusuario order by fechadesembolso desc)
--and c.nrodiasatraso>0 
--and c.nrodiasatraso<=60

--and c.codasesor = isnull( @codasesor, c.codasesor)
and c.codasesor =(
		case
		when len(@CodAsesor) = 0 then c.codasesor
		else @CodAsesor
		end
	         )

--*** La siguiente condiciona se puso para filtrar a los clientes x nombre ***
and d.codusuario in (select top 50 CodUsuario from tCsPadronClientes  
                     where NombreCompleto like '%' + @nombrecliente +'%' order by NombreCompleto)
order by c.fecha, d.codusuario, c.codprestamo
 
--Avales
insert into #avales
SELECT distinct g.codigo, codusuario
FROM tCsGarantias g with(nolock)
inner join tcspadronclientes cl with(NOLOCK) on cl.codorigen=g.docpropiedad
where g.tipogarantia='IPN' 
and g.codigo in (select codprestamo from #c)
 
--CODEUDOR
insert into #codeudor
SELECT codprestamo,CodUsuario
FROM tCsPrestamoCodeudor with(nolock)
where codprestamo in (select codprestamo from #c)

--Titulares
select top 1
	TI.*
,isnull(AV.AvalCodUsuario    ,'') as AvalCodUsuario 
	,isnull(AV.AvalApPaterno    ,'') as AvalApPaterno    
	,isnull(AV.AvalApMaterno	,'') as AvalApMaterno	
	,isnull(AV.AvalNombres		,'') as AvalNombres		
	,isnull(AV.AvalTelDomicilio	,'') as AvalTelDomicilio	
	,isnull(AV.AvalTelNegocio	,'') as AvalTelNegocio	
	,isnull(AV.AvalTelCelular	,'') as AvalTelCelular	
	,isnull(AV.AvalCalle		,'') as AvalCalle		
	,isnull(AV.AvalNumeroExt	,'') as AvalNumeroExt	
	,isnull(AV.AvalNumeroInt	,'') as AvalNumeroInt	
	,isnull(AV.AvalColonia		,'') as AvalColonia		
	,isnull(AV.AvalCodigoPostal	,'') as AvalCodigoPostal	
	,isnull(AV.AvalMunicipio	,'') as AvalMunicipio	
	,isnull(AV.AvalEstado		,'') as AvalEstado		

,isnull(CO.CodeudorCodUsuario     ,'') as CodeudorCodUsuario
	,isnull(CO.CodeudorApPaterno     ,'') as CodeudorApPaterno    
	,isnull(CO.CodeudorApMaterno	 ,'') as CodeudorApMaterno	
	,isnull(CO.CodeudorNombres		 ,'') as CodeudorNombres		
	,isnull(CO.CodeudorTelDomicilio	 ,'') as CodeudorTelDomicilio	
	,isnull(CO.CodeudorTelNegocio	 ,'') as CodeudorTelNegocio	
	,isnull(CO.CodeudorTelCelular	 ,'') as CodeudorTelCelular	
	,isnull(CO.CodeudorCalle		 ,'') as CodeudorCalle		
	,isnull(CO.CodeudorNumeroExt	 ,'') as CodeudorNumeroExt	
	,isnull(CO.CodeudorNumeroInt	 ,'') as CodeudorNumeroInt	
	,isnull(CO.CodeudorColonia		 ,'') as CodeudorColonia		
	,isnull(CO.CodeudorCodigoPostal	 ,'') as CodeudorCodigoPostal	
	,isnull(CO.CodeudorMunicipio	 ,'') as CodeudorMunicipio	
	,isnull(CO.CodeudorEstado		 ,'') as CodeudorEstado		
from 
(select 
	  c.codprestamo											as CodPrestamo
	, cl.CodUsuario											as TitularCodUsuario
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
	, c.usuarioase											as username
	--, @fecha												as FechaCorte
	, getdate()												as FechaCreacion
	, @ControlInterno										as ControlInterno
	--, substring(convert(varchar(11), @fecha,112),1,6) + '-' + ltrim(rtrim(c.codusuario)) + '-' + ltrim(rtrim(c.codprestamo))       as externalid
	, ltrim(rtrim(c.usuarioase)) + '-' + ltrim(rtrim(c.codprestamo))       as externalid
from #c c
inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
left outer join vCsUbigeoColonia u on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
--where c.codasesor not in(SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50))
) TI
--union

--Avales
--join 
left outer join  
(
select 
	  'Aval' t
	, c.codprestamo 										as CodPrestamo
	, cl.CodUsuario 										as AvalCodUsuario
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
--union
--CODEUDOR
--join 
left outer join 
(
select 
	'Codeudor' t
	, c.codprestamo																as CodPrestamo
	, cl.CodUsuario																as CodeudorCodUsuario
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