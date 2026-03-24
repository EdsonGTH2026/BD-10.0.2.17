SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsDiaGarantias]
@Fecha SmallDateTime
As
--DECLARE @Fecha SmallDateTime
--SET @FECHA = '20150406'
Declare @Cadena Varchar(4000)
--Set @Fecha = '20080928'

DELETE FROM tCsDiaGarantias
Where Fecha = @Fecha

Declare @FechaGarantia SmallDateTime
SELECT @FechaGarantia = FechaConsolidacion
FROM   vCsFechaConsolidacion

IF @FechaGarantia = @Fecha
Begin	
   -- noel - busca duplicados *************************************************
/*
    insert into tCsDiaGarantiasDuplicadasNoel
    SELECT @Fecha, 1, @FechaGarantia, G.Codigo, G.CodOficina, G.TipoGarantia, G.DocPropiedad,count(*)
	FROM   tCsGarantias G with(nolock)
	LEFT JOIN tGaClTipoGarantias TG ON G.TipoGarantia = TG.TipoGarantia
	WHERE  G.EstGarantia <> 'INACTIVO'
    group by G.codigo, G.CodOficina, G.TipoGarantia, G.DocPropiedad
*/
    -- noel - busca duplicados - FIN *******************************************

    Insert Into tCsDiaGarantias
	SELECT Fecha = @Fecha, Referencia = @FechaGarantia, G.Codigo, G.CodOficina, G.TipoGarantia, G.DocPropiedad, 
	       G.MoComercial AS Garantia, TG.DescGarantia, 'SI' AS Formalizada, 'GA' AS Tabla, G.EstGarantia
	FROM   tCsGarantias G with(nolock) 
	LEFT JOIN tGaClTipoGarantias TG with(nolock)  ON G.TipoGarantia = TG.TipoGarantia
	WHERE  G.EstGarantia <> 'INACTIVO'
End 
Else
Begin
	If dbo.fduCalculoFinMes(@Fecha) = 1
		Set @FechaGarantia = @Fecha
	Else
		Set @FechaGarantia = Cast(dbo.fduFechaATexto(@Fecha, 'AAAAMM') + '01' as SmallDateTime) - 1
    -- noel - busca duplicados *************************************************
/*
    insert into tCsDiaGarantiasDuplicadasNoel
	SELECT @Fecha, 2, @FechaGarantia, G.Codigo, G.CodOficina, G.TipoGarantia, G.DocPropiedad, count(*)
	FROM   tCsMesGarantias G with(nolock) 
	LEFT JOIN tGaClTipoGarantias TG ON G.TipoGarantia = TG.TipoGarantia
	WHERE  G.EstGarantia <> 'INACTIVO' And Fecha = @FechaGarantia
    group by G.codigo, G.CodOficina, G.TipoGarantia, G.DocPropiedad
*/
    -- noel - busca duplicados - FIN *******************************************
	Insert Into tCsDiaGarantias
	SELECT Fecha = @Fecha, Referencia = @FechaGarantia, G.Codigo, G.CodOficina, G.TipoGarantia, G.DocPropiedad, 
	       G.MoComercial AS Garantia, TG.DescGarantia, 'SI' AS Formalizada, 'GA' AS Tabla, G.EstGarantia
	FROM   tCsMesGarantias G with(nolock) 
	LEFT JOIN tGaClTipoGarantias TG with(nolock)  ON G.TipoGarantia = TG.TipoGarantia
	WHERE  G.EstGarantia <> 'INACTIVO' And Fecha = @FechaGarantia
End
--POR DEFECTO ESTA EL PRODUCTO 203
/*
Insert Into tCsDiaGarantias
SELECT     tCsCartera.Fecha, @FechaGarantia AS Referencia, tCsPadronCarteraDet.CodPrestamo, tCsCartera.CodOficina, '-A-' AS TipoGarantia, 
                      tCsAhorros.CodCuenta, tCsAhorros.SaldoCuenta, 'AHORRO CONSOLIDADO' AS DescGarantia, 'SI' AS Formalizada, 'AH' AS CodSistema, Estado = 'PENDIENTE'
FROM         tCsCartera INNER JOIN
                     tCsPadronCarteraDet ON tCsCartera.CodPrestamo = tCsPadronCarteraDet.CodPrestamo INNER JOIN
                     tCsAhorros ON tCsPadronCarteraDet.CodUsuario = tCsAhorros.CodUsuario AND tCsCartera.Fecha = tCsAhorros.Fecha
WHERE (tCsCartera.Fecha = @Fecha) AND (tCsCartera.CodProducto IN (SELECT CodProducto FROM  tCaProducto WHERE (GarantiaDPF = 1))) AND (SUBSTRING(tCsAhorros.CodProducto, 1, 3) in ('203'))
--*/

