SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [int_jjimenezm].[BI_UniversoWA] as                    

                 

-----20250701 ZCCU: Se optimiza el sp.                  

                         

declare @fecha smalldatetime                        

select @fecha = fechaconsolidacion from vcsfechaconsolidacion                        

                     

-----20250701 ZCCU: SE REALIZA UNA CONSULTA GENERAL                    

select c.CodOficina ,t.fecha,c.cartera,c.codprestamo,z.Nombre,o.NomOficina,c.CodSolicitud                  

,c.CodAsesor,d.SecuenciaCliente ,p.saldocapital,p.interesvigente ,p.interesvencido                  

,p.interesctaorden,p.moratoriovigente,p.moratoriovencido,p.moratorioctaorden ,p.cargomora                  

,p.otroscargos,p.impuestos,c.nrodiasatraso ,p.MontoDesembolsoTotal,cl.nombres ,p.telefonomovil                  

,p.Direccion,p.NUMERO ,p.COLONIA ,p.Municipio ,p.ESTADO ,p.nombre_coordinador,p.TasaIntCorriente                  

,p.nrocuotas ,r.MontoGarLiq ,c.NroDiasMax,p.NombreCliente ,e.score_valor                  

,t.SaldoCapital SaldoCapitalCa,c.MontoDesembolso,d.Monto                  

into #ptmosCA                  

from tcscarteradet t with(nolock)                        

inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo AND c.fecha=t.fecha  AND c.fecha= @fecha----20250701 ZCCU: Se corrige los campos para los joins                  

inner join tCsADatosCliCarteraActiva p with(nolock) on p.codusuario=c.CodUsuario                        

inner join  tcspadronclientes cl with(nolock) on c.CodUsuario = cl.CodUsuario                        

inner join tcloficinas o with(nolock) on o.codoficina = c.codoficina                        

inner join tclzona z on z.zona =o .zona                        

inner join tcspadroncarteradet d with(nolock) on d.CodPrestamo = c.CodPrestamo                        

inner join tcscarterareserva r with(nolock) on r.codprestamo = c.CodPrestamo and r.fecha = @fecha                        

--inner join tcsaRenovaAnticipaPreCal ra with(nolock) on t.codprestamo = ra.codprestamo                        

--inner join #Cuotas cu with(nolock) on cu.CodPrestamo=t.CodPrestamo                      

left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e WITH(NOLOCK) ON t.codprestamo=e.codprestamo                    

where  1=1                  

and t.fecha = @fecha                        

and c.cartera='ACTIVA'                        

and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))                        

                       

                       

                   

                   

select                        

Nombre region                        

,NomOficina sucursal                        

,codprestamo codprestamo                        

,CodSolicitud                        

,CodAsesor                        

,CodOficina                        

,SecuenciaCliente                        

,saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos Saldo_Pendiente                        

,nrodiasatraso                        

,MontoDesembolsoTotal credito_actual                        

,nombres nombre                        

,'521' + telefonomovil phone                        

,Direccion + ' ' + NUMERO + ', Col.' + COLONIA + ', Mun.' + Municipio + ', ' + ESTADO Direccion                        

,nombre_coordinador Promotor                        

,TasaIntCorriente Tasa                        

,nrocuotas Plazo                          

,MontoGarLiq                        

,NroDiasMax                        

,(saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos) deuda2                        

,NombreCliente                      

,isnull(score_valor,0) Score                    

--,'Ciclo 3 + Score 550-600' Universo                    

--from tcscarteradet t with(nolock)        -----20250701 ZCCU: se cambia por la tabla general                  

--inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.fecha= @fecha                        

--inner join tCsADatosCliCarteraActiva p with(nolock) on p.codusuario=c.CodUsuario                        

--inner join  tcspadronclientes cl with(nolock) on c.CodUsuario = cl.CodUsuario                  --inner join tcloficinas o with(nolock) on o.codoficina = c.codoficina                        

