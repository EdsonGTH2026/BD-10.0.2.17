SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCtaCuadreBoveda] @FecIni smalldatetime, @FecFin smalldatetime, @Codoficina varchar(5)  AS

SET NOCOUNT ON

--DECLARE @FecIni smalldatetime, @FecFin smalldatetime, @Codoficina varchar(5)  
--SET @FecIni 	= '20090201'
--SET @FecFin 	= '20090228'
--SET @Codoficina = '4'

DECLARE @Servidor varchar(50)
DECLARE @BaseDatos varchar(50)

SELECT @BaseDatos=NombreBD, @Servidor=NombreIP FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = cast(year(@FecFin) as varchar(4)))

DECLARE @FecInix varchar(8), @FecFinx varchar(8)
SET @FecInix 	= dbo.fduFechaAAAAMMDD(@FecIni)
SET @FecFinx 	= dbo.fduFechaAAAAMMDD(@FecFin)

DECLARE @csql varchar(8000)

CREATE TABLE #tbAux (
	Fecha				smalldatetime,
	CAP					decimal(16,4),
	INTE				decimal(16,4),
	INPE				decimal(16,4),
	CAR_MORA			decimal(16,4),
	COM_ANTI			decimal(16,4),
	COM_CANCEL_AH		decimal(16,4),
	CONTA_COM_APER		decimal(16,4),
	CONTA_REC_CRED		decimal(16,4),
	CONTA_CAN_AH		decimal(16,4),
	CONTA_IVA			decimal(16,4),
	CONTA_CAP			decimal(16,4),
	CONTA_INTE			decimal(16,4),
	CONTA_INPE			decimal(16,4),
	CONTA_BOVEDA		decimal(16,4),
	COM_CANCEL_IVA_AH	decimal(16,4),
	CodOficina			varchar(5)
)

