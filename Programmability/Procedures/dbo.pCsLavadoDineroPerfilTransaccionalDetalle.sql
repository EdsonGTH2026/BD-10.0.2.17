SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsLavadoDineroPerfilTransaccionalDetalle] (@FechaIni smalldatetime, @FechaFin smalldatetime, @NumOperaciones int, @PersonaFisica bit)  
AS

---Prueba
--DECLARE @FechaIni smalldatetime
--DECLARE @FechaFin smalldatetime
--DECLARE @NumOperaciones int
--DECLARE @PersonaFisica bit
--SET @FechaIni ='20250801'
--SET @FechaFin ='20250831'
--SET @NumOperaciones = 11
--SET @PersonaFisica = 1
----------------

BEGIN 

DECLARE @FechaIniCA smalldatetime
DECLARE @FechaFinCA smalldatetime

SET @FechaIniCA = @FechaIni
SET @FechaFinCA = @FechaFin

 select     
 td.NroTransaccion,  
 (case td.CodSistema   
 when 'CA' then 'CREDITO'  
 when 'AH' then 'AHORRO'  
 else 'OTRO'  
 end ) as Tipo,  
 td.Fecha,   
 td.CodigoCuenta,   
 td.codusuario,  
 u.nombrecompleto,  
 td.DescripcionTran,   
 td.MontoTotalTran,  
 o.NomOficina,  
 tot.TotalTransacciones  
 from tcstransacciondiaria as td  
 inner join tcloficinas as o on o.codoficina = td.codoficina  
 inner join tCsPadronClientes as u on u.codusuario = td.codusuario   
 inner join (  --en esta tabla se obtiene la suma total de operaciones x usuario  
   select CodUsuario, TotalTransacciones   
          from (  
    select CodUsuario, count(NroTransaccion) as TotalTransacciones  
             from tCsTransaccionDiaria  
    where  
    CodSistema = 'CA' -- in ('AH','CA')  
    and TipoTransacNivel2 = 'EFEC'  
    and (DescripcionTran like '%deposito%' or DescripcionTran like '%recupera%')  
    and Fecha >= @FechaIniCA  
    and Fecha <= @FechaFinCA  
    group by CodUsuario  
        ) as t    
   where t.TotalTransacciones >= @NumOperaciones  
     ) as tot on tot.CodUsuario = td.codusuario  
 where   
 td.CodSistema = 'CA' -- in ('AH','CA')  
 and td.TipoTransacNivel2 = 'EFEC'  
 and (td.DescripcionTran like '%deposito%' or DescripcionTran like '%recupera%')  
 and td.Fecha >= @FechaIniCA  
 and td.Fecha <= @FechaFinCA  
 and ((@PersonaFisica = 1 and u.CodTPersona = '01')  
        or  
         (@PersonaFisica = 0 and u.CodTPersona <> '01'))  
 order by u.nombrecompleto, td.CodigoCuenta, td.Fecha  
END  
  
  
GO