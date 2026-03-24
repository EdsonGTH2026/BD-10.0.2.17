SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[colocacionmiiotab1]
as 

declare @fecha smalldatetime  
set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)



declare @fecini smalldatetime 
set @fecini =cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1    

declare @fecAñoIni smalldatetime  
set @fecAñoIni= '20221001'




select 
dbo.fdufechaaperiodo(p.desembolso) periodo
,P.CODPRESTAMO 
,p.monto 
-----------´DECOMENTAR :Para sacar por ciclos.... formato que podemos usar en POWER BI
,case  when d.ciclo>= 7 then 'Ciclo 7+'  
       when d.ciclo>= 5 and d.ciclo <=6  then 'Ciclo 5-6'
       when d.ciclo>= 3 and d.ciclo <=4  then 'Ciclo 3-4'
       when d.ciclo= 2  then 'Ciclo 2'
       when d.ciclo= 1  then 'Ciclo 1'
else 'Ciclo 0' 
end rangoCiclo
,d.ciclo CICLO
---SELECT TOP 1*
from tcspadroncarteradet p with (nolock)
inner join [10.0.2.14].[finmas].[dbo].[tcaprestamos] c on c.CodPrestamo = p.CodPrestamo and c.estado<>'ANULADO'
inner join tcsCicloMIIO_230920 d on d.codprestamo=p.codprestamo
where p.desembolso>=@fecAñoIni--'20230701' 
and p.desembolso<=@fecha--'20230718' 
and p.codoficina ='999'

GO