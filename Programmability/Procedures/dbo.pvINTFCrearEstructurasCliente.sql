SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pvINTFCrearEstructurasCliente] as
set nocount on
--01:15 

UPDATE    tCsPadronClientes
SET              DireccionDirFamPri = REPLACE(DireccionDirFamPri, 'S/N', 'SIN NUMERO')
WHERE     (DireccionDirFamPri LIKE '%S/N%')

UPDATE    tCsPadronClientes
SET              DireccionDirNegPri = REPLACE(DireccionDirNegPri, 'S/N', 'SIN NUMERO')
WHERE     (DireccionDirNegPri LIKE '%S/N%')

UPDATE    tCsPadronClientes
SET DireccionDirFamPri = 
    left(
        REPLACE(
            LTRIM(
                RTRIM(
                    SUBSTRING(
                        DireccionDirFamPri, 1, 
                        case when CHARINDEX('DOMICILIO', DireccionDirFamPri, 1) = 0
                             then 1000
                             else CHARINDEX('DOMICILIO', DireccionDirFamPri, 1) - 1
                        end
                    ) + ' DOMICILIO CONOCIDO SIN NUMERO'
                )
            ) + ' ' + 
            LTRIM(
                RTRIM(
                    SUBSTRING(
                        DireccionDirFamPri, 
                        CASE WHEN CHARINDEX('NUMERO', DireccionDirFamPri, 1) = 0 
                             THEN CHARINDEX('SN', DireccionDirFamPri, 1) + 2 
                             ELSE CHARINDEX('NUMERO', DireccionDirFamPri, 1) + 6 
                        END, 1000
                    )
                )
            ), ' ,', ','
        ), 150
        
    )
WHERE (REPLACE(REPLACE(DireccionDirFamPri, ' ', ''), '/', '') LIKE '%DOMICILIOCONOCIDOSINNUMERO%') OR
       (REPLACE(REPLACE(DireccionDirFamPri, ' ', ''), '/', '') LIKE '%DOMICILIOCONOCIDOSN%')

UPDATE    tCsPadronClientes
SET DireccionDirNegPri = left(REPLACE(LTRIM(RTRIM(SUBSTRING(DireccionDirNegPri, 1, CHARINDEX('DOMICILIO', DireccionDirNegPri, 1) - 1) 
    + ' DOMICILIO CONOCIDO SIN NUMERO')) + ' ' + LTRIM(RTRIM(SUBSTRING(DireccionDirNegPri, CASE WHEN CHARINDEX('NUMERO', DireccionDirNegPri, 1) 
    = 0 THEN CHARINDEX('SN', DireccionDirNegPri, 1) + 2 ELSE CHARINDEX('NUMERO', DireccionDirNegPri, 1) + 6 END, 1000))), ' ,', ','), 150)
WHERE (REPLACE(REPLACE(DireccionDirNegPri, ' ', ''), '/', '') LIKE '%DOMICILIOCONOCIDOSINNUMERO%') OR
                      (REPLACE(REPLACE(DireccionDirNegPri, ' ', ''), '/', '') LIKE '%DOMICILIOCONOCIDOSN%')

UPDATE tCsPadronClientes
Set DireccionDirFamPri = left(CASE WHEN RIGHT(rtrim(ltrim(DireccionDirFamPri)), len(ltrim(rtrim(NumExtFam)))) = ltrim(rtrim(NumExtFam)) 
THEN substring(rtrim(ltrim(DireccionDirFamPri)), 1, len(rtrim(ltrim(DireccionDirFamPri))) - len(ltrim(rtrim(NumExtFam))) - 1) ELSE Rtrim(ltrim(DireccionDirFamPri)) 
END + ' NO ' + LTRIM(RTRIM(NumExtFam)) + CASE WHEN rtrim(ltrim(isnull(numintFam, ''))) <> '' THEN ' INT ' + rtrim(ltrim(isnull(numintFam, ''))) 
ELSE '' END, 150)
WHERE (CodUsuario IN
       (SELECT     CodUsuario
        FROM (SELECT     CodUsuario, cast(CASE WHEN RTRIM(LTRIM(replace(ISNULL(NumExtFam, ''), ' ', ''))) 
              = '' THEN '0' WHEN IsNumeric(RTRIM(LTRIM(replace(ISNULL(NumExtFam, ''), ' ', '')))) 
              = 0 THEN '0' ELSE RTRIM(LTRIM(replace(ISNULL(NumExtFam, ''), ' ', '')))
              --END AS Int --se cambio porque marcaba error
              END AS varchar
              ) AS Externo
              FROM tCsPadronClientes with(nolock)) Datos
        WHERE      
       --(Externo <> 0)))
       (Externo <> '0')))

