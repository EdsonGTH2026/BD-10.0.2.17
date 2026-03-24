SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--------------------------------------------------------------------------
--	Reporte de Corte diario 01/10/04 				--
--									--
--	Nombre Archivo : pClRptCamposTags        			--
-- 	Versión : BO-1.00						--
--	Modulo : Interface Local					--
--									--
--	Descripción : Genera un archivo con las relaciones de tablas co-	--
--	rrecta para qeu luego sea ésta comparada con la base de datos  		--
--	a prueba															--
--	Fecha (creación) : 2005/08/16										--
--	Autor : SSaravia													--
--	Revisado por:   													--
--	Historia :															--
--	Unidades:															--
--	Módulo Principal:                                    	 			--
--	Rutinas Afectadas:                                     				--
--------------------------------------------------------------------------
create proc [dbo].[pClRptCamposTags]
            @NombreTag varchar(30),
            @CodPrestamo varchar(25),
            @CodSolicitud varchar(15)=''
with encryption as
set nocount on

-- Select * From tClPlTags order by NombreTag
declare @Encontrado bit
Set @Encontrado=0
declare @CodOficina varchar(4)
declare @Codigo varchar(100)
declare @Cuota smallint
set @Codigo=''
set @CodOficina=''
/*******************************************************************************************************************
 2 Sobre datos del Credito *****************************************************************************************
********************************************************************************************************************/
If @NombreTag = '<MunicipioEstado>'
	Begin
	SELECT     dbo.fduCambiarFormato(RTRIM(LTRIM(Datos.Municipio))) + ', Estado de ' + dbo.fduCambiarFormato(RTRIM(LTRIM(tClUbiGeo.DescUbiGeo))) AS Dato
	FROM         (SELECT     tClUbiGeo.NomUbiGeo AS Municipio, SUBSTRING(Nucleo.Arbol, 1, 13) AS Arbol
	                       FROM          (SELECT     tClUbiGeo.NomUbiGeo, tClUbiGeo.CodUbiGeoTipo, tClOficinas.CodUbiGeo, SUBSTRING(tClUbiGeo.CodArbolConta, 1, 19) 
	                                                                      AS Arbol
	                                               FROM          tClOficinas INNER JOIN
	                                                                      tClUbiGeo ON tClOficinas.CodUbiGeo = tClUbiGeo.CodUbiGeo
	                                               WHERE      (tClOficinas.CodOficina = Cast(Cast(SubString(@CodPrestamo, 1, 3) as Int) As Varchar(4)))) Nucleo INNER JOIN
	                                              tClUbiGeo ON Nucleo.Arbol COLLATE Modern_Spanish_CI_AI = tClUbiGeo.CodArbolConta) Datos INNER JOIN
	                      tClUbiGeo ON Datos.Arbol COLLATE Modern_Spanish_CI_AI = tClUbiGeo.CodArbolConta
	End

If @NombreTag = '<MunicipioEstadoCliente>'
	Begin
	SELECT     dbo.fduCambiarFormato(RTRIM(LTRIM(Datos.Municipio))) + ', Estado de ' + dbo.fduCambiarFormato(RTRIM(LTRIM(tClUbiGeo.DescUbiGeo))) 
	                      AS Dato
	FROM         (SELECT     tClUbiGeo.NomUbiGeo AS Municipio, SUBSTRING(Nucleo.Arbol, 1, 13) AS Arbol
	                       FROM          (SELECT     tClUbiGeo.NomUbiGeo, tClUbiGeo.CodUbiGeoTipo, tUsUsuarioDireccion.CodUbiGeo, SUBSTRING(tClUbiGeo.CodArbolConta, 1, 19) AS Arbol
	FROM         tClUbiGeo INNER JOIN
	                      tUsUsuarioDireccion ON tClUbiGeo.CodUbiGeo = tUsUsuarioDireccion.CodUbiGeo INNER JOIN
	                      tCaPrestamos ON tUsUsuarioDireccion.CodUsuario = tCaPrestamos.CodUsuario
	WHERE     (tCaPrestamos.CodPrestamo = @CodPrestamo)) Nucleo INNER JOIN
	                                              tClUbiGeo ON Nucleo.Arbol COLLATE Modern_Spanish_CI_AI = tClUbiGeo.CodArbolConta) Datos INNER JOIN
	                      tClUbiGeo ON Datos.Arbol COLLATE Modern_Spanish_CI_AI = tClUbiGeo.CodArbolConta
	End
if @NombreTag='<NumeroPagare>'
begin
	set @CodOficina=(Select CodOficina from tcaprestamos where CodPrestamo=@CodPrestamo)
	exec pGrCodigos @CodOficina, 'Pagare', 'CA',@Codigo
	
	select @Codigo as Cad
end
	
if @NombreTag in ('<RepresentanteLegal>','<EscrituraPublica>','<NotarioPublico>','<InscripcionNotarioPublico>', '<DirectorFinAmigo>')
begin
	Select dato from tGrReporteParametros
	where ('<'+NomCampo+'>')=@NombreTag 
end

if @NombreTag in ('<CodigoPrestamo>','<TipoPrestamo>','<CodigoGrupo>','<Plazo>','<TipoPlan>','<FormaPago>','<SecPrestamo>',
                  '<NombreGrupo>','<NombreAsesor>','<DirOficina>', '<SMo>','<NumeroCuotas>',
                  '<MonedaDescripcion>','<NombreClienteFon>')--, '<NombreCliente>')
