SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*1.17*/
create procedure [dbo].[pCsAArqueosCajasGenera] 
as
	declare @fecini smalldatetime
	declare @fecfin smalldatetime
	--SELECT * 
	--INTO tCsAArqueosRemotosCajas 
	--FROM OPENROWSET('MSDASQL', 'DRIVER={SQL Server};SERVER=10.0.1.17;UID=sa;PWD=$sql$2013','SET FMTONLY OFF EXEC [10.0.2.14].finmas.dbo.pCsAArqueosCajas ''20170201'',''20170215'' ')
	declare @fecha smalldatetime
	Select @fecha = FechaConsolidacion From vCsFechaConsolidacion

	truncate table tCsAArqueosRemotosCajas
	--select dateadd(day,-7,'20170219')
	--select dateadd(day,-6,'20170219')
	if (datepart(dw,@fecha)=1) --2 todos los lunes se debe enviar la informacion
	begin
		set @fecfin=@fecha
		set @fecini=dateadd(day,-6,@fecha)
		insert into tCsAArqueosRemotosCajas
		exec [10.0.2.14].finmas.dbo.pCsAArqueosCajas @fecini,@fecfin
	end
GO