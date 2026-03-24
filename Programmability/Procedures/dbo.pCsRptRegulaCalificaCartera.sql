SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
--------------------------------------------------------------------------
--	Sistema de Verificación 2.00 15/06/04 				--
--									--
--	Nombre Archivo : pCsRptRegulaCalificaCartera    		--
-- 	Versión : BO-1.00						--
--	Modulo : Interface Local					--
--									--
--	Descripción : Genera un archivo con las relaciones de tablas co---
--	rrecta para qeu luego sea ésta comparada con la base de datos  	--
--	a prueba							--
--	Fecha (creación) : 2004/06/17					--
--	Autor : SSaravia						--
--	Revisado por: VLudeño  						--
--	Historia :							--
--	Unidades:							--
--	Módulo Principal:                                    	 	--
--	Rutinas Afectadas:                                     		--
--------------------------------------------------------------------------
create proc [dbo].[pCsRptRegulaCalificaCartera](
             @FechaIni as varchar(10))
with encryption as
set nocount on
--   Estado de resumen de calificación de cartera 
--   Normales         = 0
--   Riesgo Moderado  =1
--   Riesgo Inminente =2
--   Alto Riesgo      =3
--   Incobrables      =4  

--   Vigente           =VIGENTE
--   Atraso de 30 dias =ATRASO
--   Vencida           =VENCIDA
--   Ejecucion         =EJECUCION
--   Capital           =CAPI
/* Conceptos clasificadores estado */
declare @Formulario table(
                          CodGrupo smallint,
                          Concepto varchar(50),
                          SubConcepto varchar(50),
                          Estado varchar(15),
                          Monto money default 0,
                          PorcPrevision money default 0,
                          Prevision money
                          )
declare @i smallint
------------------------------formulario  ocsac  R04 B0417----------------------------------                    
-- *****************************************************************************************
-- **************************1 Exceso (insuficiencia en reservas)***************************
-- *****************************************************************************************
insert into @Formulario
      (CodGrupo,Concepto,Monto,Prevision)     
values(1,'Exceso ó (Insuficiencia) en reservas (C-B) 2/',0,0)

-- *****************************************************************************************
-- **************************2 Otras Reservas **********************************************
-- *****************************************************************************************
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Monto,Prevision)     
values(2,'Otras Reservas','Depósitos en garantia',0,0)


declare @MontoReservaAnterior as money
declare @GestionActual as datetime
declare @GestionAnterior as datetime

--Set @GestionActual=(select Max(Fecha)from tCsCartera)
Set @GestionActual=@FechaIni
Set @GestionAnterior=(select Max(Fecha)from tCsCartera where month(Fecha)<month(@GestionActual))


set @MontoReservaAnterior= (Select Sum(ProvisionCapital) from tCsCartera where Fecha=@GestionAnterior and estado not in ('CASTIGADO'))

insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Monto,Prevision)     
values(2,'Otras Reservas','Reservas Constituidas en el perido Anterior',@MontoReservaAnterior,0)
-- *****************************************************************************************
-- **************************3 Cartera total (insuficiencia en reservas*********************
-- *****************************************************************************************
insert into @Formulario
      (CodGrupo,Concepto,Monto,Prevision)     
Select 3,'Cartera de crédito total',sum(SaldoCapital),sum(ProvisionCapital)
From tCsCartera 
Where Fecha=@GestionActual and estado not in ('CASTIGADO')     

-- *****************************************************************************************
-- **************************4 Calificación de cartera***************************************
-- *****************************************************************************************
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision,PorcPrevision)     
select 4,'Creditos comerciales','Días de Mora (Nivel Iy II)',Estado,sum(Monto) Monto,isnull(sum(Prevision),0),0
from (
          select case when NroDiasAtraso=0                  then '0 días'
            when NroDiasAtraso between 1 and 7    then '1-7 días'
            when NroDiasAtraso between 8 and 90   then '8-90 días'
            when NroDiasAtraso between 91 and 180 then '91-180 días'
            when NroDiasAtraso >=181              then '181 o más'
          end Estado,
          sum(SaldoCapital)Monto,sum(ProvisionCapital)Prevision 
          from tcscartera
          where Fecha=@GestionActual and estado not in ('CASTIGADO')
          Group by NrodiasAtraso)x
