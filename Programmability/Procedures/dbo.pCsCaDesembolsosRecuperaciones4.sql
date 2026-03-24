SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 --sp_helptext pCsCaDesembolsosRecuperaciones3
   
/*  
Exec pCsCaDesembolsosRecuperaciones3 1, 'Z01', '20110907'  
Exec pCsCaDesembolsosRecuperaciones3 3, 'Z06', '20110912'  
*/  
CREATE Procedure [dbo].[pCsCaDesembolsosRecuperaciones4] 
 @Dato  Int,  
 @CodOficina Varchar(4),  
 @Fecha  SmallDateTime    
As  
/*  
@Dato = 1 Esto es para ver el detalle por Oficina  
@Dato = 2 Esto es para ver el resumen por Regiones.  
  
ESTE SCRIPT SE EJECUTA EN LA BASE DEL CONSOLIDADO.  
Valores posibles de @Codoficina:  
Oficinas : 1,2,3,4,.....99    
Zonas  : Z01, Z02, Z03, Z04, Z05, Z06, ZCO, ZLG   
Todas  : ZZZ  
  
-------------------------------------------------------------  
Declare @Fecha SmallDateTime   
  
Select @Fecha = FechaConsolidacion + 1  
From vCsFechaConsolidacion   
*/  
  
Declare @Cadena Varchar(8000)  
  
Declare @CUbicacion  Varchar(500)  
Declare @OtroDato  Varchar(100)  
  
Exec pGnlCalculaParametros 1, @CodOficina,  @CUbicacion  Out,  @CodOficina  Out,  @OtroDato Out  
  
CREATE TABLE #Pendientes(  
 [ConsultaPago]  [varchar](9) NOT NULL,  
 [Fecha]    [smalldatetime] NULL,  
 [CodPrestamo]  [varchar](25) NOT NULL,  
 [CodOficina]  [varchar](4) NOT NULL,  
 [NomOficina]  [varchar](30) NULL,  
 [Zona]    [varchar](3) NULL,  
 [NomZon]   [varchar](50) NULL,  
 [NombreProdCorto] [varchar](50) NULL,  
 [Asesor]   [varchar](300) NULL,  
 [ClienteGrupo]  [varchar](50) NULL,  
 [Secuencia]   [int] NULL,  
 [Estado]   [varchar](20) NULL,  
 [NroDiasAtraso]  [int] NULL,  
 [NroCuotas]   [smallint] NULL,  
 [NroCuotasPagadas] [smallint] NULL,  
 [NroCuotasPorPagar] [smallint] NULL,  
 [FechaDesembolso] [smalldatetime] NULL,  
 [FechaVencimiento] [smalldatetime] NULL,  
 [MontoDesembolso] [decimal](19, 4) NULL,  
 [SaldoCapital]  [decimal](19, 4) NULL,  
 [CodConcepto]  [varchar](5) NOT NULL,  
 [SaldoCuota]  [money] NULL,  
 [SecCuota]   [int] NULL,  
 [CapitalProgramado] [money] NULL  
) ON [PRIMARY]  
  
CREATE TABLE #Pendientes2(  
 [Fecha]    [datetime] NOT NULL,  
 [CodPrestamo]  [varchar](25) NOT NULL,  
 [SecCuota]   [smallint] NOT NULL,  
 [Pagado]   [money] NULL,  
 [CodConcepto]  [varchar](5) NOT NULL,  
 [CapitalPagado]  [money] NULL,  
 [CodOficina]  [varchar](4) NOT NULL,  
 [CodProducto]  [char](3) NULL,  
 [Asesor]   [varchar](120) NULL,  
 [ClienteGrupo]  [varchar](50) NULL,  
 [Estado]   [varchar](10) NOT NULL,  
 [MontoDesembolso] [money] NOT NULL,  
 [FechaDesembolso] [datetime] NOT NULL,  
 [FechaVencimiento] [datetime] NULL,  
 [FechaPago]   [smalldatetime] NULL,  
 [EstadoCuota]  [varchar](20) NULL,  
) ON [PRIMARY]  
  
