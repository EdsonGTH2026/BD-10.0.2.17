SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCtaCACruceCartera] @fecha smalldatetime  AS
SET NOCOUNT ON

--declare @fecha smalldatetime

--set @fecha = '20101231'

create table #tmp (
CodOficina				varchar(5),
NomOficina				varchar(200), 
CapitalVigente_CM		decimal(16,4),
CapitalVigente_CS		decimal(16,4), 
CapitalVencido_CM		decimal(16,4), 
CapitalVencido_CS		decimal(16,4), 
InteresVigente_CM		decimal(16,4), 
InteresVigente_CS		decimal(16,4), 
InteresVencido_CM		decimal(16,4), 
InteresVencido_CS		decimal(16,4), 
MoratorioVigente_CM		decimal(16,4), 
MoratorioVigente_CS		decimal(16,4), 
MoratorioVencido_CM		decimal(16,4), 
MoratorioVencido_CS		decimal(16,4),

Co_CapitalVigente_CM		decimal(16,4),
Co_CapitalVigente_CS		decimal(16,4), 
Co_CapitalVencido_CM		decimal(16,4), 
Co_CapitalVencido_CS		decimal(16,4), 
Co_InteresVigente_CM		decimal(16,4), 
Co_InteresVigente_CS		decimal(16,4), 
Co_InteresVencido_CM		decimal(16,4), 
Co_InteresVencido_CS		decimal(16,4), 
Co_MoratorioVigente_CM		decimal(16,4), 
Co_MoratorioVigente_CS		decimal(16,4), 
Co_MoratorioVencido_CM		decimal(16,4), 
Co_MoratorioVencido_CS		decimal(16,4)

)

