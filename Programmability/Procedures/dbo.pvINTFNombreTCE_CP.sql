SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---se genera sp de créditos de vivienda. 2023.09.01 ZCCU
---1 paso: subir los pagos de TCE  a la tabla [FNMGConsolidado].[dbo].[TCEPagos]
---2 paso: Ejecutar sp

CREATE PROCEDURE [dbo].[pvINTFNombreTCE_CP]  @fecini smalldatetime,@fecha smalldatetime
AS  
set nocount on    

---declara variables 
--declare @fecha smalldatetime         
--set @fecha='20230911'   --Fecha final de corte        
          
--declare @fecini smalldatetime          
--set @fecini='20230905'    --Fecha inicial de corte


---TABLAS TCE 
--select * from  [FinamigoBasesSic].[dbo].[TCETmpNombrev14] WITH(NOLOCK)


---PAGOS DEL PERIODO 
select PERIODO,CODPRESTAMO
INTO #PAGOS
FROM [FNMGConsolidado].[dbo].[TCEPagos] P WITH(NOLOCK)
INNER JOIN [FNMGConsolidado].[dbo].[TCEAuxContrato] A ON A.CONTRATO=P.CONTRATO
WHERE FECHAPAGO>=@fecini 
AND FECHAPAGO<=@fecha

delete from [FINAMIGOCONSOLIDADO].[DBO].[tCsBuroxTblReInomVr14CP] where substring(codprestamo,1,3)='500'    ------OJO: COMENTAR PARA PRUEBAS     
insert into [FINAMIGOCONSOLIDADO].[DBO].[tCsBuroxTblReInomVr14CP]  -----------------------------------------------OJO  

select N.Tipo,@fecha AS fecha,N.CodPrestamo,N.CodUsuario,
N.Paterno,N.Materno,N.Adicional,N.Nombre1,N.Nombre2,N.Nacimiento,
N.UsRFC,N.Prefijo,N.Sufijo,N.Nacionalidad,N.Residencia,N.LicenciaConducir,
N.EstadoCivil,N.Sexo,N.CedulaProfesional,N.IFE,N.CURP,N.ClaveOtroPais,
N.NumeroDependientes,N.EdadesDependientes,N.DefuncionFecha,
N.DefuncionIndicador,N.CodFondo
from  [FinamigoBasesSic].[dbo].TCETmpCuentav14 C WITH(NOLOCK)
inner join [FinamigoBasesSic].[dbo].[TCETmpNombrev14] N on N.codusuario=C.codusuario and N.CODPRESTAMO=C.CODPRESTAMO
inner join #PAGOS pagos on pagos.codprestamo=c.codprestamo

DROP TABLE #PAGOS



--select * from FinamigoConsolidado.dbo.tCsBuroxTblReInomVr14CP with(nolock)
--select * from FinamigoConsolidado.dbo.tCsBuroxTblReICueVr14CP with(nolock)

--select * from FinamigobasesSic.dbo.tCsTblDireccionesCP with(nolock)
--select * from FinamigobasesSic.dbo.tCsTblEmpleoCP with(nolock)
GO