UPDATE tCsPadronClientes
Set DireccionDirNegPri = left(CASE WHEN RIGHT(rtrim(ltrim(DireccionDirNegPri)), len(ltrim(rtrim(NumExtNeg)))) = ltrim(rtrim(NumExtNeg)) 
THEN substring(rtrim(ltrim(DireccionDirNegPri)), 1, len(rtrim(ltrim(DireccionDirNegPri))) - len(ltrim(rtrim(NumExtNeg))) - 1) ELSE Rtrim(ltrim(DireccionDirNegPri)) 
END + ' NO ' + LTRIM(RTRIM(NumExtNeg)) + CASE WHEN rtrim(ltrim(isnull(numintNeg, ''))) <> '' THEN ' INT ' + rtrim(ltrim(isnull(numintNeg, ''))) 
ELSE '' END, 150)
WHERE (CodUsuario IN
       (SELECT CodUsuario
        FROM (SELECT     CodUsuario, cast(CASE WHEN RTRIM(LTRIM(replace(ISNULL(NumExtNeg, ''), ' ', ''))) 
              = '' THEN '0' WHEN IsNumeric(RTRIM(LTRIM(replace(ISNULL(NumExtNeg, ''), ' ', '')))) 
              = 0 THEN '0' ELSE RTRIM(LTRIM(replace(ISNULL(NumExtNeg, ''), ' ', '')))
             -- END AS Int
              END AS varchar
              ) AS Externo
              FROM tCsPadronClientes with(nolock)) Datos
        WHERE (Externo <> '0')))

UPDATE    tCsPadronClientes
Set	DireccionDirFamPri =  REPLACE(DireccionDirFamPri, '  ', ' ') 
WHERE     (CHARINDEX('  ', DireccionDirFamPri, 1) <> 0)

UPDATE    tCsPadronClientes
Set	DireccionDirNegPri =  REPLACE(DireccionDirNegPri, '  ', ' ') 
WHERE     (CHARINDEX('  ', DireccionDirNegPri, 1) <> 0)

UPDATE    tCsPadronClientes
Set	DireccionDirFamPri =  LTRIM(RTRIM(DireccionDirFamPri))

UPDATE    tCsPadronClientes
Set	DireccionDirNegPri =  LTRIM(RTRIM(DireccionDirNegPri)) 

UPDATE    tCsPadronClientes
SET       DireccionDirFamPri = left(RTRIM(LTRIM(DireccionDirFamPri)) + ' SIN NUMERO', 150)
WHERE     (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END))) IN (''))

UPDATE    tCsPadronClientes
SET              DireccionDirNegPri = left(RTRIM(LTRIM(DireccionDirNegPri)) + ' SIN NUMERO', 150)
WHERE     (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END))) IN (''))

UPDATE    tCsPadronClientes
SET       DireccionDirFamPri = left(REPLACE(LTRIM(RTRIM(DireccionDirFamPri)), ' S/N', ' SIN NUMERO'), 150)
WHERE     (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END))) IN ('S/N')) AND 
                      (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END)))) = 0)

UPDATE    tCsPadronClientes
SET              DireccionDirNegPri = left(REPLACE(LTRIM(RTRIM(DireccionDirNegPri)), ' S/N', ' SIN NUMERO'), 150)
WHERE     (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END))) IN ('S/N')) AND 
                      (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END)))) = 0)

UPDATE    tCsPadronClientes
SET              DireccionDirFamPri = left(REPLACE(REPLACE(REPLACE(DireccionDirFamPri, '/', ''), '.', ''), '-', ''), 150)
WHERE     (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END))) NOT IN ('SN', 'NUMERO')) AND 
                      (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END)))) = 0) AND (CHARINDEX(' SN', 
                      REPLACE(REPLACE(REPLACE(DireccionDirFamPri, '/', ''), '.', ''), '-', ''), 1) <> 0)

