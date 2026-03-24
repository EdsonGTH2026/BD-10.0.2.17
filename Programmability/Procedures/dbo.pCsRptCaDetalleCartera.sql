SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsRptCaDetalleCartera
CREATE Procedure [dbo].[pCsRptCaDetalleCartera]
	@Fecha			SmallDateTime,
	@CUbicacion		Varchar(1500),
	@Ubicacion		Varchar(100), 
	@CClaseCartera	Varchar(500),
	@ClaseCartera	Varchar(100),
	@Tabla			Varchar(50),
	@Select 		Varchar(8000) OutPut,
	@From1 			Varchar(4000) OutPut,
	@From2 			Varchar(4000) OutPut,
	@From3 			Varchar(4000) OutPut,
	@Where 			Varchar(4000) OutPut,
	@GroupBy 		Varchar(4000) OutPut,
	@Usuario		Varchar(25) = ''
As

Declare @Contador	Int
Declare @CFiltro	Varchar(100)
Declare @CFiltro1	Varchar(100)

Set @Usuario	= ltrim(rtrim(@Usuario))
Set @CFiltro	= ''
Set @CFiltro1	= ''

If @Usuario <> ''
Begin
	Select @Contador = Count(*) From (
	SELECT    Top 1   tSgUsuarios.CodUsuario
	FROM            tSgUsuarios with(nolock) INNER JOIN
							 tCsEmpleados with(nolock) ON tSgUsuarios.CodUsuario = tCsEmpleados.CodUsuario INNER JOIN
							 tCsClPuestos with(nolock) ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo
	WHERE        (tSgUsuarios.Usuario = @Usuario) AND (tCsClPuestos.FiltraCreditos = 1)) Datos

	If @Contador Is null Begin Set @Contador = 0 End

	If @Contador = 1 And (SELECT COUNT(*) FROM tClOficinas with(nolock) INNER JOIN tSgUsuarios with(nolock) ON tClOficinas.CodUsACargo = 
							tSgUsuarios.CodUsuario WHERE (tSgUsuarios.Usuario = @Usuario)) = 0
	Begin
		Select @Usuario = Ltrim(Rtrim(CodUsuario)) From tSgUsuarios Where Usuario = @Usuario
		Set @CFiltro	= ' AND tCsCartera.CodAsesor = '''+ @Usuario +'''' 
		Set @CFiltro1	= ' AND tCsAhorros.CodAsesor = '''+ @Usuario +'''' 
	End
	Else
	Begin
		Set @Usuario = ''
	End
End 

Set @Select	= ''
Set @From1	= ''
Set @From2	= ''
Set @From3	= ''
Set @Where	= ''
Set @GroupBy 	= ''

Declare  @FI		SmallDateTime

Set @FI	= Cast(dbo.fduFechaAtexto(@Fecha, 'AAAAMM') + '01' as SmallDateTime)

If @Tabla = 'tCsCarteraDet'
Begin

	Set @Select 	=  'SELECT ''tCsCarteraDet'' AS Tabla, '''+ @ClaseCartera +''' AS Cartera, '''+ @Ubicacion +''' AS Ubicacion, tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina, tCsCarteraDet.CodPrestamo, '
	Set @Select 	=  @Select 	+ 'tCsCartera.CodProducto, tCsCarteraDet.CodUsuario, tCsCartera.NroDiasAtraso, CASE WHEN tCsCartera.Estado = ''VENCIDO'' AND '
	Set @Select 	=  @Select 	+ 'tCsRenegociadosVigentes.CodPrestamo IS NULL THEN tCaProdPerTipoCredito.NroDiasSuspenso WHEN tCsRenegociadosVigentes.CodPrestamo IS NULL AND '
	Set @Select 	=  @Select 	+ 'tCsCartera.NroDiasAtraso < tCaProdPerTipoCredito.NroDiasSuspenso AND tCsCartera.TipoReprog NOT IN (''SINRE'',''REFRE'') '
	Set @Select 	=  @Select 	+ 'THEN tCaProdPerTipoCredito.NroDiasSuspenso WHEN tCsRenegociadosVigentes.CodPrestamo IS NOT NULL AND '
	Set @Select 	=  @Select 	+ 'tCsRenegociadosVigentes.Registro > ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''' THEN tCaProdPerTipoCredito.NroDiasSuspenso ELSE tCsCartera.NroDiasAtraso END AS Dias, '
	Set @Select 	=  @Select 	+ 'tCsCarteraDet.SaldoCapital, tCsCarteraDet.InteresVigente, tCsCarteraDet.InteresVencido, tCsCarteraDet.InteresCtaOrden, tCsCarteraDet.MoratorioVigente, '
	Set @Select 	=  @Select 	+ 'tCsCarteraDet.MoratorioVencido, tCsCarteraDet.MoratorioCtaOrden, tCsCarteraDet.OtrosCargos, tCsCarteraDet.Impuestos, tCsCarteraDet.CargoMora, '
	Set @Select 	=  @Select 	+ 'tCsCarteraDet.SReservaInteres, tCsCarteraDet.SReservaCapital, dbo.fduRellena(''0'', RTRIM(LTRIM(tCsCarteraDet.CodOficina)), 2, ''D'') '
	Set @Select 	=  @Select 	+ '+ '' '' + tClOficinas.NomOficina AS Oficina, tCsCartera.CodAsesor, ISNULL(tCsPadronClientes.Nombre1 + '', '' + tCsPadronClientes.Paterno, ''No Especificado'') '
	Set @Select 	=  @Select 	+ 'AS Asesor, tUsClSexo.Genero, ISNULL(ISNULL(tCPClEstado.ID10, ''0'') + ''-'' + tCPClEstado.Crystal, ''No Especificado'') AS CP1_Estado, '
	Set @Select 	=  @Select 	+ 'ISNULL(ISNULL(tCPClMunicipio.ID10, ''00'') + ''-'' + tCPClMunicipio.Municipio, ''No Especificado'') AS CP2_Municipio, ISNULL(ISNULL(tCPLugar.ID10, ''000'') '
	Set @Select 	=  @Select 	+ '+ ''-'' + tCPLugar.Lugar, ''No Especificado'') AS CP3_Colonia, ISNULL(tCPLugar.Zona, ''No Especificada'') AS ZonaLugar, tClZona.Nombre AS Regional, '
	Set @Select 	=  @Select 	+ 'tCsCarteraDet.MontoDesembolso AS Desembolso, tCaClTecnologia.Veridico AS Tecnologia, tCaProdPerTipoCredito.Descripcion AS TipoCredito, '
	Set @Select 	=  @Select 	+ 'tCsCartera.Cartera AS ClaseCartera, ISNULL(tCsPadronClientes_1.UsRFC, '
	Set @Select 	=  @Select 	+ 'CASE tCsPadronClientes_1.coddociden WHEN ''RFC'' THEN tCsPadronClientes_1.DI ELSE '''' END) AS RFC, tCsPadronClientes_1.NombreCompleto AS NCliente, '
	Set @Select 	=  @Select 	+ 'tCsCartera.Estado, tCaProducto.NombreProdCorto AS Producto, tClFondos.NemFondo AS Fondo, tCsCartera.FechaDesembolso, tCsCartera.NroCuotas, '
	Set @Select 	=  @Select 	+ 'tCsCartera.NroCuotasPagadas, tCsCartera.ProximoVencimiento, ISNULL(Garantias.TieneGarantia, 0) AS TieneGarantia, '
	Set @Select 	=  @Select 	+ 'dbo.fduEdad(tCsPadronClientes_1.FechaNacimiento, tCsCarteraDet.Fecha) AS Edad, '
	Set @Select 	=  @Select 	+ 'CASE WHEN tCsCartera.NroDiasAtraso = 0 THEN 0 ELSE ISNULL(Seguimiento.Seguimiento, 0) END AS Seguimiento, tCsCartera.TasaIntCorriente AS TasaInt, '
	Set @Select 	=  @Select 	+ 'RTRIM(LTRIM(tCsCarteraDet.CodPrestamo)) + LTRIM(RTRIM(tCsCarteraDet.CodUsuario)) AS Registro, CASE ISNULL(Garantias.TieneGarantia, 0) '
	Set @Select 	=  @Select 	+ 'WHEN 1 THEN ''Prendaria'' WHEN 0 THEN ''Quirografaria'' END AS OperacionGarantia, '
	Set @Select 	=  @Select 	+ 'CASE WHEN tCsCartera.Estado = ''VENCIDO'' THEN tCsCarteraDet.SaldoCapital WHEN tCsCartera.Estado = ''VIGENTE'' THEN tCsCarteraDet.SaldoCapital + tCsCarteraDet.InteresVigente '
	Set @Select 	=  @Select 	+ '+ tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido END AS R04B0417, Devengado.DevengadoMes, '
	Set @Select 	=  @Select 	+ '''['' + dbo.fduFechaATexto(tCsCartera.FechaDesembolso, ''AAAAMM'') + '']-'' + DATENAME(month, tCsCartera.FechaDesembolso) AS PeriodoDesembolso, '
	Set @Select 	=  @Select 	+ '''Secuencia Cliente '' + dbo.fduRellena(''0'', tCsCarteraDet.SC, 2, ''D'') AS SecuenciaCliente, ''Secuencia '' + CASE WHEN CG IS NULL THEN ''Cliente '' + dbo.fdurellena(''0'', '
	Set @Select 	=  @Select 	+ 'SC, 2, ''D'') ELSE ''Grupo '' + dbo.fdurellena(''0'', SG, 2, ''D'') END AS SecuenciaGrupo, tClOficinas.Zona, CASE WHEN tCsCartera.TipoReprog = ''SINRE'' AND '
	Set @Select 	=  @Select 	+ '(CASE WHEN CG IS NULL THEN SC ELSE SG END) = 1 THEN ''SINRE Nuevo'' WHEN tCsCartera.TipoReprog = ''SINRE'' AND (CASE WHEN CG IS NULL '
	Set @Select 	=  @Select 	+ 'THEN SC ELSE SG END) > 1 THEN ''SINRE Represtamo'' ELSE tCsCartera.TipoReprog END AS TipoReprog, tCsClBIS.Nombre AS BIS, tClActividad.Sector1, tClActividad.Sector2, '
	Set @Select 	=  @Select 	+ 'ReasignacionCartera = Case When tCsCartera.CodAsesor = PrimerAsesor Then ''Cartera Original'' When tCsCartera.CodAsesor <> PrimerAsesor Then ''Cartera Reasignada'' End '

	--Set @From1 	=  'FROM tCsPadronClientes RIGHT OUTER JOIN '
	Set @From1 	=  'FROM tCsPadronClientes with(nolock) LEFT OUTER JOIN tClActividad with(nolock) ON tCsPadronClientes.LabCodActividad = tClActividad.CodActividad RIGHT OUTER JOIN '
	Set @From1 	=  @From1 	+ 'tClFondos with(nolock) RIGHT OUTER JOIN '
	Set @From1 	=  @From1 	+ 'tCsClBIS with(nolock) RIGHT OUTER JOIN '
	Set @From1 	=  @From1 	+ 'tCsCartera with(nolock) ON tCsClBIS.Bis = tCsCartera.BIS LEFT OUTER JOIN '
	Set @From1 	=  @From1 	+ '(SELECT Fecha, Codigo, SUM(Garantia) AS Garantia, 1 AS TieneGarantia '
	Set @From1 	=  @From1 	+ 'FROM tCsDiaGarantias with(nolock) '
	Set @From1 	=  @From1 	+ 'WHERE (Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (Estado NOT IN (''INACTIVO'')) '
	Set @From1 	=  @From1 	+ 'GROUP BY Fecha, Codigo) AS Garantias ON tCsCartera.Fecha = Garantias.Fecha AND tCsCartera.CodPrestamo = Garantias.Codigo ON '
	Set @From1 	=  @From1 	+ 'tClFondos.CodFondo = tCsCartera.CodFondo LEFT OUTER JOIN '
	Set @From1 	=  @From1 	+ 'tCaProdPerTipoCredito with(nolock) ON tCsCartera.CodTipoCredito = tCaProdPerTipoCredito.CodTipoCredito LEFT OUTER JOIN '
	Set @From1 	=  @From1 	+ 'tCaProducto with(nolock) INNER JOIN '
	Set @From1 	=  @From1 	+ 'tCaClTecnologia with(nolock) ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia ON tCsCartera.CodProducto = tCaProducto.CodProducto ON '
	Set @From1 	=  @From1 	+ 'tCsPadronClientes.CodUsuario = tCsCartera.CodAsesor RIGHT OUTER JOIN '
	Set @From1 	=  @From1 	+ 'tCsRenegociadosVigentes with(nolock) RIGHT OUTER JOIN '
	Set @From1 	=  @From1 	+ 'tUsClSexo with(nolock) INNER JOIN '
	Set @From1 	=  @From1 	+ 'tCsPadronClientes AS tCsPadronClientes_1 with(nolock) ON tUsClSexo.Sexo = tCsPadronClientes_1.Sexo LEFT OUTER JOIN '
	
	Set @From2 	=  'tCPLugar with(nolock) LEFT OUTER JOIN '
	Set @From2 	=  @From2 	+ 'tCPClEstado with(nolock) RIGHT OUTER JOIN '
	Set @From2 	=  @From2 	+ 'tCPClMunicipio with(nolock) ON tCPClEstado.CodEstado = tCPClMunicipio.CodEstado ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND '
	Set @From2 	=  @From2 	+ 'tCPLugar.CodEstado = tCPClMunicipio.CodEstado RIGHT OUTER JOIN '
	Set @From2 	=  @From2 	+ 'tClUbigeo with(nolock) ON tCPLugar.IdLugar = tClUbigeo.IdLugar AND tCPLugar.CodEstado = tClUbigeo.CodEstado AND tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio ON '
	Set @From2 	=  @From2 	+ 'ISNULL(tCsPadronClientes_1.CodUbiGeoDirFamPri, tCsPadronClientes_1.CodUbiGeoDirNegPri) = tClUbigeo.CodUbiGeo RIGHT OUTER JOIN '
	Set @From2 	=  @From2 	+ '(SELECT DISTINCT Codprestamo, CodUsuario, 1 AS Seguimiento '
	Set @From2 	=  @From2 	+ 'FROM tCsCaSegCartera with(nolock) '
	Set @From2 	=  @From2 	+ 'WHERE (Fecha <= ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (Fecha >= ''' + dbo.fduFechaATexto(DateAdd(Day, -30, @Fecha), 'AAAAMMDD') + ''')) AS Seguimiento RIGHT OUTER JOIN '
	Set @From2 	=  @From2 	+ '(SELECT CodPrestamo, CodUsuario, SUM(InteresDevengado) AS DevengadoMes '
	Set @From2 	=  @From2 	+ 'FROM tCsCarteraDet AS tCsCarteraDet_2 with(nolock) '
	Set @From2 	=  @From2 	+ 'WHERE (Fecha >= ''' + dbo.fduFechaATexto(@FI, 'AAAAMMDD') + ''') AND (Fecha <= ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') '
	Set @From2 	=  @From2 	+ 'GROUP BY CodPrestamo, CodUsuario) AS Devengado RIGHT OUTER JOIN '
	Set @From2 	=  @From2 	+ '(SELECT tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCarteraDet.CodUsuario, tCsCarteraDet.CodOficina, tCsCarteraDet.CodDestino, ' 
	Set @From2 	=  @From2 	+ 'tCsCarteraDet.MontoDesembolso, tCsCarteraDet.SaldoCapital, tCsCarteraDet.SaldoInteres, tCsCarteraDet.SaldoMoratorio, '
	Set @From2 	=  @From2 	+ 'tCsCarteraDet.OtrosCargos, tCsCarteraDet.Impuestos, tCsCarteraDet.CargoMora, tCsCarteraDet.UltimoMovimiento, '
	
	Set @From3 	=  'tCsCarteraDet.CapitalAtrasado, tCsCarteraDet.CapitalVencido, tCsCarteraDet.SaldoEnMora, tCsCarteraDet.TipoCalificacion, '
	Set @From3 	=  @From3 	+ 'tCsCarteraDet.InteresVigente, tCsCarteraDet.InteresVencido, tCsCarteraDet.InteresCtaOrden, tCsCarteraDet.InteresDevengado, ' 
	Set @From3 	=  @From3 	+ 'tCsCarteraDet.MoratorioVigente, tCsCarteraDet.MoratorioVencido, tCsCarteraDet.MoratorioCtaOrden, tCsCarteraDet.MoratorioDevengado, ' 
	Set @From3 	=  @From3 	+ 'tCsCarteraDet.SecuenciaCliente, tCsCarteraDet.SecuenciaGrupo, tCsCarteraDet.PReservaCapital, tCsCarteraDet.SReservaCapital, '
	Set @From3 	=  @From3 	+ 'tCsCarteraDet.PReservaInteres, tCsCarteraDet.SReservaInteres, tCsCarteraDet.IDA, tCsCarteraDet.IReserva, '
	Set @From3 	=  @From3 	+ 'tCsPadronCarteraDet.SecuenciaGrupo AS SG, tCsPadronCarteraDet.SecuenciaCliente AS SC, tCsPadronCarteraDet.CodGrupo AS CG, tCsPadronCarteraDet.PrimerAsesor '
	Set @From3 	=  @From3 	+ 'FROM tCsCarteraDet AS tCsCarteraDet with(nolock) LEFT OUTER JOIN '
	Set @From3 	=  @From3 	+ 'tCsPadronCarteraDet with(nolock) ON tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND '
	Set @From3 	=  @From3 	+ 'tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario '
	Set @From3 	=  @From3 	+ ' WHERE (tCsCarteraDet.Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''')) AS tCsCarteraDet ON Devengado.CodPrestamo = tCsCarteraDet.CodPrestamo AND '
	Set @From3 	=  @From3 	+ 'Devengado.CodUsuario = tCsCarteraDet.CodUsuario ON Seguimiento.Codprestamo = tCsCarteraDet.CodPrestamo AND '
	Set @From3 	=  @From3 	+ 'Seguimiento.CodUsuario = tCsCarteraDet.CodUsuario ON tCsPadronClientes_1.CodUsuario = tCsCarteraDet.CodUsuario LEFT OUTER JOIN '
	Set @From3 	=  @From3 	+ 'tClZona with(nolock) RIGHT OUTER JOIN '
	Set @From3 	=  @From3 	+ 'tClOficinas with(nolock) ON tClZona.Zona = tClOficinas.Zona ON tCsCarteraDet.CodOficina = tClOficinas.CodOficina ON '
	Set @From3 	=  @From3 	+ 'tCsRenegociadosVigentes.CodPrestamo = tCsCarteraDet.CodPrestamo ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND '
	Set @From3 	=  @From3 	+ 'tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo '

	Set @Where 	=  'WHERE (tCsCartera.Cartera IN ('+ @CClaseCartera +')) AND (tCsCarteraDet.Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (tCsCarteraDet.CodOficina IN ('+ @CUbicacion +')) '
	If @Fecha > '20090131' 
	Begin
		Set @Where 	= @Where +  ' AND tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE + tCsCartera.SaldoINPE + tCsCartera.CargoMora + tCsCartera.OtrosCargos + tCsCartera.Impuestos > 0 '
	End 
	Set @Where = @Where + @CFiltro
