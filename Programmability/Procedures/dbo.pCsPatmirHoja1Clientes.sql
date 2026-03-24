SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--ANTES DE EJECUTAR EL MES REVISAR QUE EL MES ANTERIOR LOS DATOS ESTEN EN C=CERRADOS
--SELECT * FROM tCsFondReportados WHERE CodFondo = 'PT' AND Fecha >= '20131201' AND Fecha <= '20131231'
--SELECT * FROM tCsFondReportados WHERE CodFondo = 'PT' AND Fecha >= '20140201' AND Fecha <= '20140131'
--UPDATE tCsFondReportados SET Dato1Cad = 'C' WHERE CodFondo = 'PT' AND Fecha >= '20140201' AND Fecha <= '20140228'
--DROP PROC pCsPatmirHoja1Clientes
--EXEC pCsPatmirHoja1Clientes '20140301','20140331'
--/*
CREATE PROCEDURE [dbo].[pCsPatmirHoja1Clientes]
               ( @FecIni SMALLDATETIME ,
                 @FecFin SMALLDATETIME )
AS                 
--*/
EXEC pCsActualizaLocPatmir
--drop table #clientes
/*
DECLARE @fecini SMALLDATETIME
DECLARE @fecfin SMALLDATETIME
SET @fecini='20131001'
SET @fecfin='20131031'
--*/

CREATE TABLE #clientes 
	 ( codusuario       VARCHAR(15)  ,
	   codcuenta        VARCHAR(25)  ,
	   FraccionCta      VARCHAR(25)  ,
	   Renovado         TINYINT      ,
	   codoficina       VARCHAR(4)   ,
	   saldocta         DECIMAL(16,2),
	   monapertura      DECIMAL(16,2),
	   garantia         DECIMAL(16,2),
	   FechaVencimiento DATETIME     ,
	   FechaAperturaCta DATETIME     )

--4070 + 165 = 4235
DELETE FROM tCsFondReportados WHERE CodFondo = 'PT' And Dato1Cad IS NULL AND Fecha = @fecfin
--SELECT * FROM tCsFondReportados WHERE CodFondo = 'PT' AND Fecha = '20131130' And Dato1Cad IS NULL
--SELECT * FROM tCsFondReportados WHERE CodFondo = 'PT' AND Fecha <= '20131130'
--DELETE FROM tCsFondReportados WHERE CodFondo = 'PT' AND Fecha > '20131031'
--UPDATE tCsFondReportados SET Dato1Cad = 'C' WHERE  CodFondo = 'PT' AND Fecha <= '20131130' 

/*********************************************
--INSERTAR LOS CLIENTES PATMIR DEL MES ACTUAL
*********************************************/
INSERT INTO #clientes
SELECT pa.codusuario,pa.codcuenta,pa.fraccioncta,pa.renovado,pa.codoficina,ah.saldocuenta,pa.monapertura,
       case ah.idestadocta when 'CB' then ah.montobloqueado when 'CP' then ah.saldocuenta else 0 end Garantia,
       ah.FechaVencimiento, pa.fecapertura
  FROM tCsPadronAhorros pa
 INNER JOIN tcsahorros ah WITH(NOLOCK) ON ah.fecha=pa.fechacorte AND ah.codcuenta=pa.codcuenta AND ah.FraccionCta=pa.FraccionCta
   AND ah.renovado=pa.renovado
 WHERE pa.fecapertura>=@FecIni AND pa.fecapertura<=@FecFin
 --AND pa.estadocalculado<>'CC' 
   AND pa.codusuario NOT IN (select distinct codusuario from tcspadronahorros with(nolock) where fecapertura<@FecIni) 
                                                                     
DELETE #clientes WHERE codusuario IN (select distinct codusuario from tcspadroncarteradet with(nolock) where desembolso<@FecIni)
DELETE #clientes WHERE codusuario IN (select codusuario from tcstransacciondiaria with(nolock) where extornado=0 and codsistema='TC' and fecha<@FecIni)

/**********************************************************************
--INSERTAR LOS CLIENTES NUEVOS DEL MES ACTUAL EN EL LOG PARA HISTORICO
**********************************************************************/
INSERT INTO tCsFondReportados 
SELECT DISTINCT 'PT', @fecfin Fecha,'', CodUsuario, NULL, NULL, NULL, NULL
  FROM #clientes
