SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCiCargaDatosOperativaConsolidado]
as
set nocount on
Declare @Fecha 	SmallDateTime
SELECT @Fecha = FechaConsolidacion + 1 FROM vCsFechaConsolidacion

Exec pCsCierreLog @Fecha, '350 Cargar Datos de la Operativa al Consolidado'

--INSERT INTO tCsAhorros Select * From [10.0.2.14].finmas.dbo.tCsAhorros --WHERE Fecha = @Fecha okkkkkkkkk
INSERT INTO tCsAhorros
exec [10.0.2.14].finmas.dbo.pCiCargaAhorros
--INSERT INTO tCsBoveda Select * From [10.0.2.14].finmas.dbo.tCsBoveda --WHERE Fecha = @Fecha
INSERT INTO tCsBoveda
exec [10.0.2.14].finmas.dbo.pCiCargaBoveda
--INSERT INTO tCsCajas Select * From [10.0.2.14].finmas.dbo.tCsCajas --WHERE Fecha = @Fecha
INSERT INTO tCsCajas
exec [10.0.2.14].finmas.dbo.pCiCargaCajas
--INSERT INTO tCscartera Select * From [10.0.2.14].finmas.dbo.tCscartera --WHERE Fecha = @Fecha
INSERT INTO tCscartera
exec [10.0.2.14].finmas.dbo.pCiCargaCartera
--INSERT INTO tCsCartera01 Select * From [10.0.2.14].finmas.dbo.tCsCartera01 --WHERE Fecha = @Fecha
INSERT INTO tCsCartera01
exec [10.0.2.14].finmas.dbo.pCiCargaCartera01
--INSERT INTO tCsClientes Select * From [10.0.2.14].finmas.dbo.tCsClientes
INSERT INTO tCsClientes
exec [10.0.2.14].finmas.dbo.pCiCargaClientes
--INSERT INTO tCsGarantias Select * From [10.0.2.14].finmas.dbo.tCsGarantias
INSERT INTO tCsGarantias
exec [10.0.2.14].finmas.dbo.pCiCargaGarantias
--INSERT INTO tCsIntPeriodicos Select * From [10.0.2.14].finmas.dbo.tCsIntPeriodicos
INSERT INTO tCsIntPeriodicos
exec [10.0.2.14].finmas.dbo.pCiCargaIntPeriodicos
--INSERT INTO tCsIntPeriodicosDetVariable Select * From [10.0.2.14].finmas.dbo.tCsIntPeriodicosDetVariable
INSERT INTO tCsIntPeriodicosDetVariable
exec [10.0.2.14].finmas.dbo.pCiCargaIntPeriodicosDetVariable
--INSERT INTO tCsOpRecuperables Select * From [10.0.2.14].finmas.dbo.tCsOpRecuperables --WHERE Fecha = @Fecha
INSERT INTO tCsOpRecuperables
exec [10.0.2.14].finmas.dbo.pCiCargaOpRecuperables
--INSERT INTO tCsPlanCuotas Select * From [10.0.2.14].finmas.dbo.tCsPlanCuotas --WHERE Fecha = @Fecha   okkkkkk
INSERT INTO tCsPlanCuotas
exec [10.0.2.14].finmas.dbo.pCiCargaPlanCuotas
--INSERT INTO tCsPrestamos Select * From [10.0.2.14].finmas.dbo.tCsPrestamos --WHERE Fecha = @Fecha
INSERT INTO tCsPrestamos
exec [10.0.2.14].finmas.dbo.pCiCargaPrestamos
--INSERT INTO tCsReformulacion Select * From [10.0.2.14].finmas.dbo.tCsReformulacion --WHERE Fecha = @Fecha
INSERT INTO tCsReformulacion
exec [10.0.2.14].finmas.dbo.pCiCargaReformulacion
--INSERT INTO tCsReformulacionDet Select * From [10.0.2.14].finmas.dbo.tCsReformulacionDet --WHERE Fecha = @Fecha
INSERT INTO tCsReformulacionDet
exec [10.0.2.14].finmas.dbo.pCiCargaReformulacionDet
--INSERT INTO tCsTransaccionDiaria Select * From [10.0.2.14].finmas.dbo.tCsTransaccionDiaria --WHERE Fecha = @Fecha
INSERT INTO tCsTransaccionDiaria
exec [10.0.2.14].finmas.dbo.pCiCargaTransaccionDiaria
--INSERT INTO tCsTransaccionDiariaOtros Select * From [10.0.2.14].finmas.dbo.tCsTransaccionDiariaOtros --WHERE Fecha = @Fecha
INSERT INTO tCsTransaccionDiariaOtros
exec [10.0.2.14].finmas.dbo.pCiCargaTransaccionDiariaOtros
--INSERT INTO tCsUsuariosRH Select * From [10.0.2.14].finmas.dbo.tCsUsuariosRH --WHERE Fecha = @Fecha
INSERT INTO tCsUsuariosRH
exec [10.0.2.14].finmas.dbo.pCiCargaUsuariosRH
GO