UPDATE    tCsPadronClientes
SET       direccionDirNegPri = left(REPLACE(REPLACE(REPLACE(direccionDirNegPri, '/', ''), '.', ''), '-', ''), 150)
WHERE     (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(direccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(direccionDirNegPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(direccionDirNegPri))), 1) - 1 END))) NOT IN ('SN', 'NUMERO')) AND 
                      (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(direccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(direccionDirNegPri))), 1) 
                      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(direccionDirNegPri))), 1) - 1 END)))) = 0) AND (CHARINDEX(' SN', 
                      REPLACE(REPLACE(REPLACE(direccionDirNegPri, '/', ''), '.', ''), '-', ''), 1) <> 0)

Declare @NUM 		Varchar(2)
Declare @Contador	Int

Set @Contador = 0

While @Contador <= 9
Begin 
	Set @NUM = ' ' + Cast(@Contador As Varchar(1))

	UPDATE    tcspadronclientes
	SET direcciondirfampri = left(SUBSTRING(Datos.DireccionDirFamPri, 1, CHARINDEX(Datos.Antes, Datos.DireccionDirFamPri, 1) - 1) 
	    + Datos.Antes + ' NO ' + SUBSTRING(Datos.DireccionDirFamPri, CHARINDEX(Datos.Antes, Datos.DireccionDirFamPri, 1) + LEN(Datos.Antes) + 1, 1000), 150)
	FROM (SELECT Codusuario, DireccionDirFamPri, LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', 
	      REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END))) 
        AS Final, CASE WHEN CHARINDEX(' ', REVERSE(SUBSTRING(DireccionDirFamPri, 1, CHARINDEX(@NUM, DireccionDirFamPri, 1) - 1)), 1) 
        = 0 THEN substring(direcciondirfampri, 1, charindex(' ', direcciondirfampri, 1) - 1) ELSE RIGHT(SUBSTRING(DireccionDirFamPri, 1, CHARINDEX(@NUM, 
        DireccionDirFamPri, 1) - 1), CHARINDEX(' ', REVERSE(SUBSTRING(DireccionDirFamPri, 1, CHARINDEX(@NUM, DireccionDirFamPri, 1) - 1)), 1) - 1) 
        END AS Antes
	      FROM tCsPadronClientes with(nolock)
	      WHERE (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
	      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END))) NOT IN ('SN', 'NUMERO')) AND 
	      (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
	      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END)))) = 0) AND (CHARINDEX(' SN', 
	      REPLACE(REPLACE(DireccionDirFamPri, '/', ''), '.', ''), 1) = 0) AND (CHARINDEX('NUMERO', DireccionDirFamPri, 1) = 0) AND (CHARINDEX(' INT ', 
	      DireccionDirFamPri, 1) = 0) AND (CHARINDEX(' NO ', DireccionDirFamPri, 1) = 0) AND (CHARINDEX(@NUM, DireccionDirFamPri, 1) <> 0)) Datos INNER JOIN
	      tCsPadronClientes ON Datos.Codusuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientes.CodUsuario
	WHERE (isnumeric(Datos.Antes) = 0) AND (Datos.Antes NOT IN ('A', 'ABAJO', 'C', 'CALLE', 'CDA', 'CLL', 'COL', 'DE', 'EL', 'ENLA', 'EJIDO', 'L', 'M', 'LTE', 'LT', 'LOTE', 'MANZANA', 
	'MZ', 'MZA', 'N', 'NUM', 'Y')) AND (Datos.Antes NOT LIKE 'ART%') AND (SUBSTRING(Datos.DireccionDirFamPri, CHARINDEX(@NUM, Datos.DireccionDirFamPri, 1) + 2, 7) 
	NOT LIKE '%SEC%') AND (Datos.Antes NOT LIKE 'AV%') AND (Datos.Antes NOT LIKE 'BARR%') AND (SUBSTRING(Datos.DireccionDirFamPri, CHARINDEX(@NUM, 
	Datos.DireccionDirFamPri, 1) + 2, 7) NOT LIKE '%BARR%') AND (Datos.Antes NOT LIKE 'SECC%')

	UPDATE    tcspadronclientes
	SET direcciondirfampri = left(SUBSTRING(Datos.DireccionDirFamPri, 1, CHARINDEX(Datos.Antes, Datos.DireccionDirFamPri, 1) - 1) 
  + 'NO ' + SUBSTRING(Datos.DireccionDirFamPri, CHARINDEX(Datos.Antes, Datos.DireccionDirFamPri, 1) + LEN(Datos.Antes) + 1, 1000), 150)
	FROM (SELECT Codusuario, DireccionDirFamPri, LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', 
        REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END))) 
        AS Final, CASE WHEN CHARINDEX(' ', REVERSE(SUBSTRING(DireccionDirFamPri, 1, CHARINDEX(@NUM, DireccionDirFamPri, 1) - 1)), 1) 
        = 0 THEN substring(direcciondirfampri, 1, charindex(' ', direcciondirfampri, 1) - 1) ELSE RIGHT(SUBSTRING(DireccionDirFamPri, 1, CHARINDEX(@NUM, 
        DireccionDirFamPri, 1) - 1), CHARINDEX(' ', REVERSE(SUBSTRING(DireccionDirFamPri, 1, CHARINDEX(@NUM, DireccionDirFamPri, 1) - 1)), 1) - 1) 
        END AS Antes
	      FROM tCsPadronClientes with(nolock)
	      WHERE (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
	             - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END))) NOT IN ('SN', 'NUMERO')) AND 
	             (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
	             - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END)))) = 0) AND (CHARINDEX(' SN', 
	             REPLACE(REPLACE(DireccionDirFamPri, '/', ''), '.', ''), 1) = 0) AND (CHARINDEX('NUMERO', DireccionDirFamPri, 1) = 0) AND (CHARINDEX(' INT ', 
	             DireccionDirFamPri, 1) = 0) AND (CHARINDEX(' NO ', DireccionDirFamPri, 1) = 0) AND (CHARINDEX(@NUM, DireccionDirFamPri, 1) <> 0)) Datos 
	      INNER JOIN tCsPadronClientes ON Datos.Codusuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientes.CodUsuario
	WHERE (isnumeric(Datos.Antes) = 0) AND (Datos.Antes IN ('N', 'NUM')) AND (Datos.Antes NOT LIKE 'ART%') AND (SUBSTRING(Datos.DireccionDirFamPri, CHARINDEX(@NUM, Datos.DireccionDirFamPri, 1) + 2, 7) 
	       NOT LIKE '%SEC%') AND (Datos.Antes NOT LIKE 'AV%') AND (Datos.Antes NOT LIKE 'BARR%') AND (SUBSTRING(Datos.DireccionDirFamPri, CHARINDEX(@NUM, 
	       Datos.DireccionDirFamPri, 1) + 2, 7) NOT LIKE '%BARR%') AND (Datos.Antes NOT LIKE 'SECC%')

	UPDATE    tcspadronclientes
	SET DireccionDirNegPri = left(SUBSTRING(Datos.DireccionDirNegPri, 1, CHARINDEX(Datos.Antes, Datos.DireccionDirNegPri, 1) - 1) 
	+ Datos.Antes + ' NO ' + SUBSTRING(Datos.DireccionDirNegPri, CHARINDEX(Datos.Antes, Datos.DireccionDirNegPri, 1) + LEN(Datos.Antes) + 1, 1000), 150)
	FROM (SELECT Codusuario, DireccionDirNegPri, LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', 
	      REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END))) 
        AS Final, CASE WHEN CHARINDEX(' ', REVERSE(SUBSTRING(DireccionDirNegPri, 1, CHARINDEX(@NUM, DireccionDirNegPri, 1) - 1)), 1) 
        = 0 THEN substring(DireccionDirNegPri, 1, charindex(' ', DireccionDirNegPri, 1) - 1) ELSE RIGHT(SUBSTRING(DireccionDirNegPri, 1, CHARINDEX(@NUM, 
        DireccionDirNegPri, 1) - 1), CHARINDEX(' ', REVERSE(SUBSTRING(DireccionDirNegPri, 1, CHARINDEX(@NUM, DireccionDirNegPri, 1) - 1)), 1) - 1) 
	      END AS Antes
	      FROM tCsPadronClientes with(nolock)
	      WHERE (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
	            - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END))) NOT IN ('SN', 'NUMERO')) AND 
	            (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
	            - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END)))) = 0) AND (CHARINDEX(' SN', 
	            REPLACE(REPLACE(DireccionDirNegPri, '/', ''), '.', ''), 1) = 0) AND (CHARINDEX('NUMERO', DireccionDirNegPri, 1) = 0) AND (CHARINDEX(' INT ', 
	            DireccionDirNegPri, 1) = 0) AND (CHARINDEX(' NO ', DireccionDirNegPri, 1) = 0) AND (CHARINDEX(@NUM, DireccionDirNegPri, 1) <> 0)) Datos 
	       INNER JOIN tCsPadronClientes ON Datos.Codusuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientes.CodUsuario
	WHERE (isnumeric(Datos.Antes) = 0) AND (Datos.Antes NOT IN ('A', 'ABAJO', 'C', 'CALLE', 'CDA', 'CLL', 'COL', 'DE', 'EL', 'ENLA', 'EJIDO', 'L', 'M', 'LTE', 'LT', 'LOTE', 'MANZANA', 
	      'MZ', 'MZA', 'N', 'NUM', 'Y')) AND (Datos.Antes NOT LIKE 'ART%') AND (SUBSTRING(Datos.DireccionDirNegPri, CHARINDEX(@NUM, Datos.DireccionDirNegPri, 1) + 2, 7) 
	      NOT LIKE '%SEC%') AND (Datos.Antes NOT LIKE 'AV%') AND (Datos.Antes NOT LIKE 'BARR%') AND (SUBSTRING(Datos.DireccionDirNegPri, CHARINDEX(@NUM, 
	      Datos.DireccionDirNegPri, 1) + 2, 7) NOT LIKE '%BARR%') AND (Datos.Antes NOT LIKE 'SECC%')


	UPDATE    tcspadronclientes
	SET DireccionDirNegPri = left(SUBSTRING(Datos.DireccionDirNegPri, 1, CHARINDEX(Datos.Antes, Datos.DireccionDirNegPri, 1) - 1) 
  + 'NO ' + SUBSTRING(Datos.DireccionDirNegPri, CHARINDEX(Datos.Antes, Datos.DireccionDirNegPri, 1) + LEN(Datos.Antes) + 1, 1000), 150)
	FROM (SELECT     Codusuario, DireccionDirNegPri, LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', 
	      REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END))) 
	      AS Final, CASE WHEN CHARINDEX(' ', REVERSE(SUBSTRING(DireccionDirNegPri, 1, CHARINDEX(@NUM, DireccionDirNegPri, 1) - 1)), 1) 
	      = 0 THEN substring(DireccionDirNegPri, 1, charindex(' ', DireccionDirNegPri, 1) - 1) ELSE RIGHT(SUBSTRING(DireccionDirNegPri, 1, CHARINDEX(@NUM, 
	      DireccionDirNegPri, 1) - 1), CHARINDEX(' ', REVERSE(SUBSTRING(DireccionDirNegPri, 1, CHARINDEX(@NUM, DireccionDirNegPri, 1) - 1)), 1) - 1) 
	      END AS Antes
	      FROM tCsPadronClientes with(nolock)
	      WHERE (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
	            - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END))) NOT IN ('SN', 'NUMERO')) AND 
	            (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
	            - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END)))) = 0) AND (CHARINDEX(' SN', 
	            REPLACE(REPLACE(DireccionDirNegPri, '/', ''), '.', ''), 1) = 0) AND (CHARINDEX('NUMERO', DireccionDirNegPri, 1) = 0) AND (CHARINDEX(' INT ', 
	            DireccionDirNegPri, 1) = 0) AND (CHARINDEX(' NO ', DireccionDirNegPri, 1) = 0) AND (CHARINDEX(@NUM, DireccionDirNegPri, 1) <> 0)) Datos 
	      INNER JOIN tCsPadronClientes ON Datos.Codusuario COLLATE Modern_Spanish_CI_AI = tCsPadronClientes.CodUsuario
	WHERE (isnumeric(Datos.Antes) = 0) AND (Datos.Antes IN ('N', 'NUM')) AND (Datos.Antes NOT LIKE 'ART%') AND (SUBSTRING(Datos.DireccionDirNegPri, CHARINDEX(@NUM, Datos.DireccionDirNegPri, 1) + 2, 7) 
	      NOT LIKE '%SEC%') AND (Datos.Antes NOT LIKE 'AV%') AND (Datos.Antes NOT LIKE 'BARR%') AND (SUBSTRING(Datos.DireccionDirNegPri, CHARINDEX(@NUM, 
	      Datos.DireccionDirNegPri, 1) + 2, 7) NOT LIKE '%BARR%') AND (Datos.Antes NOT LIKE 'SECC%')	

	Set @Contador = @Contador + 1
