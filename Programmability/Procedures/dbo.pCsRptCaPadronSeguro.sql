SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Drop Procedure pCsRptCaPadronSeguro
CREATE Procedure [dbo].[pCsRptCaPadronSeguro]
@Fecha 		SmallDateTime,
@Ubicacion		Varchar(100),	
@ClaseCartera		Varchar(100),
@DI			Int,
@DF			Int 
As
--Set @Fecha 		= '20080831'
--Set @ClaseCartera 	= 'CASTIGADA' 

Declare @TipoSaldo	Varchar(1000)

Declare @Cadena	Varchar(4000)
Declare @Cadena1	Varchar(4000)
Declare @Cadena2	Varchar(4000)
Declare @Cadena3	Varchar(4000)
Declare @Cadena4	Varchar(4000)
Declare @CDetalle1 	Varchar(4000)
Declare @CDetalle2 	Varchar(4000)
Declare @CDetalle3 	Varchar(4000)

Declare @CUbicacion		Varchar(500)
Declare @CClaseCartera 	Varchar(500)

Declare @Tabla 		Varchar(50)
Declare @DSelect		Varchar(4000)
Declare @DFrom1		Varchar(4000)
Declare @DFrom2		Varchar(4000)
Declare @DFrom3		Varchar(4000)
Declare @DWhere		Varchar(4000)
Declare @DGroupBy		Varchar(4000)

Declare @OtroDato		Varchar(100)
Declare @CDato 		Varchar(100)

Declare @SaldoCapital 		Varchar(1000)
Declare @SaldoCartera		Varchar(1000)
Declare @DeudaTotal		Varchar(1000)

--Set @Ubicacion 	= 'ZZZ'


Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera Out, 	@ClaseCartera 	Out,  @OtroDato Out

Set @TipoSaldo		= '02'	
Exec pGnlCalculaParametros 3, @TipoSaldo, 	@TipoSaldo 	Out, 	@Tabla 	Out,  @OtroDato Out
Set @SaldoCapital	= @TipoSaldo

Set @TipoSaldo		= '01'	
Exec pGnlCalculaParametros 3, @TipoSaldo, 	@TipoSaldo 	Out, 	@Tabla 	Out,  @OtroDato Out
Set @SaldoCartera	= @TipoSaldo

Set @TipoSaldo		= '03'	
Exec pGnlCalculaParametros 3, @TipoSaldo, 	@TipoSaldo 	Out, 	@Tabla 	Out,  @OtroDato Out
Set @DeudaTotal	= @TipoSaldo

Exec pCsRptCaDetalleCartera 	@Fecha, @CUbicacion, @Ubicacion, @CClaseCartera, @ClaseCartera, @Tabla,
				@DSelect 	Out,
				@DFrom1	Out,
				@DFrom2	Out,
				@DFrom3	Out,
				@DWhere 	Out,
				@DGroupBy	Out

Set @Cadena = 'SELECT Ubicacion =  '''+ @Ubicacion +''' ,ClaseCartera, Fecha, NCliente, Datos.CodPrestamo, RFC, ' 
Set @Cadena = @Cadena +  'SaldoSeguro.DeudaTotal * (Datos.Desembolso / SaldoSeguro.Desembolso) AS DeudaTotal, Estado, Asesor, Tecnologia, TipoCredito, '
Set @Cadena = @Cadena +  'FechaDesembolso, Datos.Desembolso, NroCuotas, NroCuotasPagadas, TipoReprog,  '
Set @Cadena = @Cadena +  'NroDiasAtraso, ProximoVencimiento, '+ @SaldoCapital +' As SaldoCapital, '+ @SaldoCartera +' As SaldoCartera  FROM ( '

Set @Cadena1 = ') Datos INNER JOIN (SELECT CodPrestamo, SUM(' + @DeudaTotal + ') AS DeudaTotal, Desembolso = SUM(montoDesembolso) FROM tCsCarteraDet '
Set @Cadena1 = @Cadena1 + 'WHERE (Fecha = '''+ dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') +''') GROUP BY CodPrestamo) SaldoSeguro ON Datos.CodPrestamo '
Set @Cadena1 = @Cadena1 + '= SaldoSeguro.CodPrestamo Where NroDiasAtraso >= '+ Cast(@DI as Varchar(10)) +' AND NroDiasAtraso <= '+ Cast(@DF as Varchar(10))
Print @Cadena + @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy + @Cadena1
Exec (@Cadena + @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy + @Cadena1)
GO