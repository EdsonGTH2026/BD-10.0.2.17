SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsBSGeneralesxOficina] @region varchar(5)  AS

CREATE TABLE #tmpind(
	item 						varchar(4),
	Oficina					varchar(30),
	Saldo						decimal(16, 6) DEFAULT (0),
	SaldoAnt				decimal(16, 6) DEFAULT (0),
	SaldoRes				varchar(20) DEFAULT (''), --Ind
	SaldoIncre			varchar(20) DEFAULT (''), --Ind Incre
	SaldoMeta				decimal(16, 6) DEFAULT (0), -- Meta
	Saldo0dias			decimal(16, 6) DEFAULT (0),
	Saldo90dias			decimal(16, 6) DEFAULT (0),
	Mora90dias			decimal(16, 6) DEFAULT (0),
	Mora90diasAnt		decimal(16, 6) DEFAULT (0),
	M90Res					varchar(20) DEFAULT (''), --Ind
	M90Incre				varchar(20) DEFAULT (''), --Ind Incre
	Mora0dias				decimal(16,6) DEFAULT (0),
	Mora0diasAnt		decimal(16,6) DEFAULT (0),
	M0Res						varchar(20) DEFAULT (''),   --Ind
	M0Incre					varchar(20) DEFAULT ('')  --Ind Incre
)

DECLARE @Fecha smalldatetime
--select @Fecha = fechaconsolidacion from vCsFechaConsolidacion
select @Fecha = '20090927'

DECLARE @ultdia smalldatetime
select @ultdia = ultimodia from tclperiodo where periodo=dbo.fduFechaAPeriodo(@Fecha)

declare @dias int
select @dias = case when datediff(day,@Fecha,@ultdia) <= 0 then 1 else datediff(day,@Fecha,@ultdia) end

INSERT INTO #tmpind
(item, Oficina, Saldo, SaldoRes, Saldo0dias, Saldo90dias, Mora90dias, M90Res, Mora0dias, M0Res,SaldoMeta)
SELECT item, Oficina, Saldo, dbo.fduBSIndRes(3,@ultdia,item,2,Saldo) SaldoRes, Saldo0dias, Saldo90dias, 
Mora90dias, dbo.fduBSIndRes(3,@ultdia,item,6,Mora90dias) M90Res, Mora0dias, dbo.fduBSIndRes(3,@ultdia,item,5,Mora0dias) M0Res ,
dbo.fduBSMetaRes(3,@ultdia,item,2,Saldo) MetaxDia 
from (
SELECT bs.codoficina 'Item', ofi.nomoficina Oficina, sum(bs.saldocartera) Saldo, sum(bs.saldo0dias) Saldo0dias, 
sum(bs.saldo90dias) Saldo90dias, sum(bs.saldo0dias)/sum(bs.saldocartera) * 100 Mora0dias, 
sum(bs.saldo90dias)/sum(bs.saldocartera) * 100 Mora90dias
FROM tCsBsCartera bs INNER JOIN tcloficinas ofi on bs.codoficina=ofi.codoficina
WHERE (Fecha = @Fecha) and ofi.zona=@region
group by bs.codoficina, ofi.nomoficina) a
order by cast(item as int)

DECLARE @mesant smalldatetime
select @mesant = ultimodia from tclperiodo where periodo=dbo.fduFechaAPeriodo(dateadd(Month,-1,@ultdia))

UPDATE  #tmpind
SET 		item=B.item, Oficina=B.Oficina, SaldoAnt=B.Saldo, SaldoIncre=B.SaldoRes, 
				Mora90diasAnt=B.Mora90dias, M90Incre=B.M90Incre, Mora0diasAnt=B.Mora0dias, M0Incre=B.M0Incre
FROM (
SELECT item, Oficina, Saldo, dbo.fduBSIndRes(3,@ultdia,item,2,Saldo) SaldoRes,  
Mora90dias, dbo.fduBSIndRes(3,@ultdia,item,6,Mora90dias) M90Incre, Mora0dias, dbo.fduBSIndRes(3,@ultdia,item,5,Mora0dias) M0Incre  
from (
SELECT bs.codoficina 'Item', ofi.nomoficina Oficina, sum(bs.saldocartera) Saldo, sum(bs.saldo0dias) Saldo0dias, 
sum(bs.saldo90dias) Saldo90dias, sum(bs.saldo0dias)/sum(bs.saldocartera) * 100 Mora0dias, 
sum(bs.saldo90dias)/sum(bs.saldocartera) * 100 Mora90dias
FROM tCsBsCartera bs INNER JOIN tcloficinas ofi on bs.codoficina=ofi.codoficina
WHERE (Fecha = @mesant) and ofi.zona=@region
group by bs.codoficina, ofi.nomoficina) a ) B inner join #tmpind on B.item=#tmpind.item

select item, oficina, saldo, round(SaldoMeta/ @dias, 2) MetaXdia,saldores, case when saldo<saldoant then '-' else '+' end + saldoincre difsaldo,saldo0dias,saldo90dias,
mora90dias,m90res,case when mora90dias<mora90diasant then '-' else '+' end + m90incre difm90dias,
mora0dias,m0res,case when mora0dias<mora0diasant then '-' else '+' end + m0incre difm0dias
from #tmpind

drop table #tmpind
GO