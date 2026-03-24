SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCAALIQUI_RRDatos] @fecha smalldatetime,@codoficina varchar(1000)
as
	--declare @codoficina varchar(500)
	--set @codoficina='15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120
	--,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136
	--,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'
		
--declare @codoficina varchar(500)
--set @codoficina='4,37,3'
----set @codoficina='%'

declare @oficinas table(codoficina varchar(4))
insert into @oficinas
select codigo
from dbo.fdutablavalores(@codoficina)

	select *
	from tCsACaLIQUI_RR
	--where codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
	where (codoficina in(select codoficina from @oficinas)
	or @codoficina='%'
	)
GO