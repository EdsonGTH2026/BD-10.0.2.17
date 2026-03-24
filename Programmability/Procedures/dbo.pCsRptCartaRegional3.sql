SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*COBRANZA PUNTUAL */

create procedure [dbo].[pCsRptCartaRegional3]  @fecha smalldatetime,@zona varchar(5)    
as    
set nocount on 

  
--declare @fecha smalldatetime  ---LA FECHA DE CORTE  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
   

declare @fecini smalldatetime  
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes  

--Del primer dia del mes a la fecha de consulta
create table #cobranzaP (
			fecha smalldatetime,fechavencimiento smalldatetime,region varchar(15)	
			,sucursal varchar(30),atraso varchar (10),rangoCiclo varchar(10)
			,saldo money,condonado money,programado_n int,programado_s money	
			,anticipado	int,puntual int	,atrasado int,monto_anticipado money	
			,monto_puntual money,monto_atrasado	money,creditosPagados int	
			,capitalPagado	money,pagado_por money,sinpago_n int
			,sinpago_s	money,sinpago_por money,pagoparcial_n int
			,pagoparcial_s	money,parcial_por money,total_n int
			,total_s money,total_por money,orden int,promotor varchar(200))
insert into  #cobranzaP
exec pCsCACobranzaPuntual @fecha,@fecini


select fecha, z.zona,sucursal
,case when sum(programado_s)=0  then 0 else sum(monto_puntual+monto_anticipado)/sum(programado_s)end *100 CobranzaPuntual
,case when sum(programado_s)=0  then 0 else sum(monto_anticipado+monto_puntual+monto_atrasado)/sum(programado_s)end *100 AlcanceCobranza
from #cobranzaP p with(nolock)
inner join tclzona z on z.nombre=p.region
where atraso in ('0-7DM','8-30DM') and z.zona=@zona
group by fecha,z.zona,sucursal

drop table #cobranzaP
GO