Group by x.Estado
-- *****************************************************************************************
-- **************************5 Cartera total (insuficiencia en reservas*********************
-- *****************************************************************************************
set @i=0
while @i<=5
begin
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(5,'Cartera de crédito comercial muy alta (Nivel III)','Periodos con incumplimiento',Cast(@i as varchar(1)),0,0)
set @i=@i+1
end
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(5,'Cartera de crédito comercial muy alta (Nivel III)','Periodos con incumplimiento','6  ó más',0,0)

-- *****************************************************************************************
-- **************************6 Cartera total (insuficiencia en reservas*********************
-- *****************************************************************************************
set @i=0
while @i<=5
begin
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(6,'Cartera de crédito comercial alta (Nivel III)','Periodos con incumplimiento',Cast(@i as varchar(1)),0,0)
set @i=@i+1
end
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(6,'Cartera de crédito comercial alta (Nivel III)','Periodos con incumplimiento','6  ó más',0,0)
-- *****************************************************************************************
-- **************************7 Cartera total (insuficiencia en reservas*********************
-- *****************************************************************************************
set @i=0
while @i<=5
begin
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(7,'Cartera de crédito comercial media (Nivel III)','Periodos con incumplimiento',Cast(@i as varchar(1)),0,0)
set @i=@i+1
end
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(7,'Cartera de crédito comercial media (Nivel III)','Periodos con incumplimiento','6  ó más',0,0)
-- *****************************************************************************************
-- **************************8 Cartera total (insuficiencia en reservas*********************
-- *****************************************************************************************
set @i=0
while @i<=5
begin
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(7,'Cartera de crédito comercial baja (Nivel III)','Periodos con incumplimiento',Cast(@i as varchar(1)),0,0)
set @i=@i+1
end
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(7,'Cartera de crédito comercial baja (Nivel III)','Periodos con incumplimiento','6  ó más',0,0)
-- *****************************************************************************************
-- **************************8 Cartera total (insuficiencia en reservas*********************
-- *****************************************************************************************
set @i=0
while @i<=5
begin
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(8,'Cartera de crédito comercial muy baja (Nivel III)','Periodos con incumplimiento',Cast(@i as varchar(1)),0,0)
set @i=@i+1
end
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(8,'Cartera de crédito comercial muy baja (Nivel III)','Periodos con incumplimiento','6  ó más',0,0)
--******************************************************************************************
-- **************************9 Cartera total (insuficiencia en reservas*********************
--******************************************************************************************
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(9,'Calificación (Nivel IV)','A',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(9,'Calificación (Nivel IV)','B',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(9,'Calificación (Nivel IV)','C',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(9,'Calificación (Nivel IV)','D',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(9,'Calificación (Nivel IV)','E',0,0)
--******************************************************************************************
-- **************************10 Cartera total (insuficiencia en reservas*********************
--******************************************************************************************
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(10,'Créditos al consumo','Días de Mora (Nivel I,II,III)','0',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(10,'Créditos al consumo','Días de Mora (Nivel I,II,III)','1 a 7',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(10,'Créditos al consumo','Días de Mora (Nivel I,II,III)','8 a 90',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(10,'Créditos al consumo','Días de Mora (Nivel I,II,III)','91 a 100',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(10,'Créditos al consumo','Días de Mora (Nivel I,II,III)','91 a 180',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(10,'Créditos al consumo','Días de Mora (Nivel I,II,III)','181 o más',0,0)
--******************************************************************************************
-- **************************11 Cartera total (insuficiencia en reservas*********************
--******************************************************************************************
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(11,'Calificación (Nivel IV)','A',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(11,'Calificación (Nivel IV)','B',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(11,'Calificación (Nivel IV)','C',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(11,'Calificación (Nivel IV)','D',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(11,'Calificación (Nivel IV)','E',0,0)
--******************************************************************************************
-- **************************10 Cartera total (insuficiencia en reservas*********************
--******************************************************************************************
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(12,'Créditos a la vivienda','Días de Mora (Nivel I,II,III)','0',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(12,'Créditos al vivienda','Días de Mora (Nivel I,II,III)','1 a 7',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(12,'Créditos al vivienda','Días de Mora (Nivel I,II,III)','8 a 90',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(12,'Créditos al vivienda','Días de Mora (Nivel I,II,III)','91 a 100',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(12,'Créditos al vivienda','Días de Mora (Nivel I,II,III)','91 a 180',0,0)
insert into @Formulario
      (CodGrupo,Concepto,SubConcepto,Estado,Monto,Prevision)     
values(12,'Créditos al vivienda','Días de Mora (Nivel I,II,III)','181 o más',0,0)

--******************************************************************************************
-- **************************13 Cartera total (insuficiencia en reservas*********************
--******************************************************************************************
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(13,'Calificación (Nivel IV)','A',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(13,'Calificación (Nivel IV)','B',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(13,'Calificación (Nivel IV)','C',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(13,'Calificación (Nivel IV)','D',0,0)
insert into @Formulario
      (CodGrupo,Concepto,Estado,Monto,Prevision)     
values(13,'Calificación (Nivel IV)','E',0,0)

--************************************************************************************************
--**************************************Foien llenado de 
select * 
from @Formulario 
order by codgrupo
--exec pCsRptregulaCalificaCartera '10/03/2006'
GO