CREATE TABLE #Resultado(  
 [ConsultaPago]  [varchar](12)  NULL,  
 [Fecha]    [smalldatetime]  NULL,  
 [CodPrestamo]  [varchar](25)  NULL,  
 [CodOficina]  [varchar](4)  NULL,  
 [NomOficina]  [varchar](30)  NULL,  
 [Zona]    [varchar](3)  NULL,  
 [NomZon]   [varchar](50)  NULL,  
 [NombreProdCorto] [varchar](50)  NULL,  
 [Asesor]   [varchar](300)  NULL,  
 [ClienteGrupo]  [varchar](50)  NULL,  
 [Secuencia]   [int]    NULL,  
 [Estado]   [varchar](20)  NULL,  
 [NroDiasAtraso]  [int]    NULL,  
 [NroCuotas]   [smallint]   NULL,  
 [NroCuotasPagadas] [smallint]   NULL,  
 [NroCuotasPorPagar] [smallint]   NULL,  
 [FechaDesembolso] [smalldatetime]  NULL,  
 [FechaVencimiento] [smalldatetime]  NULL,  
 [MontoDesembolso] [decimal](19, 4) NULL,  
 [SaldoCapital]  [decimal](19, 4) NULL,  
 [SaldoCuota]  [money]    NULL,  
 [PagoDia]   [money]    NULL,  
 [CapitalProgramado] [money]    NULL,  
 [CapitalPagado]  [money]    NULL,  
 [SecCuota]   [int]    NULL,  
 [CA]    [money]    NULL  
 ) ON [PRIMARY]  
  
Print @CUbicacion  
  
