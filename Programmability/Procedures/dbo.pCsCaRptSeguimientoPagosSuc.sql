SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SP_HELPTEXT pCsCaRptSeguimientoPagosSuc
--EXECUTE     pCsCaRptSeguimientoPagosSuc '9'
--DROP PROC  pCsCaRptSeguimientoPagosSuc
CREATE PROCEDURE [dbo].[pCsCaRptSeguimientoPagosSuc] 
               ( @CodOficina VARCHAR(10) )
AS
--Set @Codoficina = '9'

/* ESTE SCRIPT SE EJECUTA EN LA BASE DEL CONSOLIDADO.  -- 006-123-06-05-00033

Valores posibles de @Codoficina:
Oficinas	:	1,2,3,4,.....99  
Zonas		:	Z01, Z02, Z03, Z04, Z05, Z06, ZCO, ZLG 
Todas		:	ZZZ
*/
-------------------------------------------------------------
Declare @Fecha SmallDateTime 

Select @Fecha = FechaConsolidacion + 1
From vCsFechaConsolidacion 

Declare @Cadena Varchar(8000)

Declare @CUbicacion		Varchar(500)
Declare @OtroDato		Varchar(100)

Exec pGnlCalculaParametros 1, @CodOficina, 	@CUbicacion 	Out, 	@CodOficina 	Out,  @OtroDato Out

CREATE TABLE #Pendientes(
	[ConsultaPago] [varchar](9) NOT NULL,
	[Fecha] [smalldatetime] NULL,
	[CodPrestamo] [varchar](25) NOT NULL,
	[CodOficina] [varchar](4) NOT NULL,
	[NomOficina] [varchar](30) NULL,
	[Zona] [varchar](3) NULL,
	[NomZon] [varchar](50) NULL,
	[NombreProdCorto] [varchar](50) NULL,
	[Asesor] [varchar](300) NULL,
	[ClienteGrupo] [varchar](50) NULL,
	[Secuencia] [int] NULL,
	[Estado] [varchar](20) NULL,
	[NroDiasAtraso] [int] NULL,
	[NroCuotas] [smallint] NULL,
	[NroCuotasPagadas] [smallint] NULL,
	[NroCuotasPorPagar] [smallint] NULL,
	[FechaDesembolso] [smalldatetime] NULL,
	[FechaVencimiento] [smalldatetime] NULL,
	[MontoDesembolso] [decimal](19, 4) NULL,
	[SaldoCapital] [decimal](19, 4) NULL,
	[CodConcepto] [varchar](5) NOT NULL,
	[SaldoCuota] [money] NULL
) ON [PRIMARY]

Print @CUbicacion

