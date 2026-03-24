SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Considera solo las oficinas mayores a 100

CREATE Procedure [dbo].[pGnlCalculaParametros3]
@Indicador 	Int,
@Valor		Varchar(100),
@Codigo	Varchar(500) OutPut,
@Descripcion	Varchar(500) OutPut,
@OtroDato	Varchar(500) OutPut
As

/*
declare @Indicador 	Int
declare @Valor		Varchar(100)
declare @Codigo	Varchar(1000) 
declare @Descripcion	Varchar(500) 
declare @OtroDato	Varchar(500) 

set @Indicador = 1
set @Valor = 'ZZZ'
*/

Print Isnull(@Indicador, 'Nulo') 
Print isnull(@Valor, 'Nulo')

Declare @Temporal Varchar(100)
If @Indicador = 1 -- Para Oficinas
Begin
	Update tClOficinas
	Set Parametro = 0

	Set @Valor = Ltrim(Rtrim(@Valor))
	If @Valor = 'ZZZ'

	Begin
		Update tClOficinas
		Set Parametro = 1
		Where Tipo in ('Operativo', 'Matriz', 'Servicio','Cerrada')		
		Set @Descripcion = 'Todas las Agencias'
	End
	Else If Substring(@Valor, 1, 1) = 'Z'
	Begin
		Update tClOficinas
		Set Parametro = 1
		Where Tipo in ('Operativo', 'Matriz', 'Servicio','Cerrada') and Zona = @Valor
		SELECT    @Descripcion  = 'Zona ' + Nombre 
		FROM         tClZona
		WHERE     (Zona = @Valor)

	End
	Else
	Begin
		Update tClOficinas
		Set Parametro = 1
		Where Tipo in ('Operativo', 'Matriz', 'Servicio','Cerrada') and CodOficina = @Valor
		print '@Valor:' +@Valor
		SELECT    @Descripcion  = NomOficina
		FROM         tClOficinas
		WHERE     (CodOficina = @Valor)
	print '@Descripcio:' +@descripcion
	End
	Set @Codigo = ''
	Declare CurOficina Cursor For 
		SELECT    CodOficina
		FROM         tClOficinas
		WHERE    (Parametro = 1)	
		and convert(int,CodOficina) > 100 --FILTRO PARA CONCIDERAR SOLO LAS OFICINAS EXTERNAS *OSC 23-01-2016
	
	Open CurOficina
	Fetch Next From CurOficina Into @Temporal
	While @@Fetch_Status = 0
	Begin
		Set @Codigo = @Codigo + @Temporal + ', '
	Fetch Next From CurOficina Into  @Temporal
	End 
	Close 		CurOficina
	Deallocate 	CurOficina

	Set @Codigo = Substring(Ltrim(Rtrim(@Codigo)), 1, Len(Ltrim(Rtrim(@Codigo))) - 1) 
	Set @OtroDato = ''
print '@Codigo:'+@Codigo
print '@OtroDato:'+@OtroDato

End
If @Indicador = 2 -- Para Clase de Cartera.
Begin
	Set @Valor = Ltrim(Rtrim(@Valor))
	If @Valor = 'TODAS'
	Begin
		Set @Descripcion = 'Todas Las Clases de Cartera'
		Set @Codigo = ''
		Declare CurClaseCartera Cursor For 
			SELECT Cartera
			FROM tCaClClaseCartera 
		
		Open CurClaseCartera
		Fetch Next From CurClaseCartera Into @Temporal
		While @@Fetch_Status = 0
		Begin
			Set @Codigo = @Codigo + '''' + @Temporal + ''', '
		Fetch Next From CurClaseCartera Into  @Temporal
		End 
		Close 		CurClaseCartera
		Deallocate 	CurClaseCartera
		Set @Codigo = Substring(Ltrim(Rtrim(@Codigo)), 1, Len(Ltrim(Rtrim(@Codigo))) - 1) 
	End
	Else
	Begin
		SELECT   @Descripcion = Descripcion
		FROM         tCaClClaseCartera
		WHERE     (Cartera = @Valor)
		Set @Codigo = '''' + @Valor + ''''
	End	
	Set @OtroDato = ''