If @Dato In (1,2)  
Begin  
  
 Set @Cadena = 'Insert Into #Pendientes SELECT ConsultaPago, Fecha, CodPrestamo, CodOficina, NomOficina, Zona, NomZon, NombreProdCorto, Asesor, ClienteGrupo, '  
 Set @Cadena = @Cadena + 'Secuencia, Estado, NroDiasAtraso, NroCuotas, NroCuotasPagadas, NroCuotasPorPagar, FechaDesembolso, FechaVencimiento, '  
 Set @Cadena = @Cadena + 'MontoDesembolso, SaldoCapital, CodConcepto, SaldoCuota, SecCuota, CapitalProgramado FROM (SELECT ''PENDIENTE'' AS ConsultaPago, '  
 Set @Cadena = @Cadena + 'Cast(''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''' as SmallDateTime) AS Fecha, tCsPadronPlanCuotas.CodPrestamo, '  
 Set @Cadena = @Cadena + 'tCsPadronPlanCuotas.CodOficina, tClOficinas.NomOficina, tClOficinas.Zona, tClZona.Nombre AS NomZon, tCaProducto.NombreProdCorto, '  
 Set @Cadena = @Cadena + 'tCsPadronClientes_1.NombreCompleto AS Asesor, tCsPadronCarteraDet.ClienteGrupo, tCsPadronCarteraDet.Secuencia, '  
 Set @Cadena = @Cadena + 'tCsPadronCarteraDet.Estado, tCsCartera.NroDiasAtraso, tCsCartera.NroCuotas, tCsCartera.NroCuotasPagadas, '  
 Set @Cadena = @Cadena + 'tCsCartera.NroCuotasPorPagar, tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento, tCsCartera.MontoDesembolso, '  
 Set @Cadena = @Cadena + 'tCsCartera.SaldoCapital, tCsPadronPlanCuotas.CodConcepto, tCsPadronPlanCuotas.MontoDevengado - tCsPadronPlanCuotas.MontoPagado - '  
 Set @Cadena = @Cadena + 'tCsPadronPlanCuotas.MontoCondonado As SaldoCuota, SecCuota, CapitalProgramado = Case tCsPadronPlanCuotas.CodConcepto When ''CAPI'' '  
 Set @Cadena = @Cadena + 'Then tCsPadronPlanCuotas.MontoDevengado - tCsPadronPlanCuotas.MontoPagado - tCsPadronPlanCuotas.MontoCondonado Else 0 End FROM '  
 Set @Cadena = @Cadena + 'tCsPadronPlanCuotas INNER JOIN (SELECT DISTINCT tCsPadronCarteraDet_1.CodOficina, tCsPadronCarteraDet_1.CodPrestamo, '  
 Set @Cadena = @Cadena + 'tCsPadronCarteraDet_1.FechaCorte, tCsPadronCarteraDet_1.CodProducto, tCsPadronCarteraDet_1.UltimoAsesor, '  
 Set @Cadena = @Cadena + 'ISNULL(tCsCarteraGrupos.NombreGrupo, tCsPadronClientes.NombreCompleto) AS ClienteGrupo, tCsPadronCarteraDet_1.EstadoCalculado AS '  
 Set @Cadena = @Cadena + 'Estado, CASE WHEN tCsCarteraGrupos.NombreGrupo IS NULL THEN SecuenciaCliente ELSE SecuenciaGrupo END AS Secuencia FROM '  
 Set @Cadena = @Cadena + 'tCsPadronCarteraDet AS tCsPadronCarteraDet_1 LEFT OUTER JOIN tCsPadronClientes ON tCsPadronCarteraDet_1.CodUsuario = '  
 Set @Cadena = @Cadena + 'tCsPadronClientes.CodUsuario LEFT OUTER JOIN tCsCarteraGrupos ON tCsPadronCarteraDet_1.CodGrupo = tCsCarteraGrupos.CodGrupo WHERE '  
 Set @Cadena = @Cadena + 'tCsPadronCarteraDet_1.CodOficina IN ('+ @CUbicacion +')) AS tCsPadronCarteraDet ON tCsPadronPlanCuotas.CodPrestamo = '  
 Set @Cadena = @Cadena + 'tCsPadronCarteraDet.CodPrestamo INNER JOIN tClOficinas ON tCsPadronCarteraDet.CodOficina = tClOficinas.CodOficina INNER JOIN '  
 Set @Cadena = @Cadena + 'tCsCartera ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.FechaCorte = tCsCartera.Fecha LEFT '  
 Set @Cadena = @Cadena + 'OUTER JOIN tCaProducto ON tCsPadronCarteraDet.CodProducto = tCaProducto.CodProducto LEFT OUTER JOIN tCsPadronClientes AS '  
 Set @Cadena = @Cadena + 'tCsPadronClientes_1 ON tCsPadronCarteraDet.UltimoAsesor = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN tClZona ON '  
 Set @Cadena = @Cadena + 'tClOficinas.Zona = tClZona.Zona WHERE (tCsPadronPlanCuotas.FechaVencimiento = ''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''') '  
 Set @Cadena = @Cadena + ') AS Datos WHERE (CapitalProgramado + SaldoCuota > 0) '  
  
 Print GetDate()  
 Print @Cadena  
 Exec (@Cadena)  
 Print GetDate()  
  
 Set @Cadena = 'DELETE FROM #Pendientes WHERE (CodPrestamo IN (SELECT CodPrestamo FROM tCsPadronCarteraDet WHERE (Cancelacion < '''   
 Set @Cadena = @Cadena  + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''') AND (CodOficina IN ('+ @CUbicacion +'))))'  
  
 Print GetDate()  
 Print @Cadena  
 Exec (@Cadena)  
 Print GetDate()  
  
 Set @Cadena = 'Insert Into #Pendientes2 Select * From [BD-FINAMIGO-DC].Finmas.dbo.vcaRecuperaciones vcaRecuperaciones Where Fecha = '''+ dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''' and Codoficina in('+ @CUbicacion +')'   
  
 Print GetDate()  
 Print @Cadena  
 Exec (@Cadena)  
  
 Print GetDate()  
 Insert Into #Resultado  
 SELECT     ConsultaPago, Fecha, CodPrestamo, CodOficina, NomOficina, Zona, NomZon, NombreProdCorto, Asesor, ClienteGrupo, Secuencia, Estado, NroDiasAtraso, NroCuotas,   
        NroCuotasPagadas, NroCuotasPorPagar, FechaDesembolso, FechaVencimiento, MontoDesembolso, SaldoCapital, SaldoCuota, PagoDia, CapitalProgramado,   
        CapitalPagado, Seccuota, CA = 0  
 FROM         (SELECT     CASE When NroDiasAtraso = 0 And Seccuota = NroCuotasPAgadas + 1 And CapitalProgramado = 0 Then 'ADELANTADO'  
         WHEN PagoDia >= SaldoCuota THEN 'PAGADO' WHEN PagoDia < SaldoCuota AND   
              PagoDia > 0 THEN 'PAGO PARCIAL' ELSE 'PENDIENTE' END AS ConsultaPago, Fecha, CodPrestamo, CodOficina, NomOficina, Zona, NomZon,   
              NombreProdCorto, Asesor, ClienteGrupo, Secuencia, Estado, NroDiasAtraso, NroCuotas, NroCuotasPagadas, NroCuotasPorPagar, FechaDesembolso,   
              FechaVencimiento, MontoDesembolso, SaldoCapital, SaldoCuota, PagoDia, CapitalProgramado, CapitalPagado, Seccuota  
         FROM          (SELECT     ISNULL(Datos.ConsultaPago, 'NO PROGRAMADO') AS ConsultaPago, ISNULL(Datos.Fecha, Pagos.FechaPago) AS Fecha,   
                    ISNULL(Datos.CodPrestamo, Pagos.CodPrestamo) AS CodPrestamo, ISNULL(Datos.CodOficina, Pagos.CodOficina) AS CodOficina,   
                    ISNULL(Datos.NomOficina, Pagos.NomOficina) AS NomOficina, ISNULL(Datos.Zona, Pagos.Zona) AS Zona, ISNULL(Datos.NomZon,   
                    Pagos.Nombre) AS NomZon, ISNULL(Datos.NombreProdCorto, Pagos.NombreProdCorto) AS NombreProdCorto, ISNULL(Datos.Asesor,   
                    Pagos.Asesor) AS Asesor, ISNULL(Datos.ClienteGrupo, Pagos.ClienteGrupo) AS ClienteGrupo, ISNULL(Datos.Secuencia, Pagos.Secuencia)   
                    AS Secuencia, ISNULL(Datos.Estado, Pagos.Estado) AS Estado, ISNULL(Datos.NroDiasAtraso, Pagos.NroDiasAtraso) AS NroDiasAtraso,   
                    ISNULL(Datos.NroCuotas, Pagos.NroCuotas) AS NroCuotas, ISNULL(Datos.NroCuotasPagadas, Pagos.NroCuotasPagadas)   
                    AS NroCuotasPagadas, ISNULL(Datos.NroCuotasPorPagar, Pagos.NroCuotasPorPagar) AS NroCuotasPorPagar,   
                    ISNULL(Datos.FechaDesembolso, Pagos.FechaDesembolso) AS FechaDesembolso, ISNULL(Datos.FechaVencimiento, Pagos.FechaVencimiento)   
                    AS FechaVencimiento, ISNULL(Datos.MontoDesembolso, Pagos.MontoDesembolso) AS MontoDesembolso, ISNULL(Datos.SaldoCapital,   
                    Pagos.SaldoCapital) AS SaldoCapital, ISNULL(Datos.SaldoCuota, 0) AS SaldoCuota, ISNULL(Pagos.Pagado, 0) AS PagoDia,   
                    ISNULL(Datos.CapitalProgramado, 0) AS CapitalProgramado, ISNULL(Pagos.CapitalPagado, 0) AS CapitalPagado, ISNULL(Datos.SecCuota,   
                    Pagos.SecCuota) AS Seccuota  
               FROM          (SELECT     ConsultaPago, Fecha, CodPrestamo, CodOficina, NomOficina, Zona, NomZon, NombreProdCorto, Asesor, ClienteGrupo, Secuencia,   
                          Estado, NroDiasAtraso, NroCuotas, NroCuotasPagadas, NroCuotasPorPagar, FechaDesembolso, FechaVencimiento,   
                          MontoDesembolso, SaldoCapital, SUM(SaldoCuota) AS SaldoCuota, ISNULL(SUM(CapitalProgramado), 0) AS CapitalProgramado,   
                          SecCuota  
                     FROM   #Pendientes     Pendientes  
                     GROUP BY ConsultaPago, Fecha, CodPrestamo, CodOficina, NomOficina, Zona, NomZon, NombreProdCorto, Asesor, ClienteGrupo, Secuencia,   
                          Estado, NroDiasAtraso, NroCuotas, NroCuotasPagadas, NroCuotasPorPagar, FechaDesembolso, FechaVencimiento,   
                          MontoDesembolso, SaldoCapital, SecCuota) AS Datos FULL OUTER JOIN  
                     (SELECT     Datos.FechaPago, Datos.CodPrestamo, Datos.SecCuota, SUM(Datos.Pagado) AS Pagado, SUM(Datos.CapitalPagado)   
                            AS CapitalPagado, Datos.CodOficina, tClOficinas.NomOficina, tClOficinas.Zona, tClZona.Nombre, tCaProducto.NombreProdCorto,   
                            Datos.Asesor, Datos.ClienteGrupo, PadronCredito.Secuencia, Datos.Estado, Datos.NroDiasAtraso, Datos.NroCuotas,   
                            Datos.NroCuotasPagadas, Datos.NroCuotasPorPagar, Datos.SaldoCapital, Datos.MontoDesembolso, Datos.FechaDesembolso,   
                            Datos.FechaVencimiento  
                    FROM          (SELECT     Pendientes2.Fecha AS FechaPago, Pendientes2.CodPrestamo, Pendientes2.SecCuota, SUM(Pendientes2.Pagado) AS Pagado, Pendientes2.CodConcepto,   
                                CASE Pendientes2.CodConcepto WHEN 'CAPI' THEN SUM(Pendientes2.Pagado) ELSE 0 END AS CapitalPagado, Pendientes2.CodOficina, Pendientes2.CodProducto,   
                                Pendientes2.Asesor, Pendientes2.ClienteGrupo, Pendientes2.Estado, tCsCartera.NroDiasAtraso, tCsCartera.NroCuotas, tCsCartera.NroCuotasPagadas,   
                                tCsCartera.NroCuotasPorPagar, tCsCartera.SaldoCapital, Pendientes2.MontoDesembolso, Pendientes2.FechaDesembolso, Pendientes2.FechaVencimiento  
                         FROM         #Pendientes2 Pendientes2 LEFT OUTER JOIN  
                                tCsCartera ON Pendientes2.Fecha - 1 = tCsCartera.Fecha AND Pendientes2.CodPrestamo = tCsCartera.CodPrestamo  
                         GROUP BY tCsCartera.NroDiasAtraso, tCsCartera.NroCuotas, tCsCartera.NroCuotasPagadas, tCsCartera.NroCuotasPorPagar, tCsCartera.SaldoCapital, Pendientes2.Fecha,   
                                Pendientes2.CodPrestamo, Pendientes2.SecCuota, Pendientes2.CodConcepto, Pendientes2.CodOficina, Pendientes2.CodProducto, Pendientes2.Asesor,  
                                Pendientes2.ClienteGrupo, Pendientes2.Estado, Pendientes2.MontoDesembolso, Pendientes2.FechaDesembolso, Pendientes2.FechaVencimiento) AS Datos INNER JOIN  
                            tClOficinas ON Datos.CodOficina = tClOficinas.CodOficina INNER JOIN  
                            tCaProducto ON Datos.CodProducto = tCaProducto.CodProducto INNER JOIN  
                             (SELECT     CodPrestamo, MAX(CG) AS Secuencia  
                            FROM          (SELECT     CodPrestamo, CASE WHEN CodGrupo IS NULL   
                                       THEN SecuenciaCliente ELSE SecuenciaGrupo END AS CG  
                                  FROM          tCsPadronCarteraDet) AS Datos_1  
                            GROUP BY CodPrestamo) AS PadronCredito ON Datos.CodPrestamo = PadronCredito.CodPrestamo LEFT OUTER JOIN  
                            tClZona ON tClOficinas.Zona = tClZona.Zona  
                    GROUP BY Datos.FechaPago, Datos.CodPrestamo, Datos.SecCuota, Datos.CodOficina, tClOficinas.NomOficina, tClOficinas.Zona,   
                            tClZona.Nombre, tCaProducto.NombreProdCorto, Datos.Asesor, Datos.ClienteGrupo, PadronCredito.Secuencia, Datos.Estado,   
                            Datos.NroDiasAtraso, Datos.NroCuotas, Datos.NroCuotasPagadas, Datos.NroCuotasPorPagar, Datos.SaldoCapital,   
                            Datos.MontoDesembolso, Datos.FechaDesembolso, Datos.FechaVencimiento) AS Pagos ON   
                    Datos.SecCuota = Pagos.SecCuota AND Datos.CodPrestamo = Pagos.CodPrestamo) AS Datos) AS Datos  
  
  
  
 Update #Resultado  
 Set SaldoCuota = 0  
 Where SaldoCapital = CapitalPagado  
  
 UPDATE #Resultado  
 Set CA = ((tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE + tCsCartera.SaldoINPE + tCsCartera.CargoMora + tCsCartera.OtrosCargos + tCsCartera.Impuestos)  
         / (tCsCartera.NroCuotas - tCsCartera.NroCuotasPagadas)) * (tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas),   
  ConsultaPago = 'PAGADO'  
 FROM         tCsCartera INNER JOIN  
        #Resultado ON tCsCartera.CodPrestamo = #Resultado.CodPrestamo AND tCsCartera.CuotaActual = #Resultado.SecCuota  
 WHERE     (tCsCartera.Fecha = @Fecha - 1) And SaldoCuota = 0  
  
 UPDATE #Resultado  
 Set CA = ((tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE + tCsCartera.SaldoINPE + tCsCartera.CargoMora + tCsCartera.OtrosCargos + tCsCartera.Impuestos)  
         / (tCsCartera.NroCuotas - tCsCartera.NroCuotasPagadas)) * (tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas)  
 FROM         tCsCartera INNER JOIN  
        #Resultado ON tCsCartera.CodPrestamo = #Resultado.CodPrestamo AND tCsCartera.CuotaActual = #Resultado.SecCuota  
 WHERE     (tCsCartera.Fecha = @Fecha - 1) And SaldoCuota > 0 And ConsultaPago <> 'PAGADO'  
  
 Delete from #Resultado where  CodPrestamo + ltrim(rtrim(str(Seccuota, 5,0))) in (  
 SELECT     Uno.CodPrestamo + ltrim(rtrim(str(Uno.Cuota, 5,0)))   
 FROM         (SELECT     Filtro.CodPrestamo, Filtro.Cuota  
         FROM          (SELECT     Filtro_3.CodPrestamo, MAX(#Resultado_1.SecCuota) AS Cuota  
               FROM          (SELECT     CodPrestamo  
                     FROM          #Resultado  
                     GROUP BY CodPrestamo  
                     HAVING      (COUNT(*) > 1)) AS Filtro_3 INNER JOIN  
                    #Resultado AS #Resultado_1 ON Filtro_3.CodPrestamo = #Resultado_1.CodPrestamo  
               GROUP BY Filtro_3.CodPrestamo) AS Filtro INNER JOIN  
              #Resultado AS #Resultado_2 ON Filtro.CodPrestamo = #Resultado_2.CodPrestamo AND Filtro.Cuota = #Resultado_2.SecCuota  
         WHERE      (#Resultado_2.CA = 0)) AS Uno INNER JOIN  
         (SELECT     Filtro_2.CodPrestamo  
        FROM          (SELECT     Filtro_1.CodPrestamo, MIN(#Resultado_1.SecCuota) AS Cuota  
              FROM          (SELECT     CodPrestamo  
                    FROM          #Resultado AS #Resultado_3  
                    GROUP BY CodPrestamo  
                    HAVING      (COUNT(*) > 1)) AS Filtro_1 INNER JOIN  
                      #Resultado AS #Resultado_1 ON Filtro_1.CodPrestamo = #Resultado_1.CodPrestamo  
              GROUP BY Filtro_1.CodPrestamo) AS Filtro_2 INNER JOIN  
                #Resultado AS #Resultado_2 ON Filtro_2.CodPrestamo = #Resultado_2.CodPrestamo AND Filtro_2.Cuota = #Resultado_2.SecCuota  
        WHERE      (#Resultado_2.CA > 0)) AS Dos ON Uno.CodPrestamo = Dos.CodPrestamo)  
  
End  
If @Dato = 1  
Begin  
 IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Resultado]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)  
 Begin DROP TABLE [dbo].[Resultado] End  
   
 IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Pendientes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)  
 Begin DROP TABLE [dbo].[Pendientes] End  
  
 IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[Pendientes2]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)  
 Begin DROP TABLE [dbo].[Pendientes2] End  
  
 Select *  
 Into Pendientes  
 From #Pendientes  
  
 Select *  
 Into Pendientes2  
 From #Pendientes2  
   
 Select *    
 Into Resultado  
 From #Resultado  
 ORDER BY Cast(CodOficina as Int) ASC, ConsultaPago DESC  
   
 Drop Table #Pendientes                             
 Drop Table #Pendientes2  
  
  
End  
If @Dato = 2  
Begin  
 SELECT     ConsultaPago, SaldoCuota, PagoDia, Pretamos, PM, PP, TM, TP, ROUND((Case TM When 0 Then PP Else PM End + PP) / 2.0000, 2) AS Promedio  
 FROM         (SELECT     Detalle.ConsultaPago, Detalle.SaldoCuota, Detalle.PagoDia, Detalle.Pretamos, Detalle.SaldoCuota / (Case Total.TM When 0 then 1 Else Total.TM End) * 100 AS PM,   
              Detalle.Pretamos / CAST(Total.TP AS Decimal(15, 4)) * 100 AS PP, Total.TM, Total.TP  
         FROM          (SELECT     ConsultaPago, SUM(SaldoCuota) AS SaldoCuota, SUM(PagoDia) AS PagoDia, COUNT(*) AS Pretamos  
               FROM          (SELECT     ConsultaPago, SaldoCuota, CASE WHEN PagoDia > SaldoCuota THEN SaldoCuota ELSE PagoDia END AS PagoDia  
                 FROM          #Resultado) AS Datos  
               GROUP BY ConsultaPago) AS Detalle CROSS JOIN  
               (SELECT     SUM(SaldoCuota) AS TM, COUNT(*) AS TP  
              FROM          #Resultado) AS Total) AS Datos  
 Drop Table #Pendientes                             
 Drop Table #Pendientes2  
  
End  
If @Dato = 3  
Begin  
 Set @Cadena = 'Insert Into #Resultado (ConsultaPago,  CodPrestamo, SaldoCuota, PagoDia) SELECT ConsultaPago,  CodPrestamo, SaldoCuota, PagoDia = 0 FROM '  
 Set @Cadena = @Cadena + '(SELECT DISTINCT tCsPadronPlanCuotas.CodPrestamo, tCsPadronPlanCuotas.SecCuota, tCaCuotas_1.EstadoCuota, tCaCuotas_1.FechaPago, '  
 Set @Cadena = @Cadena + '((tCsCartera.SaldoCapital + tCsCartera.SaldoInteresCorriente + tCsCartera.SaldoINVE + tCsCartera.SaldoINPE + '  
 Set @Cadena = @Cadena + 'tCsCartera.CargoMora + tCsCartera.OtrosCargos + tCsCartera.Impuestos) / (tCsCartera.NroCuotas - tCsCartera.NroCuotasPagadas))* '  
 Set @Cadena = @Cadena + '(CASE WHEN tCsCartera.CuotaActual = tCsCartera.NroCuotasPagadas THEN tCsCartera.CuotaActual + 1 ELSE tCsCartera.CuotaActual END '  
 Set @Cadena = @Cadena + '- tCsCartera.NroCuotasPagadas) AS SaldoCuota, tCsCartera.NroCuotas, tCsCartera.CuotaActual, tCsCartera.NroCuotasPagadas, CASE '  
 Set @Cadena = @Cadena + 'WHEN tCaCuotas_1.EstadoCuota <> ''CANCELADO'' THEN ''PENDIENTE'' WHEN FechaPago > '  
 Set @Cadena = @Cadena + '''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD') + ''' THEN ''PENDIENTE'' WHEN tCaCuotas_1.EstadoCuota = ''CANCELADO'' AND FechaPago '  
 Set @Cadena = @Cadena + '= ''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''' THEN ''PAGADO'' WHEN tCaCuotas_1.EstadoCuota = ''CANCELADO'' AND FechaPago < '  
 Set @Cadena = @Cadena + '''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''' THEN ''ADELANTADO'' END AS ConsultaPago FROM tCsPadronPlanCuotas INNER JOIN '  
 Set @Cadena = @Cadena + 'tCsCartera ON tCsPadronPlanCuotas.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN (SELECT CodPrestamo, SecCuota, '  
 Set @Cadena = @Cadena + 'FechaVencimiento, FechaPago, EstadoCuota FROM [BD-FINAMIGO-DC].Finmas.dbo.tCaCuotas AS tCaCuotas_2 WHERE (FechaVencimiento = '  
 Set @Cadena = @Cadena + '''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''')) AS tCaCuotas_1 ON tCsPadronPlanCuotas.CodPrestamo = tCaCuotas_1.CodPrestamo '  
 Set @Cadena = @Cadena + 'AND tCsPadronPlanCuotas.FechaVencimiento = tCaCuotas_1.FechaVencimiento AND tCsPadronPlanCuotas.SecCuota = tCaCuotas_1.SecCuota '  
 Set @Cadena = @Cadena + 'WHERE (tCsPadronPlanCuotas.FechaVencimiento = ''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+ ''') AND '  
 Set @Cadena = @Cadena + '(tCsPadronPlanCuotas.CodOficina IN ('+ @CUbicacion +')) AND (tCsCartera.Fecha = '  
 Set @Cadena = @Cadena + '''' + dbo.fduFechaAtexto(@Fecha - 1, 'AAAAMMDD')+ ''')) AS Datos '  
   
 Print GetDate()  
 Print @Cadena  
 Exec (@Cadena)  
 Print GetDate()  
  
 SELECT     ConsultaPago, SaldoCuota, PagoDia, Pretamos, PM, PP, TM, TP, ROUND((Case TM When 0 Then PP Else PM End + PP) / 2.0000, 2) AS Promedio  
 FROM         (SELECT     Detalle.ConsultaPago, Detalle.SaldoCuota, Detalle.PagoDia, Detalle.Pretamos, Detalle.SaldoCuota / (Case Total.TM When 0 then 1 Else Total.TM End) * 100 AS PM,   
              Detalle.Pretamos / CAST(Total.TP AS Decimal(15, 4)) * 100 AS PP, Total.TM, Total.TP  
         FROM          (SELECT     ConsultaPago, SUM(SaldoCuota) AS SaldoCuota, SUM(PagoDia) AS PagoDia, COUNT(*) AS Pretamos  
               FROM          (SELECT     ConsultaPago, SaldoCuota, CASE WHEN PagoDia > SaldoCuota THEN SaldoCuota ELSE PagoDia END AS PagoDia  
                 FROM          #Resultado) AS Datos  
               GROUP BY ConsultaPago) AS Detalle CROSS JOIN  
               (SELECT     SUM(SaldoCuota) AS TM, COUNT(*) AS TP  
              FROM          #Resultado) AS Total) AS Datos  
End  
Print getdate()  
Drop Table #Resultado  
GO