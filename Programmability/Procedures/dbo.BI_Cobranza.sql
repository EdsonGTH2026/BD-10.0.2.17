SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[BI_Cobranza] AS  
--alter procedure BI_Cobranza as;  
declare @fecha smalldatetime  
select @fecha = fechaconsolidacion from vcsfechaconsolidacion  
--set @fecha = '20240928'  
  
SELECT codPrestamo  
 into #WA  
    FROM FNMGConsolidado.dbo.tCaDesembAutoRenovacion   
    WHERE codprestamo NOT IN (  
        SELECT codprestamonuevo   
        FROM tCsACaLIQUI_RR   
        WHERE nuevodesembolso >= '20240101'   
          AND atrasomaximo >= 17   
          AND Estado = 'Renovado'  
    )  
 AND FechaDesembolso < @fecha;  
  
SELECT   
p.CodPrestamo, p.Region,      
CASE WHEN p.Promotor in ('HERNANDEZ DUCOING V ABRAHAM BENJAMIN', 'HERNANDEZ DUCOING ABRAHAM BENJAMIN','VILLANUEVA RAMIREZ PEDRO','VILLANUEVA RAMIREZ V PEDRO') THEN 'VICTORIA'   
     WHEN p.Promotor in ('MARQUEZ LEON RENE YAMANI' ,'MARQUEZ LEON V RENE YAMANI',  
                         'TADEO RICO V EDGAR GUSTAVO', 'TADEO RICO EDGAR GUSTAVO',  
                         'CERON VIDAL ROBERTO EMMANUEL' , 'CERON VIDAL V ROBERTO EMMANUEL',  
                         'MOJICA RUIZ JOSE ALBERTO', 'MOJICA RUIZ V JOSE ALBERTO',  
                         'RODRIGUEZ DOMINGUEZ CITLALLY','RODRIGUEZ DOMINGUEZ VCITLALLY') THEN 'CARLOS A. CARRILLO'  
     WHEN p.Promotor in ('SUASTEGUI VALENTE FRANCISCO', 'RIVERA GARCIA LORENA') THEN 'SAN MARCOS'  
     WHEN p.Promotor in ('HERNANDEZ ESCOBEDO YOSEP') THEN 'PIRAMIDES'  
  when p.Promotor in ('HERNANDEZ VARGAS CESAR ALEXANDER','HERNANDEZ VARGAS V CESAR ALEXANDER',  
       'MENDEZ ROMERO JOSE GUSTAVO','MENDEZ ROMERO V JOSE GUSTAVO',  
       'VILLA SALAZAR MARISELA','VILLA SALAZAR V MARISELA') THEN 'LA PIEDAD'  
     ELSE p.Sucursal END Sucursal,   
p.NroDiasAtraso_Ini AS NroDiasAtraso,   
p.FechaConsulta_Ini AS Fecha_Consulta,   
p.FechaVencimiento,  
p.DIA_DE_PAGO AS DiaPago,  
p.NombreCompleto AS Cliente,   
p.Ciclo,  
p.Telefono,  
p.PagoRequeridoDinamico_Segui AS PagoRequerido,  
p.PagoAdelantado_Ini AS PagoAdelantado,  
p.PagoActual_Segui - PagoAdelantado_Ini AS Pago,  
p.MontoCuota_Ini AS MontoCuota,  
p.DeudaCuotaLejana_Ini AS DeudaCuotaLejana,  
p.DeudaSemanaActual_Ini AS DeudaSemanaActual,  
p.DevengadoSemana_Ini AS DevengadoSemana,  
REPLACE(p.Promotor,'VCITLALLY', 'CITLALLY') Promotor,  
p.EstatusActual_Segui AS Estatus,  
p.CubetaMora_Ini AS Cubeta,  
p.PagoRequeridoDinamico_Segui AS PagoRequeridoDinamico  
,CASE WHEN p.CodPrestamo = w.codprestamo THEN '1'  
  ELSE '0' END WA,  
@fecha Fecha_Actual  
FROM FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor p   
LEFT OUTER JOIN #WA W ON p.CodPrestamo = W.codprestamo  
WHERE FechaActualiza = @fecha;  
  
Drop table #WA
GO