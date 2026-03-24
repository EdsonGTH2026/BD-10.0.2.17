SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACASMSGeneradatos] @fecha smalldatetime
as
----·       Archivo 1:  Recordatorio de primer pago
----o   Todos los créditos que vayan a tener su primer corte. Los viernes se envían los que tendrán su primer pago el lunes. ok
----·       Archivo 2: Atraso 1-7 días.
----o   Todos los créditos que tienen entre 1 y 7 días en mora de sucursales activas. ok
----·       Archivo 3: Atraso 8-30 días
----o   Todos los créditos que tienen entre 8 y 30 días en mora de suc. activas, solo debe llegar para envío los lunes, miércoles y viernes.
----·       Archivo 4: Atraso 31-90 días
----o   Todos los créditos que tienen entre 31 y 90 días en mora de suc. activos, solo debe llegar para envío los martes.
set nocount on
--declare @fecha smalldatetime
--Select @fecha=FechaConsolidacion From vCsFechaConsolidacion
--select datepart(weekday,@fecha)
declare @f smalldatetime
set @f = @fecha+2

truncate table tCsACaSMSRecordatorio
truncate table tCsACaSMSAtraso1a7
truncate table tCsACaSMSAtraso8a30
truncate table tCsACaSMSAtraso31a90

insert into tCsACaSMSRecordatorio
exec [10.0.2.14].finmas.dbo.pCsACASMSRecordatorio @f

insert into tCsACaSMSAtraso1a7
--exec [10.0.2.14].finmas.dbo.pCsACASMSAtraso1a7
exec [10.0.2.14].finmas.dbo.pCsACASMSAtrasoDiaANDia 1,7

--lunes (2), miércoles(4) y viernes(6)
if(datepart(weekday,@fecha+1) in(2,4,6)) 
	begin
		insert into tCsACaSMSAtraso8a30
		exec [10.0.2.14].finmas.dbo.pCsACASMSAtrasoDiaANDia 8,30
	end
--lunes (2)
if(datepart(weekday,@fecha+1)=2) 
	begin
		insert into tCsACaSMSAtraso31a90
		exec [10.0.2.14].finmas.dbo.pCsACASMSAtrasoDiaANDia 31,90
	end
/*
select * from tCsACaSMSRecordatorio
select * from tCsACaSMSAtraso1a7
select * from tCsACaSMSAtraso8a30
select * from tCsACaSMSAtraso31a90
*/
--create table tCsACaSMSRecordatorio (
--estado varchar(15),
--diasmora int,
--codprestamo varchar(25),
--nombrecompleto varchar(250),
--ustelefonomovil varchar(10)
--)
--create table tCsACaSMSAtraso1a7 (
--estado varchar(15),
--diasmora int,
--codprestamo varchar(25),
--nombrecompleto varchar(250),
--ustelefonomovil varchar(10)
--)
--create table tCsACaSMSAtraso8a30 (
--estado varchar(15),
--diasmora int,
--codprestamo varchar(25),
--nombrecompleto varchar(250),
--ustelefonomovil varchar(10)
--)
--create table tCsACaSMSAtraso31a90 (
--estado varchar(15),
--diasmora int,
--codprestamo varchar(25),
--nombrecompleto varchar(250),
--ustelefonomovil varchar(10)
--)
GO