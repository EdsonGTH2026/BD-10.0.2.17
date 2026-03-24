SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Exec pCsRptTransacServicios '20111001', '20111031', '12,14,35', '13,26'

CREATE PROCEDURE [dbo].[pCsRptTransacServicios] 
	@FecIni smalldatetime, 
	@FecFin smalldatetime, 
	@CodOficina varchar(200),
	@codtransac  varchar(200)
AS
BEGIN
set nocount on

--declare @FecIni smalldatetime
--declare @FecFin smalldatetime
--declare @CodOficina varchar(200)

--set @FecIni ='20101101'
--set @FecFin ='20101101'
--set @CodOficina = '1,2,3,4,5,6,7,8,9,10'

Declare @Cadena		Varchar(8000)
Declare @From		Varchar(8000)
Declare @Select		Varchar(8000)
Declare @GroupBy	Varchar(8000)
Declare @Where		Varchar(8000)

Create Table #A
(
	Menor Decimal(18,4) Null,
	Mayor Decimal(18,4) Null
)

SET @Select		= 'Select Menor = SUM(t.montototaltran), Mayor = SUM(t.montototaltran)'

SET @From		= 'From tcstransacciondiaria t inner join tcspadronclientes c on c.codusuario=t.codusuario '
SET @From		= @From + 'Inner join tcloficinas o on o.codoficina=t.codoficina '

SET @Where		= 'WHERE (t.Fecha >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') '
SET @Where		= @Where + 'AND (t.Fecha <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''') '
SET @Where		= @Where + 'AND (t.CodSistema = ''tc'') And t.Extornado=0 '
SET @Where		= @Where + 'AND (t.Codoficina in ('+ @CodOficina +')) '
SET @Where		= @Where + 'AND t.tipotransacnivel3 in ('+ @codtransac +') '

SET @GroupBy	= 'group by  t.descripciontran, t.tipotransacnivel1, t.codoficina '

SET	@Cadena		= 'Insert Into #A  Select  Menor= Min(Menor), Mayor = Max(Mayor) From (' + @Select + @From + @Where + @GroupBy + ')Datos'

Exec (@Cadena)

SET @Select		= 'Select t.fecha,t.codoficina,o.nomoficina,case t.tipotransacnivel1 when ''I'' THEN ''INGRESOS'' WHEN ''E'' '
SET @Select		= @Select + 'THEN ''EGRESOS'' ELSE ''OTROS'' END Tipotransac,t.tipotransacnivel3 codtransac,c.nombrecompleto, '
SET @Select		= @Select + 't.descripciontran transac, t.montototaltran monto,  #A.Menor, #A.Mayor '

SET @From		= @From + 'CROSS JOIN #A '

Exec (@Select + @From + @Where)

Drop Table #A 
set nocount off
END
GO