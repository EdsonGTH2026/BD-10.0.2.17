SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsRptReporteKPI] @fecha smalldatetime,@codoficina varchar(5)
as   
set nocount on 

--declare @fecha smalldatetime
--set @fecha='20220805'

--declare @codoficina varchar(5)
--set @codoficina='309'

declare @nomoficina varchar(30)
select @nomoficina = nomoficina from tcloficinas where codoficina=(@codoficina) and tipo<>'cerrada'

select * 
from fnmgconsolidado.dbo.tcareporteKPI
where fecha=@fecha
and nomoficina=@nomoficina
GO