begin
	Set @Encontrado=1
	Select Case @NombreTag
	       WHEN '<CodigoPrestamo>'    THEN pr.CodPrestamo
	       WHEN '<TipoPrestamo>'      THEN (pr.TipoPrestamo)
	       WHEN '<CodigoGrupo>'       THEN pr.CodGrupo
	       WHEN '<Plazo>'             THEN cast(pr.Plazo as varchar(5))+ ' '+ case plaz.CodTipoPlaz 
	                                                                             when 'A' then 'Años' 
	                                                                             when 'D' then 'Días'
	                                                                             when 'M' then 'Meses'
	                                                                             when 'Q' then 'Quincena'   
	                                                                             when 'S' then 'Semanas'
	                                                                          end
	       when '<TipoPlan>'          then pl.DescTipoPlan
	       when '<FormaPago>'         then plaz.DescTipoPlaz
	       when '<SecPrestamo>'       then cast(prcl.SecPrestamo as varchar(5))
	       when '<NombreGrupo>'       then (case when pr.codgrupo is null then '------------' else gr.NombreGrupo end)
	       when '<NombreAsesor>'      then ase.nomasesor
	       when '<DirOficina>'        then ofi.Direccion --*Adicionado
	       --when '<NombreCliente>'     then us1.NombreCompleto
	       when '<NombreClienteFon>'  then rtrim(us1.Nombres )+ ' '+rtrim(us1.Paterno)+ ' '+rtrim(us1.Materno)
	       when '<SMo>'               then mo.DescABreviada
	       when '<NumeroCuotas>'      then cast(pr.cuotas as varchar(5))
	    
   when '<MonedaDescripcion>' then mo.DescMoneda
	       END
	       Cad
	FROM tCaPrestamos pr
	left outer join tCaCuotas Cu on pr.CodPrestamo=Cu.CodPrestamo
	left outer join tCaClTipoPlan pl on pr.CodTipoPlan=pl.CodTipoPlan and pr.CodTipoCredito=pl.CodTipocredito
	left outer join tcacltipoplaz plaz on pr.CodTipoPlaz=plaz.CodTipoplaz
	left outer join (select distinct CodPrestamo,(case when codgrupo is null then SecPrestCliente else SecPrestGrupo end)SecPrestamo
	                 from tcaprcliente)prcl on pr.CodPrestamo=prcl.CodPrestamo
	left outer join tcagrupos gr on pr.codGrupo=gr.codGrupo
	left outer join tcaclasesores ase on pr.codasesor=ase.codasesor
	left outer join tcloficinas ofi on pr.CodOficina=ofi.codoficina
	left outer join tususuarios us1 on pr.CodUsuario=us1.CodUsuario
	left outer join tclmonedas mo on pr.CodMoneda=mo.codmoneda
	WHERE pr.CodPrestamo=@CodPrestamo and cu.SecCuota=1
end


if @NombreTag  in('<VencCuota1>','<VencCuota1Lit>','<FechaAprobacion>','<FechaAprobacionLiteral>','<FechaDesembolso>','<FechaDesembolsoLarga>','<FechaVencimiento>',
                  '<FechaInicioCredito>')
begin
	Set @Encontrado=1
	Select Case @NombreTag 
	       when '<FechaInicioCredito>' THEN Cu.FechaInicio 
	       WHEN '<VencCuota1>' THEN cu.FechaVencimiento
	       WHEN '<VencCuota1Lit>' THEN cu.FechaVencimiento
	       WHEN '<FechaAprobacion>' THEN pr.FechaAprobacion
	       WHEN '<FechaAprobacionLiteral>' THEN pr.FechaAprobacion
	       when '<FechaDesembolso>'   then pr.Fechadesembolso
	       when '<FechaDesembolsoLarga>' then pr.fechadesembolso  
	       when '<FechaVencimiento>'     then pr.FechaVencimiento
	       END 
	       Fecha
	FROM tCaCuotas Cu
	INNER JOIN tcaprestamos pr on Cu.CodPrestamo=pr.CodPrestamo
	WHERE pr.CodPrestamo=@CodPrestamo and secCuota=1
end

if @NombreTag='<NombreClientes>' 
	select (rtrim(us.Nombres )+ ' '+rtrim(us.Paterno)+ ' '+rtrim(us.Materno))CAD
	from tcaprcliente prcl 
	inner join tususuarios us on prcl.codUsuario=us.CodUsuario
	Where prcl.CodPrestamo=@CodPrestamo

