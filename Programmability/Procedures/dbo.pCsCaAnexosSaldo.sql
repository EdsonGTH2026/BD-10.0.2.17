SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsCaAnexosSaldo

CREATE Procedure [dbo].[pCsCaAnexosSaldo]
@Fecha 		SmallDateTime,
@TipoSaldo	Varchar(1000),
@DI		Int,
@DF		Int,
@Garantia	Int,
@Cartera	Varchar(30),
@CReserva	Varchar(10),
@Indicador	Varchar(3),
@Valor Decimal(18,4) OUTPUT
As

--, '02', 0, 89, 2, '1', 'TODAS', 'DD'

Declare @Cadena	Varchar(4000)
Declare @Ubicacion	Varchar(100)
Declare @ClaseCartera	Varchar(100)
Declare @Valor1	Decimal(18,4)	

Declare @Agrupador 	Varchar(100)
Declare @Parametro	Varchar(100)
Declare @FactorID 	Int
Declare @ID		Varchar(20)

If Len(@TipoSaldo) = 5 
Begin
	Set @Ubicacion 	= Ltrim(Rtrim(Str(Cast(Substring(@TipoSaldo, 3, 3) as Int), 3, 0)))	
	Set @TipoSaldo 	= Substring(@TipoSaldo, 1, 2)	
End
Else
Begin
	Set @Ubicacion	= 'ZZZ'
End
Set @ClaseCartera	= 'ACTIVA'
Set @Valor1		= 1
Set @Agrupador 	= ''
Set @Parametro		= @TipoSaldo + Cast(@DI as Varchar(10)) + Cast(@DF as Varchar(10)) + Cast(@Garantia as Varchar(10)) +
			  Ltrim(Rtrim(@Cartera)) +  Ltrim(Rtrim(@CReserva)) +  Ltrim(Rtrim(@Indicador))

Set @FactorID 	= 10
Set @ID 	=   	SUBSTRING(dbo.fduNumeroALetras(DATEPART(Day, 	@Fecha), 0), 1, 1) +
			SUBSTRING(dbo.fduNumeroALetras(DATEPART(Month, 	@Fecha), 0), 1, 1) +
			SUBSTRING(dbo.fduNumeroALetras(Cast(dbo.fduFechaATexto(@Fecha, 'AA') as Int), 0), 1, 1) +
			SUBSTRING(@Parametro, 	1, 1) + 
			SUBSTRING(@Parametro, 	1, 1) + 
			SUBSTRING(@Parametro, 	1, 1) + 
			SUBSTRING(@Parametro,	1, 1) + 
			SUBSTRING(dbo.fduNumeroALetras(DATEPART(Second, GETDATE()), 0), 1, 1) + '-' 	+ 
			Cast((	DATEPART(Day, @Fecha) 			+ 
				DATEPART(Month, @Fecha) 		+ 
				DATEPART(Year,  @Fecha) 		+ 
				Len(@Parametro) * (@FactorID + 1)	+ 
				Ascii(SUBSTRING(@Parametro, 1, 1)) 	+ 
				Ascii(SUBSTRING(@Parametro, 1, 1)) 	+ 
				Len(@Parametro) 			+ 
				Len(@Parametro) + (DATEPART(Second, GETDATE()) * (@FactorID + 1)) + 
				IsNull(Ascii(Substring(@Parametro, 1, 1)), 0)		+
				IsNull(Ascii(Substring(@Parametro, 2, 1)), 0)		+
				IsNull(Ascii(Substring(@Parametro, 3, 1)), 0)		+
				IsNull(Ascii(Substring(@Parametro, 4, 1)), 0)) % @FactorID as Varchar(2))

Set @ID = 'KRptID_'+ Replace(@ID, '-', 'K')

Declare @CUbicacion	Varchar(1000)
Declare @CClaseCartera Varchar(1000)

Declare @Tabla 		Varchar(50)
Declare @DSelect	Varchar(6000)
Declare @DFrom1		Varchar(6000)
Declare @DFrom2		Varchar(6000)
Declare @DFrom3		Varchar(6000)
Declare @DWhere		Varchar(6000)
Declare @DGroupBy	Varchar(6000)

Declare @OtroDato	Varchar(100)

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 		Out, 	@Ubicacion 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera 		Out, 	@ClaseCartera 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 3, @TipoSaldo, 	@TipoSaldo 		Out, 	@Tabla 		Out,  @OtroDato Out

