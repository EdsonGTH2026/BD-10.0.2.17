SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaRptComparacionDesembolso] @perini varchar(6), @perfin varchar(6)  AS
--declare @perini varchar(6)
--declare @perfin varchar(6)
--set @perini = '200905'
--set @perfin = '200906'

--declare @codoficina varchar(600)
--set @codoficina = '3'

CREATE table #tbAux (
	zona varchar(50) ,
	nomoficina varchar (30) ,
	nomasesor varchar (80) ,
	ANoPrestamos int,
	ANoClientes int,
	AMonto decimal(16, 4),
	ANNoPrestamos int,
	ANNoClientes int,
	ANMonto decimal(16, 4),
	BNoPrestamos int,
	BNoClientes int,
	BMonto decimal(16, 4),
	BNNoPrestamos int,
	BNNoClientes int,
	BNMonto decimal(16, 4)
)

declare @fecini smalldatetime
declare @fecfin smalldatetime
--set @fecini = '20090601'
--set @fecfin = '20090630'

declare @csql varchar(4000)

declare @x varchar(1000)
declare @y varchar(1000)

set @x = 'INSERT INTO #tbAux (zona,nomoficina,nomasesor,ANoPrestamos,ANoClientes,AMonto,ANNoPrestamos,ANNoClientes,ANMonto, '
set @x = @x + 'BNoPrestamos,BNoClientes,BMonto,BNNoPrestamos,BNNoClientes,BNMonto) '
set @y = 'SELECT zona, nomoficina,nomasesor,SUM(NoPrestamos) NoPrestamos,SUM(NoClientes) NoClientes,SUM(Monto) Monto, '
set @y = @y + 'SUM(NNoPrestamos) NNoPrestamos,SUM(NNoClientes) NNoClientes,SUM(NMonto) NMonto FROM ( '

declare @a varchar(1000)
declare @b varchar(1000)
declare @c varchar(1000)
declare @d varchar(1000)

set @a = ' SELECT zona,nomoficina,nomasesor,0,0,0,0,0,0,NoPrestamos,NoClientes,Monto,NNoPrestamos,NNoClientes,NMonto from ( '
set @b = 'SELECT tClZona.Nombre zona, ofi.NomOficina,pa.NomAsesor, COUNT(DISTINCT pct.CodPrestamo) AS NoPrestamos, '
set @b = @b + 'COUNT(DISTINCT pct.CodUsuario) AS NoClientes, SUM(cd.MontoDesembolso) AS Monto, 0 NNoPrestamos,0 NNoClientes, 0 NMonto '

set @c = 'SELECT  zona,nomoficina,nomasesor,NoPrestamos,NoClientes,Monto,NNoPrestamos,NNoClientes,NMonto,0,0,0,0,0,0 from ( '
set @d = 'SELECT tClZona.Nombre zona, ofi.NomOficina,pa.NomAsesor,0 NoPrestamos,0 NoClientes, 0 Monto, COUNT(DISTINCT pct.CodPrestamo) AS NNoPrestamos,  '
set @d = @d + 'COUNT(DISTINCT pct.CodUsuario) AS NNoClientes,SUM(cd.MontoDesembolso) AS NMonto '

declare @n int
set @n = 0
DECLARE curperiodos CURSOR FOR 
select primerdia,ultimodia from tclperiodo where periodo in (@perini,@perfin)
order by primerdia desc
OPEN curperiodos

FETCH NEXT FROM curperiodos 
INTO @fecini, @fecfin
		
WHILE @@FETCH_STATUS = 0
BEGIN
	set @n = @n + 1
	set @csql = @x
	if(@n=1)	set @csql = @csql +  @a
	else	set @csql = @csql + @c
	set @csql = @csql + @y
	set @csql = @csql + @b
	set @csql = @csql + 'FROM tCsCarteraDet cd with(nolock) INNER JOIN tCsPadronCarteraDet pct with(nolock) ON cd.CodPrestamo = pct.CodPrestamo AND '
	set @csql = @csql + 'cd.CodUsuario = pct.CodUsuario AND cd.Fecha = pct.FechaCorte INNER JOIN tCsCartera with(nolock) ON cd.Fecha = '
	set @csql = @csql + 'tCsCartera.Fecha AND cd.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN tCsPadronAsesores pa with(nolock) '
	set @csql = @csql + 'ON tCsCartera.CodAsesor = pa.CodAsesor LEFT OUTER JOIN tClOficinas ofi with(nolock) ON pct.CodOficina = '
	set @csql = @csql + 'ofi.CodOficina INNER JOIN tClZona with(nolock) ON tClZona.Zona = ofi.Zona WHERE '
	set @csql = @csql + '(pct.Desembolso >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') AND '
	set @csql = @csql + ' (pct.Desembolso <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''')  '