End 

UPDATE    tCsPadronClientes
SET DireccionDirFamPri = left(CASE WHEN CHARINDEX(' COL ', DireccionDirFamPri) > 0 THEN substring(direcciondirfampri, 1, CHARINDEX(' COL ', DireccionDirFamPri) - 1) 
    + ' SIN NUMERO' + substring(direcciondirfampri, CHARINDEX(' COL ', DireccionDirFamPri), 1000) WHEN CHARINDEX('DOMICILIO CONOCIDO', DireccionDirFamPri) 
    > 0 THEN substring(direcciondirfampri, 1, CHARINDEX('DOMICILIO CONOCIDO', DireccionDirFamPri) - 1) 
    + 'DOMICILIO CONOCIDO SIN NUMERO' + substring(direcciondirfampri, CHARINDEX('DOMICILIO CONOCIDO', DireccionDirFamPri) + 18, 1000) 
    WHEN CHARINDEX('ESQUINA', DireccionDirFamPri) > 0 THEN replace(direcciondirfampri, 'ESQUINA', 'SIN NUMERO ESQUINA') WHEN CHARINDEX(' AG ', 
    DireccionDirFamPri) > 0 THEN substring(direcciondirfampri, 1, CHARINDEX(' AG ', DireccionDirFamPri) - 1) + ' SIN NUMERO' + substring(direcciondirfampri, 
    CHARINDEX(' AG ', DireccionDirFamPri), 1000) WHEN CHARINDEX(' S N', DireccionDirFamPri) > 0 THEN substring(direcciondirfampri, 1, CHARINDEX(' S N', 
    DireccionDirFamPri) - 1) + ' SIN NUMERO' + substring(direcciondirfampri, CHARINDEX(' S N', DireccionDirFamPri) + 4, 1000) 
    ELSE Direcciondirfampri + ' SIN NUMERO' END, 150)