if @NombreTag In ('<DirCliente>', '<CP>', '<Actividad1>', '<Nacimiento>', '<SexoEdad>', '<NombreCliente>')
	Begin
	Exec spSgAyudaReporteDOC @CodPrestamo, @NombreTag

	SELECT 
	CASE @NombreTag
		WHEN '<NombreCliente>'	THEN	u.NombreCompleto
	       	WHEN '<DirCliente>'     THEN  	UPPER(ISNULL(RTRIM(D.Direccion), '') + ' ' + ISNULL(RTRIM(D.CodPostal), '') 
	                      			+ ' - ' + ISNULL(RTRIM(dbo.fClRecorridoGenealogicoUbiGeo(D.CodUbiGeo)), '')) 
	       	WHEN '<CP>'       	THEN  	ISNULL(RTRIM(D.CodPostal), '') 
	       	WHEN '<Actividad1>'     THEN 	tUsUsuarioSecundarios.LabActividad
	       	WHEN '<Nacimiento>'     THEN  	'Día     ' + dbo.fduFechaATexto(u.FechaNacimiento, 'DD') + '     Mes     ' + dbo.fduFechaATexto(u.FechaNacimiento, 'MM') 
		                      		+ '     Año     ' + dbo.fduFechaATexto(u.FechaNacimiento, 'AAAA') 
	       	WHEN '<SexoEdad>'	THEN  	'Sexo : ' + CASE u.Sexo WHEN 0 THEN 'FEMENINO       ' WHEN 1 THEN 'MASCULINO     ' END + 'Edad : ' + CAST(Cast(DateDiff(Day, u.FechaNacimiento, GetDAte())/365.25 AS Int) AS varchar(10)) + ' Años '
       	END Cad       	
	FROM         (SELECT     Filtro.CodPrestamo, tCsAyudaReporteDOC.CodUsuario
	                       FROM          (SELECT     Fecha, CodPrestamo, MIN(Secuencial) AS Secuencial
	                                               FROM          tCsAyudaReporteDOC
	                                               WHERE      (Consulta = 0) AND (Fecha = CAST(dbo.fduFechaAAAAMMDD(GETDATE()) AS smalldatetime)) AND 
	                                                                      (CodPrestamo = @CodPrestamo)
	                                               GROUP BY Fecha, CodPrestamo) Filtro INNER JOIN
	                                              tCsAyudaReporteDOC ON Filtro.Fecha = tCsAyudaReporteDOC.Fecha AND 
	                                              Filtro.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsAyudaReporteDOC.CodPrestamo AND 
	                                              Filtro.Secuencial = tCsAyudaReporteDOC.Secuencial) Filtro2 INNER JOIN
	                      tCaPrCliente prcl INNER JOIN
	                      tUsUsuarios u ON prcl.CodUsuario = u.CodUsuario ON Filtro2.CodPrestamo COLLATE Modern_Spanish_CI_AI = prcl.CodPrestamo AND 
	                      Filtro2.CodUsuario COLLATE Modern_Spanish_CI_AI = prcl.CodUsuario INNER JOIN
	                      tUsUsuarioSecundarios ON u.CodUsuario = tUsUsuarioSecundarios.CodUsuario LEFT OUTER JOIN
	                          (SELECT     Maestro.CodUsuario, Maestro.FamiliarNegocio, MAX(Datos.IdDireccion) AS IdDireccion
	                            FROM          (SELECT     CodUsuario, MIN(FamiliarNegocio) AS FamiliarNegocio
	                                                    FROM          (SELECT     prcl.CodUsuario, D .FamiliarNegocio, D .IdDireccion
	                                                                            FROM          tCaPrCliente prcl INNER JOIN
	                                                                                                   tUsUsuarios u ON prcl.CodUsuario = u.CodUsuario LEFT OUTER JOIN
	                                                                                                   tUsUsuarioDireccion D ON u.CodUsuario = D .CodUsuario
	                                                                            WHERE      (prcl.CodPrestamo = @CodPrestamo)) Datos
	                                                    GROUP BY CodUsuario) Maestro INNER JOIN
	                                                       (SELECT     prcl.CodUsuario, D .FamiliarNegocio, D .IdDireccion
	                                                         FROM          tCaPrCliente prcl INNER JOIN
	                                                                                tUsUsuarios u ON prcl.CodUsuario = u.CodUsuario LEFT OUTER JOIN
	                                                                                tUsUsuarioDireccion D ON u.CodUsuario = D .CodUsuario
	                                                         WHERE      (prcl.CodPrestamo = @CodPrestamo)) Datos ON Maestro.CodUsuario = Datos.CodUsuario AND 
	                                                   Maestro.FamiliarNegocio = Datos.FamiliarNegocio
	                            GROUP BY Maestro.CodUsuario, Maestro.FamiliarNegocio) Filtro INNER JOIN
	                      tUsUsuarioDireccion D ON Filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = D.CodUsuario AND Filtro.FamiliarNegocio = D.FamiliarNegocio AND 
	                      Filtro.IdDireccion = D.IdDireccion ON u.CodUsuario = D.CodUsuario
	WHERE     (prcl.CodPrestamo = @CodPrestamo)
	End
if @NombreTag='[Firmantes]'
	SELECT     ISNULL(RTRIM(u.Nombres) + ' ' + RTRIM(u.Paterno) + ' ' + RTRIM(u.Materno), '') AS Nombre, ISNULL(E.EstadoCivil, '') AS 'E. Civil', 
	                      ISNULL(S.UsOcupacion, '') AS Ocupación, UPPER(ISNULL(RTRIM(D.Direccion), '') + ' ' + ISNULL(RTRIM(D.CodPostal), '') 
	                      + ' - ' + ISNULL(RTRIM(dbo.fClRecorridoGenealogicoUbiGeo(D.CodUbiGeo)), '')) AS Domicilio, ISNULL(u.CodDocIden, '') + ' ' + ISNULL(u.DI, '') 
	                      AS 'Folio IFE'
	FROM         (SELECT     Maestro.CodUsuario, Maestro.FamiliarNegocio, MAX(Datos.IdDireccion) AS IdDireccion
	                       FROM          (SELECT     CodUsuario, MIN(FamiliarNegocio) AS FamiliarNegocio
	                                               FROM          (SELECT     prcl.CodUsuario, D .FamiliarNegocio, D .IdDireccion
	                                                                       FROM          tCaPrCliente prcl INNER JOIN
	                                                                                              tUsUsuarios u ON prcl.CodUsuario = u.CodUsuario LEFT OUTER JOIN
	                                                                                              tUsUsuarioDireccion D ON u.CodUsuario = D .CodUsuario
	                                                                       WHERE      (prcl.CodPrestamo = @CodPrestamo)) Datos
	                                               GROUP BY CodUsuario) Maestro INNER JOIN
	                                                  (SELECT     prcl.CodUsuario, D .FamiliarNegocio, D .IdDireccion
	                                                    FROM          tCaPrCliente prcl INNER JOIN
	                                                                           tUsUsuarios u ON prcl.CodUsuario = u.CodUsuario LEFT OUTER JOIN
	                                                                           tUsUsuarioDireccion D ON u.CodUsuario = D .CodUsuario
	                                                    WHERE      (prcl.CodPrestamo = @CodPrestamo)) Datos ON Maestro.CodUsuario = Datos.CodUsuario AND 
	                                              Maestro.FamiliarNegocio = Datos.FamiliarNegocio
	                       GROUP BY Maestro.CodUsuario, Maestro.FamiliarNegocio) Filtro INNER JOIN
	                      tUsUsuarioDireccion D ON Filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = D.CodUsuario AND Filtro.FamiliarNegocio = D.FamiliarNegocio AND 
	                      Filtro.IdDireccion = D.IdDireccion RIGHT OUTER JOIN
	                      tCaPrCliente prcl INNER JOIN
	                      tUsUsuarios u ON prcl.CodUsuario = u.CodUsuario LEFT OUTER JOIN
	                      tUsUsuarioSecundarios S ON u.CodUsuario = S.CodUsuario LEFT OUTER JOIN
	                      tUsClEstadoCivil E ON u.CodEstadoCivil = E.CodEstadoCivil ON D.CodUsuario = u.CodUsuario
	WHERE     (prcl.CodPrestamo = @CodPrestamo)

