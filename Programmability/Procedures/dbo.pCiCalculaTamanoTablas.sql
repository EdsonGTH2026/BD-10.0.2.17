SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---sp_helptext  pCiCalculaTamanoTablas

CREATE procedure [dbo].[pCiCalculaTamanoTablas]  
as   
set nocount on  

Declare @FechaAhorros  SmallDateTime  
Declare @FechaCartera  SmallDateTime  
Declare @FechaCorte  SmallDateTime  
  
Select @FechaCorte = FechaConsolidacion  
From vCsFechaConsolidacion  
  
Exec pCsCierreLog @FechaCorte, '790 Calcular tamaño de Tablas Consolidado'  
  
UPDATE tCsCierres   
Set Cerrado = 1  
Where Fecha = @FechaCorte  
  
UPDATE tcscierres  
SET    selloelectronico = Z.SelloElectronico  
FROM tCsUDIS Z  
where Z.Fecha = tCsCierres.Fecha and tCsCierres.SelloElectronico IS NULL AND Z.SelloElectronico IS NOT NULL  
  
-- ***************************************************************************************************************************  
--if (select datepart(DW, @FechaCorte)) = 7 -- si es sabado  
-- exec sp_spaceused @updateusage = 'true'  
  
Delete From tCsTamañoTablas Where Fecha = @FechaCorte  
  
Insert Into tCsTamañoTablas    
       (Fecha      , Tabla    , Filas    , Reservado      , Data       , TamañoIndice, NoUsado)   
SELECT  @FechaCorte, so.Name,  
        --TableID      = so.ID,  
        Rows         = SUM(CASE WHEN si.IndID IN (0,1    ) THEN si.Rows           ELSE 0 END),  
        ReservedKB   = SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Reserved       ELSE 0 END) * pkb.PageKB,  
        DataKB       = SUM(CASE WHEN si.IndID IN (0,1    ) THEN si.DPages         ELSE 0 END) * pkb.PageKB  
                     + SUM(CASE WHEN si.IndID IN (    255) THEN ISNULL(si.Used,0) ELSE 0 END) * pkb.PageKB,  
        IndexKB      = SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Used           ELSE 0 END) * pkb.PageKB  
                     - SUM(CASE WHEN si.IndID IN (0,1    ) THEN si.DPages         ELSE 0 END) * pkb.PageKB  
                     - SUM(CASE WHEN si.IndID IN (    255) THEN ISNULL(si.Used,0) ELSE 0 END) * pkb.PageKB,  
        UnusedKB     = SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Reserved       ELSE 0 END) * pkb.PageKB  
                     - SUM(CASE WHEN si.IndID IN (0,1,255) THEN si.Used           ELSE 0 END) * pkb.PageKB  
   FROM dbo.SysObjects so,  
        dbo.SysIndexes si,  
        (SELECT Low/1024 AS PageKB  
           FROM Master.dbo.spt_Values   
          WHERE Number = 1  
            AND Type   = 'E'  
        ) pkb  
  WHERE si.ID = so.ID  
    AND si.IndID IN (0, 1, 255)  
    AND so.XType = 'U'  
    AND PERMISSIONS(so.ID) <> 0   
  GROUP BY so.Name,  
           so.UID,  
           so.ID,  
           pkb.PageKB  
  
GO