--inner join tclzona z on z.zona =o .zona                        

--inner join tcspadroncarteradet d with(nolock) on d.CodPrestamo = c.CodPrestamo                        

--inner join tcscarterareserva r with(nolock) on r.codprestamo = c.CodPrestamo and r.fecha = @fecha                        

----inner join tcsaRenovaAnticipaPreCal ra with(nolock) on t.codprestamo = ra.codprestamo                        

----inner join #Cuotas cu with(nolock) on cu.CodPrestamo=t.CodPrestamo                      

--left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e WITH(NOLOCK) ON t.codprestamo=e.codprestamo                    

from #ptmosCA  with(nolock)                  -----20250701 ZCCU: se usa la tabla general                  

where  1=1                      

AND codoficina not in('97','231','230','999','98','469','474','489','468','474','480','485','484','330','41','327','321','432','315','341')                    

and fecha = @fecha                        

and cartera='ACTIVA'                        

and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))                        

and NroDiasAtraso = 0                          

--and t.SaldoCapital/c.MontoDesembolso > .35                    

and SaldoCapitalCA/MontoDesembolso <= .40                    

--and Monto <= 130000                        

and NrodiasMax <= 15                    

and SecuenciaCliente >= 3                      

--and e.score_valor >= 550                  

             

               

                   

UNION ALL            

         

select                        

Nombre region                        

,NomOficina sucursal                        

,codprestamo codprestamo                        

,CodSolicitud                        

,CodAsesor                        

,CodOficina                        

,SecuenciaCliente                        

,saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos Saldo_Pendiente                        

,nrodiasatraso                        

,MontoDesembolsoTotal credito_actual                        

,nombres nombre                        

,'521' + telefonomovil phone                        

,Direccion + ' ' + NUMERO + ', Col.' + COLONIA + ', Mun.' + Municipio + ', ' + ESTADO Direccion                        

,nombre_coordinador Promotor                        

,TasaIntCorriente Tasa                        

,nrocuotas Plazo                          

,MontoGarLiq                        

,NroDiasMax                        

,(saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos) deuda2                        

,NombreCliente                      

,isnull(score_valor,0) Score                    

--,'Ciclo 3 + Score 550-600' Universo                    

--from tcscarteradet t with(nolock)        -----20250701 ZCCU: se cambia por la tabla general                  

--inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.fecha= @fecha                        

--inner join tCsADatosCliCarteraActiva p with(nolock) on p.codusuario=c.CodUsuario                        

--inner join  tcspadronclientes cl with(nolock) on c.CodUsuario = cl.CodUsuario                        

--inner join tcloficinas o with(nolock) on o.codoficina = c.codoficina                        

--inner join tclzona z on z.zona =o .zona                        

--inner join tcspadroncarteradet d with(nolock) on d.CodPrestamo = c.CodPrestamo                        

--inner join tcscarterareserva r with(nolock) on r.codprestamo = c.CodPrestamo and r.fecha = @fecha                        

----inner join tcsaRenovaAnticipaPreCal ra with(nolock) on t.codprestamo = ra.codprestamo                        

----inner join #Cuotas cu with(nolock) on cu.CodPrestamo=t.CodPrestamo                      

--left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e WITH(NOLOCK) ON t.codprestamo=e.codprestamo                    

from #ptmosCA  with(nolock)                  -----20250701 ZCCU: se usa la tabla general                  

where  1=1                      

AND codoficina in('327','321','432')                    

and fecha = @fecha          

and cartera='ACTIVA'                        

and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))                        

and NroDiasAtraso = 0                          

--and t.SaldoCapital/c.MontoDesembolso > .35                    

and SaldoCapitalCA/MontoDesembolso <= .40                    

--and Monto <= 130000                        

and NrodiasMax <= 7                    

and SecuenciaCliente >= 3                      

--and e.score_valor >= 550              

       

UNION ALL            

         

select                        