if @NombreTag='[Plancuotas]'
	Select C.SecCuota Cuota,C.FechaVencimiento 'Vencimiento',
	       sum(Case when CodConcepto='CAPI'  then MontoCuota else 0 end)Capital,
	       sum(Case when CodConcepto='INTE'  then MontoCuota else 0 end)Interes,
	       sum(Case when CodConcepto='IVAIT'  then MontoCuota else 0 end)IVA,
	       sum(Case when CodConcepto in('CAPI','INTE','IVAIT')  then MontoCuota else 0 end)Total
	from tcacuotas C
	inner join tcacuotascli CC on c.Seccuota=cc.Seccuota and c.codPrestamo=cc.CodPrestamo
	where C.codprestamo=@CodPrestamo
	group by C.SecCuota,C.FechaVencimiento

if @NombreTag='[PlancuotasFim]'
	Select C.SecCuota Cuota,C.FechaVencimiento 'Vencimiento',
	       sum(Case when CodConcepto in('CAPI','INTE','IVAIT')  then MontoCuota else 0 end)Total
	from tcacuotas C
	inner join tcacuotascli CC on c.Seccuota=cc.Seccuota and c.codPrestamo=cc.CodPrestamo
	where C.codprestamo=@CodPrestamo
	group by C.SecCuota,C.FechaVencimiento


if @NombreTag='[ListaClientes]'
	select (rtrim(us.Nombres )+ ' '+rtrim(us.Paterno)+ ' '+rtrim(us.Materno)) Cliente,''Firma 
	from tcaprcliente prcl 
	inner join tususuarios us on prcl.codUsuario=us.CodUsuario
	Where prcl.CodPrestamo=@CodPrestamo

if @NombreTag='[ListaClientesDir]'
	SELECT     RTRIM(us.Nombres) + ' ' + RTRIM(us.Paterno) + ' ' + RTRIM(us.Materno) + '     -     ' + RTRIM(usdir.Direccion) + ' ' + ISNULL(RTRIM(usdir.CodPostal), '') 
	                      + ' ' + ISNULL(RTRIM(dbo.fClRecorridoGenealogicoUbiGeo(usdir.CodUbiGeo)), '') AS Cliente, '' AS Firma
	FROM         (SELECT     Maestro.CodUsuario, Maestro.FamiliarNegocio, MAX(Datos.IdDireccion) AS IdDireccion
	                       FROM          (SELECT     CodUsuario, MIN(FamiliarNegocio) AS FamiliarNegocio
	                                               FROM          (SELECT     prcl.CodUsuario, D .FamiliarNegocio, D .IdDireccion
	                                                                       FROM          tCaPrCliente prcl INNER JOIN
	                                                                                              tUsUsuarios u ON prcl.CodUsuario = u.CodUsuario LEFT OUTER JOIN
	                                                                                              tUsUsuarioDireccion D ON u.CodUsuario = D .CodUsuario
	                                                                       WHERE      (prcl.CodPrestamo = @CodPrestamo)) Datos
	                                               GROUP BY CodUsuario) Maestro INNER JOIN
	                                                  (SELECT     prcl.CodUsuario, D .FamiliarNegocio, D .IdDireccion
	                                                    FROM          tCaPrCliente prcl INNER JOIN
	                                                                           tUsUsuarios u ON prcl.CodUsuario = u.CodUsuario LEFT OUTER JOIN
	                                                                           tUsUsuarioDireccion D ON u.CodUsuario = D .CodUsuario
	                                                    WHERE      (prcl.CodPrestamo = @CodPrestamo)) Datos ON Maestro.CodUsuario = Datos.CodUsuario AND 
	                                              Maestro.FamiliarNegocio = Datos.FamiliarNegocio
	                       GROUP BY Maestro.CodUsuario, Maestro.FamiliarNegocio) Filtro INNER JOIN
	                      tUsUsuarioDireccion usdir ON Filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = usdir.CodUsuario AND 
	                      Filtro.IdDireccion = usdir.IdDireccion RIGHT OUTER JOIN
	                      tCaPrCliente prcl INNER JOIN
	                      tUsUsuarios us ON prcl.CodUsuario = us.CodUsuario ON usdir.CodUsuario = us.CodUsuario
	WHERE     (prcl.CodPrestamo = @CodPrestamo)	


/*******************************************************************************************************************
 2 Sobre datos del Usuario *****************************************************************************************
********************************************************************************************************************/
if @NombreTag in ('<Actividad>','<OcupacionCliente>','<ProfesionP>')
begin
	Set @Encontrado=1
	SELECT  CASE @NombreTag
	        WHEN '<Actividad>' THEN UsSec.LabActividad 
	        WHEN '<OcupacionCliente>' THEN Oc.Nombre
	        WHEN '<ProfesionP>' THEN  UsSec.UsOcupacion
	        END 
	        Cad
	FROM    tUsUsuarioSecundarios UsSec
	LEFT OUTER JOIN  tCaPrCliente PrCl ON UsSec.CodUsuario = PrCl.CodUsuario 
	LEFT OUTER JOIN  tClOcupaciones Oc ON UsSec.UsCodOcupacion = OC.CodOcupacion
	WHERE PrCl.CodPrestamo=@CodPrestamo
end

if @NombreTag in ('<DirDomicilio>', '<DirNegocio>', '<Nacionalidad>', '<EstadoCivil>','<ClienteUbiGeoDom>')
begin
	Set @Encontrado=1
	select CASE @NombreTag
	       WHEN '<DirDomicilio>'     THEN  (case when prcl.codgrupo is null then dirf.direccion     else rtrim(dirf.codusuario)+'-'+rtrim(dirf.Direccion)end)
	       WHEN '<DirNegocio>'       THEN  (case when prcl.codgrupo is null then dirn.direccion     else rtrim(dirn.codusuario)+'-'+ rtrim(dirn.direccion)end)
	       WHEN '<Nacionalidad>'     THEN  (case when prcl.codgrupo is null then pais.nacionalidad  else rtrim(prcl.codusuario)+ '-' + rtrim(pais.nacionalidad)end)
	       WHEN '<EstadoCivil>'      THEN  (case when prcl.codgrupo is null then eciv.Estadocivil   else rtrim(prcl.codusuario)+ '-' + rtrim(eciv.Estadocivil)end)
	       WHEN '<ClienteUbiGeoDom>' THEN  (case when prcl.codgrupo is null then ubigeof.DescUbiGeo else rtrim(prcl.codusuario)+ '-' + rtrim(ubigeof.DescUbiGeo)end)
	       END
	       Cad
	from tcaprcliente prcl
	left outer join (Select CodUsuario,Direccion,CodUbiGeo  from tususuariodireccion where familiarnegocio='F')dirf on prcl.codusuario=dirf.codusuario
	left outer join (Select CodUsuario,Direccion  from tususuariodireccion where familiarnegocio='N')dirn on prcl.codusuario=dirn.codusuario
	left outer join tususuarios us on prcl.codusuario=us.codusuario
	left outer join tUsClEstadoCivil eciv on us.codestadocivil=eciv.codestadocivil
	left outer join tclpaises pais on us.codpais=pais.codpais
	left outer join tclubigeo ubigeof on dirf.CodUbiGeo=ubigeof.CodUbiGeo
	where prcl.codPrestamo=@codprestamo
