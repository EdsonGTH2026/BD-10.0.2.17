SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pXaCaLIQUINacioRenovadoPorSucursal]
	(@CodOficinas AS VARCHAR(2000))
AS
SET NOCOUNT ON
--CUM 2021.12.12 se colocan diferentes resultados dependiendo si consultan una sucursal, regiones o todo.
--CUM 2021.12.10 se quitan liquidados mayores a 15 dias y se cambia el porcentaje sobre el numero, estaba sobre monto

--declare @CodOficinas AS VARCHAR(2000)
------set @CodOficinas = '6'--'302,03,304,315,321,324,327,332,341,342,41,442,447,452,453,'--'4,5,6,15,21'
--set @CodOficinas='21,342,336,310,434,4,436,318,303,332,25,327,309,41,334,307,315,344,333,330,438,311,322,6,28,5,8,323,308,431,326,302,3,335,341,37,324,304,33,320,339,321,301,15,325,441,432,433,337,442,447,439,454,435,448,453,455,456,457,501,452,460,462,459,461,458,999'

declare @num int
SELECT @num=count(codigo) FROM dbo.fduTablaValores(@CodOficinas)
--select @num
DECLARE @fecha SMALLDATETIME
SELECT @fecha = fechaconsolidacion FROM vcsfechaconsolidacion

CREATE TABLE #Ca(
	item INT IDENTITY(1,1),
	fecini SMALLDATETIME,
	fecfin SMALLDATETIME,
	fila VARCHAR(200),
	Nro INT,
	Monto MONEY,
	NroRenovado INT,	
	MntoRenovado MONEY,
	PorRenovado MONEY,
	NroNorenovado INT,
	MntoNorenovado MONEY,
	PorNoRenovado MONEY)

DECLARE @fecini SMALLDATETIME
DECLARE @fecfin SMALLDATETIME

SET @fecini = dbo.fdufechaaperiodo(@fecha) + '01'
SET @fecfin = @fecha

DECLARE @fecfinuno SMALLDATETIME
SET @fecfinuno = @fecfin + 1

CREATE TABLE #padron(
	codprestamo VARCHAR(25),
	codusuario VARCHAR(15),
	cancelacion SMALLDATETIME,
	monto MONEY,
	codproducto VARCHAR(3),
	codoficina VARCHAR(4))

INSERT INTO #padron
EXEC [10.0.2.14].Finmas.dbo.pXaCaLIQUINacioRenovado_Liq_PorSucursal @fecfinuno, @CodOficinas

UPDATE #padron
SET codusuario = p.codusuario
FROM tcspadronclientes p WITH (NOLOCK)
INNER JOIN #padron x ON x.codusuario = p.codorigen

INSERT INTO #padron
SELECT codprestamo, codusuario, cancelacion, monto, codproducto, codoficina
FROM tcspadroncarteradet WITH (NOLOCK)
WHERE cancelacion >= @fecini AND cancelacion <= @fecfin
AND (codgrupo NOT IN('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') OR codgrupo IS NULL)
AND codoficina NOT IN('97','230','231','98')
AND CodOficina IN (SELECT codigo FROM dbo.fduTablaValores(@CodOficinas))

--select p.codprestamo,c.nrodiasatraso
----delete from #padron
--from #padron p with(nolock)
--inner join tcspadroncarteradet pd with(nolock) on p.codprestamo=pd.codprestamo
--inner join tcscartera c with(nolock) on c.codprestamo=pd.codprestamo and c.fecha=pd.fechacorte
--where c.nrodiasatraso>15

--select p.codprestamo,c.nrodiasatraso
delete from #padron
from #padron p with(nolock)
inner join tcspadroncarteradet pd with(nolock) on p.codprestamo=pd.codprestamo
inner join tcscartera c with(nolock) on c.codprestamo=pd.codprestamo and c.fecha=pd.fechacorte
--where c.nrodiasatraso>15
where c.nrodiasmax>15

--select * from tcscartera where codprestamo='021-170-06-00-04015' order by fecha desc

