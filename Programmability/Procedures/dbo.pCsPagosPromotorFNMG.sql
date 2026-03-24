SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE  [dbo].[pCsPagosPromotorFNMG]   @fechaConsolidado smalldatetime                 
AS                          
SET NOCOUNT ON  

declare @fechaactual smalldatetime
declare @fecini smalldatetime
declare @dia varchar(15)  
declare @descripcion  varchar(50)  

select @fechaactual=@fechaConsolidado--'20241128'-------- fecha consolidado

-------------------							--se corre en 2.17 entonces cuando es es domingo en consolidado, es lunes
SELECT @dia = DATENAME(weekday,@fechaactual)   -----> Si es domingo, se tienen que cargar los datos a la tabla de pagos.  
if @dia = 'Sunday'                             
 begin  
 set @fecini=@fechaactual 
 --set @descripcion='Cargar datos'
 exec pCsPagosCargaDatosIni_Reproceso  @fecini
 end  
else  
 begin                        ----Siempre colocar la fecha de inicio de semana
 set @fecini = case  when @dia = 'monday' then @fechaactual - 1 
					 when @dia = 'Tuesday' then @fechaactual - 2
					 when @dia = 'Wednesday' then @fechaactual - 3
					 when @dia = 'Thursday' then @fechaactual - 4
					 when @dia = 'Friday' then @fechaactual - 5
					 when @dia = 'Saturday' then @fechaactual - 6
					 end
 --set @descripcion='Actualizar datos'
 declare @valida int
 select @valida= COUNT(*) from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA 
 where fechaactualiza=@fechaactual-1 and FechaConsulta_Ini=@fecini
 if @valida > 0
	 begin
	  exec pCsActualizaPagosProm_Reproceso  @fecini ,@fechaactual   
	 end
 --else 
	-- begin 
	-- print 'No se logró actualizar, revisar el proceso'
	-- end
 end


--select @fechaactual,@dia,@fecini,@descripcion
declare @actualiza int

--select COUNT(*)  from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor--_QA 
--where fechaactualiza='20241124'--@fechaactual--

select @actualiza= COUNT(*) from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA 
where fechaactualiza=@fechaactual and FechaConsulta_Ini=@fecini


if @actualiza > 0
 begin 
 delete from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor where fechaactualiza=@fechaactual--'20241130'
 insert into FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor
 select * from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA
 where fechaactualiza=@fechaactual and FechaConsulta_Ini=@fecini

 end




GO