Nombre region                        

,NomOficina sucursal                        

,codprestamo codprestamo                        

,CodSolicitud                        

,CodAsesor                        

,CodOficina                        

,SecuenciaCliente                        

,saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos Saldo_Pendiente                        

,nrodiasatraso                        

,MontoDesembolsoTotal credito_actual                        

,nombres nombre                        

,'521' + telefonomovil phone                        

,Direccion + ' ' + NUMERO + ', Col.' + COLONIA + ', Mun.' + Municipio + ', ' + ESTADO Direccion                        

,nombre_coordinador Promotor                        

,TasaIntCorriente Tasa                        

,nrocuotas Plazo                          

,MontoGarLiq                        

,NroDiasMax                        

,(saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos) deuda2                        

,NombreCliente                      

,isnull(score_valor,0) Score                    

--,'Ciclo 3 + Score 550-600' Universo                    

--from tcscarteradet t with(nolock)        -----20250701 ZCCU: se cambia por la tabla general                  

--inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.fecha= @fecha                        

--inner join tCsADatosCliCarteraActiva p with(nolock) on p.codusuario=c.CodUsuario                        

--inner join  tcspadronclientes cl with(nolock) on c.CodUsuario = cl.CodUsuario                        

--inner join tcloficinas o with(nolock) on o.codoficina = c.codoficina                        

--inner join tclzona z on z.zona =o .zona                        

--inner join tcspadroncarteradet d with(nolock) on d.CodPrestamo = c.CodPrestamo                        

--inner join tcscarterareserva r with(nolock) on r.codprestamo = c.CodPrestamo and r.fecha = @fecha                        

----inner join tcsaRenovaAnticipaPreCal ra with(nolock) on t.codprestamo = ra.codprestamo                        

----inner join #Cuotas cu with(nolock) on cu.CodPrestamo=t.CodPrestamo                      

--left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e WITH(NOLOCK) ON t.codprestamo=e.codprestamo                    

from #ptmosCA  with(nolock)                  -----20250701 ZCCU: se usa la tabla general                  

where  1=1                      

AND codoficina in('315','341')                    

and fecha = @fecha              

and cartera='ACTIVA'                        

and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))                        

and NroDiasAtraso = 0                          

--and t.SaldoCapital/c.MontoDesembolso > .35                    

and SaldoCapitalCA/MontoDesembolso <= .50                    

--and Monto <= 130000                

and NrodiasMax <= 7                    

and SecuenciaCliente >= 3                      

--and e.score_valor >= 550          

             

               

                   

UNION ALL          

                   

select                        

Nombre region                        

,NomOficina sucursal                        

,codprestamo codprestamo                        

,CodSolicitud              

,CodAsesor                        

,CodOficina                        

,SecuenciaCliente                        

,saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos Saldo_Pendiente                        

,nrodiasatraso                        

,MontoDesembolsoTotal credito_actual            

,nombres nombre                        

,'521' + telefonomovil phone                        

,Direccion + ' ' + NUMERO + ', Col.' + COLONIA + ', Mun.' + Municipio + ', ' + ESTADO Direccion                        

,nombre_coordinador Promotor                        

,TasaIntCorriente Tasa                        

,nrocuotas Plazo                          

,MontoGarLiq                        

,NroDiasMax                        

,(saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos) deuda2                        

,NombreCliente                      

,score_valor Score                    

--,'Ciclo 1 Score 600+' Universo                    

----from tcscarteradet t with(nolock)                        

----inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.fecha= @fecha                        

----inner join tCsADatosCliCarteraActiva p with(nolock) on p.codusuario=c.CodUsuario                        

----inner join  tcspadronclientes cl with(nolock) on c.CodUsuario = cl.CodUsuario                        

----inner join tcloficinas o with(nolock) on o.codoficina = c.codoficina                        

----inner join tclzona z on z.zona =o .zona                        

