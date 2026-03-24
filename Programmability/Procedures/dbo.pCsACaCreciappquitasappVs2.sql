SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


                    
CREATE procedure  [dbo].[pCsACaCreciappquitasappVs2] --@codoficina varchar(4)                    
as                    
set nocount on                       


------ Nueva version del calculo de QUITAS y ASIGNADOS  para corregir error reportado por Mauricio el 29 junio del 2024.
------ Actualizado por Silvestre el 12.07.2024.   Consultarlo para la version anterior. 

------ Cualquier crédito que cambia de promotor durante el mes, el dia en el que cambia se toma el saldo capital, y se le toma como quita, al promotor que tenia el crédito y como asignación al promotor nuevo,
------ Los saldos y nro de prestamos deven de coincidir entre Quitas y Asignados. Entonces, se toman los préstamos y saldos del último corte antes del cambio de asesor. Por lo que, los liquidados el mismo día que se cambia de asesor, van a aparecer tanto en quitas como asignados.



--begin tran

declare @fecha smalldatetime                          
--SELECT @FECHA='20240630'               
SELECT @FECHA=FECHACONSOLIDACION FROM VCSFECHACONSOLIDACION         
                          
declare @fecini smalldatetime                          
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'                          
--set @fecini=@fecini-1        ---- Ajuste del 28.01.2025  Sil.  Mau menciono la inconsistencia de que habia asignaciones del fin de mes anterior en el nuevo mes
                                 -- se corrigio @fecini de fin de mes anterior, a fecha de inicio de mes
   
   

----------------------- En #ptmosAsesor toma todos los creditos y su asesor durante el mes  (incluye vencidos)  (entre fecha de inicio de mes @fecini y a la fecha @FECHA)                                            
select distinct codprestamo, codasesor      
into #ptmosAsesor
from tcscartera with(nolock)                          
where fecha>=@fecini and fecha <= @FECHA 
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))                          
and codoficina not in('97','230','231','999')                         
--and codoficina=@codoficina                           
and cartera='ACTIVA'                          
--and nrodiasatraso>=0 and nrodiasatraso<=30--15      (al comentar se incluye prestamos vencidos)

----------------------- En #ptmos toma los creditos del mes
select distinct codprestamo      
into #ptmos
from #ptmosAsesor



----------------------- En  #FechaCambio  tomo los prestamos del mes, y su fecha de cambio de asesor             
select p.codprestamo, cd.fechacambioasesor                   
into #FechaCambio                   
from  #ptmos  p with(nolock)                     
inner join [10.0.2.14].[finmas].[dbo].[tcaprestamos] cd on cd.codprestamo=p.codprestamo                  
where cd.fechacambioasesor is not null and  cd.fechacambioasesor>=@fecini and  cd.fechacambioasesor<=@fecha


-----------------------No se usa. --- En  #FechaCambioFiltrada  agrega un filtro a los codprestamo con fechacambioasesor. Podría filtrar sólo los casos con PrimerAsesor <> UltimoAsesor, 
------------------------ pero esto filtro casos que no deberia, por eso se comento. Si se reactiva sustituir #FechaCambio por #FechaCambioFiltrada En #CarteraPreviaCambio y En #CarteraCambio

--select fc.codprestamo, fc.fechacambioasesor , PrimerAsesor, UltimoAsesor
--into #FechaCambioFiltrada
--from #FechaCambio fc
--left outer join tcspadroncarteradet p with(nolock) on p.codprestamo=fc.codprestamo
--where PrimerAsesor <> UltimoAsesor