SET @csql = ' INSERT INTO #tbAux '
SET @csql = @csql + 'SELECT Fecha, SUM(CAP) AS CAP, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(CAR_MORA) AS CAR_MORA, SUM(COM_ANTI) AS COM_ANTI, '
SET @csql = @csql + 'SUM(COM_CANCEL_AH) AS COM_CANCEL_AH, 0 AS CONTA_COM_APER, 0 AS CONTA_REC_CRED, 0 AS CONTA_CAN_AH, 0 AS CONTA_IVA, '
SET @csql = @csql + '0 AS CONTA_CAP, 0 AS CONTA_INTE, 0 AS CONTA_INPE, 0 AS CONTA_BOVEDA, 0 AS COM_CANCEL_IVA_AH,CodOficina '
SET @csql = @csql + 'FROM (SELECT Fecha, SUM(CAP) AS CAP, SUM(INTE) AS INTE, SUM(INPE) AS INPE, SUM(CARGO_MORA) AS CAR_MORA, SUM(COM_ANTICIPADA) '
SET @csql = @csql + 'AS COM_ANTI, 0 AS COM_CANCEL_AH, 0 AS COM_CANCEL_IVA_AH,CodOficina '
SET @csql = @csql + 'FROM (SELECT Fecha, MontoCapitalTran AS CAP, MontoInteresTran AS INTE, MontoINPETran AS INPE, '
SET @csql = @csql + 'CASE TipoTransacNivel3 WHEN ''101'' THEN 0 ELSE MontoOtrosTran-(MontoINPETran+MontoInteresTran)*0.16 END AS CARGO_MORA, '
SET @csql = @csql + 'CASE TipoTransacNivel3 WHEN ''101'' THEN MontoOtrosTran/1.16 ELSE 0 END AS COM_ANTICIPADA, CodOficina '
SET @csql = @csql + 'FROM (SELECT Fecha, SUM(MontoCapitalTran) AS MontoCapitalTran, SUM(MontoInteresTran) AS MontoInteresTran, '
SET @csql = @csql + 'SUM(MontoINVETran) AS MontoINVETran, SUM(MontoINPETran) AS MontoINPETran, SUM(MontoOtrosTran) '
SET @csql = @csql + 'AS MontoOtrosTran, SUM(MontoTotalTran) AS MontoTotalTran, TipoTransacNivel3, CodOficina '
SET @csql = @csql + 'FROM tCsTransaccionDiaria WHERE (CodOficina = '''+@Codoficina+''') AND (Fecha >= ''' + @FecInix
SET @csql = @csql + '''	AND Fecha <= '''+@FecFinx+''') AND (CodSistema = ''ca'') AND (Extornado = 0) AND (TipoTransacNivel1 = ''I'') '
SET @csql = @csql + 'GROUP BY TipoTransacNivel3, Fecha,CodOficina) TRANS) A '
SET @csql = @csql + 'GROUP BY Fecha,CodOficina '
SET @csql = @csql + 'UNION '
SET @csql = @csql + 'SELECT Fecha, 0 AS CAP, 0 AS INTE, 0 AS INPE, 0 AS CAR_MORA, 0 AS COM_ANTI, '
SET @csql = @csql + 'CASE SUBSTRING(DescripcionTran, 32, 14) WHEN ''Cobro Impuesto'' THEN 0 ELSE SUM(MontoTotalTran) END AS COM_CANCEL_AH, '
SET @csql = @csql + 'CASE SUBSTRING(DescripcionTran, 32, 14) WHEN ''Cobro Impuesto'' THEN SUM(MontoTotalTran) ELSE 0 END AS COM_CANCEL_IVA_AH ,CodOficina '
SET @csql = @csql + 'FROM tCsTransaccionDiaria WHERE (CodOficina = '''+@Codoficina+''') AND (CodSistema = ''TC'') AND (Extornado = 0) AND (TipoTransacNivel3 in (''7'')) '
SET @csql = @csql + 'AND (Fecha >= '''+@FecInix+''' AND Fecha <= '''+@FecFinx+''') GROUP BY Fecha, DescripcionTran,CodOficina '

SET @csql = @csql + 'UNION '
SET @csql = @csql + 'SELECT Fecha, 0 AS CAP, 0 AS INTE, 0 AS INPE, 0 AS CAR_MORA, 0 AS COM_ANTI, '
SET @csql = @csql + 'CASE SUBSTRING(DescripcionTran, 32, 14) WHEN ''Cobro Impuesto'' THEN 0 ELSE SUM(MontoTotalTran) END AS COM_CANCEL_AH, '
SET @csql = @csql + 'CASE SUBSTRING(DescripcionTran, 32, 14) WHEN ''Cobro Impuesto'' THEN SUM(MontoTotalTran) ELSE 0 END AS COM_CANCEL_IVA_AH ,CodOficina '
SET @csql = @csql + 'FROM tCsTransaccionDiaria WHERE (CodOficina = '''+@Codoficina+''') AND (CodSistema = ''ah'') AND (Extornado = 0) AND (TipoTransacNivel3 in (''21'',''16'')) '
SET @csql = @csql + 'AND (Fecha >= '''+@FecInix+''' AND Fecha <= '''+@FecFinx+''') GROUP BY Fecha, DescripcionTran,CodOficina '

SET @csql = @csql + ') B GROUP BY Fecha,CodOficina '
EXEC (@csql)

SET @csql = ' INSERT INTO #tbAux '
SET @csql = @csql + 'SELECT FechCbte AS Fecha, 0 AS CAP, 0 AS INTE, 0 AS INPE, 0 AS CAR_MORA, 0 AS COM_ANTI, 0 AS COM_CANCEL_AH, SUM(CONTA_COM_APER) '
SET @csql = @csql + 'AS CONTA_COM_APER, SUM(CONTA_REC_CRED) AS CONTA_REC_CRED, SUM(CONTA_CAN_AH) AS CONTA_CAN_AH, SUM(CONTA_IVA) AS CONTA_IVA,SUM(CONTA_CAP) '
SET @csql = @csql + 'AS CONTA_CAP, SUM(CONTA_INTE) AS CONTA_INTE, SUM(CONTA_INPE) AS CONTA_INPE, SUM(CONTA_BOVEDA) AS CONTA_BOVEDA, 0 AS COM_CANCEL_IVA_AH,CodOficina '
SET @csql = @csql + 'FROM (SELECT a.FechCbte, '
SET @csql = @csql + 'CASE b.CodCta WHEN ''650110601'' THEN Haber WHEN ''650110201'' THEN haber ELSE 0 END AS CONTA_COM_APER, '
SET @csql = @csql + 'CASE b.CodCta WHEN ''650110701'' THEN Haber WHEN ''650111402'' THEN Haber  WHEN ''650111001''  THEN Haber ELSE 0 END AS CONTA_CAN_AH, '
SET @csql = @csql + 'CASE b.CodCta WHEN ''650111501'' THEN  ( case substring(a.glosagral, 2, 6) WHEN  ''CAR093''  then (-1)*DEBE else Haber end )  '
SET @csql = @csql + 'WHEN ''660110201'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR061'' THEN HABER  WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END)  ELSE 0 END AS CONTA_REC_CRED, '
SET @csql = @csql + 'CASE b.CodCta WHEN ''230210801'' THEN  ( case substring(a.glosagral, 2, 6) WHEN  ''CAR093''  then (-1)*DEBE else Haber end )  ELSE 0 END AS CONTA_IVA, '
SET @csql = @csql + 'CASE b.CodCta WHEN ''130110101'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR005'' THEN 0 WHEN ''CAR093'' THEN (-1)*debe  WHEN ''CAR052'' THEN 0 ELSE Haber END) '
SET @csql = @csql + 'WHEN ''130210101'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER  WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*debe ELSE 0 END) '
SET @csql = @csql + 'WHEN ''130110201'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR005'' THEN 0 WHEN ''CAR093'' THEN (-1)*debe  WHEN ''CAR052'' THEN 0 ELSE Haber END) '
SET @csql = @csql + 'WHEN ''130110301'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR005'' THEN 0 WHEN ''CAR093'' THEN (-1)*debe  WHEN ''CAR052'' THEN 0 ELSE Haber END) '
SET @csql = @csql + 'WHEN ''130210201'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR005'' THEN 0 WHEN ''CAR093'' THEN (-1)*debe  WHEN ''CAR052'' THEN 0 ELSE Haber END) '
SET @csql = @csql + 'WHEN ''660110301'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR061'' THEN (-1)*debe ELSE Haber END) '--castigado
SET @csql = @csql + 'WHEN ''130210301'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR005'' THEN 0 WHEN ''CAR093'' THEN (-1)*debe  WHEN ''CAR052'' THEN 0 ELSE Haber END) ELSE 0 END AS CONTA_CAP, '
SET @csql = @csql + 'CASE b.CodCta WHEN ''139110101'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139110201'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139110301'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''610210101'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER  WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''610210201'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER  WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''610210301'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER  WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'ELSE 0 END AS CONTA_INTE, '
SET @csql = @csql + 'CASE b.CodCta WHEN ''139110102'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139110202'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139110302'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) 'SET @csql = @csql + 'WHEN ''610410101'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''610410102'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''610410103'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139210102'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139210202'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139210302'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139210101'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139210201'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''139210301'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'WHEN ''660110301'' THEN (CASE substring(a.glosagral, 2, 6) WHEN ''CAR003'' THEN HABER WHEN ''CAR021'' THEN HABER WHEN ''CAR061'' THEN HABER WHEN ''CAR060'' THEN HABER WHEN ''CAR093'' THEN (-1)*DEBE ELSE 0 END) '
SET @csql = @csql + 'ELSE 0 END AS CONTA_INPE, '
SET @csql = @csql + 'CASE b.CodCta WHEN ''110110101'' THEN  (CASE substring(a.glosagral, 2, 6) WHEN ''CAR001'' THEN DEBE WHEN ''CAR003'' THEN DEBE WHEN ''CAR021'' THEN DEBE  WHEN ''CAR061'' THEN DEBE WHEN ''CAR060'' THEN DEBE WHEN ''CAR093'' THEN (-1)*HABER  ELSE 0 END)'
SET @csql = @csql + 'ELSE 0 END AS CONTA_BOVEDA, a.CodOficinaOri CodOficina '
SET @csql = @csql + 'FROM ['+@Servidor+'].'+@BaseDatos+'.dbo.tCoTraDiaDetalle b INNER JOIN ['+@Servidor+'].'+@BaseDatos+'.dbo.tCoTraDia a ON '
SET @csql = @csql + 'b.CodRegistro=a.CodRegistro '
--SET @csql = @csql + 'b.CodCbte=a.CodCbte AND b.NroCbte = a.NroCbte AND b.FechCbte = a.FechCbte AND b.CodOficinaOri=a.CodOficinaOri '
SET @csql = @csql + 'WHERE (a.FechCbte >= '''+@FecInix+''' AND a.FechCbte <= '''+@FecFinx+''') '
SET @csql = @csql + 'AND (a.CodOficinaOri = '''+@Codoficina+''') AND (b.CodCta '
SET @csql = @csql + 'IN (''650110601'', ''650110701'', ''650111501'', ''230210801'', ''130110101'',''130210101'', ''139110101'', ''139110102'', ''139210101'', '
SET @csql = @csql + '''139210102'', ''610210101'',''610410101'',''110110101'', ''660110201'',''660110301'', ''130110201'',''130110301'',''130210201'',''130210301'','
SET @csql = @csql + '''139110201'',''139110301'',''610210201'',''610210301'',''650111402'',''660110301'',''650111001'',''650110201'')) AND (a.EsAnulado = 0)) TRANS '
SET @csql = @csql + 'GROUP BY FechCbte, CodOficina '
EXEC (@csql)

SELECT Fecha, SUM(CAP) CAP,SUM(INTE) INTE,SUM(INPE) INPE,SUM(CAR_MORA) CAR_MORA,SUM(COM_ANTI) COM_ANTI,SUM(COM_CANCEL_AH) COM_CANCEL_AH, 
SUM(CONTA_COM_APER) CONTA_COM_APER,SUM(CONTA_REC_CRED) CONTA_REC_CRED,SUM(CONTA_CAN_AH) CONTA_CAN_AH,SUM(CONTA_IVA) CONTA_IVA,SUM(CONTA_CAP) CONTA_CAP, 
SUM(CONTA_INTE) CONTA_INTE,SUM(CONTA_INPE) CONTA_INPE, SUM(CONTA_BOVEDA) CONTA_BOVEDA, SUM(COM_CANCEL_IVA_AH) COM_CANCEL_IVA_AH, a.NomOficina 
FROM #tbAux b
inner join tcloficinas a on a.codoficina=b.codoficina 
GROUP BY b.Fecha, a.NomOficina 

drop table #tbAux

SET NOCOUNT OFF
GO