SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsPrContador
Create Procedure [dbo].[pCsPrContador]
@Fecha		SmallDateTime,
@Tabla 		Varchar(50),
@CInicio	Varchar(50),
@CFin		Varchar(50),
@CAdicional	Varchar(100),
@Valor 		Decimal(18,4) OUTPUT
As

Declare @Cadena	Varchar(4000)
Create Table #Saldo (Valor [decimal](18,4) null)
Set @Cadena = 'SELECT COUNT(*) AS Expr1 '
Set @Cadena = @Cadena  + 'FROM '+ @Tabla +' '
Set @Cadena = @Cadena  + 'WHERE ('+ @CInicio +' <= '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') AND ('+ @CFin +' > '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') OR '
Set @Cadena = @Cadena  + '('+ @CInicio +' <= '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') AND ('+ @CFin +' IS NULL)' + @CAdicional

Exec ('Insert Into #Saldo (Valor) ' +  @Cadena)

Set @Valor = 0
Select @Valor = Isnull(Valor,0) From #Saldo

GO