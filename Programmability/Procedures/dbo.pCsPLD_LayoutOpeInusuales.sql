SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsPLD_LayoutOpeInusuales] (@TipoReporte varchar(1),@Periodo smalldatetime,@CveFinanciera varchar(6),@OrganiSup varchar(6),@strOperaciones varchar(200))
as

/*
declare @TipoReporte varchar(1)
declare @Periodo smalldatetime
declare @CveFinanciera varchar(6)
declare @OrganiSup varchar(6)
declare @strOperaciones varchar(200)

set @TipoReporte = '3'
set @Periodo = '20160701' 
set @CveFinanciera = 'AAAA'
set @OrganiSup = 'ZZZZZZ'
set @strOperaciones = '8'
*/

--Crea tabla temporal
create table #operaciones
(
Consecutivo int identity,
IdOperacion int
)

--Llena la tabla temporal
insert into #operaciones
select * from dbo.Split1( @strOperaciones)
--select * from #operaciones

if @TipoReporte = '2'
	
	begin
		select 
		@TipoReporte + ';' +   --1 tipo reporte (long 1)
		convert(varchar,@Periodo, 112) + ';' +  --2 periodo    (long 6/8)
		dbo.fFormatoT(convert(varchar,n.Consecutivo),1, 3, '0', 'D') + ';' +  --'000000;' + --3 folio, consecutivo   (long 6)
		@OrganiSup + ';' + --4 organo supervisor  (long 6)
		@CveFinanciera + ';' + --5 clave del sujeto obligado "clave financiera"  (long 6)
		';' + --6 Localidad   (long 8)
		ofi.codoficina +  ';' + --7 Sucursal    (long 8)
		'01;'+ --8 Tipo de Operacion  (long 2)
		'01;'+ --9  instrumento monetario   (long 2)
		'' + ';'+ --10 numero de cuenta contrato, operacion, etc (long 16)
		convert(varchar,o.MontoTotalPeriodo) + ';' +  --11 monto (long 17)
		'MXP;' +  --12 moneda (long 3)
		';' + --13 fecha operacion  (long 8)
		convert(varchar,o.FechaCreacion,112) + ';' +  --14 fecha deteccion operacion (long 8)
		';' + --15 nacionalidad (long 1)
		(case when c.CodTPersona = '01' then '1' else '2' end) + ';' +  -- 16 tipo de persona (long 1)
		';' +  --17  Razon social (long 60)
		dbo.fFormatoT(c.Nombres,0, 60, '', 'I') + ';' +  --18 nombre (long 60)
		dbo.fFormatoT(c.Paterno,0, 60, '', 'I') + ';' +  --19 ape pat (long 60)
		dbo.fFormatoT(c.Materno,0, 60, '', 'I') + ';' +  --20 ape mat (long 60)
		(case when CodDocIden = 'RFC' then c.DI else c.UsRFC end) + ';' +  --21 rfc (long 13)
		isnull(c.usCURP,'') + ';' +  --22 curp (long 18)
		isnull(convert(varchar,c.FechaNacimiento,112),'') + ';' +  --23 fec nac (long 8)
		dbo.fFormatoT(isnull(c.DireccionDirFamPri, ''),0, 24, '', 'I') + ';' +  --24 domicilio (long 60)
		dbo.fFormatoT(isnull(uc.Colonia,''),0, 30, '', 'I') + ';' +  --25 colonia (long 30)
		'0' + ';' +  --26 ciudad (long 8) catalogo
		isnull(c.TelefonoDirFamPri, '') + ';' +  --27 telefono (long 40)
		'' + ';' +  --28 actividad economica (long 7) catalogo
		';' +  --29 agente o apoderado nombre (long 60)    VACIO
		';' +  --30 agente o apoderado apellido paterno (long 60)   VACIO
		';' +  --31 agente o apoderado apellido materno (long 60)   VACIO
		';' +  --32 agente o apoderado RFC (long 13)      VACIO
		';' +  --33 agente o apoderado CURP (long 18)     VACIO
		';' +  --34 consecutivo de cuentas y/o personas relacionadas (long 2)
		';' +  --35 numero de cuenta contrato, operaciones etc (long 16)
		';' +  --36 clave del sujeto obligado (long 6)  CAPTURAR
		';' +  --37 nombre titular de la cuenta o de la persona relacionada (long 60)
		';' +  --38 ape pat titular de la cuenta o de la persona relacionada (long 60)
		';' +  --39 ape mat titular de la cuenta o de la persona relacionada (long 30)
		--'OPERACIONES INUSUALES' + ';' + --40 descripcion de la operacion (variable)
		dbo.fFormatoT( convert(varchar,o.FechaCreacion,112) + ', PERIODO(' + convert(varchar,o.FechaIni,112) + '-' + convert(varchar,o.FechaFin,112) + ')',0, 40, '', 'I') + ';' + 
		dbo.fFormatoT((
		case 
		when o.MontoLimite > 0 then 'DEPOSITOS MAYORES A ' + convert(varchar,MontoLimite)
		else 'NUMERO DE OPERACIONES MAYORES A ' + convert(varchar,OperacionesLimite)
		end
		),0, 41, '', 'I')     --41 descripcion de la operacion (variable)
		
		from 
		tCsPLD_OperacionesInusuales as o
		inner join tCsPadronClientes as c on c.CodUsuario = o.codcliente
		inner join #operaciones as n on n.IdOperacion = o.IdOperacion
		inner join tcloficinas as ofi on ofi.CodOficina  = c.CodOficina
		left join vCsUbigeoColonia as uc on uc.CodUbiGeo = c.CodUbiGeoDirFamPri
	
	end 