End 
If @Tabla = 'tCsTransaccionDiaria'
Begin
	Set @Select 	=  'SELECT Tabla, Cartera, Ubicacion, Datos.Fecha, CodOficina, CodPrestamo, CodProducto, CodUsuario, NroDiasAtraso, Dias, SUM(SaldoCapital) AS SaldoCapital, '
	Set @Select 	=  @Select 	+ 'SUM(InteresVigente) AS InteresVigente, SUM(InteresVencido) AS InteresVencido, SUM(InteresCtaOrden) AS InteresCtaOrden, SUM(MoratorioVigente) '
	Set @Select 	=  @Select 	+ 'AS MoratorioVigente, SUM(MoratorioVencido) AS MoratorioVencido, SUM(MoratorioCTaOrden) AS MoratorioCTaOrden, SUM(OtrosCargos) '
	Set @Select 	=  @Select 	+ 'AS OtrosCargos, SUM(Impuestos) AS Impuestos, SUM(CargoMora) AS CargoMora, SUM(SReservaInteres) AS SReservaInteres, SUM(SReservaCapital) '
	Set @Select 	=  @Select 	+ 'AS SReservaCapital, Datos.Oficina, Datos.CodAsesor, Datos.Asesor, Datos.Genero, Datos.CP1_Estado, Datos.CP2_Municipio, Datos.CP3_Colonia, '
	Set @Select 	=  @Select 	+ 'ZonaLugar, Regional, SUM(Desembolso) AS Desembolso, Tecnologia, TipoCredito, ' 
	Set @Select 	=  @Select 	+ 'ClaseCartera, RFC, NCliente, Estado, Producto, Fondo, FechaDesembolso, NroCuotas, NroCuotasPagadas, TipoReprog, ProximoVencimiento, ISNULL(Garantia.TieneGarantia, 0) AS TieneGarantia, ' 
	Set @Select 	=  @Select 	+ 'Case ISNULL(Garantia.TieneGarantia, 0) When 1 Then ''Prendaria'' When 0 Then ''Quirografaria'' End AS OperacionGarantia '

	Set @From1 	=  'FROM (SELECT Datos.Tabla, Datos.Cartera, Datos.Ubicacion, Datos.Fecha, Datos.CodOficina, Datos.CodPrestamo, Datos.CodProducto, '
	Set @From1	=  @From1 	+ 'tCsPadronCarteraDet.CodUsuario, Datos.NroDiasAtraso, Datos.Dias, Datos.SaldoCapital / Datos.Contador AS SaldoCapital, ' 
	Set @From1 	=  @From1 	+ 'Datos.InteresVigente / Datos.Contador AS InteresVigente, Datos.InteresVencido / Datos.Contador AS InteresVencido, '
	Set @From1 	=  @From1 	+ 'Datos.InteresCtaOrden / Datos.Contador AS InteresCtaOrden, Datos.MoratorioVigente / Datos.Contador AS MoratorioVigente, ' 
	Set @From1 	=  @From1 	+ 'Datos.MoratorioVencido / Datos.Contador AS MoratorioVencido, Datos.MoratorioCtaOrden / Datos.Contador AS MoratorioCTaOrden, ' 
	Set @From1 	=  @From1 	+ 'Datos.OtrosCargos / Datos.Contador AS OtrosCargos, Datos.Impuestos / Datos.Contador AS Impuestos, '
	Set @From1 	=  @From1 	+ 'Datos.CargoMora / Datos.Contador AS CargoMora, Datos.SReservaInteres / Datos.Contador AS SReservaInteres, ' 
	Set @From1 	=  @From1 	+ 'Datos.SReservaCapital / Datos.Contador AS SReservaCapital, Datos.Oficina, Datos.CodAsesor, tUsClSexo.Genero, '
	Set @From1 	=  @From1 	+ 'ISNULL(ISNULL(tCPClEstado.ID10, ''0'') + ''-'' + tCPClEstado.Crystal, ''No Especificado'') AS CP1_Estado, ISNULL(ISNULL(tCPClMunicipio.ID10, '
	Set @From1 	=  @From1 	+ '''00'') + ''-'' + tCPClMunicipio.Municipio, ''No Especificado'') AS CP2_Municipio, ISNULL(IsNull(tCPLugar.ID10, ''000'') + ''-'' + tCPLugar.Lugar, ' 
	Set @From1 	=  @From1 	+ '''No Especificado'') AS CP3_Colonia, '
	Set @From1 	=  @From1 	+ 'ISNULL(tCPLugar.Zona, ''No Especifico'') AS ZonaLugar, Datos.Asesor, Datos.Regional, '
	Set @From1 	=  @From1 	+ 'Datos.Desembolso / Datos.Contador AS Desembolso, Datos.Tecnologia, Datos.TipoCredito, Datos.ClaseCartera, '
	Set @From1 	=  @From1 	+ 'ISNULL(tCsPadronClientes.UsRFC, CASE tCsPadronClientes.coddociden WHEN ''RFC'' THEN tCsPadronClientes.DI ELSE '''' END) AS RFC, '
	Set @From1 	=  @From1 	+ 'tCsPadronClientes.NombreCompleto As NCliente, Datos.Estado, Datos.Producto, Datos.Fondo, Datos.FechaDesembolso, Datos.NroCuotas, Datos.NroCuotasPagadas, Datos.TipoReprog, Datos.ProximoVencimiento '

	Set @From1 	=  @From1 	+ 'FROM (SELECT ''tCsTransaccionDiaria'' AS Tabla, '''+ @ClaseCartera +''' AS Cartera, '''+ @Ubicacion +''' AS Ubicacion, tCsTransaccionDiaria.Fecha, '
	Set @From1 	=  @From1 	+ 'tCsPadronCarteraDet.CodOficina, tCsTransaccionDiaria.CodigoCuenta AS CodPrestamo, tCsPadronCarteraDet.FechaCorte, tCsCartera.CodProducto, '
	Set @From1 	=  @From1 	+ 'tCsCartera.NroDiasAtraso, CASE WHEN tCsCartera.Estado = ''VENCIDO'' AND tCsRenegociadosVigentes.CodPrestamo IS NULL THEN tCaProdPerTipoCredito.NroDiasSuspenso '
	Set @From1 	=  @From1 	+ 'WHEN tCsRenegociadosVigentes.COdPrestamo IS NULL AND '
	Set @From1 	=  @From1 	+ 'tCsCartera.NroDiasAtraso < tCaProdPerTipoCredito.NroDiasSuspenso AND tCsCartera.TipoReprog NOT IN (''SINRE'') '
	Set @From1 	=  @From1 	+ 'THEN tCaProdPerTipoCredito.NroDiasSuspenso WHEN tCsRenegociadosVigentes.CodPrestamo IS NOT NULL AND tCsRenegociadosVigentes.Registro > ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''' THEN '
	Set @From1 	=  @From1 	+ 'tCaProdPerTipoCredito.NroDiasSuspenso ELSE tCsCartera.NroDiasAtraso END AS Dias, '
	Set @From1 	=  @From1 	+ 'CASE WHEN tCsTransaccionDiaria.TipoTransacNivel3 IN (''104'', ''105'', ''106'') THEN tCsTransaccionDiaria.MontoCapitalTran ELSE 0 END AS SaldoCapital, CASE WHEN tCsTransaccionDiaria.TipoTransacNivel3 IN (''104'', ''105'', ''106'') THEN tCsTransaccionDiaria.MontoInteresTran ELSE 0 END AS InteresVigente, '
	Set @From2 	=  '0 AS InteresVencido, 0 AS InteresCtaOrden, CASE WHEN tCsTransaccionDiaria.TipoTransacNivel3 IN (''104'', ''105'', ''106'') THEN tCsTransaccionDiaria.MontoINPETran ELSE 0 END AS MoratorioVigente, 0 AS MoratorioVencido, '
	Set @From2 	=  @From2 	+ '0 AS MoratorioCtaOrden, CASE WHEN tCsTransaccionDiaria.TipoTransacNivel3 IN (''104'', ''105'', ''106'') THEN tCsTransaccionDiaria.MontoOtrosTran ELSE 0 END AS OtrosCargos, 0 AS Impuestos, 0 AS CargoMora, '
	Set @From2 	=  @From2	+ '0 AS SReservaInteres, 0 AS SReservaCapital, dbo.fduRellena(''0'', RTRIM(LTRIM(tCsPadronCarteraDet.CodOficina)), 2, ''D'') '
	Set @From2 	=  @From2 	+ '+ '' '' + tClOficinas.NomOficina AS Oficina, tCsCartera.CodAsesor, '
	Set @From2 	=  @From2 	+ 'Isnull(tCsPadronClientes.Nombre1 + '', '' + tCsPadronClientes.Paterno, ''No Especificado'') AS Asesor, tClZona.Nombre AS Regional, CASE WHEN tCsTransaccionDiaria.TipoTransacNivel3 IN (''102'', ''103'') THEN tCsTransaccionDiaria.MontoCapitalTran ELSE 0 END AS Desembolso, '
	Set @From2 	=  @From2 	+ 'tCaClTecnologia.Veridico AS Tecnologia, tCaProdPerTipoCredito.Descripcion AS TipoCredito, tCsCartera.Cartera AS ClaseCartera, '
	Set @From2 	=  @From2 	+ 'COUNT(*) AS Contador, tCsCartera.Estado, tCaProducto.NombreProdCorto As Producto, tClFondos.NemFondo As Fondo, tCsCartera.FechaDesembolso, tCsCartera.NroCuotas, tCsCartera.NroCuotasPagadas, tCsCartera.TipoReprog, tCsCartera.ProximoVencimiento '

	Set @From2 	=  @From2 	+ 'FROM tCaProdPerTipoCredito with(nolock) INNER JOIN '
	Set @From2 	=  @From2 	+ 'tCsCartera with(nolock) INNER JOIN '
	Set @From2 	=  @From2 	+ '(SELECT Datos.CodPrestamo, Datos.FechaCorte, tCsPadronCarteraDet.CodUsuario, tCsPadronCarteraDet.CodOficina '
	Set @From2 	=  @From2 	+ 'FROM (SELECT CodPrestamo, MAX(FechaCorte) AS FechaCorte '
	Set @From2 	=  @From2 	+ 'FROM tCsPadronCarteraDet with(nolock) '
	Set @From2 	=  @From2 	+ 'WHERE CodOficina IN ('+ @CUbicacion +') '
	Set @From2 	=  @From2 	+ 'GROUP BY CodPrestamo) Datos INNER JOIN '
	Set @From2 	=  @From2 	+ 'tCsPadronCarteraDet ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo AND '
	Set @From2 	=  @From2 	+ 'Datos.FechaCorte = tCsPadronCarteraDet.FechaCorte) tCsPadronCarteraDet ON tCsCartera.Fecha = tCsPadronCarteraDet.FechaCorte AND '
	Set @From2 	=  @From2 	+ 'tCsCartera.CodPrestamo = tCsPadronCarteraDet.CodPrestamo ON tCaProdPerTipoCredito.CodTipoCredito = tCsCartera.CodTipoCredito INNER JOIN '
	Set @From2 	=  @From2 	+ 'tCsPadronClientes with(nolock) ON tCsCartera.CodAsesor = tCsPadronClientes.CodUsuario INNER JOIN '
	Set @From2 	=  @From2 	+ 'tClOficinas with(nolock) ON tCsPadronCarteraDet.CodOficina = tClOficinas.CodOficina INNER JOIN '
	Set @From2 	=  @From2 	+ 'tClZona with(nolock) ON tClOficinas.Zona = tClZona.Zona INNER JOIN '
	Set @From2 	=  @From2 	+ 'tCaProducto with(nolock) ON tCsCartera.CodProducto = tCaProducto.CodProducto INNER JOIN '
	Set @From2 	=  @From2 	+ 'tCaClTecnologia with(nolock) ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia LEFT OUTER JOIN '
	Set @From2 	=  @From2 	+ 'tClFondos with(nolock) ON tCsCartera.CodFondo = tClFondos.CodFondo RIGHT OUTER JOIN '
	Set @From2 	=  @From2	+ 'tCsRenegociadosVigentes with(nolock) RIGHT OUTER JOIN '
	Set @From2 	=  @From2 	+ 'tCsTransaccionDiaria with(nolock) ON tCsRenegociadosVigentes.CodPrestamo = tCsTransaccionDiaria.CodigoCuenta ON '
	Set @From2 	=  @From2 	+ 'tCsPadronCarteraDet.CodPrestamo = tCsTransaccionDiaria.CodigoCuenta '

	Set @From3 	=  'WHERE (tCsTransaccionDiaria.Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (tCsTransaccionDiaria.CodSistema = ''CA'') AND '
	Set @From3 	=  @From3 	+ '(tCsTransaccionDiaria.TipoTransacNivel3 IN (''102'', ''103'', ''104'', ''105'', ''106'')) AND '
	Set @From3 	=  @From3 	+ '(tCsTransaccionDiaria.Extornado = 0) AND (tCsTransaccionDiaria.CodOficina IN ('+ @CUbicacion +')) AND (tCsCartera.Cartera IN ('+ @CClaseCartera +')) ' + @CFiltro
	
	Set @From3 	=  @From3 	+ 'GROUP BY tCsPadronCarteraDet.FechaCorte, tCsTransaccionDiaria.Fecha, tCsTransaccionDiaria.CodigoCuenta, tCsTransaccionDiaria.MontoCapitalTran, '
    Set @From3 	=  @From3 	+ 'tCsTransaccionDiaria.MontoInteresTran, tCsTransaccionDiaria.MontoINPETran, tCsTransaccionDiaria.MontoOtrosTran, '
    Set @From3 	=  @From3 	+ 'tCsTransaccionDiaria.MontoTotalTran, tCsPadronCarteraDet.CodOficina, tCsCartera.CodProducto, tCsCartera.NroDiasAtraso, ' 
    Set @From3 	=  @From3 	+ 'tCaProdPerTipoCredito.NroDiasSuspenso, tCsRenegociadosVigentes.CodPrestamo, tCsCartera.TipoReprog, tCsCartera.CodAsesor, ' 
    Set @From3 	=  @From3 	+ 'tCsPadronClientes.Nombre1, tCsPadronClientes.Paterno, tClOficinas.NomOficina, tClZona.Nombre, tCaClTecnologia.Veridico, '
    Set @From3 	=  @From3 	+ 'tCaProdPerTipoCredito.Descripcion, tCsCartera.Cartera, tCsRenegociadosVigentes.Registro, tCsTransaccionDiaria.TipoTransacNivel3, ' 
    Set @From3 	=  @From3 	+ 'tCsCartera.Estado, tCaProducto.NombreProdCorto, tClFondos.NemFondo, tCsCartera.FechaDesembolso, tCsCartera.NroCuotas, tCsCartera.NroCuotasPagadas, tCsCartera.TipoReprog, tCsCartera.ProximoVencimiento '
	
	Set @From3 	=  @From3 	+ ') Datos INNER JOIN '
	Set @From3 	=  @From3 	+ 'tCsPadronCarteraDet with(nolock) ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo AND '
    Set @From3 	=  @From3 	+ 'Datos.FechaCorte = tCsPadronCarteraDet.FechaCorte LEFT OUTER JOIN '
	Set @From3 	=  @From3 	+ 'tCPLugar with(nolock) LEFT OUTER JOIN '
    Set @From3 	=  @From3 	+ 'tCPClEstado with(nolock) RIGHT OUTER JOIN '
    Set @From3 	=  @From3 	+ 'tCPClMunicipio with(nolock) ON tCPClEstado.CodEstado = tCPClMunicipio.CodEstado ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND '
    Set @From3 	=  @From3 	+ 'tCPLugar.CodEstado = tCPClMunicipio.CodEstado RIGHT OUTER JOIN '
	Set @From3 	=  @From3 	+ 'tUsClSexo with(nolock) INNER JOIN '
	Set @From3 	=  @From3 	+ 'tCsPadronClientes with(nolock) ON tUsClSexo.Sexo = tCsPadronClientes.Sexo INNER JOIN '
	Set @From3 	=  @From3 	+ 'tClUbigeo with(nolock) ON ISNULL(tCsPadronClientes.CodUbiGeoDirFamPri, tCsPadronClientes.CodUbiGeoDirNegPri) = tClUbigeo.CodUbiGeo ON '
	Set @From3 	=  @From3 	+ 'tCPLugar.IdLugar = tClUbigeo.IdLugar AND tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio AND '
	Set @From3 	=  @From3 	+ 'tCPLugar.CodEstado = tClUbigeo.CodEstado ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario)  Datos LEFT OUTER JOIN '
    Set @From3 	=  @From3 	+ '(SELECT Fecha, Codigo, SUM(Garantia) AS Garantia, 1 AS TieneGarantia '
    Set @From3 	=  @From3 	+ 'FROM tCsDiaGarantias with(nolock) '
    Set @From3 	=  @From3 	+ 'WHERE (Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (Estado NOT IN (''INACTIVO'')) '
    Set @From3 	=  @From3 	+ 'GROUP BY Fecha, Codigo) Garantia ON Datos.Fecha = Garantia.Fecha AND Datos.CodPrestamo = Garantia.Codigo '

	Set @GroupBy	= 'GROUP BY Datos.Tabla, Datos.Cartera, Datos.Ubicacion, Datos.Fecha, Datos.CodOficina, Datos.CodPrestamo, Datos.CodProducto, Datos.CodUsuario, '
	Set @GroupBy	= @GroupBy 	+ 'Datos.NroDiasAtraso, Datos.Dias, Datos.Oficina, Datos.CodAsesor, Datos.Genero, Datos.CP1_Estado, Datos.CP2_Municipio, Datos.CP3_Colonia, Datos.ZonaLugar, Datos.Asesor, Datos.Regional, '
	Set @GroupBy	= @GroupBy 	+ 'Datos.Tecnologia, Datos.TipoCredito, Datos.ClaseCartera, Datos.RFC, Datos.NCliente, Datos.Estado, Datos.Producto, Datos.Fondo, '
	Set @GroupBy	= @GroupBy 	+ 'Datos.FechaDesembolso, Datos.NroCuotas, Datos.NroCuotasPagadas, Datos.TipoReprog, Datos.ProximoVencimiento, Garantia.TieneGarantia '

