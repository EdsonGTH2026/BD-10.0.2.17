SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsAhAnexosSaldo
CREATE Procedure [dbo].[pCsAhAnexosSaldo]
@Fecha 		SmallDateTime,
@ClaseCartera	Varchar(100),
@TipoSaldo	Varchar(200),
@DI		Int,
@DF		Int,
@MI		Decimal(18,4),
@MF		Decimal(18,4),
@Indicador	Int,
@Valor 		Decimal(18,4) OUTPUT
As


Declare @Ubicacion	Varchar(100)
Set @Ubicacion		= 'ZZZ'


Declare @CUbicacion	Varchar(1000)
Declare @CClaseCartera Varchar(1000)

Declare @Tabla 	Varchar(50)
Declare @DSelect	Varchar(4000)
Declare @DFrom1	Varchar(4000)
Declare @DFrom2	Varchar(4000)
Declare @DFrom3	Varchar(4000)
Declare @DWhere	Varchar(4000)
Declare @DGroupBy	Varchar(4000)
Declare @Temporal	Varchar(4000)

Declare @OtroDato	Varchar(100)

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 		Out, 	@Ubicacion 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 5, @ClaseCartera, 	@CClaseCartera 		Out, 	@ClaseCartera 	Out,  @OtroDato Out
Exec pGnlCalculaParametros 3, @TipoSaldo, 	@TipoSaldo 		Out, 	@Tabla 		Out,  @OtroDato Out

Exec pCsRptCaDetalleCartera 	@Fecha, @CUbicacion, @Ubicacion, @CClaseCartera, @ClaseCartera, @Tabla,
				@DSelect 	Out,
				@DFrom1		Out,
				@DFrom2		Out,
				@DFrom3		Out,
				@DWhere 	Out,
				@DGroupBy	Out

If substring(ltrim(rtrim(cast(@Indicador as varchar(10)))), 1,1) in ('3')
Begin
	Set @Temporal = 'Edad'
End
else If substring(ltrim(rtrim(cast(@Indicador as varchar(10)))), 1,1) in ('5')
Begin
	Set @Temporal = 'EdadT'
End
Else
Begin
	Set @Temporal = 'Dias'
End

Set @Indicador = cast(right(ltrim(rtrim(cast(@Indicador as varchar(10)))),1) as Int)

Set @DGroupBy = @DGroupBy + ') Datos Where ('+ @Temporal +' >= '+ Cast(@DI as Varchar(10)) +') AND ('+ @Temporal +' <= '+ Cast(@DF as Varchar(10)) +') AND ' + @TipoSaldo + ' >= '+ Cast(@MI As varchar(50)) +' AND ' + @TipoSaldo + ' <= '+ Cast(@MF As varchar(50)) +''
Create Table #Saldo (Valor [decimal](18,4) null)

If @Indicador = 0 -- Saldos
Begin
	Set @TipoSaldo	= Replace(@TipoSaldo, '* Integrantes', '')
	Set @DSelect 	= 'Select Sum('+ @TipoSaldo +') as Saldo From (' + @DSelect
End
If @Indicador = 1 -- Cuentas
Begin
	Set @DSelect 	= 'SELECT COUNT(*) AS Cuentas FROM (SELECT DISTINCT CodPrestamo From (' + @DSelect
	Set @DGroupBy 	= @DGroupBy + ') Datos '
End
If @Indicador in (2) -- Clientes
Begin
	Set @DSelect 	= 'SELECT COUNT(*) AS Cuentas FROM (SELECT DISTINCT CodUsuario From (' + @DSelect
	Set @DGroupBy 	= @DGroupBy + ') Datos '
End
If @Indicador in (4) -- Titulares
Begin
	Set @DSelect 	= 'SELECT COUNT(*) AS Cuentas FROM (SELECT DISTINCT Titular From (' + @DSelect
	Set @DGroupBy 	= @DGroupBy + ') Datos '
End

Print @DSelect
Print @DFrom1
Print @DFrom2
Print @DFrom3
Print @DWhere
Print @DGroupBy

Exec ('Insert Into #Saldo (Valor) ' +  @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy)
Set @Valor = 0
Select @Valor = Isnull(Valor,0) From #Saldo

Print @Valor

Drop Table #Saldo
GO