--select * from #clientes order by codusuario
  
/*******************************************
OBTENER CLIENTES DE LOS MESES YA REPORTADOS
*******************************************/
INSERT INTO #clientes
SELECT pa.codusuario,pa.codcuenta,pa.fraccioncta,pa.renovado,pa.codoficina,ah.saldocuenta,pa.monapertura,
       case ah.idestadocta when 'CB' then ah.montobloqueado when 'CP' then ah.saldocuenta else 0 end Garantia,
       ah.FechaVencimiento, pa.fecapertura
  FROM tCsPadronAhorros pa
 INNER JOIN tcsahorros ah WITH(NOLOCK) ON ah.fecha=pa.fechacorte AND ah.codcuenta=pa.codcuenta AND ah.FraccionCta=pa.FraccionCta
   AND ah.renovado    = pa.renovado
 WHERE pa.fecapertura>= '20120701' AND pa.fecapertura <= @FecFin--@fecini
   AND pa.codusuario IN (Select codusuario From tCsFondReportados Where CodFondo = 'PT'  And Dato1Cad = 'C')--And Fecha < @fecini)
 --and pa.codusuario = 'ARM1004801'
 --AND pa.estadocalculado<>'CC' 
 --and pa.codusuario not in (select distinct codusuario from tcspadronahorros with(nolock) where fecapertura<'20120701') 

DELETE #clientes WHERE codusuario IN (select distinct codusuario from tcspadroncarteradet with(nolock) where desembolso<'20120701')
DELETE #clientes WHERE codusuario IN (select codusuario from tcstransacciondiaria with(nolock) where extornado=0 and codsistema='TC' and fecha<'20120701')

--select * from tCsFondReportados where codusuario = 'ARM1004801' and codfondo = 'PT'
--select * from tcsahorros where codusuario = 'ARM1004801' order by fecha desc
--select * from #clientes where codusuario = 'ARM1004801'
--Select codusuario From tCsFondReportados Where CodFondo = 'PT'  And Dato1Cad = 'C' and codusuario = 'ARM1004801'
--select * from tcsahorros where c
/*
select codusuario From tCsFondReportados Where CodFondo = 'PT'  And Dato1Cad = 'C' and codusuario not in
(SELECT distinct pa.codusuario
  FROM tCsPadronAhorros pa
 INNER JOIN tcsahorros ah WITH(NOLOCK) ON ah.fecha=pa.fechacorte AND ah.codcuenta=pa.codcuenta AND ah.FraccionCta=pa.FraccionCta
   AND ah.renovado    = pa.renovado
 WHERE pa.fecapertura>= '20120701' AND pa.fecapertura <= '20130930'--@fecini
   AND pa.codusuario IN (Select codusuario From tCsFondReportados Where CodFondo = 'PT'  And Dato1Cad = 'C'))
select * from tCsFondReportados Where CodFondo = 'PT' and codusuario = 'AHJ1206501'
select * from tcsahorros where codusuario = 'AHJ1206501' order by fecha desc
select * from tCsPadronAhorros where codusuario = 'AHJ1206501'
--SELECT codusuario,* from tCsFondReportados where CodFondo = 'PT' order by codusuario asc
--select distinct codusuario from #clientes
*/
                     
