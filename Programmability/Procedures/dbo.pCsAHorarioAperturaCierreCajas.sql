SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsAHorarioAperturaCierreCajas] @fecha smalldatetime, @codoficina varchar(5)
as
BEGIN	

	--declare @fecha smalldatetime 
	--set @fecha = '20190228'
		
	truncate table tCsAHorarioAperturaCierreCajas
	
	insert into tCsAHorarioAperturaCierreCajas
	exec [10.0.2.14].finmas.dbo.pTcRptBovAnxCaj3 @fecha

	select * from tCsAHorarioAperturaCierreCajas
    
END

GO