WHERE (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END))) NOT IN ('SN', 'NUMERO')) AND 
      (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END)))) = 0) AND (CHARINDEX(' SN', 
      REPLACE(REPLACE(DireccionDirFamPri, '/', ''), '.', ''), 1) = 0) AND (CHARINDEX('NUMERO', DireccionDirFamPri, 1) = 0) AND (CHARINDEX(' INT ', DireccionDirFamPri, 1) 
      = 0) AND (CHARINDEX(' NO ', DireccionDirFamPri, 1) = 0) AND (DireccionDirFamPri NOT LIKE '% LT %') AND (DireccionDirFamPri NOT LIKE '% LOTE %') AND 
      (DireccionDirFamPri NOT LIKE '% L %') AND (DireccionDirFamPri NOT LIKE '% N[1,2,3,4,5,6,7,8,9]%') AND 
      (SUBSTRING(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirFamPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) 
      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirFamPri))), 1) - 1 END))), 1, 2) <> 'NO') AND 
      (DireccionDirFamPri NOT LIKE '% L[1, 2, 3, 4, 5, 6,7, 8, 9]%') AND (DireccionDirFamPri NOT LIKE '% [L,N]-[1, 2, 3, 4, 5, 6,7, 8, 9]%') AND 
      (DireccionDirFamPri NOT LIKE '% [L,N] [1, 2, 3, 4, 5, 6,7, 8, 9]%') AND (DireccionDirFamPri NOT LIKE '% NO[1, 2, 3, 4, 5, 6,7, 8, 9]%') AND 
      (DireccionDirFamPri NOT LIKE '% NO [1, 2, 3, 4, 5, 6,7, 8, 9]%') AND (DireccionDirFamPri NOT LIKE '%[1, 2, 3, 4, 5, 6,7, 8, 9] BARR%')


