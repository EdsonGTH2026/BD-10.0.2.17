SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--EXEC pCsCobranzaFormiik
--DROP PROC pCsCobranzaFormiik
CREATE PROCEDURE [dbo].[pCsCobranzaFormiik]
AS
CREATE TABLE #AProcesar(InternalID INT, ExternalId VARCHAR(50), CodUsuario VARCHAR(25), CodPrestamo VARCHAR(25), Fecha SMALLDATETIME, Hora DATETIME) 
INSERT INTO #AProcesar
SELECT InternalID, ExternalId, pcd.codusuario, f.codprestamo, FinamigoConsolidado.dbo.fduFechaATexto(f.InitialDate, 'AAAAMMDD') Fecha,     
       right(f.InitialDate,8) Hora
  FROM dbFormiik..FormatoCobranza f
 INNER JOIN FinamigoConsolidado..tCsPadronCarteraDet pcd ON f.codprestamo = pcd.codprestamo 
  LEFT OUTER JOIN FinamigoConsolidado..tSgUsuarios  u ON u.usuario = f.AssignedTo
  LEFT OUTER JOIN FinamigoConsolidado..tcsempleados e ON u.codusuario = e.codusuario 
  LEFT OUTER JOIN FinamigoConsolidado..tCsClParentesco p ON f.Parentesco = p.CodParentesco
 WHERE f.EstadoSubida IS NULL 
   AND f.fechapromesapago is null or f.fechapromesapago not like '%/-%'
 
INSERT INTO tCsCaSegCartera
          ( CodUsuario,	TipoSeguimiento, Fecha, Hora, Codprestamo, Relacion, Nombrecompleto, Resultado, Observacion, CodUsuarioReg, CodUsuarioSup, 
            FechaSeg, FechaCompro, horacompro, horaseg, ObsSupervisor, FechaUltEdicion, CodOficina, MontoCompro, Prioridad, Motivo, TipoContacto, 
            formapago, mailase,	mailger, mailreg, mailcor, genorden )  --*/
SELECT pcd.codusuario, 
       '1' TipoSeguimiento, 
       FinamigoConsolidado.dbo.fduFechaATexto(f.InitialDate, 'AAAAMMDD') Fecha,     --FinamigoConsolidado.dbo.fduFechaATexto(f.ResponseDate, 'AAAAMMDD') Fecha,     
       right(f.InitialDate,8) Hora, 
       f.codprestamo, 
       isnull(f.Parentesco,7) Relacion,
       --7 Relacion,   select * from tCsClParentesco
       case quien_atiende 
            when 'Titular'  then TitularApPaterno+' '+TitularApMaterno+' '+TitularNombres
            when 'Codeudor' then CodeudorApPaterno+' '+CodeudorApMaterno+' '+CodeudorNombres 
            when 'Aval'     then AvalApPaterno+' '+AvalApMaterno+' '+AvalNombres
            else f.NombrePersonaAtendio end NombreCompleto,
       isnull(case when ResultGestionSiAtendio is null 
					then 'No atendio: '+ case ResultGestionNoAtendio 
											  when 1 then 'Se esconde' 
											  when 2 then 'Sin Contacto'            
											  when 3 then 'No se encontro' end 
					else 'Si atendio. Acuerdo: '+
						 case ResultGestionSiAtendio
											  when 1 then 'Compromiso de pago'
											  when 2 then 'No acepta pagar'
											  when 3 then 'Envío Jurídico'
											  when 4 then 'Ofrece Garantia'
											  when 5 then 'Envío a despacho'
											  when 6 then 'Solicita refinanciamiento'
											  when 7 then 'No aceptó dar mensaje'
											  when 8 then 'Si acepta dar mensaje' end end +'.'+
					' Estatus de la Cobranza: '+case when EstatusDeLaCobranza is null 
													 then 'N/E'
													 else case EstatusDeLaCobranza
														  when 'C'   then 'Convenio Comercial'
														  when 'CO'  then 'Conciliación'
														  when 'CVP' then 'Convenio plazo'
 														  when 'DE'  then 'Demanda'
														  when 'DP'  then 'Dación de pago'
														  when 'E'   then 'Embargo'
														  when 'I'   then 'Ilocalizable'
														  when 'L'   then 'Localizable'
														  when 'NP'  then 'Negativa de pago'
														  when 'PP'  then 'Promesa de pago'
														  when 'SE'  then 'Sentencia'
														  when 'VI'  then 'Visita ' end end,'') Resultado,
	   'Estrategia Aplicada: '+f.EstrategiaAplicada +'. Razón Incumplimiento: '+ f.RazonIncumplimientoCompromiso Observacion,
       u.CodUsuario CodUsuarioReg,
       f.AcompanianteCobranza CodUsuarioSup,
       NULL FechaSeg, --FinamigoConsolidado.dbo.fduFechaATexto(f.ResponseDate, 'AAAAMMDD') FechaSeg,
       FinamigoConsolidado.dbo.fduFechaATexto(f.FechaPromesaPago, 'AAAAMMDD') FechaCompro,
       convert(datetime,'00:00:00') HoraCompro,-- right(f.FechaPromesaPago,8) HoraCompro,   
       right(f.ResponseDate,8) HoraSeg,  
       '' ObsSupervisor, 
       FinamigoConsolidado.dbo.fduFechaATexto(f.ResponseDate, 'AAAAMMDD') FechaUltEdicion, 
       pcd.CodOficina, 
       isnull(MontoDelPago,0) MontoCompro,
       NULL Prioridad, 
       10 Motivo,  --Fijo Formiik
       1 TipoContacto, 
       f.TipoCompromiso Formapago, 
       0 mailase,	
       0 mailger, 
       0 mailreg, 
       0 mailcor, 
       NULL genorden
  FROM dbFormiik..FormatoCobranza f
 INNER JOIN #AProcesar t ON f.InternalID = t.InternalID  AND f.ExternalId = t.ExternalId 
 INNER JOIN FinamigoConsolidado..tCsPadronCarteraDet pcd ON f.codprestamo = pcd.codprestamo 
  LEFT OUTER JOIN FinamigoConsolidado..tSgUsuarios  u ON u.usuario = f.AssignedTo
  LEFT OUTER JOIN FinamigoConsolidado..tcsempleados e ON u.codusuario = e.codusuario 
  LEFT OUTER JOIN FinamigoConsolidado..tCsClParentesco p ON f.Parentesco = p.CodParentesco
 WHERE f.EstadoSubida IS NULL  
   
   
UPDATE f
   SET f.EstadoSubida = 1
  FROM #AProcesar t,  dbFormiik..FormatoCobranza f, tCsCaSegCartera s
 WHERE f.InternalID = t.InternalID 
   AND f.ExternalId = t.ExternalId 
   AND t.CodPrestamo = s.CodPrestamo
   AND t.CodUsuario  = s.CodUsuario
   AND t.Fecha       = s.Fecha
   AND t.Hora        = s.Hora
   AND s.motivo = 10

 drop table #AProcesar
 
--update dbFormiik..FormatoCobranza set estadosubida = NULL
--select fechapromesapago,* from dbFormiik..FormatoCobranza
--delete from tCsCaSegCartera where motivo = 10-- AND codprestamo = '078-157-06-03-00105'
--select resultado,* from tCsCaSegCartera where motivo = 10

GO