--	set @csql = @csql + ' AND  (cd.CodOficina  in( '+@codoficina+')) '
	set @csql = @csql + ' GROUP BY tClZona.Nombre,ofi.NomOficina, pa.NomAsesor '
	set @csql = @csql + ' union '
	set @csql = @csql + @d
	set @csql = @csql + 'FROM tCsCarteraDet cd with(nolock) INNER JOIN tCsPadronCarteraDet pct with(nolock) ON cd.CodPrestamo = pct.CodPrestamo AND '
	set @csql = @csql + 'cd.CodUsuario = pct.CodUsuario AND cd.Fecha = pct.FechaCorte INNER JOIN tCsCartera with(nolock) ON cd.Fecha = '
	set @csql = @csql + 'tCsCartera.Fecha AND cd.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN tCsPadronAsesores pa with(nolock) '
	set @csql = @csql + 'ON tCsCartera.CodAsesor = pa.CodAsesor LEFT OUTER JOIN tClOficinas ofi with(nolock) ON pct.CodOficina = '
	set @csql = @csql + 'ofi.CodOficina INNER JOIN tClZona with(nolock) ON tClZona.Zona = ofi.Zona WHERE '
	set @csql = @csql + '(pct.Desembolso >= '''+dbo.fduFechaAAAAMMDD(@FecIni)+''') AND '
	set @csql = @csql + ' (pct.Desembolso <= '''+dbo.fduFechaAAAAMMDD(@FecFin)+''') AND '
	set @csql = @csql + '  pct.secuenciacliente=1 '
	set @csql = @csql + ' GROUP BY tClZona.Nombre,ofi.NomOficina, pa.NomAsesor '
	set @csql = @csql + ' ) A GROUP BY nomoficina,nomasesor, zona) b '
	print @csql
	exec (@csql)

	FETCH NEXT FROM curperiodos 
	INTO @fecini, @fecfin
	END
CLOSE curperiodos
DEALLOCATE curperiodos

SELECT zona,nomoficina ,nomasesor, ANoPrestamos,ANoClientes ,	AMonto,ANNoPrestamos,ANNoClientes,ANMonto,	
	BNoPrestamos,BNoClientes,BMonto,BNNoPrestamos,BNNoClientes,BNMonto,
BNoPrestamos - ANoPrestamos DNoPrestamos,BNoClientes-ANoClientes DNoClientes,BMonto-AMonto  DMonto ,BNNoPrestamos-ANNoPrestamos DNNoPrestamos,
BNNoClientes-ANNoClientes DNNoClientes,BNMonto-ANMonto DNMonto
FROM (
SELECT zona,nomoficina ,nomasesor, SUM(ANoPrestamos) ANoPrestamos, SUM(ANoClientes) ANoClientes , SUM(AMonto) AMonto, SUM(ANNoPrestamos) ANNoPrestamos, SUM(ANNoClientes) ANNoClientes,SUM(ANMonto) ANMonto,	
SUM(BNoPrestamos) BNoPrestamos,SUM(BNoClientes) BNoClientes,SUM(BMonto) BMonto,SUM(BNNoPrestamos) BNNoPrestamos,SUM(BNNoClientes) BNNoClientes, SUM(BNMonto) BNMonto from (
SELECT zona,nomoficina ,nomasesor ,ANoPrestamos,ANoClientes ,	AMonto,ANNoPrestamos,ANNoClientes,ANMonto,	
	BNoPrestamos,BNoClientes,BMonto,BNNoPrestamos,BNNoClientes,BNMonto 
FROM #tbAux) a
group by zona,nomoficina ,nomasesor) B

drop table #tbAux
GO