End
If @Tabla = 'tCsAhorros'
Begin
	Set @Select 	= 'SELECT ''tCsAhorros'' AS tabla,  Cartera = '''+ @ClaseCartera +''', '''+ @Ubicacion +''' AS Ubicacion, tCsAhorros.Fecha, tCsAhorros.CodOficina, '
	Set @Select 	= @Select  + 'tCsAhorros.CodCuenta + ''-'' + tCsAhorros.FraccionCta + ''-'' + CAST(tCsAhorros.Renovado AS Varchar(10)) AS CodPrestamo, tCsAhorros.CodProducto, '
	Set @Select 	= @Select  + 'ISNULL(tCsClientesAhorrosFecha.CodUsCuenta, tCsAhorros.CodUsuario) AS CodUsuario, tCsClientesAhorrosFecha.Coordinador, '
	Set @Select 	= @Select  + 'ISNULL(tCsAhorros.Plazo, 0) AS Dias, Case When DateDiff(day, ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''', Isnull(FechaVencimiento, ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''')) < 0 then 0 else DateDiff(day, ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''', Isnull(FechaVencimiento, ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''')) End As Liquidez, Factor.Factor AS Integrantes, tCsClientesAhorrosFecha.Capital AS Capital, '
	Set @Select 	= @Select  + 'tCsClientesAhorrosFecha.Interes, tCsUDIS.UDI, tCsClientesAhorrosFecha.Capital / tCsUDIS.UDI AS CapitalUDI, '
	Set @Select 	= @Select  + 'tCsClientesAhorrosFecha.Interes / tCsUDIS.UDI AS InteresUDI, dbo.fduRellena(''0'', RTRIM(LTRIM(tCsAhorros.CodOficina)), 2, ''D'') ' 
	Set @Select 	= @Select  + '+ '' '' + tClOficinas.NomOficina AS Oficina, tCsAhorros.CodAsesor, ISNULL(tCsPadronClientes.Nombre1 + '', '' + tCsPadronClientes.Paterno, '
	Set @Select 	= @Select  + '''No Especificado'') AS Asesor, tUsClSexo.Genero, ISNULL(ISNULL(tCPClEstado.ID10, ''0'') + ''-'' + tCPClEstado.Crystal, ''No Especificado'') AS CP1_Estado, '
    Set @Select 	= @Select  + 'ISNULL(ISNULL(tCPClMunicipio.ID10, ''00'') + ''-'' + tCPClMunicipio.Municipio, ''No Especificado'') AS CP2_Municipio, ISNULL(ISNULL(tCPLugar.ID10, ''000'') '
    Set @Select 	= @Select  + '+ ''-'' + tCPLugar.Lugar, ''No Especificado'') AS CP3_Colonia, '
	Set @Select 	= @Select  + 'tCPLugar.Zona AS ZonaLugar, tClZona.Nombre AS Regional, '
	Set @Select 	= @Select  + 'tAhClFormaManejo.Nombre AS Tecnologia, tAhClTipoProducto.DescTipoProd AS ClaseCartera, ISNULL(Clientes.UsRFC, '
	Set @Select 	= @Select  + 'CASE Clientes.coddociden WHEN ''RFC'' THEN clientes.DI ELSE '''' END) AS RFC, Clientes.NombreCompleto AS NCliente, ' 
	Set @Select 	= @Select  + 'tAhClEstadoCuenta.Descripcion AS Estado, tAhProductos.Abreviatura AS Producto, tCsAhorros.FechaApertura, tCsAhorros.FechaVencimiento, '
	Set @Select 	= @Select  + 'tCsAhorros.EnGarantia, tCsAhorros.Garantia, tCsAhorros.CuentaPreferencial, tCsAhorros.CuentaReservada, '
	Set @Select 	= @Select  + 'CASE tCsAhorros.Lucro WHEN 1 THEN ''CON FINES DE LUCRO'' WHEN 0 THEN ''SIN FINES DE LUCRO'' END AS Fondo, ' 
	Set @Select		= @Select  + 'tAhClTipoCapitalizacion.DesTipoCapi AS TipoCapitalizacion, tAhClTipoInteres.Descripcion AS TipoCredito, Desembolso = tCsClientesAhorrosFecha.Interes, DevengadoMes.DevengadoMes, '
	Set @Select 	= @Select  + 'Edad = dbo.fduEdad(Clientes.FechaNacimiento, tCsAhorros.Fecha), TasaInt = TasaInteres, tCsAhorros.CodUsuario as Titular, EdadT = dbo.fduEdad(tCsPadronClientes_1.FechaNacimiento, tCsAhorros.Fecha), '
	Set @Select 	= @Select + 'Case tCsAhorros.EnGarantia When 1 Then ''Es Garantía'' When 0 Then ''No Garantía'' End AS OperacionGarantia,  ''['' + dbo.fduFechaATexto(tcsahorros.FechaApertura, ''AAAAMM'') + '']-'' + DATENAME([month], tcsahorros.FechaApertura)  As PeriodoDesembolso, tClOficinas.Zona '
	
	Set @From1 =  'FROM tCPClEstado with(nolock) RIGHT OUTER JOIN '
    Set @From1 = @From1  + 'tCPClMunicipio with(nolock) ON tCPClEstado.CodEstado = tCPClMunicipio.CodEstado RIGHT OUTER JOIN '
    Set @From1 = @From1  + 'tCPLugar with(nolock) ON tCPClMunicipio.CodMunicipio = tCPLugar.CodMunicipio AND tCPClMunicipio.CodEstado = tCPLugar.CodEstado RIGHT OUTER JOIN '
	Set @From1 = @From1  + 'tClUbigeo with(nolock) ON tCPLugar.CodEstado = tClUbigeo.CodEstado AND tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio AND '
	Set @From1 = @From1  + 'tCPLugar.IdLugar = tClUbigeo.IdLugar RIGHT OUTER JOIN '
	Set @From1 = @From1  + 'tCsPadronClientes Clientes with(nolock) ON tClUbigeo.CodUbiGeo = ISNULL(Clientes.CodUbiGeoDirFamPri, Clientes.CodUbiGeoDirNegPri) LEFT OUTER JOIN '
	Set @From1 = @From1  + 'tUsClSexo with(nolock) ON Clientes.Sexo = tUsClSexo.Sexo RIGHT OUTER JOIN '
	Set @From1 = @From1  + '(SELECT CodOficina, CodCuenta, FraccionCta, Renovado, CodUsCuenta, SUM(InteresDia) AS DevengadoMes '
	Set @From1 = @From1  + 'FROM tCsClientesAhorrosFecha with(nolock) '
	Set @From1 = @From1  + 'WHERE (Fecha >= ''' + dbo.fduFechaATexto(@FI, 'AAAAMMDD') + ''') AND (Fecha <= ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (idEstado = ''AC'') AND InteresDia > 0 '
	Set @From1 = @From1  + 'GROUP BY CodOficina, CodCuenta, FraccionCta, Renovado, CodUsCuenta) DevengadoMes RIGHT OUTER JOIN '
	Set @From1 = @From1  + 'tCsClientesAhorrosFecha with(nolock) ON DevengadoMes.CodOficina COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.CodOficina AND '
	Set @From1 = @From1  + 'DevengadoMes.CodCuenta COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.CodCuenta AND '
	Set @From1 = @From1  + 'DevengadoMes.FraccionCta COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.FraccionCta AND ' 
	
	Set @From2 = 'DevengadoMes.Renovado = tCsClientesAhorrosFecha.Renovado AND '
	Set @From2 = @From2  + 'DevengadoMes.CodUsCuenta COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.CodUsCuenta ON '
	Set @From2 = @From2  + 'Clientes.CodUsuario = tCsClientesAhorrosFecha.CodUsCuenta RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tClZona with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tClOficinas with(nolock) ON tClZona.Zona = tClOficinas.Zona RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tCsPadronClientes with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tAhClFormaManejo with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tAhProductos with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tAhClTipoCapitalizacion with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tCsAhorros with(nolock) LEFT OUTER JOIN '
    Set @From2 = @From2  + 'tCsPadronClientes tCsPadronClientes_1 with(nolock) ON tCsAhorros.CodUsuario = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN '
	Set @From2 = @From2  + 'tAhClTipoInteres with(nolock) ON tCsAhorros.CodTipoInteres = tAhClTipoInteres.CodTipoInteres ON '
	Set @From2 = @From2  + 'tAhClTipoCapitalizacion.idTipoCapi = tCsAhorros.idTipoCapi LEFT OUTER JOIN '
	
	Set @From3 = 'tAhClEstadoCuenta ON tCsAhorros.idEstadoCta = tAhClEstadoCuenta.idEstadoCta ON '
	Set @From3 = @From3  + 'tAhProductos.idProducto = tCsAhorros.CodProducto LEFT OUTER JOIN '
	Set @From3 = @From3  + 'tAhClTipoProducto with(nolock) ON tAhProductos.idTipoProd = tAhClTipoProducto.idTipoProd ON tAhClFormaManejo.FormaManejo = tCsAhorros.FormaManejo ON '
	Set @From3 = @From3  + 'tCsPadronClientes.CodUsuario = tCsAhorros.CodAsesor ON tClOficinas.CodOficina = tCsAhorros.CodOficina LEFT OUTER JOIN '
	Set @From3 = @From3  + 'tCsUDIS with(nolock) ON tCsAhorros.Fecha = tCsUDIS.Fecha LEFT OUTER JOIN '
	Set @From3 = @From3  + '(SELECT Fecha, CodCuenta, FraccionCta, Renovado, COUNT(*) AS Factor '
	Set @From3 = @From3  + 'FROM tCsClientesAhorrosFecha with(nolock) '
	Set @From3 = @From3  + 'WHERE (Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (idEstado = ''AC'') '
	Set @From3 = @From3  + 'GROUP BY Fecha, CodCuenta, FraccionCta, Renovado) Factor ON tCsAhorros.Fecha = Factor.Fecha AND '
	Set @From3 = @From3  + 'tCsAhorros.CodCuenta = Factor.CodCuenta COLLATE Modern_Spanish_CI_AI AND '
	Set @From3 = @From3  + 'tCsAhorros.FraccionCta = Factor.FraccionCta COLLATE Modern_Spanish_CI_AI AND tCsAhorros.Renovado = Factor.Renovado ON '
	Set @From3 = @From3  + 'tCsClientesAhorrosFecha.Fecha = tCsAhorros.Fecha AND tCsClientesAhorrosFecha.CodOficina = tCsAhorros.CodOficina AND '
	Set @From3 = @From3  + 'tCsClientesAhorrosFecha.CodCuenta = tCsAhorros.CodCuenta AND tCsClientesAhorrosFecha.FraccionCta = tCsAhorros.FraccionCta AND '
	Set @From3 = @From3  + 'tCsClientesAhorrosFecha.Renovado = tCsAhorros.Renovado '

	Set @Where = 'WHERE (tCsAhorros.Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (tCsAhorros.CodOficina IN ('+ @CUbicacion +')) AND (tAhProductos.idTipoProd IN ('+ @CClaseCartera +')) AND (tCsClientesAhorrosFecha.Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''' AND tCsAhorros.idEstadoCta Not in (''CC''))' + @CFiltro1
