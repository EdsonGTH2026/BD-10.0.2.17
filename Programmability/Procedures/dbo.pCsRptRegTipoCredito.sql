SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO
--------------------------------------------------------------------------
--	Sistema de Cartera 07/09/2004					--
--									--
--	Nombre Archivo :pCsRptRegTipoCredito				--
-- 	Versión : 							--
--	Modulo : 							--
--									--
--	Descripción : Permite generar el reporte Regulatorio 		--
--		      Cartera por Tipo de Credito		 	--
--		      	  Monto						--
--	Fecha (creación) : 2004/09/07					--
--	Autor : SSaravia					        --
--	Revisado por:	 						--
--	Historia :							--
--	Unidades:							--
--	Módulo Principal:               		                --
--	Rutinas Afectadas:              		                --
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[pCsRptRegTipoCredito](@FechaIni varchar(10)) 

							
with encryption  AS
set nocount on

declare @GestionActual as datetime
declare @GestionAnterior as datetime

--Set @GestionActual=(select Max(Fecha)from tCsCartera)
Set @GestionActual=(@FechaIni)
--Set @GestionAnterior=(select Max(Fecha)from tCsCartera where month(Fecha)<month(@GestionActual))

-----------DECLARACION DE TABLAS--------------
declare @tabla table(
		capitalvcg		money,	--capital vigente con garantia
		interesvcg		money,	--interes vigente con garantia
                intcobrvcg		money,	--interes cobrados del mes con garantia
                comisionvcg             money,  -- comision vigente con garantia

		capitalvsg		money,	--capital vigente sin garantia
		interesvsg      	money,	--interes vigente sin garantia
                intcobrvsg		money,	--interes cobrados del mes sin garantia
                comisionvsg             money,-- comision vigente sin garantia 

		capitalvendocg		money,	--capital vencido con garantia
		interesvendocg		money,  --interes vencido con garantia
		intcobrvendocg		money,  --interes cobrado del mes vencido con garantia
                comisionvendocg         money,  

		capitalvendosg		money,	--capital vencido sin garantia
		interesvendosg		money,  --interes vencido sin garantia
		intcobrvendosg		money,  --interes cobrado por mes vencido sin garantia
                comisionvendosg         money,
		
                capitalvendacg		money,	--capital vencida con garantia
		interesvendacg		money,	--interes vencida con garantia
		intcobrvendacg		money,	--interes cobrado del mes vencida con garantia
                comisionvendacg         money,

		capitalvendasg		money,	--capital vencida sin garantia
		interesvendasg		money,	--interes vencida sin garantia
		intcobrvendasg		money,  --interes cobrado por mes vencida sin garantia
                comisionvendasg         money,
                dias                    integer)	
                
		
declare @subtabla table(
		codprestamo	varchar(30),
		codtipocredito	int,
		estado		varchar(10),
		diasatraso	smallint,
		capital		money,
		interes		money,
		intcobrado	money,
		garantia	int,
                Comision        money)



insert into @subtabla(codprestamo,codtipocredito,estado,diasatraso,capital,interes,intcobrado,garantia,Comision)
Select C.CodPrestamo,C.CodTipoCredito, case when C.NroDiasAtraso=0   then 'VIGENTE'
                                            when     C.NroDiasAtraso<=89 then 'VENCIDO'
                                            when     C.NroDiasAtraso> 89 then 'VENCIDA' 
                                       end Esdtado,
       C.NroDiasAtraso,C.SaldoCapital,C.SaldoInteresCorriente,A.MontoPagado,isnull(g.GNoPersonal,0),isnull(ComisionDesembolso,0)Comision
From tcsCartera C
left outer join (Select CodPrestamo,Sum(MontoPagado)MontoPagado
                 From tCsPlanCuotas
                 Where CodConcepto='INTE'and Fecha=@GestionActual
                 Group by CodPrestamo)A on C.CodPrestamo=A.Codprestamo
left outer join (select Codigo,case when TipoGarantia='IPN' then 0
                               else 1  end GNoPersonal
                 from tcsgarantias
                 Where Correlativo=1)g on c.CodPrestamo=g.Codigo
