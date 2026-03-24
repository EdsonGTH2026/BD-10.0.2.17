SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsCaRepAvanceMetasPromotor] @fecha smalldatetime, @codoficina varchar(4)
as
BEGIN
set nocount on
	--Limpia la tabla principal en caso de que tenga fecha diferente y la vuelve a llenar
	if exists( select * from tCsCaRepAvanceMetasPromotor where fecha <> (@fecha-1))
	begin
--print 'Limpia Tabla'
		--===================================================
		--Limpia la tabla Principal
		delete from tCsCaRepAvanceMetasPromotor 

		--===================================================
		--limpia la tabla si hay registros de otra fecha
		--if exists(select * from tCsCaRepAvanMetPromDesembolsosTemp where FechaDesembolso <> @Fecha)
		--begin
			delete from tCsCaRepAvanMetPromDesembolsosTemp 
		--end
		
		--Si no existe informacion a la fecha, los inserta
		--if not exists(select * from tCsCaRepAvanMetPromDesembolsosTemp where FechaDesembolso = @Fecha)
		--begin
			insert into tCsCaRepAvanMetPromDesembolsosTemp (CodAsesor, FechaDesembolso, nroprestamos, monto )
			SELECT 	p.CodAsesor, FechaDesembolso, count(codprestamo) nroprestamos, 	sum(MontoDesembolso) monto
			FROM [10.0.2.14].finmas.dbo.tCaPrestamos as p
			WHERE FechaDesembolso>= (@Fecha-1)
			AND FechaDesembolso<= (@Fecha-1)
			AND p.CodOficina <> '97' 
			AND Estado<>'TRAMITE'AND Estado<>'ANULADO' 
			GROUP BY p.CodAsesor, FechaDesembolso
		--end

		--===================================================
		delete from tCsCaRepAvanMetPromAsesorMontoTemp

		--Llena la tabla
		insert into tCsCaRepAvanMetPromAsesorMontoTemp (CodAsesor, TotalPanel)
		select b.CodAsesor, 	sum(b.montoaprobado) as TotalPanel 
		from [10.0.2.14].finmas.dbo.tcasolicitudproce a 
		INNER JOIN [10.0.2.14].finmas.dbo.tcasolicitud b  ON b.CodSolicitud= a.codsolicitud AND b.codoficina=a.codoficina
		INNER JOIN [10.0.2.14].finmas.dbo.tUsUsuarios u  ON u.CodUsuario=b.CodAsesor
		INNER JOIN [10.0.2.14].finmas.dbo.tClOficinas o  ON a.CodOficina=o.CodOficina 
		WHERE 
		estado = 1 or --Solicitado preliminar
		estado = 2 or -- solicitado
		estado = 3 or -- creditoexce
		estado = 4 or -- mesa de control
		estado = 5 or -- aceptado
		estado = 6 or -- fondeo
		estado = 7 or -- entrega
		estado = 21 or -- solicitado dev.
		estado = 22 or -- solicitado dev.
		estado = 23 or -- regional
		estado = 24 or -- regional 
		estado = 31 or -- credito
		estado = 61 -- fondeo progresemos
		group by b.CodAsesor
	end

	--Genera informacion si la tabla esta vacia
	if not exists( select * from tCsCaRepAvanceMetasPromotor where fecha = (@fecha-1))
	begin
--print 'Genera informacion'
		--Vuelve a cargar la tabla principal, pero solo una vez
		exec pCsCaRepAvanceMetasPromotorV3 @Fecha 
	end

--print 'Regresa la información'
	--regresa el resultado de la tabla principal
	select Fecha, Region, CodOficina, Sucursal, CodPromotor, Promotor, CarteraVigIni, CarteraVigAlDia, Crecimiento, MetaCrecimiento, CobranzaProg, ColocadoHoy, EnPanel, FaltaParaMeta, EnRiesgoVencida        
	from tCsCaRepAvanceMetasPromotor
	order by Sucursal
END
GO