--delete tCsDiaGarantias
----select a.*
--from (
--	Select c.CodPrestamo,AG.Codigo,AG.TipoGarantia,AG.DocPropiedad,AG.Codoficina
--	FROM tCsDiaGarantias AG
--	INNER JOIN tCsCartera C with(nolock) ON AG.Codigo = C.CodSolicitud AND AG.CodOficina = C.CodOficina
--	WHERE  C.Fecha = @FechaGarantia
--	group by c.CodPrestamo,AG.Codigo,AG.TipoGarantia,AG.DocPropiedad,AG.Codoficina
--	having count(AG.Codigo)>1
--) a inner join tCsDiaGarantias g on g.Codigo=a.codigo and g.TipoGarantia=a.TipoGarantia and g.DocPropiedad=a.DocPropiedad and g.Codoficina=a.Codoficina

--UPDATE tCsDiaGarantias
--SET    Codigo = CodPrestamo
--FROM   tCsDiaGarantias AG 
--INNER JOIN tCsCartera C with(nolock) ON AG.Codigo = C.CodSolicitud AND AG.CodOficina = C.CodOficina
--WHERE  C.Fecha = @FechaGarantia
-----NOEL

DELETE FROM tCsDiaGarantias
WHERE EXISTS (
    SELECT * FROM (
        SELECT DG.Fecha, DG.Referencia, DG.Codigo, DG.CodOficina, DG.TipoGarantia, DG.DocPropiedad
        FROM (SELECT Fecha, Referencia, Codigo, DocPropiedad, COUNT(*) AS Contador
              FROM   tCsDiaGarantias with(nolock)
              WHERE  TipoGarantia IN ('GADPF', 'GARAH', '-A-') AND Fecha = @Fecha
              GROUP BY Fecha, Referencia, Codigo, DocPropiedad
              HAVING COUNT(*) > 1
        ) F 
        INNER JOIN tCsDiaGarantias DG with(nolock)  ON F.Fecha = DG.Fecha AND F.Referencia = DG.Referencia AND F.Codigo = DG.Codigo
        WHERE DG.Tabla = 'AH'
    ) Z
    where tCsDiaGarantias.Fecha = Z.Fecha and tCsDiaGarantias.Referencia = z.referencia 
	and tCsDiaGarantias.Codigo = z.codigo and tCsDiaGarantias.CodOficina = z.codoficina 
	and tCsDiaGarantias.TipoGarantia = z.tipogaRantia and tCsDiaGarantias.DocPropiedad 	= z.docpropiedad
)

