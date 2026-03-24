SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCARenGeneraSolicitud] @CodSolicitud varchar(20), @CodOficina varchar(4)
as
	--declare @CodSolicitud varchar(20)
	--declare @CodOficina varchar(4)
	--set @CodSolicitud='SOL-0001893'--'SOL-0001803'
	--set @CodOficina='341'

	set nocount on
	declare @codusuario varchar(15)
	select @codusuario=codusuario from [10.0.2.14].finmas.dbo.tcaprestamos where CodSolicitud=@CodSolicitud and codoficina=@codoficina

	declare @CodSolicitud_New varchar(20)

	select @CodSolicitud_New=s.codsolicitud--,s.codoficina,s.codusuario,s.fechadesembolso,s.montoaprobado
	from [10.0.2.14].finmas.dbo.tcasolicitud s
	inner join [10.0.2.14].finmas.dbo.tCaSolicitudApp a on s.codsolicitud=a.codsolicitud and s.codoficina=a.codoficina
	left outer join [10.0.2.14].finmas.dbo.tCaSolicitudproce p on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina
	where s.codoficina=@codoficina and p.idproceso is null and s.codestado='TRAMITE' and codusuario=@codusuario

	--select @CodSolicitud_New
	if (@CodSolicitud_New is null)
	begin
		/*SI NO EXISTE SOLICITUD PARA EL CLIENTE*/
		create table #tmp (CodSolicitud varchar(20), CodOficina varchar(4))
		insert into #tmp
		exec [10.0.2.14].finmas.dbo.pCaCrearSolicitudRenovacionCiclo @CodSolicitud,@CodOficina  --prodccion
		--exec [10.0.2.14].finmas_20190315ini.dbo.pCaCrearSolicitudRenovacionCiclo @CodSolicitud,@CodOficina  --pruebas
	
		insert into [10.0.2.14].finmas.dbo.tcasolicitudapp  --prodccion
		--insert into [10.0.2.14].finmas_20190315ini.dbo.tcasolicitudapp  --pruebas
		select codsolicitud,codoficina,getdate() fecha from #tmp
		--select * from [10.0.2.14].finmas.dbo.tcasolicitudapp

		select * from #tmp

		drop table #tmp
	end
	else
		begin
			/*SI EXISTE SOLICITUD PARA EL CLIENTE SE ENVIA CODIGO EXISTENTE*/
			select @CodSolicitud_New CodSolicitud, @CodOficina CodOficina
		end

--SOL-0002482	341
--SOL-0002483	341
--SANCHEZ MOLINA ARMANDO
--select * from tCsACaLIQUI_RR where codoficina=341 and cliente='SANCHEZ MOLINA ARMANDO'
--select * from [10.0.2.14].finmas.dbo.tcaprestamos where codprestamo='341-170-06-06-01693'

GO