Exec pCsRptCaDetalleCartera 	@Fecha, @CUbicacion, @Ubicacion, @CClaseCartera, @ClaseCartera, @Tabla,
				@DSelect 	Out,
				@DFrom1		Out,
				@DFrom2		Out,
				@DFrom3		Out,
				@DWhere 	Out,
				@DGroupBy	Out

Set @Indicador = Ltrim(Rtrim(@Indicador))

If Len(@Indicador) = 3 
Begin
	Set @Agrupador 	= 	Case Right(@Indicador, 1) 
					When 'O' Then 'CodOficina' 
					When 'P' Then 'CodPrestamo' 
					When 'Z' Then 'Zona'
					When 'A' Then 'CodAsesor'
					Else '' 
				End
	Set @Indicador 	= Substring(@Indicador, 1, 2)	
End

If @Indicador = 'DD' -- Combinacion Saldos con Dias de Atraso, 
Begin
	Set @DWhere = @DWhere + ' AND (tCsCartera.CodTipoCredito IN (' + @Cartera + ')) '
End
Else
Begin
	Set @DWhere = @DWhere + ' AND (tCsCartera.NroDiasAtraso >= '+ Cast(@DI as Varchar(10)) +') AND (tCsCartera.NroDiasAtraso <= '+ Cast(@DF as Varchar(10)) +') AND (tCsCartera.CodTipoCredito IN (' + @Cartera + ')) '
End

Set @cReserva = Upper(Ltrim(Rtrim(@CReserva)))

