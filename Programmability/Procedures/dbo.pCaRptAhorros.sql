SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--EXEC pCaRptAhorros

CREATE PROCEDURE [dbo].[pCaRptAhorros]
AS
    BEGIN
        DECLARE @Fechareporte VARCHAR;
        DECLARE @T VARCHAR(10);
        SET @T = ' 00:00:00';
        DECLARE @fecha VARCHAR(10);
        SET @fecha = CONVERT(VARCHAR, GETDATE() - 1, 120);
        SELECT Fecha, 
               NomCuenta, 
               Codcuenta AS Cuenta, 
               SaldoCuenta AS Capital, 
               Saldomonetizado, 
               Montointeres, 
               intAcumulado, 
               FechaApertura,
			   FechaVencimiento, 
               TasaInteres, 
               InteresCalculado, 
               Plazo, 
               Renovado,
               CASE
                   WHEN IdEstadocta = 'BA'
                   THEN 'Bloqueo Activo'
                   WHEN IdEstadocta = 'BC'
                   THEN 'Bloqueo Cancelado'
                   WHEN IdEstadocta = 'BP'
                   THEN 'Bloqueo Parcial'
                   WHEN IdEstadocta = 'CA'
                   THEN 'Cuenta Activa'
                   WHEN IdEstadocta = 'CB'
                   THEN 'Cuenta Bloqueada Parcial'
                   WHEN IdEstadocta = 'CC'
                   THEN 'Cuenta Cerrada'
                   WHEN IdEstadocta = 'CE'
                   THEN 'Cuenta Extornada'
                   WHEN IdEstadocta = 'CF'
                   THEN 'Cuenta DPF que venció su plazo y no recogió'
                   WHEN IdEstadocta = 'CI'
                   THEN 'Cuenta Inactiva'
                   WHEN IdEstadocta = 'CP'
                   THEN 'Cuenta Pignorada'
                   WHEN IdEstadocta = 'CR'
                   THEN 'Cuenta Retenida'
                   WHEN IdEstadocta = 'CS'
                   THEN 'Cuenta para sorteo'
                   WHEN IdEstadocta = 'CT'
                   THEN 'Cuenta Bloqueada Total'
                   WHEN IdEstadocta = 'CV'
                   THEN 'Cuenta de DPF lista para ser cancelada'
                   WHEN IdEstadocta = 'IC'
                   THEN 'Intereces/capital cancelado por cierre anticipado'
                   WHEN IdEstadocta = 'IE'
                   THEN 'Interes Extornado'
                   WHEN IdEstadocta = 'IL'
                   THEN 'Interes Pagado Parcialmente'
                   WHEN IdEstadocta = 'IP'
                   THEN 'Intereses o capital a pagar o pendiente'
                   WHEN IdEstadocta = 'IR'
                   THEN 'Interes/Capital retirado por el cliente'
                   WHEN IdEstadocta = 'IV'
                   THEN 'Interes en ventanilla'
                   WHEN IdEstadocta = 'SA'
                   THEN 'Solicitud Aceptada'
                   WHEN IdEstadocta = 'SC'
                   THEN 'Solicitud Completa'
                   WHEN IdEstadocta = 'SE'
                   THEN 'Solicitud Eliminada'
                   WHEN IdEstadocta = 'SN'
                   THEN 'Solicitud Anulada'
                   WHEN IdEstadocta = 'SP'
                   THEN 'Solicitud Pendiente'
                   WHEN IdEstadocta = 'SR'
                   THEN 'Solicitud Rechazada'
                   WHEN IdEstadocta = 'TA'
                   THEN 'Transacción Activa'
                   WHEN IdEstadocta = 'TC'
                   THEN 'Transacción Cancelada'
                   WHEN IdEstadocta = 'UI'
                   THEN 'Usuario Inactivo'
                   ELSE 'Cuenta alta por servicio web' --IdEstadocta ='WC'
               END IdEstadocta, 
        (
            SELECT SUM(saldocuenta)
            FROM tCsAhorros WITH(NOLOCK)
        ) AS CapitalTotal, 
        (
            SELECT SUM(intAcumulado)
            FROM tCsAhorros WITH (NOLOCK)
        ) AS TotalTazaAcumulada
        FROM tCsAhorros WITH (NOLOCK)
        WHERE FECHA =@fecha+@T;
    END;



GO