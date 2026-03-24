SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-------ACTUALIZA LOS LUNES LA TABLA DE PAGOS POR PROMOTOR
---- CORRER CADA DOMINGO A REPROCESAR
create PROCEDURE  [dbo].[pCsPagosCargaDatosIni_Reproceso]  @fechaini smalldatetime                       
AS                          
SET NOCOUNT ON   
--PRIMER PASO: LIMPIAR LA TABLA DE TRABAJO PARA SEMANA 

delete from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA
--select *from FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA

--PASO 2: GENERA LA INFORMACION DEL DOMINGO
create table #seguimientoLunes (CodPrestamo  varchar(30),
CodOficina  varchar(3),
Region  varchar(30),
Sucursal  varchar(60),
Division varchar(60),
NroDiasAtraso int,
FechaConsulta smalldatetime,
FechaVencimiento smalldatetime,
DIA_DE_PAGO varchar(30),
Ciclo int,
NombreCompleto varchar(600),
Telefono varchar(30),
PagoRequerido money,
PagoAdelantado money,
Pago money,
MontoCuota money,
DeudaCuotaLejana money,
DeudaSemanaActual money,
DevengadoSemana money,
Promotor varchar(600),
Estatus varchar(30),
CubetaMoraInicial varchar(30),
SecCuota int,
SaldoCapital_Ini money)
insert into #seguimientoLunes
exec pCsSeguiPagosPromotor_Reproceso   @fechaini--- '20241117' ------ FECHA DEL DOMINGO: INICIA LA SEMANA



insert into FNMGCONSOLIDADO.DBO.tCaSeguiPagosPromotor_QA (CodPrestamo,CodOficina,Region  ,Sucursal ,Division,
NroDiasAtraso_Ini ,FechaConsulta_Ini ,FechaVencimiento ,DIA_DE_PAGO,Ciclo ,NombreCompleto ,Telefono ,
PagoRequerido_Ini ,PagoAdelantado_Ini ,Pago_Ini ,MontoCuota_Ini ,DeudaCuotaLejana_Ini ,
DeudaSemanaActual_Ini ,DevengadoSemana_Ini ,Promotor ,Estatus_Ini ,CubetaMora_Ini ,SecCuota ,
NroDiasAtraso_Segui,FechaActualiza ,
PagoRequerido_Segui ,
PagoRequeridoDinamico_Segui ,
PagoActual_Segui ,
MontoCuota_Segui ,
DeudaCuotaLejana_Segui ,
DeudaSemanaActual_Segui ,
DevengadoSemana_Segui ,
EstatusActual_Segui ,SaldoCapital_Ini)

select CodPrestamo,CodOficina,Region  ,Sucursal ,Division
,isnull(NroDiasAtraso,0) NroDiasAtraso_Ini 
,FechaConsulta FechaConsulta_Ini 
,FechaVencimiento 
,DIA_DE_PAGO
,Ciclo 
,NombreCompleto 
,Telefono 
,isnull(PagoRequerido,0) PagoRequerido_Ini 
,isnull(PagoAdelantado,0) PagoAdelantado_Ini 
,isnull(Pago,0) Pago_Ini 
,isnull(MontoCuota,0) MontoCuota_Ini 
,isnull(DeudaCuotaLejana,0) DeudaCuotaLejana_Ini 
,isnull(DeudaSemanaActual,0) DeudaSemanaActual_Ini 
,isnull(DevengadoSemana,0) DevengadoSemana_Ini 
,Promotor ,Estatus Estatus_Ini ,CubetaMoraInicial CubetaMora_Ini ,SecCuota  
,isnull(NroDiasAtraso,0) NroDiasAtraso_Segui,
FechaConsulta FechaActualiza ,
isnull(PagoRequerido,0) PagoRequerido_Segui ,
isnull(PagoRequerido,0) PagoRequeridoDinamico_Segui ,
(isnull(PagoAdelantado,0) + isnull(Pago,0)) PagoActual_Segui ,
isnull(MontoCuota,0) MontoCuota_Segui ,
isnull(DeudaCuotaLejana,0) DeudaCuotaLejana_Segui ,
isnull(DeudaSemanaActual,0) DeudaSemanaActual_Segui ,
isnull(DevengadoSemana,0)  DevengadoSemana_Segui ,
Estatus EstatusActual_Segui ,
isnull(SaldoCapital_Ini,0)  SaldoCapital_Ini
from #seguimientoLunes with(nolock)


drop table #seguimientoLunes



GO