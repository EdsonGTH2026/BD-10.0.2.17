SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCaRptReporteMercedes] @Regiones varchar(50), @fechainicio DATETIME, @fechafinal DATETIME
AS
--SERVIDOR .17
--REPORTE QUE PIDIO MERCEDES 
--PARAMETROS QUE DEBERAN DE PASAR la región y periodo de fechas
/*--------------------------------------------------------------------
DECLARE @Regiones varchar(50)
SET @Regiones='BAJIO'

---------------------PERIODO A EVALUAR-----------------------------
DECLARE @fechainicio DATETIME
SET @fechainicio='2019-07-01'

DECLARE @fechafinal DATETIME
SET @fechafinal='2019-07-15'
--------------------------------------------------------------------*/

Declare @Fecha                SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion
 
create table #sol (
          codsolicitud varchar(15) NOT NULL,
          codoficina varchar(4) NOT NULL,
          codestadoactual tinyint NULL,
          estadoactual varchar(30) NOT NULL,
          Menor15 int NOT NULL,
          Mayor15 int NOT NULL,
          montoaprobado money NULL,
          codusuario varchar(20) NOT NULL,
          fechadesembolso smalldatetime NULL,
          codproducto char(3) NOT NULL,
          fechasolicitud smalldatetime,
          codasesor varchar(15),
          promotor varchar(200),
          tipoRegistro varchar(6),
          codestado varchar(10),
          codpromotor varchar(15)
)
insert into #sol

       select c.codsolicitud, c.codoficina, pr.estado, 
       (case  
       when pr.estado = 1 then 'Solicitado preliminar'
             when pr.estado = 2 then 'solicitado'
             when pr.estado = 3 then 'credito'
             when pr.estado = 4 then 'mesa de control'
             when pr.estado = 5 then 'aceptado'
             when pr.estado = 6 then 'fondeo'
             when pr.estado = 7 then 'entrega'
             when pr.estado = 21 then 'solicitado dev.'
             when pr.estado = 22 then 'solicitado dev.'
             when pr.estado = 23 then 'regional'
             when pr.estado = 24 then 'regional'
             when pr.estado = 31 then 'credito'
             when pr.estado = 61 then 'fondeo progresemos'
             when pr.estado = 12 then 'regional'
             when pr.estado=70 then 'prestamoentregado'
             when pr.estado=9 then 'revisionexpediente'
             when pr.estado=11 then 'anulado'
             else '?'
             end) as 
             estadoactual, 0,0, c.montoaprobado, c.codusuario, c.fechadesembolso, c.codproducto
       ,c.fechasolicitud, c.CodAsesor,e.nombrecompleto promotor, case when a.fecha is null then 'FINMAS' else 'APP' end tipoRegistro, c.CodEstado, space (15) codpromotor
       from [10.0.2.14].finmas.dbo.tcasolicitud c 
       INNER JOIN [10.0.2.14].finmas.dbo.tClOficinas o  ON c.CodOficina=o.CodOficina 
       LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tCaSolicitudApp a on a.CodOficina=c.CodOficina and a.CodSolicitud=c.CodSolicitud
       LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tCaSolicitudproce pr on pr.CodOficina=c.CodOficina and pr.CodSolicitud=c.CodSolicitud
       LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tUsUsuarios e  ON e.CodUsuario=c.CodAsesor
       LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tUsUsuarios cl  ON cl.CodUsuario=c.CodUsuario

       where fechasolicitud >= @fechainicio and fechasolicitud < @fechafinal and len (c.codsolicitud)<=12 ---PERIODO A EVALUAR--
 
		update #sol
		set codusuario=cl.codusuario
		from #sol p with(nolock)
		inner join tcspadronclientes cl with(nolock) on p.codusuario=cl.codorigen
		 
		update #sol
		set codpromotor=cl.codusuario
		from #sol p with(nolock)
		inner join tcspadronclientes cl with(nolock) on p.codasesor=cl.codorigen
		 
		create table #liqreno(codsolicitud varchar(25) not null,codoficina varchar(4),desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)
		insert into #liqreno
		select p.codsolicitud,p.codoficina,p.fechadesembolso,p.codusuario,max(a.cancelacion) cancelacion
		from #sol p with(nolock)
		left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.fechadesembolso
		--and p.codproducto = (case when a.codproducto ='370' then '370' else '170' end)
		group by p.codsolicitud,p.codoficina,p.fechadesembolso,p.codusuario
		having max(a.cancelacion) is not null
	

/************INICIO DE FILTO**************************************/
SELECT 
	--s.*,l.*,
	s.codsolicitud AS codsolicitud,
	s.codoficina AS CodOficina,
	s.montoaprobado AS MontoAprobado,
	case when l.cancelacion is null then 'Nuevo' 
		   when l.cancelacion >= @fechainicio /*'20190701'*/ and l.cancelacion<='20190731' then 'Renovacion' 
		   when l.cancelacion < @fechainicio /*'20190701'*/ then 'Reactivacion' else '?' end Tipo,
	o.nomoficina sucursal, 
	z.Nombre region,

	 case when e.codpuesto<>66 then 'HUERFANO'
	 else
	 case when e.codusuario is null then 'HUERFANO' else s.promotor end
	 end Promotor,
	 count(s.codsolicitud) AS No_SolicitudXsucursal,
	 s.tiporegistro AS TipoDeRegistro,
	 s.codestado AS Estado

	FROM #sol s
	left outer join #liqreno l with(nolock) on l.codsolicitud=s.codsolicitud and l.codoficina=s.codoficina
	inner join tClOficinas o with(nolock) on o.codoficina=s.codoficina
	inner join tclzona z with(nolock) on z.zona=o.zona
	left outer join tCsEmpleadosFecha e with(nolock) on e.codusuario=s.codpromotor and fecha= @fecha  /*'2019-07-14 00:00:00'*/
	
	WHERE z.Nombre = @Regiones /*'bajio'*/ 
	GROUP BY s.codoficina, o.nomoficina, e.codpuesto, e.codusuario, s.promotor, z.Nombre, l.cancelacion, s.codsolicitud, s.codoficina, s.montoaprobado, s.tiporegistro,
    s.codestado
	
	
	
	drop table #sol 
	drop table #liqreno 
	
GO