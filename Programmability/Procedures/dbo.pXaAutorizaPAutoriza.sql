SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaAutorizaPAutoriza] @id int,@usuario varchar(25)
as
--select * 
--from [10.0.2.14].finmas_13072017.dbo.tSgAutoGenerada 
--where idautogenerada=59935--@id

--delete from [10.0.2.14].finmas_13072017.dbo.tSgAutoFirmas where idautoriza=@id--59935--

--insert [10.0.2.14].finmas_13072017.dbo.tSgAutoFirmas(idautoriza,codusuarioauto,codusuariosoli,tipoauto,fechahora,desde)
--select a.idautogenerada,s.codusuario,a.coduscreo,'E',getdate(),3
--from [10.0.2.14].finmas_13072017.dbo.tSgAutoGenerada a
--cross join (select codusuario from [10.0.2.14].finmas_13072017.dbo.tsgusuarios where usuario='avillanuevag') s
--where a.idautogenerada=@id--59935--

--update [10.0.2.14].finmas_13072017.dbo.tSgAutoGenerada
--set completada=1
--where idautogenerada=@id--59935--

delete from [10.0.2.14].finmas.dbo.tSgAutoFirmas where idautoriza=@id--59935--

insert [10.0.2.14].finmas.dbo.tSgAutoFirmas (idautoriza,codusuarioauto,codusuariosoli,tipoauto,fechahora,desde)
select a.idautogenerada,s.codusuario,a.coduscreo,'E',getdate(),3
from [10.0.2.14].finmas.dbo.tSgAutoGenerada a
cross join (select codusuario from [10.0.2.14].finmas.dbo.tsgusuarios where usuario=@usuario--'avillanuevag'
) s
where a.idautogenerada=@id--59935--

update [10.0.2.14].finmas.dbo.tSgAutoGenerada
set completada=1
where idautogenerada=@id--59935--
GO