end

/*******************************************************************************************************************
 3 Sobre las garantias *********************************************************************************************
********************************************************************************************************************/
if @NombreTag in ('<NombreAval>', '<DireccionAval>', '<NroDocAval>', '<NacionalidadAval>','<UbigeoAval>','<OcupacionAval>','<EstadoCivilAval>')
begin
	Set @Encontrado=1
	SELECT distinct CASE @NombreTag
		       WHEN '<NroDocAval>'      THEN RTRIM(Us.CodDocIden) + ' - ' + RTRIM(Us.DI) 
		       WHEN '<NombreAval>'      THEN (CASE WHEN PATERNO = '' THEN NombreCompleto ELSE RTRIM(Nombres) + ' ' + RTRIM(Paterno)+ ' ' + RTRIM(Materno) END)
		       WHEN '<DireccionAval>'   THEN Ud.Direccion
		       WHEN '<NacionalidadAval>'THEN (Select Nacionalidad From tClPaises Where CodPais = Us.CodPais)
		       WHEN '<UbigeoAval>'      THEN  ubigeo.DescUbiGeo
		       When '<OcupacionAval>'   THEN usec.usocupacion
	               WHEN '<EstadoCivilAval>' THEN cvl.EstadoCivil
		       END
		       Cad
	from tGaGarantias Ga 
	Inner Join tUsUsuarios Us ON Ga.DocPropiedad = Us.CodUsuario 
	left join tUsUsuarioDireccion Ud on Ga.DocPropiedad=Ud.CodUsuario 
	inner join tGaClTipoGarantias T ON Ga.TipoGarantia = T.TipoGarantia 
	left outer join tclubigeo ubigeo on ud.CodUbiGeo=ubigeo.CodUbiGeo
	left outer join tUsClEstadoCivil cvl on us.CodEstadoCivil=cvl.CodEstadoCivil
	left outer join tususuariosecundarios usec on us.CodUsuario=usec.CodUsuario
	where ga.Codigo=@CodPrestamo And T.CodTipoAvaluo = 9 and Ga.Activo = 1
end


if @NombreTag in ('<TipoGarantia>','<DocumentoGarantia>','<NroGravamen>')
begin
	Set @Encontrado=1
	SELECT CASE @NombreTag
	       WHEN '<TipoGarantia>' THEN dbo.fCaRptCreditoGarantia(@CodPrestamo) 
	       WHEN '<DocumentoGarantia>' THEN CASE WHEN av.CodTipoAvaluo = 1 OR av.CodTipoAvaluo = 2 OR av.CodTipoAvaluo = 18 THEN av.InNoInscripcion 
	                                            WHEN av.CodTipoAvaluo = 3 THEN av.VhPropiedad  
	                                            END
	       WHEN '<NroGravamen>'  THEN av.RegGravamen 
	       END
	       Cad
	from tGaGarantias Ga 
	inner Join tUsUsuarios Us ON Ga.DocPropiedad = Us.CodUsuario 
	inner join tGaClTipoGarantias T ON Ga.TipoGarantia = T.TipoGarantia 
	left outer join tGaAvaluo av on Ga.NoAvaluo=av.NoRegAval
	where ga.Codigo=@CodPrestamo and Ga.Activo=1
end


if @NombreTag in ('<FechaDocumentoGarantia>','<FechaDocumentoGarLit>','<FechaGravamen>','<FechaGravamenLit>')
begin
	Set @Encontrado=1
	SELECT CASE @NombreTag
	       WHEN '<FechaDocumentoGarantia>' THEN (case when av.CodTipoAvaluo = 1 OR av.CodTipoAvaluo = 2 OR av.CodTipoAvaluo = 18 then av.FeInscripcion else '-------------' end )
	       WHEN '<FechaDocumentoGarLit>' THEN (case when av.CodTipoAvaluo = 1 OR av.CodTipoAvaluo = 2 OR av.CodTipoAvaluo = 18 then av.FeInscripcion else '-------------' end )
	       WHEN '<FechaGravamen>' THEN  Av.FeGravamen
	       WHEN '<FechaGravamenLit>' THEN Av.FeGravamen
	       END
	       Fecha
	from tGaGarantias Ga 
	inner Join tUsUsuarios Us ON Ga.DocPropiedad = Us.CodUsuario 
	inner join tGaClTipoGarantias T ON Ga.TipoGarantia = T.TipoGarantia 
	left outer join tGaAvaluo av on Ga.NoAvaluo=av.NoRegAval
	where ga.Codigo=@CodPrestamo and Ga.Activo=1
end


if @NombreTag ='<DetallePrendas>'
begin
	Set @Encontrado=1
	select PDescripcion
	from tGaGarantias Ga 
	inner join tGaAvaluo av on Ga.NoAvaluo=av.NoRegAval
	inner join tgaavaluoprendarias pre on av.CodTipoavaluo=pre.SubTipoAval
	where av.codtipoavaluo in(5,6,7,15,17) and ga.Codigo=@CodPrestamo
end

/*******************************************************************************************************************
 4 Sobre las tasas aplicadas  **************************************************************************************
********************************************************************************************************************/

if @NombreTag in ('<TasaInteresMensual>','<TasaInteresMensualLit>','<TasaInteresAnual>','<TasaInteresAnualLit>',
                  '<TasaMoratorioMensual>','<TasaMoratorioMensualLit>','<SeguroDesgravamen>','<SeguroDesgravamenLit>',
                  '<ComisionApertura>','<ComisionAperturaLit>','<ComisionAperturaLinea>','<ComisionAperturaLineaLit>')
