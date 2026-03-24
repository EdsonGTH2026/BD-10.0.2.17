SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROC  [dbo].[pCsRptCatalogoMinimo] (@pMes char(2),@pGestion char(4))
WITH ENCRYPTION AS
set nocount on
--BD CONSOLIDAD FIMEDER--
	declare @Cuentas table(
		CodCta		varchar(25),
	        DescCta 	varchar(300),
		NroNivel	smallint,
	        Saldo   	money default 0
	)
	--variables locales
	declare @vNivDet 	int,
		@c 	 	int, 	
		@vlong	 	int, 
		@vMes		char(2),
		@vGestion	char(4)

	set @vMes 	= @pMes 
	set @vGestion 	= @pGestion

	--solo las cuentas de ultimo nivel son transaccionales
	select 	@vNivDet = max(NroNivel) from tCsClCuentasNiveles where TipoNivel in ('L','U')

	insert into @Cuentas (CodCta,Saldo,NroNivel) 
	select CodCTa,sum(isnull(Saldo,0))Saldo,@vNivDet
	from tCsContabilidad 
	where datepart(yy,Fecha)=@vGestion and datepart(mm,Fecha)=@vMes
	group by CodCTa
	-- Reconstruyendo el plan de cuota y sumarizando
	set @c = @vNivDet
	While  @c > 1
	begin
		select @vlong=LongitudTotal from tCsClCuentasNiveles where nroNivel = @c-1
		insert into @Cuentas(CodCta,Saldo,NroNivel)
		select distinct substring(CodCta,1,@vlong)CodCta,0, @c-1 
		from @Cuentas where NroNivel = @c 
		update @Cuentas  set Saldo = X.Saldo
		 	from 	(select substring(CodCta,1, @vlong)CodCta1,Sum(isnull(Saldo,0)) Saldo
					from @Cuentas
					where NroNivel= @c
					group by substring(CodCta,1, @vlong)
				) X
			where CodCta= X.CodCta1	
		set  @c= @c-1
	end
	--Tabla final
	update @Cuentas set DescCta = C.DescCta from @Cuentas A 
	inner join tCsPlanCuentas C on A.CodCta=C.CodCta 

	select CodCta,DescCta,NroNivel,Saldo from @Cuentas order by CodCta
GO