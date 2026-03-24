SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create function [dbo].[fduAhTasaPonderada] (@fecha smalldatetime)
returns varchar(200)
as
begin
	declare @valor varchar(200)
	declare @sumxprod table (montototal money, montoofcentral money, montoSinofcentral money)

	insert into @sumxprod
	select sum(monto) monto,sum(montoofcentral) montoofcentral,sum(montoSinofcentral) montoSinofcentral
	from(
	SELECT c.saldocuenta monto,case when codoficina='98' then c.saldocuenta else 0 end montoofcentral,case when codoficina<>'98' then c.saldocuenta else 0 end montoSinofcentral
	FROM tCsahorros c with(nolock) where c.fecha=@fecha and substring(codcuenta,5,1)='2'
	) a

	select @valor=rtrim(ltrim(str(div,16,2))) +'|'+ rtrim(ltrim(str(divofcentral,16,2))) +'|'+ rtrim(ltrim(str(divSinofcentral,16,2)))
	from (
		select sum(b.div) div, sum(b.divofcentral) divofcentral,sum(b.divSinofcentral) divSinofcentral
		from (
			select a.txm/mxp.montototal div, a.txmofcentral/mxp.montoofcentral divofcentral, a.txmsinofcentral/mxp.montoSinofcentral divSinofcentral
			from (
				SELECT c.tasainteres*c.saldocuenta txm
				,c.tasainteres*(case when codoficina='98' then c.saldocuenta else 0 end) txmofcentral
				,c.tasainteres*(case when codoficina<>'98' then c.saldocuenta else 0 end) txmsinofcentral
				FROM tCsahorros c with(nolock) where c.fecha=@fecha and substring(codcuenta,5,1)='2'
			) a cross join @sumxprod mxp
		) b
	) c

	return @valor
end
GO