SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsRptObtieneSaldoCta](
	@CodCta as varchar(25),		-- Código de la cuenta contable
	@CodFondo as varchar(2),	-- Código del fondo que se quiere obtener el saldo. (-1 Todos los fondos)
	@Fecha as smalldatetime,
--	@pMes char(2),
--	@pGestion char(4),
	@SaldoCta as money out,
	@SaldoCtaMes as money out) 

with encryption
AS
set nocount on -- <-- Noel. Optimizacion

declare @Cuentas 	table (CodCta varchar(25))
--declare @CuentasTmp 	table (CodCta varchar(25))
--declare @CuentasTmpAux 	table (CodCta varchar(25))
--declare @CuentaSaldos 	table (codCta varchar(25))

--declare @SaldoDebe 	money
--declare @SaldoHaber 	money
--declare @SaldoCta 	money
--declare @SaldoCtaMes	money

--declare @Anio as int
--declare @Mes as int 

DECLARE @vMes		char(2),
	@vGestion	char(4),
	@vNroDias 	int

--set @vMes 	= @pMes 
--set @vGestion 	= @pGestion

	-- Selecciona las cuentas dependientes para calcular el saldo del mes
	insert into @Cuentas (CodCta) values (@CodCta)
/*	insert into @CuentasTmp (CodCta) values (@CodCta)
	
	while exists (select CodCta from tCoCuentas where CodCtaPadre 
		in (select CodCta from @CuentasTmp))
	begin
		insert into @Cuentas (CodCta) select CodCta 
			from tCoCuentas where CodCtaPadre in (select CodCta from @CuentasTmp)
	
		delete from @CuentasTmpAux
		insert into @CuentasTmpAux (CodCta) select CodCta from @CuentasTmp
	
		delete from @CuentasTmp
	
		insert into @CuentasTmp (CodCta) select CodCta 
			from tCoCuentas where CodCtaPadre in (select CodCta from @CuentasTmpAux)
	end

	set @Anio = year(@Fecha)
	set @Mes = month(@Fecha) 
	set @SaldoCta = 0
	set @SaldoDebe = 0
	set @SaldoHaber = 0

	-- Recupera el saldo mayorizado de la cuenta
	if (@CodFondo = '-1')
		select @SaldoDebe = isnull( Sum(MesDebe), 0), @SaldoHaber = isnull( Sum(MesHaber), 0)
		from tCoMayores
		where Gestion = @Anio
		and Mes <= @Mes - 1
		and CodCta = @CodCta
	else
		select @SaldoDebe = isnull( Sum(MesDebe), 0), @SaldoHaber = isnull( Sum(MesHaber), 0)
		from tCoMayores
		where Gestion = @Anio
		and Mes <= @Mes - 1
		and CodCta = @CodCta
		and CodFondo = @CodFondo

	-- Suma los movimientos del mes
	if @CodFondo = '-1'
		select 	@SaldoDebe = @SaldoDebe + isnull( Sum (Debe), 0) , 
			@SaldoHaber = @SaldoHaber + isnull( Sum (Haber), 0)
		from tCoTraDia t 
		inner join tCoTraDiaDetalle d 
		on T.CodCbte       = D.CodCbte     and
		  T.NroCbte        = D.nrocbte     and
		  T.FechCbte       = D.fechcbte    and
		  T.CodOficinaOri  = D.CodOficinaOri
		where t.EsAnulado=0 --and T.Estado <> 'M'
		and CodCta in (select CodCta from @Cuentas)
		and month(t.FechCbte) = @Mes
		and t.FechCbte <= @Fecha
	else
				select 	@SaldoDebe = @SaldoDebe + isnull( Sum (Debe), 0) , 
			@SaldoHaber = @SaldoHaber + isnull( Sum (Haber), 0)
		from tCoTraDia t 
		inner join tCoTraDiaDetalle d 
		on T.CodCbte       = D.CodCbte     and
		  T.NroCbte        = D.nrocbte     and
		  T.FechCbte       = D.fechcbte    and
		  T.CodOficinaOri  = D.CodOficinaOri
		where t.EsAnulado=0 --and T.Estado <> 'M'
		and CodCta in (select CodCta from @Cuentas)
		and CodFondo = @CodFondo
		and month(t.FechCbte) = @Mes
		and t.FechCbte <= @Fecha

	-- Verifica la naturaleza de la cuenta
	if ((select Naturaleza from tCoCuentas C
		inner join tCoClCuentasGrupo G
		on C.GrupoCta = G.GrupoCta
		where CodCta = @CodCta) = '0')
		set @SaldoCta = @SaldoDebe - @SaldoHaber
	else
		set @SaldoCta = @SaldoHaber - @SaldoDebe
*/

	---PARA CONSOLIDADA
	set @SaldoCtaMes = 0
	set @SaldoCta = 0

	select @vNroDias = day( max(fecha)) from tCsContabilidad where month(Fecha) = month(@Fecha) --@vMes
								 and YEAR(Fecha) = YEAR( @Fecha) --@vGestion
	if @CodFondo = '-1'
	BEGIN
		select  @SaldoCta= isnull(sum(isnull(Saldo,0)),0),@SaldoCtaMes = isnull(sum(isnull(Saldo,0)),0)/@vNroDias
		from tCsContabilidad 
		where datepart(yy,Fecha)=YEAR( @Fecha)--@vGestion
			and datepart(mm,Fecha)=month(@Fecha)--@vMes
			and CodCta in(select CodCta from @Cuentas)
		group by CodCta
	END
	ELSE
	BEGIN
		select @SaldoCta = isnull(sum(isnull(Saldo,0)),0),@SaldoCtaMes = isnull(sum(isnull(Saldo,0)),0)/@vNroDias
		from tCsContabilidad 
		where datepart(yy,Fecha)=YEAR( @Fecha)--@vGestion 
			and datepart(mm,Fecha)=month(@Fecha)--@vMes
			and CodCta in(select CodCta from @Cuentas) and CodFondo= @CodFondo
		group by CodCta
	END

	-- Calcula el promedio mensual delsaldo de la cuenta 
--	set @SaldoCtaMes = 0
--	exec pCsRptObtieneSaldoCtaPromDia @CodCta, @CodFondo, @Fecha, @SaldoCtaMes output


GO