/**********************************
--DATOS CLIENTES AHORRO Y CRÉDITOS
**********************************/
--drop table #cteubigeo
SELECT DISTINCT c.codorigen, o.nomoficina,u.codubigeo, c.codusuario,'PERSONA' tipodatos,
	   --cast(year(Fechanacimiento)as char(4)) +'/'+ replicate('0',2-len(cast(month(Fechanacimiento)as varchar(2)))) + cast(month(Fechanacimiento) as varchar(2)) +'/'+ replicate('0',2-len(cast(day(Fechanacimiento)as varchar(2)))) + cast(day(Fechanacimiento) as varchar(2)) Fecha_nacimiento,
	   replicate('0',2-len(cast(day(Fechanacimiento)as varchar(2)))) + cast(day(Fechanacimiento) as varchar(2)) +'/'+replicate('0',2-len(cast(month(Fechanacimiento)as varchar(2)))) + cast(month(Fechanacimiento) as varchar(2)) +'/'+cast(year(Fechanacimiento)as char(4)) Fecha_nacimiento,
	   case when paterno is null then materno when paterno='' then materno else paterno end paterno,--isnull(paterno,materno) paterno,
	   case when paterno is null then '' when paterno='' then '' else materno end materno,--isnull(paterno,'') materno,
	   nombre1,isnull(nombre2,'') nombre2,'0' tipopersona,
       --cast(year(FechaAperturaCta)as char(4)) +'/'+ replicate('0',2-len(cast(month(FechaAperturaCta)as varchar(2)))) + cast(month(FechaAperturaCta) as varchar(2)) +'/'+ replicate('0',2-len(cast(day(FechaAperturaCta)as varchar(2)))) + cast(day(FechaAperturaCta) as varchar(2)) Fecha_inscripcion,
	   replicate('0',2-len(cast(day(FechaAperturaCta)as varchar(2)))) + cast(day(FechaAperturaCta) as varchar(2)) +'/'+replicate('0',2-len(cast(month(FechaAperturaCta)as varchar(2)))) + cast(month(FechaAperturaCta) as varchar(2)) +'/'+cast(year(FechaAperturaCta)as char(4)) Fecha_inscripcion,
	   case when sexo=0 then 'M' else 'F' end sexo, isnull(direcciondirfampri,direcciondirnegpri) direccion,
	   isnull(numextfam,numextneg) numero, u.descubigeo colonia, isnull(c.codpostalfam,c.codpostalneg) codpostal -- c.codpostalfam, c.codpostalneg--
	   ,c.LocPatmir Clave_Localidad, 
