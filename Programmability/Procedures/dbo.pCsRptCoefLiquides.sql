SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROC  [dbo].[pCsRptCoefLiquides] ( @pMes char(2),@pGestion char(4),@pCtas varchar(4000))
WITH ENCRYPTION AS
set nocount on
DECLARE @vNivel 	int,
	@vNroDias 	int,
	@vMes		char(2),
	@vGestion	char(4),
	@vCodCta        varchar(25)

declare @Cuentas table(
	CodCta		varchar(25),
	DescCta 	varchar(300),
	NroNivel	smallint,
	Saldo   	money default 0
	)
declare @CuentasSal table(
	CodCta		varchar(25),
	DescCta 	varchar(300),
	Saldo   	money default 0,
	NroDias 	int

)
declare  @tCtas table ( CodCta  varchar(25)) 

set @vMes 	= @pMes 
set @vGestion 	= @pGestion

select @vNivel 	= max(NroNivel) from tCsClCuentasNiveles where TipoNivel in ('L','U')
--colo la consolidacion sera dia a dia,
select @vNroDias = day( max(fecha)) from tCsContabilidad where month(Fecha) = @vMes and YEAR(Fecha) = @vGestion
--insertamos cuentas seleccionadas.
insert into @tCtas
select str as CodCta from fCoCadEnTabla(@pCtas)
--seleccionamos los saldos de las cuentas que nos interesan 
insert into @Cuentas (CodCta,Saldo,NroNivel) 
select CodCTa,isnull(sum(isnull(Saldo,0)),0)Saldo,0
from tCsContabilidad 
where datepart(yy,Fecha)=@vGestion and datepart(mm,Fecha)=@vMes
and CodCta in( select cb.CodCta from tCsPlanCuentas cb
		inner join @tCtas ca on cb.CodCta like rtrim(ca.CodCta) +'%'
		where cb.NroNivel = @vNivel) 
group by CodCTa
--cursor que solo recorre la cuenta seleccionada en busca de su saldo a nivel de detalle...
DECLARE cCtasSel CURSOR LOCAL FAST_FORWARD FOR
	SELECT DISTINCT CodCta FROM @tCtas
        OPEN cCtasSel
	FETCH NEXT FROM cCtasSel INTO @vCodCta
	WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @@FETCH_STATUS <> -2
		BEGIN
			insert into @CuentasSal (CodCta,Saldo,NroDias) 
			select @vCodCta,isnull(sum(isnull(Saldo,0)),0),@vNroDias from @Cuentas where CodCta like rtrim(@vCodCta) +'%'
		END	
		FETCH NEXT FROM cCtasSel INTO @vCodCta
	END 
	CLOSE cCtasSel

select CodCta		,
	DescCta 	,
	Saldo   	,
	isnull(NroDias,1) 	NroDias  from @CuentasSal


GO