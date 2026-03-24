SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---se genera sp de créditos de vivienda. 2023.09.01 ZCCU
---1 paso: subir los pagos de TCE  a la tabla [FNMGConsolidado].[dbo].[TCEPagos]
---2 paso: Ejecutar sp


CREATE PROCEDURE [dbo].[pvINTFEmpleoTCE_CP]  @fecini smalldatetime,@fecha smalldatetime
AS  
set nocount on    

-----declara variables 
--declare @fecha smalldatetime         
--set @fecha='20230911'   --Fecha final de corte        
          
--declare @fecini smalldatetime          
--set @fecini='20230905'    --Fecha inicial de corte


---TABLAS TCE 
--select * from  [FinamigoBasesSic].[dbo].[TCETmpEmpleov14] WITH(NOLOCK)


---PAGOS DEL PERIODO 
select PERIODO,CODPRESTAMO
INTO #PAGOS
FROM [FNMGConsolidado].[dbo].[TCEPagos] P WITH(NOLOCK)
INNER JOIN [FNMGConsolidado].[dbo].[TCEAuxContrato] A ON A.CONTRATO=P.CONTRATO
WHERE FECHAPAGO>=@fecini 
AND FECHAPAGO<=@fecha

select E.*
Into #codusuario
from  [FinamigoBasesSic].[dbo].TCETmpCuentav14 C WITH(NOLOCK)
inner join [FinamigoBasesSic].[dbo].[TCETmpEmpleov14] E on E.codusuario=C.codusuario
inner join #PAGOS pagos on pagos.codprestamo=c.codprestamo



delete from [FinamigobasesSic].[DBO].[tCsTblEmpleoCP] where codusuario in (select codusuario from #codusuario with(nolock))   ------OJO: COMENTAR PARA PRUEBAS     
insert into [FinamigobasesSic].[DBO].[tCsTblEmpleoCP]  -----------------------------------------------OJO  


select distinct E.*
from  [FinamigoBasesSic].[dbo].TCETmpCuentav14 C WITH(NOLOCK)
inner join [FinamigoBasesSic].[dbo].[TCETmpEmpleov14] E on E.codusuario=C.codusuario
inner join #PAGOS pagos on pagos.codprestamo=c.codprestamo

DROP TABLE #PAGOS
drop table #codusuario


--select * from FinamigobasesSic.dbo.tCsTblEmpleoCP with(nolock)where codusuario in (select codusuario from #codusuario with(nolock))

--select * from FinamigoConsolidado.dbo.tCsBuroxTblReInomVr14CP with(nolock)
--select * from FinamigobasesSic.dbo.tCsTblDireccionesCP with(nolock)
--select TOP 10* from FinamigoConsolidado.dbo.tCsBuroxTblReICueVr14CP with(nolock)
GO