insert into #tmp ( CodOficina,NomOficina, CapitalVigente_CM,CapitalVigente_CS, CapitalVencido_CM, CapitalVencido_CS, InteresVigente_CM, InteresVigente_CS, 
InteresVencido_CM, InteresVencido_CS, MoratorioVigente_CM, MoratorioVigente_CS, MoratorioVencido_CM, MoratorioVencido_CS)
SELECT CodOficina, NomOficina, SUM(CapitalVigente_CM) AS CapitalVigente_CM, SUM(CapitalVigente_CS) AS CapitalVigente_CS, SUM(CapitalVencido_CM) 
AS CapitalVencido_CM, SUM(CapitalVencido_CS) AS CapitalVencido_CS, SUM(InteresVigente_CM) AS InteresVigente_CM, SUM(InteresVigente_CS) 
AS InteresVigente_CS, SUM(InteresVencido_CM) AS InteresVencido_CM, SUM(InteresVencido_CS) AS InteresVencido_CS, SUM(MoratorioVigente_CM) 
AS MoratorioVigente_CM, SUM(MoratorioVigente_CS) AS MoratorioVigente_CS, SUM(MoratorioVencido_CM) AS MoratorioVencido_CM, SUM(MoratorioVencido_CS) 
AS MoratorioVencido_CS
FROM (SELECT tClOficinas.CodOficina, tClOficinas.NomOficina, tCsCartera.CodTipoCredito, 
--      ******* CAMPOS DE LA TABLA *******
--      CASE tCsCartera.CodTipoCredito WHEN 1 THEN tCsCarteraDet.SaldoCapital - tCsCarteraDet.CapitalVencido ELSE 0 END AS CapitalVigente_CM, 
--      CASE tCsCartera.CodTipoCredito WHEN 3 THEN tCsCarteraDet.SaldoCapital - tCsCarteraDet.CapitalVencido ELSE 0 END AS CapitalVigente_CS, 
--      CASE tCsCartera.CodTipoCredito WHEN 1 THEN tCsCarteraDet.CapitalVencido ELSE 0 END AS CapitalVencido_CM, 
--      CASE tCsCartera.CodTipoCredito WHEN 3 THEN tCsCarteraDet.CapitalVencido ELSE 0 END AS CapitalVencido_CS, 

--      ******* DIAS DE ATRASO *******
--      CASE tCsCartera.CodTipoCredito WHEN 1 THEN (case when nrodiasatraso>=0 and nrodiasatraso<=89 then tCsCarteraDet.SaldoCapital else 0 end) ELSE 0 END AS CapitalVigente_CM, 
--      CASE tCsCartera.CodTipoCredito WHEN 3 THEN (case when nrodiasatraso>=0 and nrodiasatraso<=89 then tCsCarteraDet.SaldoCapital else 0 end) ELSE 0 END AS CapitalVigente_CS, 
--      CASE tCsCartera.CodTipoCredito WHEN 1 THEN (case when nrodiasatraso>89 then tCsCarteraDet.SaldoCapital else 0 end) ELSE 0 END AS CapitalVencido_CM, 
--      CASE tCsCartera.CodTipoCredito WHEN 3 THEN (case when nrodiasatraso>89 then tCsCarteraDet.SaldoCapital else 0 end) ELSE 0 END AS CapitalVencido_CS, 

--      ******* ESTADOS *******
      CASE tCsCartera.CodTipoCredito WHEN 1 THEN (case when estado='VIGENTE' then tCsCarteraDet.SaldoCapital else 0 end) ELSE 0 END AS CapitalVigente_CM, 
      CASE tCsCartera.CodTipoCredito WHEN 3 THEN (case when estado='VIGENTE' then tCsCarteraDet.SaldoCapital else 0 end) ELSE 0 END AS CapitalVigente_CS, 
      CASE tCsCartera.CodTipoCredito WHEN 1 THEN (case when estado='VENCIDO' then tCsCarteraDet.SaldoCapital else 0 end) ELSE 0 END AS CapitalVencido_CM, 
      CASE tCsCartera.CodTipoCredito WHEN 3 THEN (case when estado='VENCIDO' then tCsCarteraDet.SaldoCapital else 0 end) ELSE 0 END AS CapitalVencido_CS, 


      CASE tCsCartera.CodTipoCredito WHEN 1 THEN tCsCarteraDet.InteresVigente ELSE 0 END AS InteresVigente_CM, 
      CASE tCsCartera.CodTipoCredito WHEN 3 THEN tCsCarteraDet.InteresVigente ELSE 0 END AS InteresVigente_CS, 
      CASE tCsCartera.CodTipoCredito WHEN 1 THEN tCsCarteraDet.InteresVencido ELSE 0 END AS InteresVencido_CM, 
      CASE tCsCartera.CodTipoCredito WHEN 3 THEN tCsCarteraDet.InteresVencido ELSE 0 END AS InteresVencido_CS, 
      CASE tCsCartera.CodTipoCredito WHEN 1 THEN tCsCarteraDet.MoratorioVigente ELSE 0 END AS MoratorioVigente_CM, 
      CASE tCsCartera.CodTipoCredito WHEN 3 THEN tCsCarteraDet.MoratorioVigente ELSE 0 END AS MoratorioVigente_CS, 
      CASE tCsCartera.CodTipoCredito WHEN 1 THEN tCsCarteraDet.MoratorioVencido ELSE 0 END AS MoratorioVencido_CM, 
      CASE tCsCartera.CodTipoCredito WHEN 3 THEN tCsCarteraDet.MoratorioVencido ELSE 0 END AS MoratorioVencido_CS
	  FROM tCsCartera with(nolock) INNER JOIN
      tCsCarteraDet with(nolock) ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo INNER JOIN
      tClOficinas with(nolock) ON tCsCartera.CodOficina = tClOficinas.CodOficina
	  WHERE      (tCsCartera.Fecha = @fecha) AND (tCsCartera.Cartera = 'ACTIVA')) A
GROUP BY CodOficina, NomOficina
ORDER BY CAST(CodOficina AS int)

DECLARE @Servidor varchar(50)
DECLARE @BaseDatos varchar(50)
DECLARE @NomSrv varchar(100)

SELECT @BaseDatos=NombreBD, @Servidor=NombreIP,@NomSrv=nombreservidor FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = cast(year(@Fecha) as varchar(4)))

		if(@NomSrv=(select @@SERVERNAME))  SET @Servidor = ''
		else SET @Servidor = '['+@Servidor+'].'

declare @csql varchar(4000)

