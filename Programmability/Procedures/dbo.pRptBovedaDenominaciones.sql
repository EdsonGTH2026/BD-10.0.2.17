SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pRptBovedaDenominaciones]
@CodOficina 	Varchar(4),
@Fecha 		SmallDateTime
--Set @Fecha 	= '20081020'
--Set @CodOficina = '2'
As
Declare @Cadena		Varchar(4000)
Declare @Servidor	Varchar(100)
Declare @BaseDatos	Varchar(50)

Declare @CUbicacion		Varchar(500)
Declare @Ubicacion		Varchar(100)
Declare @OtroDato		Varchar(100)

--Set @Ubicacion = @CodOficina

--Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out

SELECT    @Servidor = Servidor, @BaseDatos = BaseDatos
FROM      tClOficinas
WHERE     Tipo in ('Operativo', 'Matriz', 'Servicio') And CodOficina = @CodOficina

Print 'OFICINA: ' + @CodOficina
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[B]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[B]End
Set @Cadena = 'CREATE TABLE [dbo].[B] ( '
Set @Cadena = @Cadena + '[Cadena] [varchar] (1157) COLLATE Modern_Spanish_CI_AI NULL ' 
Set @Cadena = @Cadena + ') ON [PRIMARY] '

Exec(@Cadena)
Set @Cadena = 'NBTSTAT -a '+ Ltrim(rTrim(@Servidor))
Insert Into B
Exec master..xp_cmdshell @Cadena

SELECT   @Servidor =  RTRIM(LTRIM(SUBSTRING(LTRIM(RTRIM(Cadena)), 1, CHARINDEX('<00>', LTRIM(RTRIM(Cadena)), 1) - 1))) 
FROM         B
WHERE     (Cadena LIKE '%<00>  UNIQUE%') OR (Cadena LIKE '%<00>  Único%')

If @Servidor Is null 
Begin
	Set @Cadena = 'Servidor no Encontrado'
	Select @Cadena as Observacion
End
Else
Begin
	Set @Servidor 	= '[' + @Servidor + '].'	
	
	Set @Cadena 	= 'SELECT Datos.CodOficina, Datos.FechaPro, Datos.CodMoneda, Datos.Tipo, Datos.Corte, SUM(Datos.Cantidad) AS Cantidad, Datos.Corte * SUM(Datos.Cantidad) '
	Set @Cadena 	= @Cadena + 'AS Monto, tClMonedas.DescMoneda, tClOficinas.NomOficina '
	Set @Cadena 	= @Cadena + 'FROM (SELECT CodOficina, FechaPro, CodMoneda, Tipo, Corte, CASE esentradaboveda WHEN 1 THEN Cantidad ELSE - 1 * cantidad END AS Cantidad '
	Set @Cadena 	= @Cadena + 'FROM ' + @Servidor +'['+ @BaseDatos +'].dbo.tTcBovPlaniArqueo tTcBovPlaniArqueo '
	Set @Cadena 	= @Cadena + 'WHERE (FechaPro = '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') AND (Anulada = 0) And CodOficina IN( '+ @CodOficina +')) Datos INNER JOIN '
	Set @Cadena 	= @Cadena + @Servidor +'['+ @BaseDatos +'].dbo.tClOficinas tClOficinas ON Datos.CodOficina COLLATE Modern_Spanish_CI_AI = tClOficinas.CodOficina INNER JOIN '
	Set @Cadena 	= @Cadena + @Servidor +'['+ @BaseDatos +'].dbo.tClMonedas tClMonedas ON Datos.CodMoneda COLLATE Modern_Spanish_CI_AI = tClMonedas.CodMoneda '
	Set @Cadena 	= @Cadena + 'GROUP BY Datos.CodOficina, Datos.FechaPro, Datos.CodMoneda, Datos.Tipo, Datos.Corte, tClMonedas.DescMoneda, tClOficinas.NomOficina '

	Print @Cadena
	Exec  (@Cadena)
					
End
GO