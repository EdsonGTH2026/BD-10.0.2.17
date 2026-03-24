SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCoObtieneSaldoCtaCs](
	@CodCta as varchar(25),		-- Código de la cuenta contable
	@CodFondo as varchar(2),	-- Código del fondo que se quiere obtener el saldo. (-1 Todos los fondos)
	@Fecha as smalldatetime,
	@SaldoCta as money out) 

with encryption
AS
set nocount on

declare @Cuentas 	table (CodCta varchar(25))
declare @CuentasTmp 	table (CodCta varchar(25))
declare @CuentasTmpAux 	table (CodCta varchar(25))
declare @CuentaSaldos 	table (codCta varchar(25))

declare @Anio as int
declare @Mes as int 


	-- Selecciona las cuentas dependientes para calcular el saldo del mes
	insert into @Cuentas (CodCta) values (@CodCta)
	insert into @CuentasTmp (CodCta) values (@CodCta)
	
	while exists (select CodCta from tCsPlanCuentas where CodCtaPadre 
		in (select CodCta from @CuentasTmp))
	begin
		insert into @Cuentas (CodCta) select CodCta 
			from tCsPlanCuentas where CodCtaPadre in (select CodCta from @CuentasTmp)
	
		delete from @CuentasTmpAux
		insert into @CuentasTmpAux (CodCta) select CodCta from @CuentasTmp
	
		delete from @CuentasTmp
	
		insert into @CuentasTmp (CodCta) select CodCta 
			from tCsPlanCuentas where CodCtaPadre in (select CodCta from @CuentasTmpAux)
	end

	set @Anio = year(@Fecha)
	set @Mes = month(@Fecha) 
	set @SaldoCta = 0

	-- Recupera el saldo mayorizado de la cuenta
	
	if (@CodFondo = '-1')
	begin
		select @SaldoCta = isnull( Sum(Saldo), 0)
		from tCsContabilidad
		where YEAR(Fecha) = @Anio
		      and MONTH(Fecha) <= @Mes 
		      and CodCta = @CodCta
	end
	else
	begin
		select @SaldoCta = isnull( Sum(Saldo), 0)
		from tCsContabilidad
		where YEAR(Fecha) = @Anio
		      and MONTH(Fecha) <= @Mes 
		      and CodCta = @CodCta
                      and CodFondo=@CodFondo
	end

GO