set @csql= 'declare @codoficina varchar(5) '
set @csql= @csql+'declare @CaVi_CM decimal(16,4) '
set @csql= @csql+'declare @CaVi_CS decimal(16,4) '
set @csql= @csql+'declare @CaVe_CM decimal(16,4) '
set @csql= @csql+'declare @CaVe_CS decimal(16,4) '
set @csql= @csql+'declare @InVi_CM decimal(16,4) '
set @csql= @csql+'declare @InVi_CS decimal(16,4) '
set @csql= @csql+'declare @InVe_CM decimal(16,4) '
set @csql= @csql+'declare @InVe_CS decimal(16,4) '
set @csql= @csql+'declare @MoVi_CM decimal(16,4) '
set @csql= @csql+'declare @MoVi_CS decimal(16,4) '
set @csql= @csql+'declare @MoVe_CM decimal(16,4) '
set @csql= @csql+'declare @MoVe_CS decimal(16,4) '

set @csql= @csql+' declare tmp_cur cursor for '

set @csql= @csql+'SELECT CodOficina, '
set @csql= @csql+'SUM(CaVi_CM) AS CaVi_CM, SUM(CaVi_CS) AS CaVi_CS, SUM(CaVe_CM) AS CaVe_CM, '
set @csql= @csql+'SUM(CaVe_CS) AS CaVe_CS, SUM(InVi_CM) AS InVi_CM, SUM(InVi_CS) AS InVi_CS, '
set @csql= @csql+'SUM(InVe_CM) AS InVe_CM, SUM(InVe_CS) AS InVe_CS, SUM(MoVi_CM) AS MoVi_CM, '
set @csql= @csql+'SUM(MoVi_CS) AS MoVi_CS, SUM(MoVe_CM) AS MoVe_CM, SUM(MoVe_CS) AS MoVe_CS '
set @csql= @csql+'FROM (SELECT CodOficina, NomOficina,  '
set @csql= @csql+'CASE codcta WHEN ''130110101'' THEN monto ELSE 0 END AS CaVi_CM, '
set @csql= @csql+'CASE codcta WHEN ''130110201'' THEN monto ELSE 0 END AS CaVi_CS, '
set @csql= @csql+'CASE codcta WHEN ''130210101'' THEN monto ELSE 0 END AS CaVe_CM, '
set @csql= @csql+'CASE codcta WHEN ''130210201'' THEN monto ELSE 0 END AS CaVe_CS, '
set @csql= @csql+'CASE codcta WHEN ''139110101'' THEN monto ELSE 0 END AS InVi_CM, '
set @csql= @csql+'CASE codcta WHEN ''139110201'' THEN monto ELSE 0 END AS InVi_CS, '
set @csql= @csql+'CASE codcta WHEN ''139210101'' THEN monto ELSE 0 END AS InVe_CM, '
set @csql= @csql+'CASE codcta WHEN ''139210201'' THEN monto ELSE 0 END AS InVe_CS, '
set @csql= @csql+'CASE codcta WHEN ''139110102'' THEN monto ELSE 0 END AS MoVi_CM, '
set @csql= @csql+'CASE codcta WHEN ''139110202'' THEN monto ELSE 0 END AS MoVi_CS, '
set @csql= @csql+'CASE codcta WHEN ''139210102'' THEN monto ELSE 0 END AS MoVe_CM, '
set @csql= @csql+'CASE codcta WHEN ''139210202'' THEN monto ELSE 0 END AS MoVe_CS '
set @csql= @csql+'FROM (SELECT tClOficinas.CodOficina, tClOficinas.NomOficina, b.CodCta, b.Debe - b.Haber AS Monto '
set @csql= @csql+'FROM  '+@Servidor+@BaseDatos+'.dbo.tCoTraDia a '
set @csql= @csql+'INNER JOIN  '+@Servidor+@BaseDatos+'.dbo.tCoTraDiaDetalle b ON a.CodRegistro = b.CodRegistro INNER JOIN '
set @csql= @csql+'tClOficinas ON b.CodOficina = tClOficinas.CodOficina '
set @csql= @csql+'WHERE (a.FechCbte >= '''+cast(year(@fecha) as varchar(4))+'0101'') AND (a.FechCbte <= '''++dbo.fduFechaAAAAMMDD(@Fecha)++''') AND '
set @csql= @csql+'(b.CodCta IN (''130110101'',''130110201'',''130210101'',''130210201'', '
set @csql= @csql+'''139110101'',''139110201'',''139210101'',''139210201'',''139110102'',''139210102'',''139110202'',''139210202'')) AND '
set @csql= @csql+'(a.EsAnulado = 0)) A) B '
set @csql= @csql+'GROUP BY CodOficina '
set @csql= @csql+'ORDER BY CAST(CodOficina AS int) '

