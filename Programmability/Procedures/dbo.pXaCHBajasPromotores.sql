SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pXaCHBajasPromotores
--create procedure pXaCHBajasPromotores
--as

CREATE procedure [dbo].[pXaCHBajasPromotores]
as
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

select case when datediff(month,ingreso,salida)>=0 and datediff(month,ingreso,salida)<=3 then '0 a 3 Meses'
           when datediff(month,ingreso,salida)>=3.01 and datediff(month,ingreso,salida)<=6 then '3 a 6 Meses'
           when datediff(month,ingreso,salida)>=6.01 and datediff(month,ingreso,salida)<=9 then '6 a 9 Meses'
           when datediff(month,ingreso,salida)>=9.01 and datediff(month,ingreso,salida)<=12 then '9 a 12 Meses'
           when datediff(month,ingreso,salida)>=12.01 then ' + 12 Meses'
           else '' end Et
,dbo.fdufechaaperiodo(salida) periodo
,case when codmbaja in(1,3,5) then 'Renuncia'
                    when codmbaja in(2,4) then 'Baja'
                    else '' end motivo
, count(curp) nro
from tcsempleados with(nolock)
where estado=0 and salida>='20180101' and codpuesto=66
group by case when datediff(month,ingreso,salida)>=0 and datediff(month,ingreso,salida)<=3 then '0 a 3 Meses'
           when datediff(month,ingreso,salida)>=3.01 and datediff(month,ingreso,salida)<=6 then '3 a 6 Meses'
           when datediff(month,ingreso,salida)>=6.01 and datediff(month,ingreso,salida)<=9 then '6 a 9 Meses'
           when datediff(month,ingreso,salida)>=9.01 and datediff(month,ingreso,salida)<=12 then '9 a 12 Meses'
           when datediff(month,ingreso,salida)>=12.01 then ' + 12 Meses'
           else '' end
          ,dbo.fdufechaaperiodo(salida)
,case when codmbaja in(1,3,5) then 'Renuncia'
                    when codmbaja in(2,4) then 'Baja'
                    else '' end
GO