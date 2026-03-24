SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----DETERIORO C1 desglosado por cosecha semanal&sucursal
----antigüedad semanas 4-16 (12 semanas evaluadas)


CREATE procedure [dbo].[pCsDeterioroSemanalNuevos] with encryption
as  
SET NOCOUNT ON  
BEGIN

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

--set @fecha = CAST(GETDATE() - 1 AS DATE)

declare @fecini smalldatetime
set @fecini= DATEADD(WEEK, -16,
             DATEADD(DAY,
                     -((DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST - 2) % 7),
                     CAST(GETDATE() AS DATE)));

declare @fecf smalldatetime
set @fecf=DATEADD(WEEK, -4,
             DATEADD(DAY,
                     -((DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST - 2) % 7),
                     CAST(GETDATE() AS DATE)));

--TIPO DE OPERACION 
create table #ptmos (codprestamo varchar(25))
insert into #ptmos
select distinct codprestamo
   from tcspadroncarteradet with(nolock)
where DATEADD(day, -((DATEPART(weekday, Desembolso) + @@DATEFIRST - 1) % 7), Desembolso) 
	between  @fecini and @fecf


and codoficina not in('97','230','231','999') 


and codprestamo not in (select codprestamo from tCsCarteraAlta)
 
select 

o.NomOficina sucursal
, (sum(case when c.cartera='CASTIGADA' then cd.saldocapital else 0 end) +
sum(case when c.cartera<>'CASTIGADA' and c.NroDiasAtraso>=16 	then cd.saldocapital 
	else 0 	end) )/sum(pd.monto) Deterioro16
,DATEADD(day, -((DATEPART(weekday, Desembolso) + @@DATEFIRST - 1) % 7), Desembolso) InicioSemana
  FROM tcspadroncarteradet pd with(nolock)

  left outer join tcscarteradet cd with(nolock) on cd.fecha=@fecha and cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario
  left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha
  inner join tcloficinas o with(nolock) on o.codoficina=pd.codoficina

  inner join tclzona z on z.zona=o.zona

  where pd.codprestamo in(select codprestamo from #ptmos) and pd.codoficina not in('97','230','231','999')
  and pd.CodPrestamo not in ('435-170-06-00-04873',	'339-170-06-06-15512',	'434-170-06-02-05128 ',	'435-170-06-05-05506',	'310-170-06-00-09621',	'431-170-06-00-05911',	'307-170-06-05-19145')
  and pd.SecuenciaCliente=1
  and o.zona<>'ZSC'
and tipo <> 'cerrada'
and o.CodOficina not in (
'330',	'138',	'163',	'18',	'212',	'26',	'330',	'338',	'363',
'412',	'452',	'456',	'468',	'471',	'467','479','496','473','477','474','478','475','493','480',	'483',	'484',	'485',	'489',	'469',	'41')
 group by 
 o.NomOficina
 ,DATEADD(day, -((DATEPART(weekday, Desembolso) + @@DATEFIRST - 1) % 7), Desembolso)
 order by deterioro16 desc
drop table #ptmos

END
GO

GRANT EXECUTE ON [dbo].[pCsDeterioroSemanalNuevos] TO [rie_jalvarezc]
GO

GRANT EXECUTE ON [dbo].[pCsDeterioroSemanalNuevos] TO [int_ltorresa]
GO