set @csql= @csql+'open tmp_cur '

set @csql= @csql+'fetch next from tmp_cur '
set @csql= @csql+'into @codoficina,@CaVi_CM,@CaVi_CS,@CaVe_CM,@CaVe_CS,@InVi_CM,@InVi_CS, '
set @csql= @csql+'@InVe_CM,@InVe_CS,@MoVi_CM,@MoVi_CS,@MoVe_CM,@MoVe_CS '

set @csql= @csql+'while @@FETCH_STATUS = 0 '
set @csql= @csql+'begin '

set @csql= @csql+'if exists(select 1 from #tmp where codoficina=@codoficina) '
set @csql= @csql+'begin '
set @csql= @csql+'update #tmp '
set @csql= @csql+'set Co_CapitalVigente_CM=@CaVi_CM, '
set @csql= @csql+'Co_CapitalVigente_CS=@CaVi_CS, '
set @csql= @csql+'Co_CapitalVencido_CM=@CaVe_CM, '
set @csql= @csql+'Co_CapitalVencido_CS=@CaVe_CS, '
set @csql= @csql+'Co_InteresVigente_CM=@InVi_CM, '
set @csql= @csql+'Co_InteresVigente_CS=@InVi_CS, '
set @csql= @csql+'Co_InteresVencido_CM=@InVe_CM, '
set @csql= @csql+'Co_InteresVencido_CS=@InVe_CS, '
set @csql= @csql+'Co_MoratorioVigente_CM=@MoVi_CM, '
set @csql= @csql+'Co_MoratorioVigente_CS=@MoVi_CS, '
set @csql= @csql+'Co_MoratorioVencido_CM=@MoVe_CM, '
set @csql= @csql+'Co_MoratorioVencido_CS=@MoVe_CS '
set @csql= @csql+'where codoficina=@codoficina '
set @csql= @csql+'end '
set @csql= @csql+'else '
set @csql= @csql+'begin '
set @csql= @csql+'INSERT INTO #tmp (codoficina,Co_CapitalVigente_CM,Co_CapitalVigente_CS,Co_CapitalVencido_CM,Co_CapitalVencido_CS,Co_InteresVigente_CM,Co_InteresVigente_CS, '
set @csql= @csql+'Co_InteresVencido_CM,Co_InteresVencido_CS,Co_MoratorioVigente_CM,Co_MoratorioVigente_CS,Co_MoratorioVencido_CM,Co_MoratorioVencido_CS) '
set @csql= @csql+'VALUES (@codoficina,@CaVi_CM,@CaVi_CS,@CaVe_CM,@CaVe_CS,@InVi_CM,@InVi_CS, '
set @csql= @csql+'@InVe_CM,@InVe_CS,@MoVi_CM,@MoVi_CS,@MoVe_CM,@MoVe_CS) '
set @csql= @csql+'end '

set @csql= @csql+'fetch next from tmp_cur '
set @csql= @csql+'into @codoficina,@CaVi_CM,@CaVi_CS,@CaVe_CM,@CaVe_CS,@InVi_CM,@InVi_CS, '
set @csql= @csql+'@InVe_CM,@InVe_CS,@MoVi_CM,@MoVi_CS,@MoVe_CM,@MoVe_CS '
set @csql= @csql+'end '

set @csql= @csql+'close tmp_cur '
set @csql= @csql+'deallocate tmp_cur '
print @csql
exec (@csql)

select * from #tmp

drop table #tmp 

SET NOCOUNT OFF
GO