/*	   case when clavesiti.Clave_Localidad is null or clavesiti.Clave_Localidad = ''
	         then c.LocPatmir 
			 else clavesiti.Clave_Localidad end as Clave_Localidad, */
       isnull(s.NombreCompleto,'MATA MILLAN MARIA MYRNA') AS UsuarioCaptura,       			 
	   ' ' parte_social, ' ' as fecha_baja,cl.codoficina, cl.saldocta
  INTO #cteubigeo
  FROM tcspadronclientes   c with(nolock) 
 INNER JOIN tcloficinas    o with(nolock) ON o.codoficina = c.codoficina
 LEFT OUTER JOIN tclubigeo u with(nolock) ON u.codubigeo  = isnull(codubigeodirfampri,codubigeodirnegpri)
 /*LEFT OUTER JOIN (Select codubigeo,max(clave_localidad) clave_localidad 
                    From tClUbigeoSITIEqui with(nolock) 
                   Group By codubigeo) clavesiti on clavesiti.codubigeo=u.codubigeo*/
 LEFT OUTER JOIN tclUbigeoDGRV d ON c.LocPatmir = d.Localidad_id
 INNER JOIN (Select codusuario, codoficina, FechaAperturaCta, sum(saldocta) saldocta
               From #clientes
              Group by codusuario, codoficina,FechaAperturaCta) cl ON cl.codusuario = c.codusuario
 LEFT OUTER JOIN tsgusuarios s ON c.CodUsResp = s.CodUsuario
 WHERE c.codusuario IN (select codusuario from #clientes) 
   AND c.CodTPersona = '01' 
--   AND c.codusuario = 'PBJ2005891'
order by codpostal

SELECT CodOrigen, case when len(isnull(dirf.CodPostal,dirn.CodPostal)) = 6 then left(isnull(dirf.CodPostal,dirn.CodPostal),5) else isnull(dirf.CodPostal,dirn.CodPostal) end CodPostal  
  INTO #ActualizaCP
  FROM #cteubigeo u
  LEFT OUTER JOIN (Select codusuario, min(CodPostal) CodPostal from [10.0.2.14].Finmas.dbo.tususuariodireccion where FamiliarNegocio = 'F' group by codusuario)dirf on u.CodOrigen=dirf.codusuario 
  LEFT OUTER JOIN (Select codusuario, min(CodPostal) CodPostal from [10.0.2.14].Finmas.dbo.tususuariodireccion where FamiliarNegocio = 'N' group by codusuario)dirn on u.CodOrigen=dirn.codusuario 
 WHERE len(u.codpostal) = 6 
    OR u.codpostal = '00000' 
    OR u.codpostal IS NULL
       
--update tcspadronclientes set codpostalFam = '54240' where codusuario = 'SHJ0206871'   
UPDATE p
    SET p.codpostalFam = a.codpostal
   FROM tcspadronclientes p, #ActualizaCP a
  WHERE p.codorigen = a.codorigen
 
 UPDATE u
    SET u.Codpostal = a.codpostal
   FROM #cteubigeo u, #ActualizaCP a
  WHERE u.codorigen = a.codorigen

/*       
 SELECT u.Codpostal, a.codpostal, a.codorigen, u.codorigen
   FROM #cteubigeo u, #ActualizaCP a
  WHERE u.codorigen = a.codorigen
*/

--SELECT codpostal,* FROM [10.0.2.14].Finmas.dbo.tUsUsuarioDireccion 
 --WHERE codusuario IN (select CodOrigen from #cteubigeo where len(codpostal) = 6 or codpostal = '00000' or codpostal IS NULL)

--select isnull(codubigeofam,codubigeoneg) from [10.0.2.14].Finmas.dbo.tUsUsuarioDireccion where codusuario like '%33FHC2502701'

--SELECT CodOrigen,* FROM #cteubigeo WHERE len(codpostal) = 6 OR codpostal = '00000' OR codpostal IS NULL

--select * from tclubigeodgrv where localidad_id = '300870001'--'300870046'
--select * from #clientes where codusuario = 'ARM1004801'
--select * from #cteubigeo where codusuario = 'ARM1004801'
--select codpostal,* from #cteubigeo order by codpostal-- where codpostal = '00000'

--select codpostal,* from #cteubigeo where len(codpostal) = 6
--select codpostal,* from #cteubigeo where codpostal IS NULL

--select codpostal,* from [10.0.2.14].Finmas.dbo.tUsUsuarioDireccion where codusuario like '%33FHC2502701'
--update tcspadronclientes set codpostalFam = '54240' where codusuario = 'SHJ0206871'   
--select codubigeodirfampri, * from  tcspadronclientes where codusuario= 'PMM0407711'
--select codpostalfam, codpostalneg, * from tcspadronclientes where codusuario= 'VGE1108901'

/*
select codpostal,* from [10.0.2.14].Finmas.dbo.tUsUsuarioDireccion where codusuario like '%GRA0201921'
select codpostal,* from [10.0.2.14].Finmas.dbo.tUsUsuarioDireccion where codusuario like '%78SHJ0206871'
select codpostal,* from [10.0.2.14].Finmas.dbo.tUsUsuarioDireccion where codusuario like '%78PNA0604501'*/

--select codpostal,* from #cteubigeo where codusuario = 'MSM0810831' 

--update tcspadronclientes set codpostalFam = '50884' where codusuario = 'GRA0201921'   



/***********************
--HOJA 1 SOCIO-CLIENTES
***********************/
--drop table #hoja1
SELECT '0468' AS FolioIF, 
       isnull(c.CodUsuario,'') AS CveSocioCte, 
       isnull(c.paterno,'') AS PrimerApellido, 
       isnull(c.materno,'') AS SegundoApellido,
       rtrim(c.Nombre1)+' '+rtrim(c.Nombre2) AS Nombre, 
       CASE WHEN c.Sexo = 'M' THEN 'masculino' ELSE 'femenino' END AS Sexo,
       isnull(c.Fecha_Nacimiento,'') AS FechaNacimiento, 
       ' ' AS Lengua, 
       ' ' AS Ocupacion,--case when p.Descripcion is null then isnull(pc.RubroNegocio,'') else isnull(p.Descripcion,'') end AS Ocupacion,
       ' ' AS ActividadProductiva, --case when a.Descripcion is null then isnull(pc.Actividad,'') else isnull(a.Descripcion,'') end AS ActividadProductiva,
       ' ' AS EstadoCivil,--isnull(e.EstadoCivil,'') AS EstadoCivil, 
       ' ' AS Escolaridad, --isnull(pc.GradoInstruccion,'') AS Escolaridad, 
       isnull(c.Fecha_Inscripcion,'') as FechaAltaSistema, 
       case when isnull(replace(direccion,'_',''),'CALLE DESCONOCIDA')= '' then 'CALLE DESCONOCIDA' else isnull(replace(direccion,'_',''),'CALLE DESCONOCIDA')end AS Calle,
       case when isnull(replace(Numero,'_',''),'S\N') = '' then 'S\N' else isnull(replace(Numero,'_',''),'S\N') end as NumExt, 
       ' ' AS NumInt, 
       isnull(Colonia,'COLONIA DESCONOCIDA') AS Colonia, 
       case when isnull(replace(c.codpostal,'_',''),'11111') = '' then '00000' else isnull(replace(c.codpostal,'_',''),'00000') end AS CodigoPostal, 
       isnull(c.clave_localidad,'') as Localidad, 
       isnull(u.municipio_id,'') AS Municipio, 
       isnull(u.estado_id,'') AS Estado, 
       ' ' AS CapitalSocialRequerido,
       ' ' AS SaldoAportacionRequerido,
       ' ' AS SaldoAportacionExcedente,
       ' ' AS SaldoAportacionVoluntario,
       c.CodOficina AS Sucursal,
       UsuarioCaptura,
       ' ' FechaBaja,
       0 AS PersonaMoralFisica
  INTO #hoja1 --drop table #hoja1       
  FROM #cteubigeo c
  LEFT OUTER JOIN tclUbigeoDGRV    u ON c.clave_localidad  = u.localidad_id 
  WHERE c.clave_localidad is not null and c.clave_localidad <> ''
-- INNER JOIN tcspadronclientes     pc ON c.CodUsuario       = pc.CodUsuario
--  LEFT OUTER JOIN tClOcupaciones   p ON pc.USCODOCUPACION  = p.CodOcupacion
--  LEFT OUTER JOIN tClActividad     a ON pc.LabCodActividad = a.CodActividad
--  LEFT OUTER JOIN tUsClEstadoCivil e ON pc.CodEstadoCivil  = e.CodEstadoCivil

--select * from #cteubigeo where codusuario not in (select CveSocioCte from #hoja11)
--update  #hoja1 set localidad = '300870001' where  cvesociocte ='MKR0210841'
--drop table #hoja11
SELECT DISTINCT ''''+FolioIF FolioIF,	CveSocioCte,	PrimerApellido,	SegundoApellido, Nombre,	Sexo,
  	   FechaNacimiento,	Lengua,	Ocupacion,	ActividadProductiva,	EstadoCivil,
  	   Escolaridad,	min(FechaAltaSistema) FechaAltaSistema,	Calle,	
  	   case when NumExt= '' then 'S\N' else NumExt end NumExt,	NumInt,	Colonia, ''''+CodigoPostal CodigoPostal,
  	   ''''+Localidad Localidad,	''''+Municipio Municipio,	''''+Estado Estado,	CapitalSocialRequerido,	SaldoAportacionRequerido,
  	   SaldoAportacionExcedente,	SaldoAportacionVoluntario,	max(Sucursal) Sucursal,	UsuarioCaptura,
  	   FechaBaja,	PersonaMoralFisica
  INTO #hoja11  	   
  FROM #hoja1
 WHERE localidad <> '' and localidad is not null
 GROUP BY FolioIF,	CveSocioCte,	PrimerApellido,	SegundoApellido,	Nombre,	Sexo,
  	   FechaNacimiento,	Lengua,	Ocupacion,	ActividadProductiva,	EstadoCivil,
  	   Escolaridad, Calle,	NumExt,	NumInt,	Colonia,	CodigoPostal,
  	   Localidad,	Municipio,	Estado,	CapitalSocialRequerido,	SaldoAportacionRequerido,
  	   SaldoAportacionExcedente,	SaldoAportacionVoluntario,	UsuarioCaptura,
  	   FechaBaja,	PersonaMoralFisica

--DELETE FROM tCsFondReportados WHERE CodFondo = 'PT' AND Dato1Cad IS NULL AND Fecha = @FecFin AND CodUsuario NOT IN (Select CveSocioCte From #hoja11)
SELECT * FROM #hoja11 WHERE CveSocioCte not in ('OGG0904891','OGG0904892')

DROP TABLE #hoja1
DROP TABLE #hoja11
DROP TABLE #clientes
GO