If @CReserva <> '' and @CReserva <> 'TODAS'
Begin
	Set @DWhere = @DWhere + ' AND (tCsCarteraDet.IReserva = '''+ @CReserva +''')'
End 

Create Table #Saldo (Valor [decimal](18,4) null)

If @Garantia In (0, 1)
Begin
	Set @DGroupBy = @DGroupBy + ')Datos Where TieneGarantia = '+ Cast(@Garantia as Varchar(1)) +  ' '
	If @Indicador = 'DD'
	Begin
		Set @DGroupBy = @DGroupBy + 'AND (Dias >= '+ Cast(@DI as Varchar(10)) +') AND (Dias <= '+ Cast(@DF as Varchar(10)) +')' 
		Set @Indicador = 'SD'
	End
End
Else
Begin
	Set @DGroupBy = @DGroupBy + ')Datos '
	If @Indicador = 'DD'
	Begin
		Set @DGroupBy = @DGroupBy + 'Where (Dias >= '+ Cast(@DI as Varchar(10)) +') AND (Dias <= '+ Cast(@DF as Varchar(10)) +')' 
		Set @Indicador = 'SD'
	End

End

Print 'Indicador : ' + @Indicador

Print '@DSelect :' + Isnull(@DSelect, 'Nulo') 
Print '@DFrom1 :' + Isnull(@DFrom1, 'Nulo') 
Print '@DFrom2 :' + Isnull(@DFrom2, 'Nulo') 
Print '@DFrom3 :' + Isnull(@DFrom3, 'Nulo')
Print '@DWhere :' + Isnull(@DWhere, 'Nulo') 
Print '@DGroupBy :' + Isnull(@DGroupBy, 'Nulo')

Print 'Indicador : ' + @Indicador
Print '@TipoSaldo :' + Isnull(@TipoSaldo, 'Nulo')
Print '@Agrupador :' + @Agrupador
--/*
If @Indicador = 'SD' -- Saldos
Begin	
	if(@TipoSaldo='DevengadoMes')
		begin
		--@CUbicacion
		--@fecha

		create table #detdev(
		  CodPrestamo varchar(25), 
		  CodUsuario varchar(25),
		  DevengadoMes decimal(18,4)
		)
		
		insert into #detdev
		SELECT CodPrestamo, CodUsuario, SUM(InteresDevengado) AS DevengadoMes
		FROM tCsCarteraDet AS tCsCarteraDet_2 WITH (nolock)
		WHERE (Fecha >= (select primerdia from tClPeriodo WITH (nolock) where ultimodia=@fecha )) AND (Fecha <= @fecha)
		GROUP BY CodPrestamo, CodUsuario
		
		declare @tmpcad varchar(4000)
		set @tmpcad = 'Insert Into #Saldo (Valor) '
		set @tmpcad = @tmpcad + 'Select Sum(DevengadoMes) as Saldo From ( '
		set @tmpcad = @tmpcad + 'SELECT tCsCarteraDet_1.CodPrestamo, tCsCarteraDet_1.CodUsuario, CASE WHEN tCsCartera.Estado = ''VENCIDO'' AND tCsRenegociadosVigentes.CodPrestamo IS NULL '
		set @tmpcad = @tmpcad + 'THEN tCaProdPerTipoCredito.NroDiasSuspenso WHEN tCsRenegociadosVigentes.CodPrestamo IS NULL AND '
		set @tmpcad = @tmpcad + 'tCsCartera.NroDiasAtraso < tCaProdPerTipoCredito.NroDiasSuspenso AND tCsCartera.TipoReprog NOT IN (''SINRE'') '
		set @tmpcad = @tmpcad + 'THEN tCaProdPerTipoCredito.NroDiasSuspenso WHEN tCsRenegociadosVigentes.CodPrestamo IS NOT NULL AND '
		set @tmpcad = @tmpcad + 'tCsRenegociadosVigentes.Registro > '''+dbo.fduFechaAtexto(@fecha, 'AAAAMMDD')+''' THEN tCaProdPerTipoCredito.NroDiasSuspenso ELSE tCsCartera.NroDiasAtraso END AS Dias, '
		set @tmpcad = @tmpcad + 'Devengado.DevengadoMes , ISNULL(Garantias.TieneGarantia, 0) AS TieneGarantia '
		set @tmpcad = @tmpcad + 'FROM tCsCartera WITH (nolock) '
		set @tmpcad = @tmpcad + 'LEFT OUTER JOIN (SELECT Fecha, Codigo, SUM(Garantia) AS Garantia, 1 AS TieneGarantia '
		set @tmpcad = @tmpcad + 'FROM tCsDiaGarantias WITH (nolock) '
		set @tmpcad = @tmpcad + 'WHERE (Fecha = '''+dbo.fduFechaAtexto(@fecha, 'AAAAMMDD')+''') AND (Estado NOT IN (''INACTIVO'')) '
		set @tmpcad = @tmpcad + 'GROUP BY Fecha, Codigo) AS Garantias ON tCsCartera.Fecha = Garantias.Fecha AND tCsCartera.CodPrestamo = Garantias.Codigo '
		set @tmpcad = @tmpcad + 'RIGHT OUTER JOIN tCsRenegociadosVigentes WITH (nolock) '
		set @tmpcad = @tmpcad + 'RIGHT OUTER JOIN #detdev AS Devengado '
		set @tmpcad = @tmpcad + 'RIGHT OUTER JOIN (SELECT tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCarteraDet.CodUsuario,tCsCarteraDet.CodOficina '
		set @tmpcad = @tmpcad + 'FROM tCsCarteraDet AS tCsCarteraDet WITH (nolock) LEFT OUTER JOIN '
		set @tmpcad = @tmpcad + 'tCsPadronCarteraDet WITH (nolock) ON tCsCarteraDet.CodPrestamo = tCsPadronCarteraDet.CodPrestamo AND '
		set @tmpcad = @tmpcad + 'tCsCarteraDet.CodUsuario = tCsPadronCarteraDet.CodUsuario '
		set @tmpcad = @tmpcad + 'WHERE (tCsCarteraDet.Fecha = '''+dbo.fduFechaAtexto(@fecha, 'AAAAMMDD')+''')) AS tCsCarteraDet_1 '
		set @tmpcad = @tmpcad + 'ON Devengado.CodPrestamo = tCsCarteraDet_1.CodPrestamo AND '
		set @tmpcad = @tmpcad + 'Devengado.CodUsuario = tCsCarteraDet_1.CodUsuario ON tCsRenegociadosVigentes.CodPrestamo = tCsCarteraDet_1.CodPrestamo ON '
		set @tmpcad = @tmpcad + 'tCsCartera.Fecha = tCsCarteraDet_1.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet_1.CodPrestamo '
		set @tmpcad = @tmpcad + 'LEFT OUTER JOIN tCaProdPerTipoCredito with(nolock) ON tCsCartera.CodTipoCredito = tCaProdPerTipoCredito.CodTipoCredito '
		set @tmpcad = @tmpcad + 'WHERE (tCsCartera.Cartera IN (''ACTIVA'')) AND (tCsCarteraDet_1.Fecha = '''+dbo.fduFechaAtexto(@fecha, 'AAAAMMDD')+''') AND (tCsCarteraDet_1.CodOficina IN ('+@CUbicacion+')) AND '
		set @tmpcad = @tmpcad + '(tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE + tCsCartera.SaldoINPE + tCsCartera.CargoMora + tCsCartera.OtrosCargos + tCsCartera.Impuestos '
		set @tmpcad = @tmpcad + '> 0) AND (tCsCartera.CodTipoCredito IN (1)) '
		set @tmpcad = @tmpcad + ')Datos Where TieneGarantia = 0 AND (Dias >= 0) AND (Dias <= 0) '
		exec(@tmpcad)
		
		drop table #detdev


		end
	else
		begin
	Exec ('Insert Into #Saldo (Valor) Select Sum('+ @TipoSaldo +') as Saldo From (' + @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy)
	If Rtrim(Ltrim(@Agrupador))  <> ''
	Begin
		Delete From KRptID_Tabla Where Tabla = @ID And Parametro = @Parametro 
		Set @TipoSaldo	= 'INSERT INTO KRptID_Tabla Select Fecha, Parametro = ''' + @Parametro + ''', Tabla = ''' + @ID + ''', Hora = Getdate(), ' + @Agrupador + ' as Agrupado, Cuenta = ''' + @Parametro + ''', Signo = ''+'', Debe = 0, Haber = Sum('+ @TipoSaldo +'), Saldo = Sum('+ @TipoSaldo +') From ('
		Set @DGroupBy 	= @DGroupBy + ' GROUP BY Fecha, ' + @Agrupador
		Exec (@TipoSaldo + @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy)
	End
		end
End

If @Indicador = 'CL' -- Clientes
Begin
	Exec ('Insert Into #Saldo (Valor) SELECT COUNT(*) AS Datos FROM (SELECT DISTINCT codusuario FROM (' + @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy + ')Datos')
End

If @Indicador = 'CU' -- Prestamos
Begin
	Exec ('Insert Into #Saldo (Valor) SELECT COUNT(*) AS Datos FROM (SELECT DISTINCT CodPrestamo FROM (' + @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy + ')Datos')
End

If @Indicador = 'RE' -- Registros
Begin
	Exec ('Insert Into #Saldo (Valor) SELECT COUNT(*) AS Datos FROM (SELECT DISTINCT Registro FROM (' + @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy + ')Datos')
End

If @Indicador = 'FE'
Begin
	Print @Dwhere	

	Set @Cadena = 'Insert Into #Saldo (Valor) SELECT DISTINCT PReservaCapital / 100 '
	Set @Cadena = @Cadena + 'FROM (SELECT DISTINCT tCsCarteraDet.PReservaCapital, ISNULL(Garantia.TieneGarantia, 0) AS Tienegarantia '
	Set @Cadena = @Cadena + 'FROM tCsCarteraDet with(nolock) INNER JOIN '
	Set @Cadena = @Cadena + 'tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN '
	Set @Cadena = @Cadena + '(SELECT Fecha, Codigo, SUM(Garantia) AS Garantia, 1 AS TieneGarantia '
	Set @Cadena = @Cadena + 'FROM tCsDiaGarantias with(nolock) '
	Set @Cadena = @Cadena + 'WHERE (Fecha = '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') AND (Estado NOT IN (''INACTIVO'')) '
	Set @Cadena = @Cadena + 'GROUP BY Fecha, Codigo) Garantia ON tCsCartera.Fecha = Garantia.Fecha AND ' 
	Set @Cadena = @Cadena + 'tCsCartera.CodPrestamo = Garantia.Codigo COLLATE Modern_Spanish_CI_AI '+ @DWhere + @DGroupBy 
	
	Exec(@Cadena)
	Set @Valor1 = 0
	Select @Valor1 = Isnull(Valor,0) From #Saldo
	Truncate Table #Saldo
		
	Exec ('Insert Into #Saldo (Valor) Select Sum('+ @TipoSaldo +')  as Saldo From (' + @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy)
End

--*/ Insert Into #Saldo (Valor) Values(0)
Set @Valor = 0
Select @Valor = Isnull(Valor,0) * @Valor1 From #Saldo

Print @ID
Print @Valor

Drop Table #Saldo
GO