----inner join tcspadroncarteradet d with(nolock) on d.CodPrestamo = c.CodPrestamo                        

----inner join tcscarterareserva r with(nolock) on r.codprestamo = c.CodPrestamo and r.fecha = @fecha                        

------inner join tcsaRenovaAnticipaPreCal ra with(nolock) on t.codprestamo = ra.codprestamo                        

------inner join #Cuotas cu with(nolock) on cu.CodPrestamo=t.CodPrestamo                      

----left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e WITH(NOLOCK) ON t.codprestamo=e.codprestamo                    

from #ptmosCA  with(nolock)   -----20250701 ZCCU: se usa la tabla general                  

where  1=1                          

and codoficina not in('97','231','230','999','98','469','474','489','468','474','480','485','484','330','41')                    

and fecha = @fecha                        

and cartera='ACTIVA'                        

and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))                        

and NroDiasAtraso = 0                          

--and t.SaldoCapital/c.MontoDesembolso > .35                    

and SaldoCapitalCA/MontoDesembolso <= .25                    

--and Monto <= 130000                        

and NrodiasMax <= 15                    

and SecuenciaCliente = 1                      

                   

UNION ALL                        

                       

select                        

Nombre region                        

,NomOficina sucursal                        

,codprestamo codprestamo                  

,CodSolicitud                        

,CodAsesor                        

,CodOficina                        

,SecuenciaCliente                        

,saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos Saldo_Pendiente                        

,nrodiasatraso                        

,MontoDesembolsoTotal credito_actual                        

,nombres nombre            

,'521' + telefonomovil phone                        

,Direccion + ' ' + NUMERO + ', Col.' + COLONIA + ', Mun.' + Municipio + ', ' + ESTADO Direccion                        

,nombre_coordinador Promotor                        

,TasaIntCorriente Tasa                        

,nrocuotas Plazo                          

,MontoGarLiq                        

,NroDiasMax                        

,(saldocapital + interesvigente + interesvencido + interesctaorden + moratoriovigente + moratoriovencido + moratorioctaorden + cargomora + otroscargos + impuestos) deuda2                        

,NombreCliente                      

,score_valor Score                    

--,'Ciclo 2 Score 500+' Universo                    

----from tcscarteradet t with(nolock)                        

----inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.fecha= @fecha                        

----inner join tCsADatosCliCarteraActiva p with(nolock) on p.codusuario=c.CodUsuario                        

----inner join  tcspadronclientes cl with(nolock) on c.CodUsuario = cl.CodUsuario                        

----inner join tcloficinas o with(nolock) on o.codoficina = c.codoficina                        

----inner join tclzona z on z.zona =o .zona                        

----inner join tcspadroncarteradet d with(nolock) on d.CodPrestamo = c.CodPrestamo                    

----inner join tcscarterareserva r with(nolock) on r.codprestamo = c.CodPrestamo and r.fecha = @fecha                        

------inner join tcsaRenovaAnticipaPreCal ra with(nolock) on t.codprestamo = ra.codprestamo                        

------inner join #Cuotas cu with(nolock) on cu.CodPrestamo=t.CodPrestamo                      

----left outer join [FNMGConsolidado].dbo.[tCaDesembEval] e WITH(NOLOCK) ON t.codprestamo=e.codprestamo                    

from #ptmosCA  with(nolock)   -----20250701 ZCCU: se usa la tabla general                  

where  1=1                          

and codoficina not in('97','231','230','999','98','469','474','489','468','474','480','485','484','330','41')                    

and fecha = @fecha                        

and cartera='ACTIVA'                        

and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))                        

and NroDiasAtraso = 0                          

--and t.SaldoCapital/c.MontoDesembolso > .35                    

and SaldoCapitalCA/MontoDesembolso <= .35                    

--and Monto <= 130000                        

and NrodiasMax <= 15                    

and SecuenciaCliente = 2                    

                 

DROP TABLE #ptmosCA
GO