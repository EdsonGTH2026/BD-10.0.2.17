SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduSaldoCarteraQuirografarias] (@Fecha smalldatetime, @Estado varchar(20),@EstadoGarantia bit)  
	RETURNS decimal(16,2) AS  
BEGIN 

DECLARE @Monto decimal(16,2)

declare @F smalldatetime
set @f=@Fecha
--declare @Fecha smalldatetime
--declare @Estado varchar(20)
--declare @EstadoGarantia bit
--SET @Fecha = '20200430'
--SET @Estado = 'VIGENTE'
--SET @EstadoGarantia = 0
--87,788,527.06

IF (@EstadoGarantia = 1) 
	SELECT  @Monto =  SUM(tCsCarteraDet.SaldoCapital) + SUM(tCsCarteraDet.InteresVigente) + SUM(tCsCarteraDet.InteresVencido) + SUM(tCsCarteraDet.MoratorioVigente) + SUM(tCsCarteraDet.MoratorioVencido) 
	FROM         tCsCarteraDet with(nolock) INNER JOIN
	                      tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
	WHERE     (tCsCarteraDet.Fecha = @f) AND (tCsCartera.CodTipoCredito = 1) AND (tCsCartera.Estado = @Estado) AND (tCsCartera.Cartera <> 'ADMINISTRATIVA')  
	and	tCsCartera.codoficina not in('230','231','97')
	and tCsCartera.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock)) 
	AND (tCsCartera.CodPrestamo IN
		                          (SELECT     Codigo
                            FROM          tCsDiaGarantias with(nolock)
                            WHERE      (Fecha = @f) AND (estado NOT IN ('INACTIVO')) ))
ELSE
	SELECT  @Monto =  SUM(tCsCarteraDet.SaldoCapital) + SUM(tCsCarteraDet.InteresVigente) + SUM(tCsCarteraDet.InteresVencido) + SUM(tCsCarteraDet.MoratorioVigente) + SUM(tCsCarteraDet.MoratorioVencido) 
	FROM         tCsCarteraDet with(nolock) INNER JOIN
	                      tCsCartera with(nolock) ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
	WHERE     (tCsCarteraDet.Fecha = @f) AND (tCsCartera.CodTipoCredito = 1) AND (tCsCartera.Estado = @Estado) AND (tCsCartera.Cartera <> 'ADMINISTRATIVA')  
	and	tCsCartera.codoficina not in('230','231','97')
	and tCsCartera.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock)) 
	AND (tCsCartera.CodPrestamo NOT IN
		                          (SELECT     Codigo
                            FROM          tCsDiaGarantias with(nolock)
                            WHERE      (Fecha = @f) AND (estado NOT IN ('INACTIVO'))))

--select @monto

RETURN @Monto
END
GO

GRANT EXECUTE ON [dbo].[fduSaldoCarteraQuirografarias] TO [jarriagaa]
GO