UPDATE    tCsPadronClientes
SET DireccionDirNegPri = left(CASE WHEN CHARINDEX(' COL ', DireccionDirNegPri) > 0 THEN substring(DireccionDirNegPri, 1, CHARINDEX(' COL ', DireccionDirNegPri) - 1) 
    + ' SIN NUMERO' + substring(DireccionDirNegPri, CHARINDEX(' COL ', DireccionDirNegPri), 1000) WHEN CHARINDEX('DOMICILIO CONOCIDO', DireccionDirNegPri) 
    > 0 THEN substring(DireccionDirNegPri, 1, CHARINDEX('DOMICILIO CONOCIDO', DireccionDirNegPri) - 1) 
    + 'DOMICILIO CONOCIDO SIN NUMERO' + substring(DireccionDirNegPri, CHARINDEX('DOMICILIO CONOCIDO', DireccionDirNegPri) + 18, 1000) 
    WHEN CHARINDEX('ESQUINA', DireccionDirNegPri) > 0 THEN replace(DireccionDirNegPri, 'ESQUINA', 'SIN NUMERO ESQUINA') WHEN CHARINDEX(' AG ', 
    DireccionDirNegPri) > 0 THEN substring(DireccionDirNegPri, 1, CHARINDEX(' AG ', DireccionDirNegPri) - 1) + ' SIN NUMERO' + substring(DireccionDirNegPri, 
    CHARINDEX(' AG ', DireccionDirNegPri), 1000) WHEN CHARINDEX(' S N', DireccionDirNegPri) > 0 THEN substring(DireccionDirNegPri, 1, CHARINDEX(' S N', 
    DireccionDirNegPri) - 1) + ' SIN NUMERO' + substring(DireccionDirNegPri, CHARINDEX(' S N', DireccionDirNegPri) + 4, 1000) 
    ELSE DireccionDirNegPri + ' SIN NUMERO' END, 150)
