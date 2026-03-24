SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Create procedure BI_CAJAS as 
CREATE procedure [dbo].[BI_CAJAS] as

DECLARE @MaxD DATE, @MaxE DATE;

SELECT @MaxD = MAX(Fecha) FROM [FNMGConsolidado].[dbo].[tCaAperturaCajaBov];
SELECT @MaxE = MAX(Fecha) FROM tcsempleadosfecha;


SELECT 
    d.Fecha,
    d.CodOficina,
    d.Tipo,
    d.NumCaja,
    CONVERT(VARCHAR(8), d.Hora_Apertura, 108) AS Hora_Apertura,
    CONVERT(VARCHAR(8), d.Hora_Cierre, 108) AS Hora_Cierre,
    d.Responsable_Apertura,
	case when e.CodPuesto = 16 then 'a. Asistente Administrativo'
		 when e.CodPuesto = 17 then 'b. Asistente Administrativo Sucursal'
		 when e.CodPuesto = 20 then 'c. Cajero'
		 when e.CodPuesto = 41 then 'd. Gerente Sucursal' 
		 when e.CodPuesto = 42 then 'e. Gerente Regional' 
		 when e.CodPuesto = 63 then 'f. Gerente de Cobranza'
		 when e.CodPuesto = 64 then 'g. Gestor de Cobranza'
         when e.CodPuesto = 66 then 'h. Promotor'              
         when e.CodPuesto = 68 then 'i. Lider Volante'
		 when e.CodPuesto = 70 then 'j. Lider de Sucursal'
		 when e.CodPuesto = 71 then 'k. Lider Regional'
		 when e.CodPuesto = 95 then 'l. Auxiliar y/o Cajero'
		 when e.CodPuesto = 97 then 'm. Analista de Caja General'
		 when e.CodPuesto = 110 then 'n. Subgerente de Sucursal'
		 when e.CodPuesto = 111 then 'o. Gestor de Cobranza Regional'
		 when e.CodPuesto = 116 then 'p. Gerente Regional Operativo'
		 when e.CodPuesto = 123 then 'q. Supervisior de cajas'
		 when e.CodPuesto = 124 then 'r. Gerente Volante'
		 else '?' end Puesto 
	--e.CodPuesto
FROM [FNMGConsolidado].[dbo].[tCaAperturaCajaBov] d
LEFT OUTER join tcspadronclientes cl with(nolock) on cl.nombrecompleto = d.Responsable_Apertura
LEFT OUTER JOIN tcsempleadosfecha e WITH (NOLOCK) ON e.codusuario = cl.codusuario
where e.Fecha = d.Fecha

Union all 

SELECT 
    d.Fecha,
    d.CodOficina,
    d.Tipo,
    d.NumCaja,
    CONVERT(VARCHAR(8), d.Hora_Apertura, 108) AS Hora_Apertura,
    CONVERT(VARCHAR(8), d.Hora_Cierre, 108) AS Hora_Cierre,
    d.Responsable_Apertura,
    CASE 
         WHEN e.CodPuesto = 16 THEN 'a. Asistente Administrativo'
         WHEN e.CodPuesto = 17 THEN 'b. Asistente Administrativo Sucursal'
         WHEN e.CodPuesto = 20 THEN 'c. Cajero'
         WHEN e.CodPuesto = 41 THEN 'd. Gerente Sucursal' 
         WHEN e.CodPuesto = 42 THEN 'e. Gerente Regional' 
         WHEN e.CodPuesto = 63 THEN 'f. Gerente de Cobranza'
         WHEN e.CodPuesto = 64 THEN 'g. Gestor de Cobranza'
         WHEN e.CodPuesto = 66 THEN 'h. Promotor'              
         WHEN e.CodPuesto = 68 THEN 'i. Lider Volante'
         WHEN e.CodPuesto = 70 THEN 'j. Lider de Sucursal'
         WHEN e.CodPuesto = 71 THEN 'k. Lider Regional'
         WHEN e.CodPuesto = 95 THEN 'l. Auxiliar y/o Cajero'
         WHEN e.CodPuesto = 97 THEN 'm. Analista de Caja General'
         WHEN e.CodPuesto = 110 THEN 'n. Subgerente de Sucursal'
         WHEN e.CodPuesto = 111 THEN 'o. Gestor de Cobranza Regional'
         WHEN e.CodPuesto = 116 THEN 'p. Gerente Regional Operativo'
         WHEN e.CodPuesto = 123 THEN 'q. Supervisior de cajas'
         WHEN e.CodPuesto = 124 THEN 'r. Gerente Volante'
         ELSE '?' 
    END AS Puesto
FROM [FNMGConsolidado].[dbo].[tCaAperturaCajaBov] d
LEFT OUTER JOIN tcspadronclientes cl WITH (NOLOCK) 
    ON cl.nombrecompleto = d.Responsable_Apertura
INNER JOIN tcsempleadosfecha e WITH (NOLOCK) 
    ON e.codusuario = cl.codusuario
   AND e.Fecha = @MaxE
WHERE d.Fecha = @MaxD

ORDER BY d.Fecha, d.CodOficina 

--SELECT *
--FROM [FNMGConsolidado].[dbo].[tCaAperturaCajaBov]
--WHERE Fecha = '20250924'

--select *
--from tcspadronclientes
--where nombrecompleto in ('MARTINEZ ESTRADA DANIELA TERESITA DE JESUS')

--select *
--from tcsempleadosfecha
--where codusuario in ('MED011029FM400')
--and fecha = '20250923'
GO