----------------------- En #CarteraPreviaCambio  toma  asesor, prestamo, desembolso,   saldo  al ultimo corte del anterior asesor 
select 
DATEADD(day, -1, fc.fechacambioasesor) fechaPreviaCambioAsesor
,c.codasesor
,c.codprestamo
,c.saldocapital                          
,c.fechadesembolso
into #CarteraPreviaCambio                          
from tcscartera c with(nolock)                          
inner join #FechaCambio fc with(nolock) on c.codprestamo=fc.codprestamo and c.fecha= DATEADD(day, -1, fc.fechacambioasesor) -- Restar un día a fechacambioasesor
--where c.codprestamo in(select codprestamo from #ptmos with(nolock))   -- se comento porque repite el filtro del inner join



----------------------- En #CarteraCambio  toma  asesor, prestamo, desembolso,   saldo  al primer corte del nuevo asesor                      
select 
fc.fechacambioasesor
,c.codasesor
,c.codprestamo
,c.saldocapital                          
,c.fechadesembolso
into #CarteraCambio                          
from tcscartera c with(nolock)                          
inner join #FechaCambio fc with(nolock) on c.codprestamo=fc.codprestamo and c.fecha=fc.fechacambioasesor 
--where c.codprestamo in(select codprestamo from #ptmos with(nolock))   -- se comento porque repite el filtro del inner join



---------------- LIQUIDADOS
----- Los prestamos cancelados el día del cambio de asesor. No aparecen al corte con el cambio, por lo que se consulta la 2.14 
----------------------- En #ptmosLiquidadosAlCambiar toma los prestamos sin registron el dia que cambia (liquidados) 
select *
into #ptmosLiquidadosAlCambiar
from #CarteraPreviaCambio
where codprestamo not in (select CodPrestamo from #CarteraCambio) order by codprestamo

----------------------- En #asesorLiquidadosAlCambiar toma el asesor de los liquidados de la 2.14 
select codasesor, codprestamo
into #asesorLiquidadosAlCambiar
from [10.0.2.14].[finmas].[dbo].[tcaprestamos] cd 
where codprestamo in (select codprestamo from #ptmosLiquidadosAlCambiar)

----------------------- Se agregan a #CarteraCambio los liquidados con su asesor actualizado y saldo 0
insert into #CarteraCambio  
select 
DATEADD(day, +1, c.fechaPreviaCambioAsesor)
, a.codasesor  
,c.codprestamo  
,0 saldocapital   
,c.fechadesembolso
from #ptmosLiquidadosAlCambiar c
inner join #asesorLiquidadosAlCambiar a on c.codprestamo=a.codprestamo



-------------------- ACTUALIZA
----------------------- En  #CarteraCambio actualiza el saldo con #CarteraPreviaCambio 
----------------------- La idea es que el monto quitas y asignado coincidan. 
----------------------- (Mauricio indico que priorizemos el nro y saldo  al ultimo corte antes del cambio de asesor)
UPDATE cc
SET cc.saldocapital = cpc.saldocapital
FROM #CarteraCambio cc
INNER JOIN #CarteraPreviaCambio cpc    ON  cc.codprestamo = cpc.codprestamo

----------------------- Este no se usa.--- En este caso, En  #CarteraPreviaCambio actualiza el saldo con #CarteraCambio. Es decir, Priorizaria el nro y saldo  al primer corte despues del cambio de asesor
--UPDATE cpc
--SET cpc.saldocapital = cc.saldocapital
--FROM #CarteraCambio cc
--INNER JOIN #CarteraPreviaCambio cpc    ON  cc.codprestamo = cpc.codprestamo




----------------------- En  #quitas  toma el promotor, Nro de prestamos Quitas, Suma de saldos Quitas                      
select codasesor codpromotor                                             
,count(codprestamo) nro_quitas                          
,sum(saldocapital) monto_quitas 
into #quitas
from #CarteraPreviaCambio
group by codasesor


----------------------- En  #asignados  toma el promotor, Nro de prestamos Asignados, Suma de saldos Asignados
select codasesor codpromotor                                             
,count(codprestamo) nro_asignado                          
,sum(saldocapital) monto_asignado
into #asignados
from #CarteraCambio
group by codasesor







----------------------- En #asesores toma todos los codpromotor durante el mes  
select distinct codasesor      
into #codasesores
from #ptmosAsesor

----------------------- En #promotores relaciona los nombres de los promotores durante el mes  
select distinct
e.codusuario,
e.codpuesto,
case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end   codpromotor                          
,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pr.nombrecompleto end   promotor
--,c.codprestamo                        
into #promotores                          
from #codasesores c with(nolock)                          
inner join tcspadronclientes pr with(nolock) on pr.codusuario=c.codasesor                          
left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor --@fecini-->huerfano                          




----------------------- OUTPUT: Selecciona    promotor en #promotores,   Nro de ptmos y saldos en  #quitas,     Nro de ptmos y saldos Asignados  en  #asignados                     
select 
c.promotor,c.codpromotor,
isnull(q.nro_quitas,0) qui_nro_qui,
isnull(q.monto_quitas,0) qui_monto_qui,                    
isnull(a.nro_asignado,0) asi_nro_asi,
isnull(a.monto_asignado,0) asi_monto_asi                          
from #promotores c with(nolock)                          
left outer join #quitas q with(nolock) on q.codpromotor=c.codpromotor                          
left outer join #asignados a with(nolock) on a.codpromotor=c.codpromotor                     
WHERE c.codpromotor IS NOT NULL    





drop table #ptmosAsesor
drop table #ptmos
drop table #codasesores
drop table #FechaCambio 
--drop table #FechaCambioFiltrada
drop table #CarteraCambio
drop table #CarteraPreviaCambio
drop table #ptmosLiquidadosAlCambiar
drop table #asesorLiquidadosAlCambiar
drop table #quitas
drop table #asignados
drop table #promotores
                          
                   
                    
--rollback tran
GO