SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBIRenovaciones] 
as

--sp_helptext 
--exec [pCsBIRenovaciones]

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecfin smalldatetime
select @fecfin=fechaconsolidacion from vcsfechaconsolidacion

declare @mes integer 
select @mes=(month(@fecfin))

declare @fecini smalldatetime
select @fecini=dateadd(day,(-1)*day(@fecfin)+1,@fecfin)

declare @fechainicial smalldatetime
select @fechainicial ='20180131'--dateadd(month,(-12),@fecha)


declare @inicio smalldatetime
select @inicio =(select primerdia from tclperiodo with(nolock) where primerdia<=@fechainicial and ultimodia>=@fechainicial)

declare @final smalldatetime
select @final =(select ultimodia from tclperiodo with(nolock) where primerdia<=@fechainicial and ultimodia>=@fechainicial)

create table #prueba
( Fecha smalldatetime
  ,Region varchar(250)
  ,Sucursal varchar(250)
  ,MontoCancelado money
  ,Estado varchar(20)
  ,MontoRenovado money
  ,PorcRenovacion money
  ,cancelacion smalldatetime
  ,nrodiasmaximo integer
  ,secuenciacliente integer
  )

				Create table #desembolsos 
				(codusuario varchar(25)
				,desembolso smalldatetime
				,monto money)
				
				Create table #UsuariosCancelados 
				(codusuario varchar(25)
				,codoficina varchar(5)
				,monto money
				,cancelacion smalldatetime
				,nrodiasmaximo integer
				,secuenciacliente integer
				)
				
while (@inicio<=@fecha)
begin 
        set @fecini=@inicio 
        IF @final<=@fecha
          set @fecfin=@final
		ELSE 
		  set @fecfin=@fecha
		truncate table #usuarioscancelados
		truncate table #desembolsos
		
		INSERT into #usuarioscancelados
		select  codusuario,codoficina,monto,cancelacion, nrodiasmaximo, secuenciacliente from tcspadroncarteradet with(nolock)  
		where cancelacion >= @fecini and cancelacion <=  @fecfin

		Insert into #desembolsos
		Select codusuario,desembolso,monto from tcspadroncarteradet with(nolock)
		where desembolso>= @fecini and desembolso <= @fecfin


		insert into #prueba
		select @fecfin Fecha, z.nombre Region, ofi.nomoficina Sucursal, u.monto MontoCancelado,
		case when (isnull( d.desembolso,0))= 0 then 'No Renovado' else 'Renovado' end Estado
		, ISNULL(d.monto,0) MontoRenovado 
		, case when u.monto= 0 then 1 else ((isnull(d.monto,0))/ u.monto) end PorcRenovacion
		,u.cancelacion, u.nrodiasmaximo, u.secuenciacliente
		from #UsuariosCancelados u with(nolock)
		left outer join #desembolsos d with(nolock) on u.codusuario=d.codusuario
		inner join tcloficinas ofi with(nolock) on u.codoficina=ofi.codoficina
		inner join tclzona z with(nolock) on ofi.zona=z.zona
						
		set @inicio=dateadd(month,1,@inicio)
		set @final=(select ultimodia from tclperiodo with(nolock) where primerdia=@inicio)
		
	
end

select Fecha, Region, Sucursal, MontoCancelado, Estado, MontoRenovado, PorcRenovacion, Cancelacion, Nrodiasmaximo,secuenciacliente
,case when datediff(month,cancelacion,@fecha)>= 12 then 'R4'
when datediff(month,cancelacion,@fecha)>=6 then 'R3'
when datediff(month,cancelacion,@fecha)>=3 then 'R2'
when datediff(month,cancelacion,@fecha)>=1 then 'R1'
else 'R0' end Clasificacion
,case when secuenciacliente >=10 then 'C10+'
when secuenciacliente >=7 then 'C7-9'
when secuenciacliente >=4 then 'C4-6'
when secuenciacliente >=2 then 'C2-3'
else 'C1' end Ciclo
 from #prueba  where region <> 'Zona Cerradas' and nrodiasmaximo < 30 and Sucursal <>'Villa Hidalgo'

Drop table #UsuariosCancelados
Drop table #desembolsos
drop table #prueba
GO