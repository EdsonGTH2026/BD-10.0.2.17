SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

--------------------------------------------------------------------------
--	Sistema de Verificación 2.00 15/06/04 				--
--									--
--	Nombre Archivo : pCsRptReporteR04       			--
-- 	Versión : BO-1.00						--
--	Modulo : Interface Local					--
--									--
--	Descripción : Genera un archivo con las relaciones de tablas co---
--	rrecta para qeu luego sea ésta comparada con la base de datos  	--
--	a prueba							--
--	Fecha (creación) : 2004/03/20					--
--	Autor : EArruaza						--
--	Revisado por:   						--
--	Historia :							--
--	Unidades:							--
--	Módulo Principal:                                    	 	--
--	Rutinas Afectadas:                                     		--
--------------------------------------------------------------------------

CREATE PROC  [dbo].[pCsRptReporteR04](
             @FechaIni as varchar(10))
WITH ENCRYPTION AS
set nocount on

declare @GestionActual as datetime
declare @GestionAnterior as datetime

Set @GestionActual=(@FechaIni)
Set @GestionAnterior=(select Max(Fecha)from tCsCartera where month(Fecha)<month(@GestionActual))


Select  'cl.NombreCompleto' Cliente,c.CodUsuario,c.CodPrestamo,'FISICA'Persona,'rtrim(cl.CodDocIden)+ +rtrim(cl.DI)'CodDocIden,
        c.Estado,c.SaldoCapital,c.FechaDesembolso,c.FechaVencimiento,isnull(x.Interes,0)Interes,isnull(x.SaldoInteres,0)SaldoInteres,
        isnull(y.SaldoInteresVencido,0)SaldoInteresVencido,0 Capitalizar,isnull(c.NumReprog,0)NumReprog,isnull(c.NroDiasAtraso,0) DiasMora,
        case when ModalidadPlazo='A' Then 'ANUAL'
             when ModalidadPlazo='D' then 'DIA'
             when ModalidadPlazo='M' then 'MES'
             when ModalidadPlazo='Q' then 'QUINCENA'
             when ModalidadPlazo='S' then 'SEMANA'
        end
        DescTipoPlaz,'---------' TipoAcred,'----------'Reciproc,'-------------'CrditRegTrans,c.Estado Situacion
from tCsCartera c
left outer join (Select Codprestamo,sum(MontoCuota)Interes,Sum(MontoDevengado-MontoPagado-MontoCondonado)SaldoInteres
                 From tCsPlanCuotas
                 Where CodConcepto='INTE'and Fecha=@GestionActual
                 Group by CodPrestamo)x on c.CodPrestamo=x.Codprestamo             
left outer join (Select Codprestamo,Sum(MontoDevengado-MontoPagado-MontoCondonado)SaldoInteresVencido
                 From tCsPlanCuotas
                 Where CodConcepto='INTE'and Fecha=@GestionActual and EstadoCuota='VENCIDO'
                 Group by CodPrestamo)y on c.CodPrestamo=y.Codprestamo             
left outer join (Select distinct a.CodUsuario,a.NombreCompleto,a.DI,a.CodDocIden,a.CodOficina 
                 From tCsClientes a)cl on c.CodUsuario=cl.CodUsuario and c.CodOficina=cl.CodOficina
Where Fecha=@GestionActual and  c.estado not in ('CASTIGADO')


--exec pCsRptReporteR04 '10/03/2006'

GO