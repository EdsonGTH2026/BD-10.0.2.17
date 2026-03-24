SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsAhAperturas] 
(
	@Ubicacion	Varchar(100),
	@Inicio         SmallDateTime,
	@Fin		SmallDateTime,
	@ClaseCartera   Varchar(100)
)
 AS
set nocount on
--COMENTAR
/*
Declare	@Ubicacion	Varchar(100)
Declare	@Inicio         SmallDateTime
Declare	@Fin		SmallDateTime
Declare	@ClaseCartera   Varchar(100)
set	@Ubicacion='98'
set	@Inicio='20180701'
set	@Fin='20180731'
set	@ClaseCartera='2'
*/

Declare @OtroDato		Varchar(100)
Declare @CClaseCartera		Varchar(500)
Declare @CUbicacion		Varchar(2000)
Declare @CCartera	        Varchar(500)

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out 
Exec pGnlCalculaParametros 5, @ClaseCartera, 	@CClaseCartera Out, 	@ClaseCartera 	Out,  @OtroDato Out

--pRINT @CClaseCartera
Declare @Cadena Varchar(8000)

Set @Cadena = 'SELECT TipoProducto = '''+ dbo.fduRellena(' ', @ClaseCartera, 60, 'I') +''',Ubicacion='''+ dbo.fduRellena(' ', @Ubicacion, 60, 'I') +''',Zona = dbo.fduRellena(''0'', tClZona.Orden, ''2'', ''D'') + tClOficinas.Zona '
Set @Cadena = @Cadena + ',tClZona.Nombre as Region, p.CodProducto,tAhProductos.nombre as Producto, p.CodOficina, tClOficinas.NomOficina, p.CodCuenta '
Set @Cadena = @Cadena + ',tAhClEstadoCuenta.descripcion, tCsPadronClientes.NombreCompleto as Nombre, p.Renovado '
Set @Cadena = @Cadena + ',a.saldocuenta MonApertura, p.MonApertura as MonApertura2 '
Set @Cadena = @Cadena + ',(a.saldocuenta - p.MonApertura) as RenInterna,'
Set @Cadena = @Cadena + ' case (a.saldocuenta - p.MonApertura)'
Set @Cadena = @Cadena + ' when 0 then 0 '
Set @Cadena = @Cadena + ' else p.MonApertura'
Set @Cadena = @Cadena + ' end as Aumento'
Set @Cadena = @Cadena + ' ,p.FecApertura,tAhProductos.idTipoProd, tAhClTipoProducto.DescTipoProd,a.Plazo, a.TasaInteres,a.FechaVencimiento '
Set @Cadena = @Cadena + 'FROM tClOficinas with(nolock) INNER JOIN tClZona  with(nolock) ON tClOficinas.zONA= tClZona.zONA '
Set @Cadena = @Cadena + 'INNER JOIN tCsPadronAhorros p with(nolock) inner join tAhClEstadoCuenta with(nolock) on tAhClEstadoCuenta.idEstadoCta=p.EstadoCalculado '
Set @Cadena = @Cadena + 'INNER JOIN tCsPadronClientes with(nolock) on p.codUsuario = tCsPadronClientes.codUsuario '
Set @Cadena = @Cadena + 'INNER JOIN tAhProductos with(nolock) ON tAhProductos.idProducto = p.CodProducto ON p.CodOficina = tClOficinas.CodOficina '
Set @Cadena = @Cadena + 'INNER JOIN tAhClTipoProducto with(nolock) ON tAhProductos.idTipoProd = tAhClTipoProducto.idTipoProd '
Set @Cadena = @Cadena + 'inner join tcsahorros a with(nolock) on a.codcuenta=p.codcuenta and a.fraccioncta=p.fraccioncta and a.renovado=p.renovado and a.fecha=p.fecapertura '
Set @Cadena = @Cadena + 'WHERE (p.FecApertura >= '''+ dbo.fduFechaATexto(@Inicio, 'AAAAMMDD') +''') AND '
Set @Cadena = @Cadena + '(p.FecApertura <= '''+ dbo.fduFechaAtexto(@Fin, 'AAAAMMDD') +''') '
Set @Cadena = @Cadena + 'And (SUBSTRING(p.CodProducto, 1, 1) IN ('+ @CClaseCartera + ')) AND p.CodOficina in ('+ @CUbicacion +') order by p.FecApertura ' 
--Print @Cadena

Exec (@Cadena)

GO