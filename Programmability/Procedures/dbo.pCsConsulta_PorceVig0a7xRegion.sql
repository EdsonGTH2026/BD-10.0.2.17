SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



  
    /* Calcula el porcentage de saldo Vigente entre 0 y 7 días para las 12 semanas anteriores */
----Creado por Sil   12.02.2025 
  
CREATE procedure [dbo].[pCsConsulta_PorceVig0a7xRegion]  @fecha smalldatetime  
as  
set nocount on   
  
--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
 	
--DECLARE @fecha smalldatetime;
--SET @fecha = '20250121';


---- >>>>> Fechas a generar
CREATE TABLE #FechasDomingos (
    Fecha smalldatetime
);

-- Insertar la fecha original
INSERT INTO #FechasDomingos (Fecha)
VALUES (@fecha);

-- Obtenemos el domingo anterior más cercano (ajustado por @fecha - 1)
DECLARE @domingo smalldatetime;
SET @domingo = DATEADD(DAY, -(DATEPART(WEEKDAY, DATEADD(DAY, -1, @fecha)) - 1), DATEADD(DAY, -1, @fecha));

-- Declarar el contador para el ciclo
DECLARE @i INT;
SET @i = 0;

-- Insertar el domingo calculado y los 11 domingos anteriores
WHILE @i < 11
BEGIN
    INSERT INTO #FechasDomingos (Fecha)
    VALUES (DATEADD(WEEK, -@i, @domingo));

    SET @i = @i + 1; -- Incrementar el contador
END;

---- Fechas a calcular:
--SELECT * FROM #FechasDomingos ORDER BY Fecha DESC;




---- >>>>> Calcula el porcentaje vigente de 0 a 7 días, para las Regiones
select 
c.fecha 'Fecha',
z.Nombre Region
,z.zona 'Zona'
--,c.codoficina codoficina 
--,sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)  Vigente0a7 
,case when sum(c.saldocapital)=0 then 0 
		else sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)/sum(c.saldocapital)end *100 Imor7---- > PorceVig0a7    
from tcscartera c with(nolock)    
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina      --and c.fecha=@fecha   --para sólo reportar el saldovigente0a7 a la fecha
inner join tclzona z on z.zona=o.zona
inner join #FechasDomingos Dom on c.fecha=dom.fecha        --se comenta para sólo reportar el saldovigente0a7 a la fecha
where --c.fecha=@fecha  and
c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))    
and c.codoficina not in('97','231','230','999')  
and cartera='ACTIVA'
and z.zona not like 'ZE%' -- ('ZE1','ZE2')
group by c.fecha, z.Nombre, z.zona   --- ,c.codoficina
--order by c.fecha, z.Nombre

UNION

---- >>>>> Calcula el porcentaje vigente de 0 a 7 días, para el Total
select 
c.fecha 'Fecha',
'Expansion' Region
,'ZE' Zona
--,c.codoficina codoficina 
--,sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)  Vigente0a7 
,case when sum(c.saldocapital)=0 then 0 
		else sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)/sum(c.saldocapital)end *100 Imor7 ---- > PorceVig0a7  
from tcscartera c with(nolock)    
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina      --and c.fecha=@fecha   --para sólo reportar el saldovigente0a7 a la fecha
inner join tclzona z on z.zona=o.zona
inner join #FechasDomingos Dom on c.fecha=dom.fecha        --se comenta para sólo reportar el saldovigente0a7 a la fecha
where --c.fecha=@fecha  and
c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))    
and c.codoficina not in('97','231','230','999')  
and cartera='ACTIVA'
and z.zona like 'ZE%'
group by c.fecha--, z.Nombre, z.zona   --- ,c.codoficina
--order by c.fecha--, z.Nombre

UNION

---- >>>>> Calcula el porcentaje vigente de 0 a 7 días, para el Total
select 
c.fecha 'Fecha',
'Total' Region
,'ALL' Zona
--,c.codoficina codoficina 
--,sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)  Vigente0a7 
,case when sum(c.saldocapital)=0 then 0 
		else sum(case when c.nrodiasatraso>=0 and c.nrodiasatraso<=7 then c.saldocapital else 0 end)/sum(c.saldocapital)end *100 Imor7 ---- > PorceVig0a7  
from tcscartera c with(nolock)    
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina      --and c.fecha=@fecha   --para sólo reportar el saldovigente0a7 a la fecha
inner join tclzona z on z.zona=o.zona
inner join #FechasDomingos Dom on c.fecha=dom.fecha        --se comenta para sólo reportar el saldovigente0a7 a la fecha
where --c.fecha=@fecha  and
c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))    
and c.codoficina not in('97','231','230','999')  
and cartera='ACTIVA' 
group by c.fecha--, z.Nombre, z.zona   --- ,c.codoficina
--order by c.fecha--, z.Nombre



drop table #FechasDomingos 

GO