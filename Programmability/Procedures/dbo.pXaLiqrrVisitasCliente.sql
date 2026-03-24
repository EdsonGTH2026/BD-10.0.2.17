SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaLiqrrVisitasCliente] @codusuario varchar(15)
as
SELECT v.codusuario
--,cl.nombrecompleto cliente
,v.fecha
,case when v.clasificacion=1 then 'Interesado'
	  when v.clasificacion=2 then 'Re agendar'
	  when v.clasificacion=3 then 'No se localiza'
	  when v.clasificacion=4 then 'Alto endeudamiento'
	  when v.clasificacion=5 then 'Sin ingresos'
		when v.clasificacion=5 then 'No le interesa'
		when v.clasificacion=5 then 'Problematico'
		when v.clasificacion=5 then 'Cambio residencia'
		when v.clasificacion=5 then 'Fallecimiento'
	  else 'No definido' end clasificacion
,case when v.estado=0 then 'Inactivo' else 'Activo' end estado
FROM tCsCALIQRRVisitas v with(nolock)
--inner join tcspadronclientes cl with(nolock) on cl.codusuario=v.codusuario
where v.codusuario=@codusuario--'AGA0505831'
GO