Set @Cadena	= 'Insert Into #Pendientes SELECT ''PENDIENTE'' AS ConsultaPago, Cast(''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''' as SmallDateTime) AS '
Set @Cadena	= @Cadena + 'Fecha, tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.CodOficina, tClOficinas.NomOficina, tClOficinas.Zona, tClZona.Nombre AS '
Set @Cadena	= @Cadena + 'NomZon, tCaProducto.NombreProdCorto, tCsPadronClientes_1.NombreCompleto AS Asesor, tCsPadronCarteraDet.ClienteGrupo, '
Set @Cadena	= @Cadena + 'tCsPadronCarteraDet.Secuencia, tCsPadronCarteraDet.Estado, tCsCartera.NroDiasAtraso, tCsCartera.NroCuotas, '
Set @Cadena	= @Cadena + 'tCsCartera.NroCuotasPagadas, tCsCartera.NroCuotasPorPagar, tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento, '
Set @Cadena	= @Cadena + 'tCsCartera.MontoDesembolso, tCsCartera.SaldoCapital, tCsPadronPlanCuotas.CodConcepto, tCsPadronPlanCuotas.MontoDevengado -  '
Set @Cadena	= @Cadena + 'tCsPadronPlanCuotas.MontoPagado - tCsPadronPlanCuotas.MontoCondonado As SaldoCuota FROM tCsPadronPlanCuotas INNER JOIN (SELECT '
Set @Cadena	= @Cadena + 'DISTINCT tCsPadronCarteraDet_1.CodOficina, tCsPadronCarteraDet_1.CodPrestamo, tCsPadronCarteraDet_1.FechaCorte, '
Set @Cadena	= @Cadena + 'tCsPadronCarteraDet_1.CodProducto, tCsPadronCarteraDet_1.UltimoAsesor, ISNULL(tCsCarteraGrupos.NombreGrupo, '
Set @Cadena	= @Cadena + 'tCsPadronClientes.NombreCompleto) AS ClienteGrupo, tCsPadronCarteraDet_1.EstadoCalculado AS Estado, CASE WHEN '
Set @Cadena	= @Cadena + 'tCsCarteraGrupos.NombreGrupo IS NULL THEN SecuenciaCliente ELSE SecuenciaGrupo END AS Secuencia FROM tCsPadronCarteraDet AS '
Set @Cadena	= @Cadena + 'tCsPadronCarteraDet_1 LEFT OUTER JOIN tCsPadronClientes ON tCsPadronCarteraDet_1.CodUsuario = tCsPadronClientes.CodUsuario '
Set @Cadena	= @Cadena + 'LEFT OUTER JOIN tCsCarteraGrupos ON tCsPadronCarteraDet_1.CodGrupo = tCsCarteraGrupos.CodGrupo WHERE '
Set @Cadena	= @Cadena + '(tCsPadronCarteraDet_1.EstadoCalculado NOT IN (''CANCELADO'')) And tCsPadronCarteraDet_1.CodOficina IN ('+ @CUbicacion +')) AS '
Set @Cadena	= @Cadena + 'tCsPadronCarteraDet ON tCsPadronPlanCuotas.CodPrestamo = tCsPadronCarteraDet.CodPrestamo INNER JOIN tClOficinas ON '
Set @Cadena	= @Cadena + 'tCsPadronCarteraDet.CodOficina = tClOficinas.CodOficina INNER JOIN tCsCartera ON tCsPadronCarteraDet.CodPrestamo = '
Set @Cadena	= @Cadena + 'tCsCartera.CodPrestamo AND tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha LEFT OUTER JOIN tCaProducto ON '
Set @Cadena	= @Cadena + 'tCsPadronCarteraDet.CodProducto = tCaProducto.CodProducto LEFT OUTER JOIN tCsPadronClientes AS tCsPadronClientes_1 ON '
Set @Cadena	= @Cadena + 'tCsPadronCarteraDet.UltimoAsesor = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN tClZona ON tClOficinas.Zona = tClZona.Zona WHERE '
Set @Cadena	= @Cadena + '(tCsPadronPlanCuotas.FechaVencimiento = ''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''') AND (tCsPadronPlanCuotas.EstadoCuota NOT '
Set @Cadena	= @Cadena + 'IN (''CANCELADO''))' 

Print @Cadena
Exec (@Cadena)

SELECT     ConsultaPago, Fecha, CodPrestamo, NomOficina, NomZon, NombreProdCorto, Asesor, ClienteGrupo, Secuencia, Estado, NroDiasAtraso, NroCuotas, 
                      NroCuotasPorPagar, FechaDesembolso, FechaVencimiento, MontoDesembolso, SaldoCapital, SaldoCuota, PagoDia
FROM         (SELECT     CASE WHEN PagoDia >= SaldoCuota THEN 'PAGADO' WHEN PagoDia < SaldoCuota AND 
                                              PagoDia > 0 THEN 'PAGO PARCIAL' ELSE 'PENDIENTE' END AS ConsultaPago, Fecha, CodPrestamo, CodOficina, NomOficina, Zona, NomZon, 
                                              NombreProdCorto, Asesor, ClienteGrupo, Secuencia, Estado, NroDiasAtraso, NroCuotas, NroCuotasPagadas, NroCuotasPorPagar, FechaDesembolso, 
                                              FechaVencimiento, MontoDesembolso, SaldoCapital, SaldoCuota, PagoDia
                       FROM          (SELECT     Datos.ConsultaPago, Datos.Fecha, Datos.CodPrestamo, Datos.CodOficina, Datos.NomOficina, Datos.Zona, Datos.NomZon, 
                                                                      Datos.NombreProdCorto, Datos.Asesor, Datos.ClienteGrupo, Datos.Secuencia, Datos.Estado, Datos.NroDiasAtraso, Datos.NroCuotas, 
                                                                      Datos.NroCuotasPagadas, Datos.NroCuotasPorPagar, Datos.FechaDesembolso, Datos.FechaVencimiento, Datos.MontoDesembolso, 
                                                                      Datos.SaldoCapital, Datos.SaldoCuota, ISNULL(Pagos.Pagado, 0) AS PagoDia
                                               FROM          (SELECT     ConsultaPago, Fecha, CodPrestamo, CodOficina, NomOficina, Zona, NomZon, NombreProdCorto, Asesor, ClienteGrupo, Secuencia, 
                                                                                              Estado, NroDiasAtraso, NroCuotas, NroCuotasPagadas, NroCuotasPorPagar, FechaDesembolso, FechaVencimiento, 
                                                                                              MontoDesembolso, SaldoCapital, SUM(SaldoCuota) AS SaldoCuota
                                                                       FROM   #Pendientes As  Pendientes
                                                                       GROUP BY ConsultaPago, Fecha, CodPrestamo, CodOficina, NomOficina, Zona, NomZon, NombreProdCorto, Asesor, ClienteGrupo, Secuencia, 
                                                                                              Estado, NroDiasAtraso, NroCuotas, NroCuotasPagadas, NroCuotasPorPagar, FechaDesembolso, FechaVencimiento, 
                                                                                              MontoDesembolso, SaldoCapital) AS Datos LEFT OUTER JOIN
                                                                          (SELECT     CodPrestamo, SUM(MontoPago) AS Pagado
                                                                            FROM          [BD-FINAMIGO-DC].Finmas.dbo.tcapagoreg AS tcapagoreg
                                                                            WHERE      (FechaPago = @Fecha) AND (Extornado = 0)
                                                                            GROUP BY CodPrestamo) AS Pagos ON Datos.CodPrestamo = Pagos.CodPrestamo) AS Datos) AS Datos
ORDER BY Cast(CodOficina as Int) ASC, ConsultaPago DESC                       

Drop Table #Pendientes     
GO