CREATE TABLE #desem(
	codprestamo VARCHAR(25),
	codproducto VARCHAR(3),
	codusuario VARCHAR(15),
	nuevomonto MONEY,
	nuevodesembolso SMALLDATETIME)

INSERT INTO #desem
EXEC [10.0.2.14].Finmas.dbo.pXaCaLIQUINacioRenovado_Des_PorSucursal @fecfinuno, @CodOficinas

UPDATE #desem
SET codusuario = p.codusuario
FROM tcspadronclientes p WITH (NOLOCK)
INNER JOIN #desem x ON x.codusuario = p.codorigen

INSERT INTO #desem
SELECT codprestamo, codproducto, codusuario, monto nuevomonto, desembolso nuevodesembolso
FROM tcspadroncarteradet WITH (NOLOCK)
WHERE desembolso >= @fecini AND desembolso <= @fecha

if(@num=1)
	begin
		--Sucursal unica se muestra por promotor
		INSERT INTO #Ca (fecini, fecfin, fila, Nro, Monto, NroRenovado, MntoRenovado, NroNorenovado, MntoNorenovado)
		SELECT @fecini, @fecfin--, o.nomoficina--z.nombre
		,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinadorEstado
		, count(p.codprestamo) Nro, sum(p.monto) Monto,
			SUM(CASE WHEN cr.nuevodesembolso IS NOT NULL THEN --1 
				CASE WHEN dbo.fdufechaaperiodo(p.cancelacion) = dbo.fdufechaaperiodo(cr.nuevodesembolso) THEN 1 ELSE 0 END
				ELSE 0 END) NroRenovado,
			SUM(CASE WHEN cr.nuevodesembolso IS NOT NULL THEN --1 
				CASE WHEN dbo.fdufechaaperiodo (p.cancelacion) = dbo.fdufechaaperiodo(cr.nuevodesembolso) THEN cr.nuevomonto ELSE 0 END
				ELSE 0 END) MntoRenovado,
			SUM(CASE WHEN cr.nuevodesembolso IS NULL THEN 1 ELSE 0 END) NroNorenovado,
			SUM(CASE WHEN cr.nuevodesembolso IS NULL THEN p.monto ELSE 0 END) MntoNorenovado
		FROM #padron p WITH (NOLOCK)
		LEFT OUTER JOIN tCsPadronCarteradet pd WITH (NOLOCK) ON pd.codprestamo = p.codprestamo
		LEFT OUTER JOIN (
			SELECT codprestamo, codproducto, codusuario, nuevomonto, nuevodesembolso FROM #desem) cr 
			ON cr.codusuario = p.codusuario AND cr.nuevodesembolso >= p.cancelacion
			--AND cr.codproducto = (CASE WHEN p.codproducto ='370' THEN '370' ELSE '170' END)
		left outer join tcsempleadosfecha e with(nolock) on e.codusuario=pd.ultimoasesor and e.fecha=pd.fechacorte
		left outer join tcspadronclientes co with(nolock) on co.codusuario=e.codusuario
		INNER JOIN tcloficinas o WITH (NOLOCK) ON o.codoficina = p.codoficina
		INNER JOIN tclzona z WITH (NOLOCK) ON z.zona = o.zona
		WHERE z.zona <> 'ZSC'
		GROUP BY --o.nomoficina--z.nombre
		case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end
	end
else
	begin
		if(@num>=67) --> Aqui cambiar por el numero maximo se sucursales en una region
			begin
				INSERT INTO #Ca (fecini, fecfin, fila, Nro, Monto, NroRenovado, MntoRenovado, NroNorenovado, MntoNorenovado)
				SELECT @fecini, @fecfin, z.nombre
				, count(p.codprestamo) Nro, sum(p.monto) Monto,
					SUM(CASE WHEN cr.nuevodesembolso IS NOT NULL THEN --1 
						CASE WHEN dbo.fdufechaaperiodo(p.cancelacion) = dbo.fdufechaaperiodo(cr.nuevodesembolso) THEN 1 ELSE 0 END
						ELSE 0 END) NroRenovado,
					SUM(CASE WHEN cr.nuevodesembolso IS NOT NULL THEN --1 
						CASE WHEN dbo.fdufechaaperiodo (p.cancelacion) = dbo.fdufechaaperiodo(cr.nuevodesembolso) THEN cr.nuevomonto ELSE 0 END
						ELSE 0 END) MntoRenovado,
					SUM(CASE WHEN cr.nuevodesembolso IS NULL THEN 1 ELSE 0 END) NroNorenovado,
					SUM(CASE WHEN cr.nuevodesembolso IS NULL THEN p.monto ELSE 0 END) MntoNorenovado
				FROM #padron p WITH (NOLOCK)
				--LEFT OUTER JOIN tCsPadronCarteraSecuen s WITH (NOLOCK) ON s.codprestamo = p.codprestamo
				LEFT OUTER JOIN (
					SELECT codprestamo, codproducto, codusuario, nuevomonto, nuevodesembolso FROM #desem) cr 
					ON cr.codusuario = p.codusuario AND cr.nuevodesembolso >= p.cancelacion
					--AND cr.codproducto = (CASE WHEN p.codproducto ='370' THEN '370' ELSE '170' END)
				INNER JOIN tcloficinas o WITH (NOLOCK) ON o.codoficina = p.codoficina
				INNER JOIN tclzona z WITH (NOLOCK) ON z.zona = o.zona
				WHERE z.zona <> 'ZSC'
				GROUP BY z.nombre
			end
		else
			begin --Son muchas sucursales se muestra por region
				--Son regiones se selecciona por sucursal
				INSERT INTO #Ca (fecini, fecfin, fila, Nro, Monto, NroRenovado, MntoRenovado, NroNorenovado, MntoNorenovado)
				SELECT @fecini, @fecfin, o.nomoficina--z.nombre
				, count(p.codprestamo) Nro, sum(p.monto) Monto,
					SUM(CASE WHEN cr.nuevodesembolso IS NOT NULL THEN --1 
						CASE WHEN dbo.fdufechaaperiodo(p.cancelacion) = dbo.fdufechaaperiodo(cr.nuevodesembolso) THEN 1 ELSE 0 END
						ELSE 0 END) NroRenovado,
					SUM(CASE WHEN cr.nuevodesembolso IS NOT NULL THEN --1 
						CASE WHEN dbo.fdufechaaperiodo (p.cancelacion) = dbo.fdufechaaperiodo(cr.nuevodesembolso) THEN cr.nuevomonto ELSE 0 END
						ELSE 0 END) MntoRenovado,
					SUM(CASE WHEN cr.nuevodesembolso IS NULL THEN 1 ELSE 0 END) NroNorenovado,
					SUM(CASE WHEN cr.nuevodesembolso IS NULL THEN p.monto ELSE 0 END) MntoNorenovado
				FROM #padron p WITH (NOLOCK)
				--LEFT OUTER JOIN tCsPadronCarteraSecuen s WITH (NOLOCK) ON s.codprestamo = p.codprestamo
				LEFT OUTER JOIN (
					SELECT codprestamo, codproducto, codusuario, nuevomonto, nuevodesembolso FROM #desem) cr 
					ON cr.codusuario = p.codusuario AND cr.nuevodesembolso >= p.cancelacion
					--AND cr.codproducto = (CASE WHEN p.codproducto ='370' THEN '370' ELSE '170' END)
				INNER JOIN tcloficinas o WITH (NOLOCK) ON o.codoficina = p.codoficina
				INNER JOIN tclzona z WITH (NOLOCK) ON z.zona = o.zona
				WHERE z.zona <> 'ZSC'
				GROUP BY o.nomoficina--z.nombre				
			end
	end
--UPDATE #Ca SET PorRenovado = (MntoRenovado/Monto) * 100, PorNoRenovado = (MntoNoRenovado/Monto) * 100
UPDATE #Ca SET PorRenovado = (cast(NroRenovado as decimal(16,4))/Nro) * 100, PorNoRenovado = (cast(NroNoRenovado as decimal(16,4))/Nro) * 100

SELECT * FROM #Ca

DROP TABLE #Ca
DROP TABLE #padron
DROP TABLE #desem
GO