SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsACALiquidadosTodos '20180927',''
CREATE procedure [dbo].[pCsACALiquidadosTodos] @fecha smalldatetime,@codoficina varchar(2)
as
----declare @fecha smalldatetime
----set @fecha='20190228'

--truncate table tCsACALiqui

--declare @fecini smalldatetime
--set @fecini=dbo.fdufechaaperiodo(dateadd(month,-3,@fecha))+'01'
----select @fecini

--select codprestamo
--into #ptmos
--from tcspadroncarteradet p with(nolock) where p.cancelacion>=@fecini and p.cancelacion<=@fecha
--and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
--and p.codoficina not in('97','230','231')
----15,306
----15,693

--select codprestamo,max(nrodiasatraso) nrodiasatraso
--into #dias
--from tcscartera with(nolock)
--where codprestamo in (select codprestamo from #ptmos)
--group by codprestamo

--insert into tCsACALiqui
--select o.nomoficina sucursal,p.codprestamo,cl.nombrecompleto,p.cancelacion,pro.nombrecompleto coordinador
--,p.monto montoanterior
--,ca.estado,dias.nrodiasatraso
--,s.SecuenciaProductivo,s.SecuenciaConsumo
--,case when e.codusuario is null or e.codpuesto<>66 then 'Baja' else 'Activo' end EstadoPromotor
--,cr.nuevodesembolso,isnull(cr.codprestamo,'') nuevoprestamo
--,cl.telefonomovil
----into tCsACALiqui
--from tcspadroncarteradet p with(nolock)
--inner join tcloficinas o with(nolock) on p.codoficina=o.codoficina
--inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
--left outer join tCsPadronCarteraSecuen s with(nolock) on s.codprestamo=p.codprestamo
--left outer join(
--	select x.codprestamo,x.codproducto,x.codusuario,x.desembolso nuevodesembolso,x.secuenciacliente,y.secuenciaproductivo
--       ,y.secuenciaconsumo
--	from tcspadroncarteradet x
--	left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo
--	where x.desembolso>=@fecini
----) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
--) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
--       --and (case when cr.codproducto='370' then cr.secuenciaconsumo else cr.secuenciaproductivo end)
--       --       =(case when p.codproducto='370' then s.secuenciaconsumo+1 else s.secuenciaproductivo+1 end)
--left outer join tcspadronclientes pro with(nolock) on pro.codusuario=p.ultimoasesor
--left outer join tcsempleadosfecha e on e.codusuario=p.ultimoasesor and e.fecha=@fecha
--inner join tcscartera ca with(nolock) on ca.codprestamo=p.codprestamo and ca.fecha=p.fechacorte
--inner join #dias dias with(nolock) on dias.codprestamo=p.codprestamo
--where p.cancelacion>=@fecini and p.cancelacion<=@fecha
--and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
--and p.codoficina not in('97','230','231')

--drop table #dias
--drop table #ptmos
----select * from tcspadroncarteradet where codprestamo in('430-170-06-06-00679','430-170-06-04-00488')
----select * from tCsPadronCarteraSecuen where codprestamo in('430-170-06-06-00679','430-170-06-04-00488')
GO