/* se comenta porque elimina garantias si 2 creditos apuntan a una sola cuenta de ahorro
CREATE TABLE #A (
	[Registro] [int] IDENTITY (1, 1) NOT NULL ,
	[Fecha] [smalldatetime] NOT NULL ,
	[Referencia] [smalldatetime] NOT NULL ,
	[Codigo] [varchar] (25) NOT NULL ,
	[CodOficina] [varchar] (4) NOT NULL ,
	[TipoGarantia] [varchar] (5) NOT NULL ,
	[DocPropiedad] [varchar] (25) NOT NULL ,
	[Tabla] [varchar] (2) NOT NULL 
) 

Insert Into #A 
       (  Fecha,    Referencia,    Codigo,    CodOficina,    TipoGarantia,    DocPropiedad,    Tabla)
SELECT DG.Fecha, DG.Referencia, DG.Codigo, DG.CodOficina, DG.TipoGarantia, DG.DocPropiedad, DG.Tabla
FROM (
    SELECT DocPropiedad, COUNT(*) AS Contador
    FROM   tCsDiaGarantias with(nolock)
    WHERE  Fecha = @Fecha AND TipoGarantia IN ('GADPF', 'GARAH', '-A-')
    GROUP BY DocPropiedad
    HAVING COUNT(*) > 1
) F 
INNER JOIN tCsDiaGarantias DG with(nolock) ON F.DocPropiedad = DG.DocPropiedad
WHERE DG.Fecha = @Fecha AND DG.TipoGarantia IN ('GADPF', 'GARAH', '-A-')
ORDER BY F.DocPropiedad, DG.Tabla

DELETE FROM tCsDiaGarantias
WHERE exists (
    select 1 from (
        SELECT #A.Fecha, #A.Referencia, #A.Codigo, #A.CodOficina, #A.TipoGarantia, #A.DocPropiedad
        FROM (SELECT MAX(Registro) AS Registro, DocPropiedad
              FROM #A 
              GROUP BY DocPropiedad
        ) F
        INNER JOIN #A ON F.Registro <> #A.Registro AND F.DocPropiedad = #A.DocPropiedad
    ) B
    where tCsDiaGarantias.Fecha = B.Fecha and tCsDiaGarantias.Referencia = B.Referencia and tCsDiaGarantias.Codigo = B.Codigo
      and tCsDiaGarantias.CodOficina = B.CodOficina and tCsDiaGarantias.TipoGarantia = B.TipoGarantia and tCsDiaGarantias.DocPropiedad = B.DocPropiedad
) 
--DELETE FROM tCsDiaGarantias
--WHERE CAST(Fecha AS varchar(100)) + CAST(Referencia AS varchar(100)) + Codigo + CodOficina + TipoGarantia + DocPropiedad
--   IN (SELECT CAST(#A.Fecha AS varchar(100)) + CAST(#A.Referencia AS varchar(100)) + #A.Codigo + #A.CodOficina + #A.TipoGarantia + #A.DocPropiedad
--       FROM (SELECT MAX(Registro) AS Registro, DocPropiedad
--             FROM #A
--             GROUP BY DocPropiedad
--       ) F
--       INNER JOIN #A ON F.Registro <> #A.Registro AND F.DocPropiedad = #A.DocPropiedad
--      )

DROP TABLE #A
*/
/*
Declare @CodPrestamo 	Varchar(25)
Declare @Contador	Int
Declare @TipoGarantia 	Varchar(25)
Declare @DocPropiedad 	Varchar(25)

Set @Contador = 0

Declare curFragmento2 Cursor For 
	SELECT D.Codigo
	FROM (
	    SELECT Codigo, MAX(Garantia) AS Garantia
        FROM (SELECT Codigo, TipoGarantia, SUM(Garantia) AS Garantia
              FROM   tCsDiaGarantias with(nolock)
              WHERE  Estado NOT IN ('INACTIVO') AND Fecha = @Fecha
     GROUP BY Codigo, TipoGarantia
        ) X
        GROUP BY Codigo
    ) F 
    INNER JOIN (
        SELECT Codigo, TipoGarantia, SUM(Garantia) AS Garantia
        FROM  tCsDiaGarantias with(nolock)
        WHERE Estado <> 'INACTIVO' AND Fecha = @Fecha
        GROUP BY Codigo, TipoGarantia
    ) D ON F.Codigo = D.Codigo AND F.Garantia = D.Garantia 
    LEFT JOIN tGaClTipoGarantias TG ON D.TipoGarantia = TG.TipoGarantia
	GROUP BY D.Codigo
	HAVING  COUNT(*) > 1

Open curFragmento2
Fetch Next From curFragmento2 Into @CodPrestamo
While @@Fetch_Status = 0
Begin 	
	Declare curFragmento3 Cursor For 
		SELECT TipoGarantia, DocPropiedad
		FROM   tCsDiaGarantias with(nolock)
		WHERE  Fecha = @Fecha AND Codigo = @CodPrestamo AND Estado <> 'INACTIVO'
	Open curFragmento3
	Fetch Next From curFragmento3 Into @TipoGarantia, @DocPropiedad

	While @@Fetch_Status = 0
	Begin 
		Set @Contador = @Contador + 1
		If @Contador % 2 = 1
			Update tCsDiaGarantias
			Set Garantia = Garantia + 0.01
			Where Codigo = @CodPrestamo And Fecha = @Fecha and TipoGarantia = @TipoGarantia and DocPropiedad = @DocPropiedad And Estado <> 'INACTIVO'
		Else
			Update tCsDiaGarantias
			Set Garantia = Garantia - 0.01
			Where Codigo = @CodPrestamo And Fecha = @Fecha and TipoGarantia = @TipoGarantia and DocPropiedad = @DocPropiedad and Estado <> 'INACTIVO'
	    Fetch Next From curFragmento3 Into @TipoGarantia, @DocPropiedad
	End 
	Close 		curFragmento3
	Deallocate 	curFragmento3
    Fetch Next From curFragmento2 Into @CodPrestamo
End 
Close 		curFragmento2
Deallocate 	curFragmento2
*/

--UPDATE tCsAhorros
--SET    engarantia = 1, codprestamo = codigo, Montogarantia = G.Garantia
--FROM   tCsAhorros A
--INNER JOIN tCsDiaGarantias G with(nolock) ON A.Fecha = G.Fecha AND A.CodCuenta = G.DocPropiedad
--WHERE A.Fecha = @Fecha AND G.TipoGarantia IN ('GADPF', 'GARAH', '-A-') AND G.Estado <> 'INACTIVO' AND G.Fecha = @Fecha
GO