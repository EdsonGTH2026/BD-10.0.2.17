SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBIColDeter] 
as

--sp_helptext [pCsBIColDeter]
--exec [pCsBIColDeter]

declare @fecha smalldatetime  
select @fecha=fechaconsolidacion from vcsfechaconsolidacion  

select  dbo.fdufechaaperiodo(desembolso) periodo, secuenciacliente,sum(monto) colocacion from tcspadroncarteradet with(NoLock)
where desembolso >= '20180101' and desembolso <= @fecha and codoficina not in ('97','230','231','98')
group by dbo.fdufechaaperiodo(desembolso),secuenciacliente
GO