begin
	Set @Encontrado=1
	SELECT CASE @NombreTag
	       WHEN '<TasaInteresMensual>'       THEN (select isnull(ValorConcepto/12,0) from tCaconcpre  where Codprestamo=@CodPrestamo and codconcepto='INTE')
	       WHEN '<TasaInteresMensualLit>'    THEN (select isnull(ValorConcepto/12,0) from tCaconcpre  where Codprestamo=@CodPrestamo and codconcepto='INTE')
	       WHEN '<TasaInteresAnual>'         THEN (select isnull(ValorConcepto,0) from tCaconcpre  where Codprestamo=@CodPrestamo and codconcepto='INTE')
	       WHEN '<TasaInteresAnualLit>'      THEN (select isnull(ValorConcepto,0) from tCaconcpre  where Codprestamo=@CodPrestamo and codconcepto='INTE')
	       WHEN '<TasaMoratorioMensual>'     THEN (select isnull(Valor/12,0) from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='INPE')
	       WHEN '<TasaMoratorioMensualLit>'  THEN (select isnull(Valor/12,0) from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='INPE')
	       WHEN '<TasaMoratorioAnual>'       THEN (select isnull(Valor,0) from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='INPE')
	       WHEN '<TasaMoratorioAnualLit>'    THEN (select isnull(Valor,0) from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='INPE')
	       WHEN '<SeguroDesgravamen>'        THEN isnull((select Valor from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='SEDES'),0)
	       WHEN '<SeguroDesgravamenLit>'     THEN isnull((select Valor from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='SEDES'),0)
	       WHEN '<ComisionApertura>'         THEN isnull((select Valor from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='COM'),0)
	       WHEN '<ComisionAperturaLit>'      THEN isnull((select Valor from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='COM'),0)
	       WHEN '<ComisionAperturaLinea>'    THEN isnull((select Valor from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='COMLC'),0)
	       WHEN '<ComisionAperturaLineaLit>' THEN isnull((select Valor from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='COMLC'),0)
	       END
	       Valor
end

if @NombreTag='<DiasEntraMora>' 
begin
	Select isnull(Diasmora,0) from tCaPrestamoConceptoAplica  where Codprestamo=@CodPrestamo and codconcepto='INPE'
end 


/*******************************************************************************************************************
 4 Sobre Montos y Saldos pagados y por pagar************************************************************************
********************************************************************************************************************/

if @NombreTag in ('<TotalCAPIINTEIMPUESTO>','<TotalCAPIINTEIMPUESTOLit>','<TotalCAPI>','<TotalCAPILit>',
                  '<TotalCAPIINTE>','<TotalCAPIINTELit>','<SaldoCAPI>','<SaldoCAPILit>','<ImporteCuotas>','<ImporteCuotasLit>')