End
If @Indicador = 3 -- Para tipo de Saldo.
Begin
	SELECT     @Codigo = Formula, @Descripcion = Tabla,  @OtroDato = Nombre
	FROM         tCsPrTipoSaldo
	WHERE     (TipoSaldo = @Valor)
End
If @Indicador = 4 -- Para Nivel de Dias de Atraso.
Begin
	SELECT     @Codigo = Formula, @Descripcion = Nombre,  @OtroDato = ''
	FROM         tCsPrNivelDiasAtraso
	WHERE     (NivelDiaAtraso = @Valor)
End
If @Indicador = 5 -- Para tipo de Ahorro
Begin
	Set @Valor = Ltrim(Rtrim(@Valor))
	If @Valor = 'TODAS'
	Begin
		Set @Descripcion = 'Todos los Tipos de Productos'
		Set @Codigo = ''
		Declare CurOficina Cursor For 
			SELECT DISTINCT idTipoProd
			FROM         tAhProductos
		
		Open CurOficina
		Fetch Next From CurOficina Into @Temporal
		While @@Fetch_Status = 0
		Begin
			Set @Codigo = @Codigo + @Temporal + ', '
		Fetch Next From CurOficina Into  @Temporal
		End 
		Close 		CurOficina
		Deallocate 	CurOficina
		Set @Codigo = Substring(Ltrim(Rtrim(@Codigo)), 1, Len(Ltrim(Rtrim(@Codigo))) - 1) 
		Set @OtroDato = ''
	End
	Else
	Begin
		Set @Codigo = @Valor
		SELECT     @Descripcion = DescTipoProd
		FROM         tAhClTipoProducto
		WHERE     (idTipoProd = @Valor)
	End
End
If @Indicador = 6 -- Para Identificar Reporte
Begin
	Set @Valor = Ltrim(Rtrim(@Valor))
	SELECT     @Codigo = tCsPrTipoSaldo.Reporte, @Descripcion = tCsPrReporte.Nombre, @OtroDato = tCsPrReporte.Sistema
	FROM         tCsPrTipoSaldo INNER JOIN
	                      tCsPrReporte ON tCsPrTipoSaldo.Reporte = tCsPrReporte.Reporte AND tCsPrTipoSaldo.Sistema = tCsPrReporte.Sistema
	WHERE     (tCsPrTipoSaldo.TipoSaldo = @Valor)
End
If @Indicador = 7 -- Para tipo de Observaciones de Clientes
Begin
	Set @Valor = Ltrim(Rtrim(@Valor))
	If @Valor = 'TODAS'
	Begin
		Set @Descripcion = 'Todos las Observaciones'
		Set @Codigo = ''
		Declare CurOficina Cursor For 
			SELECT     Observacion
			FROM         tCsClClientesObservaciones
			WHERE     (Activo = 1)
		
		Open CurOficina
		Fetch Next From CurOficina Into @Temporal
		While @@Fetch_Status = 0
		Begin
			Set @Codigo = @Codigo + '''' + @Temporal + ''', '
		Fetch Next From CurOficina Into  @Temporal
		End 
		Close 		CurOficina
		Deallocate 	CurOficina
		Set @Codigo = Substring(Ltrim(Rtrim(@Codigo)), 1, Len(Ltrim(Rtrim(@Codigo))) - 1) 
		Set @OtroDato = ''
	End
	Else
	Begin
		Set @Codigo = @Valor
		SELECT     @Descripcion = Nombre
		FROM         tCsClClientesObservaciones
		WHERE     (Observacion = @Valor)
	End
End



--select '@Codigo: ', @Codigo	
--select '@Descripcion:', @Descripcion	
--select '@OtroDato:', @OtroDato	 



GO