WHERE (LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END))) NOT IN ('SN', 'NUMERO')) AND 
      (isnumeric(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END)))) = 0) AND (CHARINDEX(' SN', 
      REPLACE(REPLACE(DireccionDirNegPri, '/', ''), '.', ''), 1) = 0) AND (CHARINDEX('NUMERO', DireccionDirNegPri, 1) = 0) AND (CHARINDEX(' INT ', DireccionDirNegPri, 1) 
      = 0) AND (CHARINDEX(' NO ', DireccionDirNegPri, 1) = 0) AND (DireccionDirNegPri NOT LIKE '% LT %') AND (DireccionDirNegPri NOT LIKE '% LOTE %') AND 
      (DireccionDirNegPri NOT LIKE '% L %') AND (DireccionDirNegPri NOT LIKE '% N[1,2,3,4,5,6,7,8,9]%') AND 
      (SUBSTRING(LTRIM(RTRIM(RIGHT(LTRIM(RTRIM(DireccionDirNegPri)), CASE WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) 
      - 1 <= 0 THEN 0 ELSE CHARINDEX(' ', REVERSE(LTRIM(RTRIM(DireccionDirNegPri))), 1) - 1 END))), 1, 2) <> 'NO') AND 
      (DireccionDirNegPri NOT LIKE '% L[1, 2, 3, 4, 5, 6,7, 8, 9]%') AND (DireccionDirNegPri NOT LIKE '% [L,N]-[1, 2, 3, 4, 5, 6,7, 8, 9]%') AND 
      (DireccionDirNegPri NOT LIKE '% [L,N] [1, 2, 3, 4, 5, 6,7, 8, 9]%') AND (DireccionDirNegPri NOT LIKE '% NO[1, 2, 3, 4, 5, 6,7, 8, 9]%') AND 
      (DireccionDirNegPri NOT LIKE '% NO [1, 2, 3, 4, 5, 6,7, 8, 9]%') AND (DireccionDirNegPri NOT LIKE '%[1, 2, 3, 4, 5, 6,7, 8, 9] BARR%')