begin
	Set @Encontrado=1
	SELECT CASE @NombreTag
	       WHEN '<TotalCAPI>'                 THEN (select sum(MontoCuota) from tCaCuotasCli  where Codprestamo=@CodPrestamo and codconcepto ='CAPI')
	       WHEN '<TotalCAPILit>'              THEN (select sum(MontoCuota) from tCaCuotasCli  where Codprestamo=@CodPrestamo and codconcepto='CAPI')
	       WHEN '<TotalCAPIINTE>'             THEN (select sum(MontoCuota) from tCaCuotasCli  where Codprestamo=@CodPrestamo and codconcepto in('CAPI','INTE'))
	       WHEN '<TotalCAPIINTELit>'          THEN (select sum(MontoCuota) from tCaCuotasCli  where Codprestamo=@CodPrestamo and codconcepto in('CAPI','INTE'))
	       WHEN '<TotalCAPIINTEIMPUESTO>'     THEN (select sum(MontoCuota) from tCaCuotasCli  where Codprestamo=@CodPrestamo and codconcepto in('CAPI','INTE','IVAIT'))
	       WHEN '<TotalCAPIINTEIMPUESTOLit>'  THEN (select isnull(sum(MontoCuota),0) from tCaCuotasCli  where Codprestamo=@CodPrestamo and codconcepto in('CAPI','INTE','I
VAIT'))
	       WHEN '<SaldoCAPI>'                 THEN (select isnull(sum(MontoDevengado-MontoPagado-MOntoCondonado),0) from tCaCuotasCli  where Codprestamo=@CodPrestamo and codconcepto='CAPI')
	       WHEN '<SaldoCAPILit>'              THEN (select isnull(sum(MontoDevengado-MontoPagado-MOntoCondonado),0) from tCaCuotasCli  where Codprestamo=@CodPrestamo and codconcepto='CAPI')
	       WHEN '<ImporteCuotas>'             THEN (select isnull(sum(MontoDevengado-MontoPagado-MOntoCondonado),0) from tCaCuotasCli where Codprestamo=@CodPrestamo)
	       WHEN '<ImporteCuotasLit>'             THEN (select isnull(sum(MontoDevengado-MontoPagado-MOntoCondonado),0) from tCaCuotasCli where Codprestamo=@CodPrestamo)
	       END
	       Valor
end

if @NombreTag in ('<MontoPrimeraCuota>','<MontoUltimaCuota>','<MontoPrimeraCuotaLit>','<MontoUltimaCuotaLit>')
begin
	set @Cuota=(Select  Cuotas from tcaprestamos  where CodPrestamo=@CodPrestamo)
	SELECT CASE @NombreTag 
	       when '<MontoPrimeraCuota>'  THEN (select sum(MontoCuota) from tCaCuotasCli where CodPrestamo=@CodPrestamo and SecCuota=1 and CodConcepto in('CAPI','INTE','IVAIT'))
	       when '<MontoUltimaCuota>'  then (select sum(MontoCuota) from tCaCuotasCli where CodPrestamo=@CodPrestamo and SecCuota=@Cuota and CodConcepto in ('CAPI','INTE','IVAIT'))
	       when '<MontoPrimeraCuotaLit>' THEN (select sum(MontoCuota) from tCaCuotasCli where CodPrestamo=@CodPrestamo and SecCuota=1 and CodConcepto in('CAPI','INTE','IVAIT'))
	       when '<MontoUltimaCuotaLit>' then (select sum(MontoCuota) from tCaCuotasCli where CodPrestamo=@CodPrestamo and SecCuota=@Cuota and CodConcepto in ('CAPI','INTE','IVAIT'))
	       END
	       Monto
end
/*******************************************************************************************************************
 5 Sobre Renegociación *********************************************************************************************
********************************************************************************************************************/
if @NombreTag in ('<FechaRenegocio>','<FechaRenegocioLit>')
begin
	Set @Encontrado=1
	SELECT CASE @NombreTag 
	       when '<FechaRenegocio>' THEN re.FechaReprog
	       when '<FechaRenegocioLit>' then  re.FechaReprog
	       END
	       Fecha
	from tcareformulacion re
	where re.codprestamo=@CodPrestamo and re.Ejecutado=1
end

if @NombreTag in ('<TipoPlanRenegocio>','<FormaPagoRenegocio>','<PrestamoNRenegocio>','<PlazoRenegocio>')
begin
	Set @Encontrado=1
	SELECT CASE @NombreTag
	       when '<TipoPlanRenegocio>'   then  cl.DescTipoplan
	       when '<FormaPagoRenegocio>'then  pl.DescTipoplaz
	       when '<PrestamoNRenegocio>' then  isnull(re.CodPrestamoN,'------------------')
	       when '<PlazoRenegocio>' then cast(re.plazo as varchar(5))
	       END
	       Cad
	from tcareformulacion re
	inner join tcaprestamos pr on re.codprestamo=pr.codprestamo
	left outer join tcacltipoplan cl on re.Codtipoplan=cl.codtipoplan and pr.Codtipocredito=cl.codtipocredito
	left outer join tcacltipoplaz pl on re.codtipoplaz=pl.codtipoplaz
	where re.codprestamo=@CodPrestamo and re.Ejecutado=1 
end

if @NombreTag in ('<MontoIteresDiferido>','<MontoIteresDiferidoLit>','<MontoIteresCapitaliza>','<MontoIteresCapitalizaLit>')
begin
	Set @Encontrado=1
	SELECT CASE @NombreTag
	       WHEN '<MontoIteresDiferido>'     THEN (select sum(Diferir)    from tcareformulaciondet  where Codprestamo=@CodPrestamo and codconcepto ='INTE')
	       WHEN '<MontoIteresDiferidoLit>'  THEN (select sum(Diferir)    from tcareformulaciondet  where Codprestamo=@CodPrestamo and codconcepto ='INTE')
	       WHEN '<MontoIteresCapitaliza>'   THEN (select sum(Capitalizar)    from tcareformulaciondet  where Codprestamo=@CodPrestamo and codconcepto ='INTE')
	       WHEN '<MontoIteresCapitalizaLit>'THEN (select sum(Capitalizar)    from tcareformulaciondet  where Codprestamo=@CodPrestamo and codconcepto ='INTE')
	    
   END
	       Valor
end
--exec pclRptCamposTags '[Firmantes]','004-115-06-00-00038'

--***************************
--	Tags para ahorros FIMEDER
--***************************
-- PERSONA NATURAL
if @NombreTag in ('<NroSolicitudAh>','<MonedaAh>','<ManejoAh>','<CapitalizacionAh>','<NroCuentaAh>')
begin
	SELECT CASE @NombreTag
	       WHEN '<NroSolicitudAh>' THEN (select @CodSolicitud)
	
	       WHEN '<NroCuentaAh>' THEN (select @CodPrestamo)
	
	       WHEN '<MonedaAh>'   THEN (SELECT TOP 1  DescAbreviada  FROM tAhSolicitud s
				                INNER JOIN tClMonedas m ON m.CodMoneda = s.CodMoneda  
				                WHERE  s.NroSolicitud = @CodSolicitud)
	
	       WHEN '<ManejoAh>'   THEN (SELECT TOP 1  DescManejo  FROM tAhSolicitud s
	          			         INNER JOIN tAhClFormaManejo m ON m.idManejo = s.idManejo  
		  		                 WHERE  s.NroSolicitud = @CodSolicitud)
	
	       WHEN '<CapitalizacionAh>'   THEN (SELECT TOP 1  DesTipoCapi  FROM tAhSolicitud s
	                		    	INNER JOIN  tAhClTipoCapitalizacion c ON c.idTipoCapi = s.idTipoCapi  
			                        WHERE  s.NroSolicitud = @CodSolicitud)
	
	       END
	       cad
end

if @NombreTag='<FechaSolicitudAh>'
begin
	SELECT FechaSolicitud Fecha from tAhSolicitud 
	WHERE  NroSolicitud = @CodSolicitud
	
	If @@RowCount = 0 
	Begin
		SELECT      tAhSolicitud.FechaSolicitud 
		FROM         tAhCuenta INNER JOIN
		                      tAhSolicitud ON tAhCuenta.NroSolicitud = tAhSolicitud.NroSolicitud
		WHERE     (tAhCuenta.CodCuenta = @CodPrestamo)	
	End
end

if @NombreTag='<FechaApertura>'
begin
	SELECT     FechaApertura
	FROM         tAhCuenta
	WHERE     (CodCuenta = @CodPrestamo)
end
if @NombreTag in ('<NombOficinaAho>','<ProdNombAho>','<CodCuentaAho>','<NomCuentaAho>','<DescMonedaAho>','<PlazoDiasAho>')
begin
	if len(@CodPrestamo) <> 0 
	begin
		Select case @NombreTag
		       when '<NombOficinaAho>' then ofi.NomOficina
		       when '<ProdNombAho>'    then prod.Nombre
		       when '<CodCuentaAho>'   then ah.CodCuenta
		       when '<NomCuentaAho>'   then ah.NomCuenta
		       when '<DescMonedaAho>'  then mo.DescMoneda
		       when '<PlazoDiasAho>'    then cast(PlazoDias as varchar(5))
		    end Cad
		from tahCuenta ah 
		inner join tahproductos prod on ah.IdProducto=prod.IdProducto 
		inner join tcloficinas ofi on ah.CodOficina=ofi.CodOficina
		inner join tClMonedas mo on ah.CodMoneda=mo.CodMoneda
		Where ah.CodCuenta=@CodPrestamo
	end
	else 
	begin
		Select case @NombreTag
		       when '<NombOficinaAho>' then ofi.NomOficina
		       when '<ProdNombAho>'    then prod.Nombre
		       when '<CodCuentaAho>'   then s.NroSolicitud
		       when '<NomCuentaAho>'   then u.NombreCompleto
		       when '<DescMonedaAho>'  then mo.DescMoneda
		       when '<PlazoDiasAho>'    then cast(PlazoDias as varchar(5))
		    end Cad
		from tAhSolicitud s 
		inner join tahproductos prod on s.IdProducto=prod.IdProducto 
		left join tUsusuarios u on u.Codusuario= s.CodUsTitular
		inner join tcloficinas ofi on s.CodOficina=ofi.CodOficina
		inner join tClMonedas mo on s.CodMoneda=mo.CodMoneda
		Where s.NroSolicitud=@CodSolicitud
	
	end
end
if @NombreTag ='<CapitalAho>'
begin
	Select  c.SaldoCuenta Valor
	from tahCuenta c
	Where c.CodCuenta=@Codprestamo
end

if @NombreTag = '<TasaIntAho>'
begin
	Select cast(c.TasaInteres as varchar(5)) + ' ' + t.DescTipoInt Cad
       	from tahCuenta c
	inner join tAhClTipoInteres t on  c.CodTipoInteres = t.CodTipoInteres  
	Where CodCuenta=@Codprestamo

end 
--if @NombreTag in('<FechaIniAho>','<FechaFinAho>')
if @NombreTag ='<FechaFinAho>'
begin
	Select 
       		FechaVcmto Fecha
	from tahCuenta 
	Where CodCuenta=@Codprestamo
end

if @NombreTag = '<FechaIniAho>'
begin
	select  Convert(VarChar(10),min(Fecha),103) Cad
	from tAhTransaccionMaestra  
	where CodCuenta=@Codprestamo
end

if @NombreTag = ('[FirmantesAH]')
begin
	SELECT  u.NombreCompleto Nombre , UsRuc, DI,   Direccion , DescUbiGeo Colonia ,
		dir.CodPostal Postal , Telefono,ub.CodUbiGeo
	From tAhSolicitud s
	INNER JOIN tAhUsSolicitud us ON us.NroSolicitud = s.NroSolicitud
	INNER JOIN tUsUsuarios u ON u.CodUsuario = us.CodUsSolicitud
	LEFT OUTER JOIN tUsUsuarioSecundarios usc ON u.CodUsuario = usc.CodUsuario  
	LEFT OUTER JOIN tUsUsuarioDireccion dir ON u.CodUsuario = dir.CodUsuario  
	LEFT OUTER JOIN tClUbiGeo ub ON ub.CodUbiGeo = dir.CodUbigeo  
	WHERE  s.NroSolicitud = @CodSolicitud
end 

if @NombreTag in ('<DireccionTitEmp>','<ColoniaTitEmp>','<PostalTitEmp>','<TelefonoTitEmp>',
		'<DocIdenTitEmp>','<RFCTitEmp>','<TipoPersona>')
begin
	SELECT 
		case @NombreTag
		       when '<DireccionTitEmp>' then isnull(Direccion,'') +
					case 
					when len(isnull(NumExterno,''))>0 then ' #viv:'+ isnull(NumExterno,'')
					else ''
					end + 
					case 
					when len(isnull(NumInterno,''))>0 then ' #depto:'+ isnull(NumInterno,'')
					else ''
					end + 
					case 
					when len(isnull(Ubicacion,''))>0 then ' Ubicación:'+ isnull(Ubicacion,'')
					else ''
					end
		       when '<ColoniaTitEmp>' then DescUbiGeo
		       when '<PostalTitEmp>' then dir.CodPostal
		       when '<TelefonoTitEmp>' then Telefono
		       when '<RFCTitEmp>' then case when CodDocIden='RFC' then DI end
		       when '<DocIdenTitEmp>' then case when CodDocIden <> 'RFC' then DI end
			when '<TipoPersona>' then DescTPersona
		 end Cad
	From tAhSolicitud s
	--                 INNER JOIN tAhUsSolicitud us ON us.NroSolicitud = s.NroSolicitud
	INNER JOIN tUsClTipoPersona tp ON s.CodTPersona=  tp.CodTPersona
	INNER JOIN tUsUsuarios u ON u.CodUsuario = s.CodUsTitular
	LEFT OUTER JOIN tUsUsuarioSecundarios usc ON u.CodUsuario = usc.CodUsuario  
	LEFT OUTER JOIN (SELECT     tUsUsuarioDireccion.*
FROM         (SELECT     Datos.CodUsuario, MAX(tUsUsuarioDireccion.IdDireccion) AS IdDireccion
                       FROM          (SELECT     CodUsuario, MIN(FamiliarNegocio) AS FamiliarNegocio
                                               FROM          tUsUsuarioDireccion
                                               --WHERE      (CodUsuario = '15ABC2012611')
                                               GROUP BY CodUsuario) Datos INNER JOIN
                                              tUsUsuarioDireccion ON Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tUsUsuarioDireccion.CodUsuario AND 
                                              Datos.FamiliarNegocio COLLATE Modern_Spanish_CI_AI = tUsUsuarioDireccion.FamiliarNegocio
                       GROUP BY Datos.CodUsuario) Datos INNER JOIN
                      tUsUsuarioDireccion ON Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tUsUsuarioDireccion.CodUsuario AND 
                      Datos.IdDireccion = tUsUsuarioDireccion.IdDireccion) dir ON u.CodUsuario = dir.CodUsuario
	LEFT OUTER JOIN tClUbiGeo ub ON ub.CodUbiGeo = dir.CodUbigeo  
	WHERE  s.NroSolicitud = @CodSolicitud
end 

if @NombreTag='<FechaProcesoAH>'
begin
	select cast(floor(cast(getdate() as real)) as datetime) as FechaProceso
end

grant execute on pClRptCamposTags to Programadores
GO