End

If @Tabla = 'tCsAhorros2'
Begin
	Set @Select = 'SELECT ''tCsAhorros'' AS tabla,  Cartera = '''+ @ClaseCartera +''', '''+ @Ubicacion +''' AS Ubicacion, tCsAhorros.Fecha, tCsAhorros.CodOficina, '
	Set @Select = @Select  + 'tCsAhorros.CodCuenta + ''-'' + tCsAhorros.FraccionCta + ''-'' + CAST(tCsAhorros.Renovado AS Varchar(10)) AS CodPrestamo, tCsAhorros.CodProducto, '
	Set @Select = @Select  + 'ISNULL(tCsClientesAhorrosFecha.CodUsCuenta, tCsAhorros.CodUsuario) AS CodUsuario, tCsClientesAhorrosFecha.Coordinador, '
	Set @Select = @Select  + 'ISNULL(tCsAhorros.Plazo, 0) AS Dias1, Case When DateDiff(day, ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''', Isnull(FechaVencimiento, ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''')) < 0 then 0 else DateDiff(day, ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''', Isnull(FechaVencimiento, ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''')) End As Dias, Factor.Factor AS Integrantes, tCsClientesAhorrosFecha.Capital AS Capital, '
	Set @Select = @Select  + 'tCsClientesAhorrosFecha.Interes, tCsUDIS.UDI, tCsClientesAhorrosFecha.Capital / tCsUDIS.UDI AS CapitalUDI, '
	Set @Select = @Select  + 'tCsClientesAhorrosFecha.Interes / tCsUDIS.UDI AS InteresUDI, dbo.fduRellena(''0'', RTRIM(LTRIM(tCsAhorros.CodOficina)), 2, ''D'') ' 
	Set @Select = @Select  + '+ '' '' + tClOficinas.NomOficina AS Oficina, tCsAhorros.CodAsesor, ISNULL(tCsPadronClientes.Nombre1 + '', '' + tCsPadronClientes.Paterno, '
	Set @Select = @Select  + '''No Especificado'') AS Asesor, tUsClSexo.Genero, ISNULL(ISNULL(tCPClEstado.ID10, ''0'') + ''-'' + tCPClEstado.Crystal, ''No Especificado'') AS CP1_Estado, '
	Set @Select = @Select  + 'ISNULL(ISNULL(tCPClMunicipio.ID10, ''00'') + ''-'' + tCPClMunicipio.Municipio, ''No Especificado'') AS CP2_Municipio, ISNULL(ISNULL(tCPLugar.ID10, ''000'') '
    Set @Select = @Select  + '+ ''-'' + tCPLugar.Lugar, ''No Especificado'') AS CP3_Colonia, '
	Set @Select = @Select  + 'tCPLugar.Zona AS ZonaLugar, tClZona.Nombre AS Regional, '
	Set @Select = @Select  + 'tAhClFormaManejo.Nombre AS Tecnologia, tAhClTipoProducto.DescTipoProd AS ClaseCartera, ISNULL(Clientes.UsRFC, '
	Set @Select = @Select  + 'CASE Clientes.coddociden WHEN ''RFC'' THEN clientes.DI ELSE '''' END) AS RFC, Clientes.NombreCompleto AS NCliente, ' 
	Set @Select = @Select  + 'tAhClEstadoCuenta.Descripcion AS Estado, tAhProductos.Abreviatura AS Producto, tCsAhorros.FechaApertura, tCsAhorros.FechaVencimiento, '
	Set @Select = @Select  + 'tCsAhorros.EnGarantia, tCsAhorros.Garantia, tCsAhorros.CuentaPreferencial, tCsAhorros.CuentaReservada, '
	Set @Select = @Select  + 'CASE tCsAhorros.Lucro WHEN 1 THEN ''CON FINES DE LUCRO'' WHEN 0 THEN ''SIN FINES DE LUCRO'' END AS Fondo, ' 
	Set @Select = @Select  + 'tAhClTipoCapitalizacion.DesTipoCapi AS TipoCapitalizacion, tAhClTipoInteres.Descripcion AS TipoCredito, Desembolso = tCsClientesAhorrosFecha.Interes, DevengadoMes.DevengadoMes, '
	Set @Select = @Select + 'Edad = dbo.fduEdad(Clientes.FechaNacimiento, tCsAhorros.Fecha), Case tCsAhorros.EnGarantia When 1 Then ''Es Garantía'' When 0 Then ''No Garantía'' End AS OperacionGarantia, '
	Set @Select = @Select + '''['' + dbo.fduFechaATexto(tcsahorros.FechaApertura, ''AAAAMM'') + '']-'' + DATENAME([month], tcsahorros.FechaApertura)  As PeriodoDesembolso, tClOficinas.Zona '
	
	Set @From1 =  'FROM tCPClEstado with(nolock) RIGHT OUTER JOIN '
    Set @From1 = @From1  + 'tCPClMunicipio with(nolock) ON tCPClEstado.CodEstado = tCPClMunicipio.CodEstado RIGHT OUTER JOIN '
    Set @From1 = @From1  + 'tCPLugar with(nolock) ON tCPClMunicipio.CodMunicipio = tCPLugar.CodMunicipio AND tCPClMunicipio.CodEstado = tCPLugar.CodEstado RIGHT OUTER JOIN '
	Set @From1 = @From1  + 'tClUbigeo with(nolock) ON tCPLugar.CodEstado = tClUbigeo.CodEstado AND tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio AND '
	Set @From1 = @From1  + 'tCPLugar.IdLugar = tClUbigeo.IdLugar RIGHT OUTER JOIN '
	Set @From1 = @From1  + 'tCsPadronClientes Clientes with(nolock) ON tClUbigeo.CodUbiGeo = ISNULL(Clientes.CodUbiGeoDirFamPri, Clientes.CodUbiGeoDirNegPri) LEFT OUTER JOIN '
	Set @From1 = @From1  + 'tUsClSexo with(nolock) ON Clientes.Sexo = tUsClSexo.Sexo RIGHT OUTER JOIN '
	Set @From1 = @From1  + '(SELECT CodOficina, CodCuenta, FraccionCta, Renovado, CodUsCuenta, SUM(InteresDia) AS DevengadoMes '
	Set @From1 = @From1  + 'FROM tCsClientesAhorrosFecha with(nolock) '
	Set @From1 = @From1  + 'WHERE (Fecha >= ''' + dbo.fduFechaATexto(@FI, 'AAAAMMDD') + ''') AND (Fecha <= ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (idEstado = ''AC'') '
	Set @From1 = @From1  + 'GROUP BY CodOficina, CodCuenta, FraccionCta, Renovado, CodUsCuenta) DevengadoMes RIGHT OUTER JOIN '
	Set @From1 = @From1  + 'tCsClientesAhorrosFecha with(nolock) ON DevengadoMes.CodOficina COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.CodOficina AND '
	Set @From1 = @From1  + 'DevengadoMes.CodCuenta COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.CodCuenta AND '
	Set @From1 = @From1  + 'DevengadoMes.FraccionCta COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.FraccionCta AND ' 
	
	Set @From2 = 'DevengadoMes.Renovado = tCsClientesAhorrosFecha.Renovado AND '
	Set @From2 = @From2  + 'DevengadoMes.CodUsCuenta COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.CodUsCuenta ON '

	Set @From2 = @From2  + 'Clientes.CodUsuario = tCsClientesAhorrosFecha.CodUsCuenta RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tClZona with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tClOficinas with(nolock) ON tClZona.Zona = tClOficinas.Zona RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tCsPadronClientes with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tAhClFormaManejo with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tAhProductos with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tAhClTipoCapitalizacion with(nolock) RIGHT OUTER JOIN '
	Set @From2 = @From2  + 'tCsAhorros with(nolock) LEFT OUTER JOIN '
	Set @From2 = @From2  + 'tAhClTipoInteres with(nolock) ON tCsAhorros.CodTipoInteres = tAhClTipoInteres.CodTipoInteres ON '
	Set @From2 = @From2  + 'tAhClTipoCapitalizacion.idTipoCapi = tCsAhorros.idTipoCapi LEFT OUTER JOIN '
	
	Set @From3 = 'tAhClEstadoCuenta with(nolock) ON tCsAhorros.idEstadoCta = tAhClEstadoCuenta.idEstadoCta ON '
	Set @From3 = @From3  + 'tAhProductos.idProducto = tCsAhorros.CodProducto LEFT OUTER JOIN '
	Set @From3 = @From3  + 'tAhClTipoProducto with(nolock) ON tAhProductos.idTipoProd = tAhClTipoProducto.idTipoProd ON tAhClFormaManejo.FormaManejo = tCsAhorros.FormaManejo ON '
	Set @From3 = @From3  + 'tCsPadronClientes.CodUsuario = tCsAhorros.CodAsesor ON tClOficinas.CodOficina = tCsAhorros.CodOficina LEFT OUTER JOIN '
	Set @From3 = @From3  + 'tCsUDIS with(nolock) ON tCsAhorros.Fecha = tCsUDIS.Fecha LEFT OUTER JOIN '
	Set @From3 = @From3  + '(SELECT Fecha, CodCuenta, FraccionCta, Renovado, COUNT(*) AS Factor '
	Set @From3 = @From3  + 'FROM tCsClientesAhorrosFecha with(nolock) '
	Set @From3 = @From3  + 'WHERE (Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (idEstado = ''AC'') '
	Set @From3 = @From3  + 'GROUP BY Fecha, CodCuenta, FraccionCta, Renovado) Factor ON tCsAhorros.Fecha = Factor.Fecha AND '
	Set @From3 = @From3  + 'tCsAhorros.CodCuenta = Factor.CodCuenta COLLATE Modern_Spanish_CI_AI AND '
	Set @From3 = @From3  + 'tCsAhorros.FraccionCta = Factor.FraccionCta COLLATE Modern_Spanish_CI_AI AND tCsAhorros.Renovado = Factor.Renovado ON '
	Set @From3 = @From3  + 'tCsClientesAhorrosFecha.Fecha = tCsAhorros.Fecha AND tCsClientesAhorrosFecha.CodOficina = tCsAhorros.CodOficina AND '
	Set @From3 = @From3  + 'tCsClientesAhorrosFecha.CodCuenta = tCsAhorros.CodCuenta AND tCsClientesAhorrosFecha.FraccionCta = tCsAhorros.FraccionCta AND '
	Set @From3 = @From3  + 'tCsClientesAhorrosFecha.Renovado = tCsAhorros.Renovado '
	
	Set @Where = 'WHERE (tCsAhorros.Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''') AND (tCsAhorros.CodOficina IN ('+ @CUbicacion +')) AND (tAhProductos.idTipoProd IN ('+ @CClaseCartera +')) AND (tCsClientesAhorrosFecha.Fecha = ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + ''' AND tCsAhorros.idEstadoCta Not in (''CC''))' + @CFiltro1
End

Print 'Select 	: ' + @Select
Print 'From1 	: ' + @From1
Print 'From2 	: ' + @From2
Print 'From3 	: ' + @From3
Print 'Where 	: ' + @Where
Print 'GroupBy	: ' + @GroupBy
GO