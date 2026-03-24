SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*Genera tabla historica  2.17   05.09.2022*/
CREATE procedure [dbo].[pCsDatosCliCarteraActiva]
as
set nocount on 


declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion


delete  fnmgconsolidado.dbo.tCsDatosCliCarteraActiva  where fecha=@fecha 
insert into fnmgconsolidado.dbo.tCsDatosCliCarteraActiva


select * from tCsADatosCliCarteraActiva with(nolock)
GO