Where Fecha=@GestionActual and C.Estado not in ('CASTIGADO')





insert into @tabla (
			capitalvcg,	--capital vigente con garantia
			interesvcg,	--interes vigente con garantia
			intcobrvcg,	--interes cobrados del mes con garantia
			comisionvcg,     -- comision vigente con garantia

                        capitalvsg,	--capital vigente sin garantia
			interesvsg,	--interes vigente sin garantia
			intcobrvsg,	--interes cobrados del mes sin garantia
                        comisionvsg,     -- comision vigente sin garantia 


			capitalvendocg,	 --capital vencido con garantia
			interesvendocg,  --interes vencido con garantia
			intcobrvendocg,  --interes cobrado del mes vencido con garantia
                        comisionvendocg,  --comision vencido con garantia 
 
			capitalvendosg,	 --capital vencido sin garantia
			interesvendosg,  --interes vencido sin garantia
			intcobrvendosg,  --interes cobrado por mes vencido sin garantia
                        comisionvendosg,  --comision vencido sin garantia

			capitalvendacg,	--capital vencida con garantia
			interesvendacg,	--interes vencida con garantia
			intcobrvendacg,	--interes cobrado del mes vencida con garantia
                        comisionvendacg, --comision vencida sin garantia                         

			capitalvendasg,	--capital vencida sin garantia
			interesvendasg,	--interes vencida sin garantia
			intcobrvendasg,	--interes cobrado por mes vencida sin garantia
                        comisionvendasg, --comision vencida sin garantia
                        dias
                                      )
           

select 
isnull((select sum(capital) from @subtabla where estado='VIGENTE' and garantia=1),0),
isnull((select sum(interes) from @subtabla where estado='VIGENTE' and garantia=1),0),
isnull((select sum(intcobrado) from @subtabla where estado='VIGENTE' and garantia=1),0),
isnull((select sum(Comision) from @subtabla where estado='VIGENTE' and garantia=1),0),

isnull((select sum(capital) from @subtabla where estado='VIGENTE' and garantia=0),0),
isnull((select sum(interes) from @subtabla where estado='VIGENTE' and garantia=0),0),
isnull((select sum(intcobrado) from @subtabla where estado='VIGENTE' and garantia=0),0),
isnull((select sum(Comision) from @subtabla where estado='VIGENTE' and garantia=0),0),

isnull((select sum(capital) from @subtabla where estado='VENCIDO' and garantia=1),0),
isnull((select sum(interes) from @subtabla where estado='VENCIDO' and garantia=1),0),
isnull((select sum(intcobrado) from @subtabla where estado='VENCIDO' and garantia=1),0),
isnull((select sum(Comision) from @subtabla where estado='VENCIDO' and garantia=1),0),

isnull((select sum(capital) from @subtabla where estado='VENCIDO' and garantia=0),0),
isnull((select sum(interes) from @subtabla where estado='VENCIDO' and garantia=0),0),
isnull((select sum(intcobrado) from @subtabla where estado='VENCIDO' and garantia=0),0),
isnull((select sum(Comision) from @subtabla where estado='VENCIDO' and garantia=0),0),

isnull((select sum(capital) from @subtabla where estado='VENCIDA' and garantia=1),0),
isnull((select sum(interes) from @subtabla where estado='VENCIDA' and garantia=1),0),
isnull((select sum(intcobrado) from @subtabla where estado='VENCIDA' and garantia=1),0),
isnull((select sum(Comision) from @subtabla where estado='VENCIDA' and garantia=1),0),

isnull((select sum(capital) from @subtabla where estado='VENCIDA' and garantia=0),0),
isnull((select sum(interes) from @subtabla where estado='VENCIDA' and garantia=0),0),
isnull((select sum(intcobrado) from @subtabla where estado='VENCIDA' and garantia=0),0),
isnull((select sum(Comision) from @subtabla where estado='VENCIDA' and garantia=0),0),
day(@GestionActual)


select * from @tabla


--exec pCsRptRegTipoCredito '2006-09-30'	        	        

GO