SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
--------------------------------------------------------------------------
--	Sistema Reportes FIMEDER 05/10/2004				--
--									--
--	Nombre Archivo : pCaRptGastosOperaciones    			--
-- 	Versión : 							--
--	Modulo : Interface Local					--
--									--
--	Descripción : Permite generar el Reporte de Cartera por 	--
--		      GastosOperaciones	             			--
--	Fecha (creación) : 2004/10/05				        --
--	Autor : SMerino							--
--	Revisado por:VLudeño   					        --
--	Historia :Se realizaron modificaciones, para que cosulte de una 
--	db consolidada eaguirre 2006/11/07 							--
--	Unidades:							--
--	Módulo Principal:               		                --
--	Rutinas Afectadas:              		                --
--	select * from tCsUsuariosRh ush 
--	pCsRptGastosOperaciones
--------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[pCsRptGastosOperaciones]( @Fecha as varchar(10)='2006-11-05' )

with encryption  AS
set nocount on

select 	case when t.tipocontrato='DETERMINADO' 
		then 'Remuneraciones y prestaciones al personal y consejeros'
		else 'Honorarios' end CLASIFICACION,
	us.nombrecompleto NOMBRE, 
	c.nomcargo PUESTO,
	case when t.tipocontrato='DETERMINADO' 
		then 'DETERMINADO'
		else 'INDEFINIDO' 
		end PERCEPCION,'' DESCRIPCION,   
	ush.sueldobasico DATO,1 ORDEN
from tCsUsuariosRh ush 
inner join tCsUsuarios us on us.codusuario=ush.codusuario 
inner join tCsClCargos c on c.codcargo=ush.codcargo
inner join tCsClTipoContrato t on t.codtipocontrato=ush.Codtipocontrato
WHERE t.codtipocontrato='CD' and ush.Fecha = @Fecha
union
select	case when t.tipocontrato='DETERMINADO' 
		then 'Remuneraciones y prestaciones al personal y consejeros'
		else 'Honorarios' end CLASIFICACION,
		us.nombrecompleto NOMBRE, 
		c.nomcargo PUESTO,
	case when t.tipocontrato='DETERMINADO' 
		then 'DETERMINADO'
		else 'INDEFINIDO' end PERCEPCION,
		'' DESCRIPCION,ush.sueldobasico DATO,2 ORDEN
from tCsUsuariosRh ush 
inner join tCsUsuarios us on us.codusuario=ush.codusuario 
inner join tCsClCargos c on c.codcargo=ush.codcargo
inner join tCsClTipoContrato t on t.codtipocontrato=ush.Codtipocontrato
WHERE t.codtipocontrato in ('ACC','IND')and ush.Fecha = @Fecha
union 
select 'Rentas','', '','','',0,3
UNION
select 'Gastos de Promoción y Publicidad','', '','','',0,4
union
select 'Otros Gastos de Administración y Promoción','', '','','',0,5
ORDER BY ORDEN
-- exec pCsRptGastosOperaciones 
GO