if @TipoReporte = '3'
	begin
	
		select 

		@TipoReporte + ';' +   --1 tipo reporte (long 1)
		convert(varchar,@Periodo, 112) + ';' +  --2 periodo    (long 6/8)
		dbo.fFormatoT(convert(varchar,n.Consecutivo),1, 3, '0', 'D') + ';' +  --'000000;' + --3 folio, consecutivo   (long 6)
		@OrganiSup + ';' + --4 organo supervisor  (long 6)
		@CveFinanciera + ';' + --5 clave del sujeto obligado "clave financiera"  (long 6)
		';' + --6 Localidad   (long 8)
		ofi.codoficina +  ';' + --7 Sucursal    (long 8)
		';'+ --8 Tipo de Operacion  (long 2)
		';'+ --9  instrumento monetario   (long 2)
		';'+ --10 numero de cuenta contrato, operacion, etc (long 16)
		'0.00;' +  --11 monto (long 17)
		'MXP;' +  --12 moneda (long 3)
		convert(varchar,o.FechaReporte,112) + ';' + --13 fecha operacion  (long 8)
		convert(varchar,o.FechaCreacion,112) + ';' +  --14 fecha deteccion operacion (long 8)
		';' + --15 nacionalidad (long 1)
		'1;' +  -- 16 tipo de persona (long 1)
		';' +  --17  Razon social (long 60)
		dbo.fFormatoT(o.NomEmpleadoReporte,0, 60, '', 'I') + ';' +  --18 nombre (long 60)
		';' +  --19 ape pat (long 60)
		';' +  --20 ape mat (long 60)
		';' +  --21 rfc (long 13)
		';' +  --22 curp (long 18)
		';' +  --23 fec nac (long 8)
		';' +  --24 domicilio (long 60)
		';' +  --25 colonia (long 30)
		'0' + ';' +  --26 ciudad (long 8) catalogo
		';' +  --27 telefono (long 40)
		';' +  --28 actividad economica (long 7) catalogo
		';' +  --29 agente o apoderado nombre (long 60)    VACIO
		';' +  --30 agente o apoderado apellido paterno (long 60)   VACIO
		';' +  --31 agente o apoderado apellido materno (long 60)   VACIO
		';' +  --32 agente o apoderado RFC (long 13)      VACIO
		';' +  --33 agente o apoderado CURP (long 18)     VACIO
		';' +  --34 consecutivo de cuentas y/o personas relacionadas (long 2)
		';' +  --35 numero de cuenta contrato, operaciones etc (long 16)
		';' +  --36 clave del sujeto obligado (long 6)  CAPTURAR
		';' +  --37 nombre titular de la cuenta o de la persona relacionada (long 60)
		';' +  --38 ape pat titular de la cuenta o de la persona relacionada (long 60)
		';' +  --39 ape mat titular de la cuenta o de la persona relacionada (long 30)
		dbo.fFormatoT( convert(varchar,o.FechaCreacion,112), 0, 40, '', 'I') + ';' + 
		dbo.fFormatoT( o.MotivosReporte,0, 41, '', 'I')     --41 descripcion de la operacion (variable)

		from 
		tCsLavadoDineroBuzon as o
		inner join #operaciones as n on n.IdOperacion = o.IdBuzon
		inner join tcloficinas as ofi on ofi.CodOficina = o.CodOficinaReporte
	
	end 


drop table #operaciones




GO