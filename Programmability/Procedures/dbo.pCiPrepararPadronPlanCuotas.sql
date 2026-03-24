SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCiPrepararPadronPlanCuotas]
as
set nocount on
Declare @Fecha SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

--declare @T1 datetime
--declare @T2 datetime
--set @T1 = getdate()

Declare @Cadena Varchar(500)

declare @cartera table(codprestamo varchar(20))
insert into @cartera
SELECT DISTINCT CodPrestamo
FROM   tCsPadronCarteraDet with(nolock)
WHERE  FechaCorte = @Fecha --And CodOficina = @CodOficina
and codoficina not in('230','231')

DELETE FROM tCsPadronPlanCuotas
WHERE CodPrestamo IN (select codprestamo from @cartera)
and Fecha >= @Fecha - 1

/*No vamos a borrar la ultima porque es util, se borra la anterior solo queda la ultima fecha*/
delete from tcspadronplancuotas
where codprestamo in(
	select codprestamo
	from tcspadroncarteradet with(nolock)
	where cancelacion=@Fecha
)
and fecha=@Fecha-1

--set @T2 = getdate()
--print 'Tiempo 1 - '+ cast( datediff(millisecond, @T1, @T2) as varchar(10))
--set @T1 = getdate()

Insert Into tCsPadronPlanCuotas
SELECT  *
FROM  tCsPlanCuotas with(nolock)--_21042022
WHERE Fecha = @Fecha --And CodOficina = @Codoficina--'20220420'--
and codoficina not in('230','231')
and NumeroPlan=0
and seccuota>0

GO