UPDATE tCsPadronClientes
SET    DireccionDirFamPri = left(SUBSTRING(DireccionDirFamPri, 1, LEN(DireccionDirFamPri) - 2) + 'SIN NUMERO', 150)
WHERE  (RIGHT(RTRIM(LTRIM(DireccionDirFamPri)), 3) = ' SN')

UPDATE    tCsPadronClientes
SET              DireccionDirNegPri = left(SUBSTRING(DireccionDirNegPri, 1, LEN(DireccionDirNegPri) - 2) + 'SIN NUMERO', 150)
WHERE     (RIGHT(RTRIM(LTRIM(DireccionDirNegPri)), 3) = ' SN')

Set @Contador = 0

SELECT @Contador = Count(*)
FROM   tCsPadronClientes with(nolock)
WHERE  (CodTPersona = '01') AND (UsRFCBD IS NULL)

If @Contador is null Begin Set @Contador = 0 End

If @Contador > 0
Begin

	Declare @CodUsuario	Varchar(15)
	Declare @Nombres 	Varchar(50)
	Declare @Paterno	Varchar(50)
	Declare @Materno	Varchar(50)
	Declare @Nacimiento	SmallDateTime
	Declare @RFC		Varchar(30)
	Declare @Nombre1	Varchar(50)
	Declare @Nombre2	Varchar(50)	
	
	Declare curFragmento Cursor For 
		SELECT     CodUsuario, Paterno, Materno, Nombres, FechaNacimiento, Nombre1, Nombre2
		FROM         tCsPadronClientes with(nolock)
		WHERE     (CodTPersona = '01') AND (UsRFCBD IS NULL)	
	Open curFragmento
	Fetch Next From curFragmento Into @CodUsuario, @Paterno, @Materno, @Nombres, @Nacimiento, @Nombre1, @Nombre2
	While @@Fetch_Status = 0
	Begin 
	
		--Print @Nombres
		--Print @Paterno
		--Print @Materno
		--Print @Nacimiento
	
		If Isnull(Ltrim(Rtrim(@Paterno)), '') = '' Or Isnull(Ltrim(Rtrim(@Materno)), '') = ''
		Begin
			If Rtrim(Ltrim(@Nombre1)) = 'MARIA' And Rtrim(Ltrim(Isnull(@Nombre2, ''))) <> ''
			Begin
				If Substring(Rtrim(Ltrim(@Nombre2)), 1, 4) = 'DEL '
				Begin
					Set @Nombres = Rtrim(Ltrim(Substring(@Nombre2, 5, 100))) 
				End
				Else
				Begin
					Set @Nombres = Rtrim(Ltrim(Substring(@Nombre2, 1, 100))) 
				End
			End
			If Isnull(Ltrim(Rtrim(@Paterno)), '') = '' Begin Set @Paterno 	= @Materno End	
			If Isnull(Ltrim(Rtrim(@Materno)), '') = '' Begin Set @Paterno 	= Ltrim(Rtrim(@Paterno)) End	
				
			Set @Materno 	= Substring(Ltrim(Rtrim(@Nombres)), 1, 1) 
			Set @Nombres 	= Substring(Ltrim(Rtrim(@Nombres)), 2, 1)				
		End
	
		Set @Paterno = Case When Isnull(Ltrim(Rtrim(@Paterno)), '') = '' Then @Materno Else @Paterno end	
		Set @Materno = Case When Isnull(Ltrim(Rtrim(@Materno)), '') = '' Then @Paterno Else @Materno end	
		
		Set @Paterno = Ltrim(Rtrim(@Paterno))
		Set @Materno = Ltrim(Rtrim(@Materno))
		Set @Nombres = Ltrim(Rtrim(@Nombres))
	
		Exec pCsCalculoRFC @Nombres, @Paterno, @Materno, @Nacimiento, @RFC OUT
	
		--Print @Nombres
		--Print @Paterno
		--Print @Materno
		--Print @Nacimiento
		--Print @RFC
	
		Update tCsPadronClientes
		Set UsRFCBD = @RFC
		Where CodUsuario = @CodUsuario
	
	Fetch Next From curFragmento Into @CodUsuario, @Paterno, @Materno, @Nombres, @Nacimiento, @Nombre1, @Nombre2
	End 
	Close 		curFragmento
	Deallocate 	curFragmento
End
GO