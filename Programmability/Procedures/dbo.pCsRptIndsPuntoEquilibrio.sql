SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsRptIndsPuntoEquilibrio] @periodo varchar(6) AS

--declare @periodo varchar(6)
--set @periodo = '200906'

declare @fecini smalldatetime
declare @fecfin smalldatetime
select @fecini=primerdia,@fecfin=ultimodia from tclperiodo where periodo=@periodo

declare @nrooficinas int
select @nrooficinas=count(codoficina) from tcloficinas

create table #tbAux (
	codoficina		varchar(5),
	nomoficina		varchar(200),
	fechaapertura		smalldatetime,
	saldocartera		decimal(16,6) DEFAULT (0),
	montodesembolso	decimal(16,6) DEFAULT (0),
	nroprestamos		decimal(16,6) DEFAULT (0),
	nroprestamosant		decimal(16,6) DEFAULT (0),
	saldoahorros		decimal(16,6) DEFAULT (0),
	resantes		decimal(16,6) DEFAULT (0),
	gastos			decimal(16,6) DEFAULT (0),
	gastosadm		decimal(16,6) DEFAULT (0),
	gastosfijos		decimal(16,6) DEFAULT (0),
	gastosvariables		decimal(16,6) DEFAULT (0)
)

declare @csql varchar(3000)

set @csql = 'insert into #tbAux (codoficina,nomoficina,fechaapertura,saldocartera,nroprestamos,montodesembolso) '
set @csql = @csql + 'SELECT ofi.CodOficina, ofi.NomOficina, ofi.FechaApertura, '
set @csql = @csql + 'SUM(cdet.SaldoCapital + cdet.InteresVigente + cdet.InteresVencido + '
set @csql = @csql + 'cdet.MoratorioVigente + cdet.MoratorioVencido '
set @csql = @csql + ') AS SaldoCartera, count(cdet.codprestamo) nro,sum(cdet.montodesembolso) monto '
set @csql = @csql + 'FROM tCsCarteraDet cdet INNER JOIN tCsCartera ON cdet.Fecha = tCsCartera.Fecha AND '
set @csql = @csql + 'cdet.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN tClOficinas ofi ON '
set @csql = @csql + 'cdet.CodOficina = ofi.CodOficina '
set @csql = @csql + 'WHERE (cdet.Fecha = '''+dbo.fduFechaAAAAMMDD(@Fecfin)+''') AND (tCsCartera.Cartera = ''ACTIVA'') '
set @csql = @csql + 'GROUP BY ofi.CodOficina, ofi.NomOficina, ofi.FechaApertura '
set @csql = @csql + 'ORDER BY CAST(ofi.CodOficina AS int) '

exec (@csql)

/*
set @csql = 'insert into #tbAux (codoficina,nomoficina,fechaapertura,montodesembolso) '
set @csql = @csql + 'select cdet.codoficina,ofi.nomoficina,ofi.fechaapertura,sum(cdet.monto) monto from tcspadroncarteradet cdet '
set @csql = @csql + 'inner join tcloficinas ofi on ofi.codoficina=cdet.codoficina '
set @csql = @csql + 'where cdet.desembolso >='''+dbo.fduFechaAAAAMMDD(@Fecini)+'''  '
set @csql = @csql + 'and cdet.desembolso <='''+dbo.fduFechaAAAAMMDD(@Fecfin)+''' '
set @csql = @csql + 'group by cdet.codoficina,ofi.nomoficina,ofi.fechaapertura '

exec (@csql)
*/
set @csql = 'insert into #tbAux (codoficina,nomoficina,fechaapertura,nroprestamosant) '
set @csql = @csql + 'SELECT ofi.CodOficina, ofi.NomOficina, ofi.FechaApertura, count(cdet.codprestamo) nroant '
set @csql = @csql + 'FROM tCsCarteraDet cdet INNER JOIN tCsCartera ON cdet.Fecha = tCsCartera.Fecha AND  '
set @csql = @csql + 'cdet.CodPrestamo = tCsCartera.CodPrestamo LEFT OUTER JOIN tClOficinas ofi ON  '
set @csql = @csql + 'cdet.CodOficina = ofi.CodOficina  '
set @csql = @csql + 'WHERE (cdet.Fecha = '''+ cast((cast(substring(@periodo,1,4) as int) - 1) as varchar(4))   +'1231'') AND (tCsCartera.Cartera = ''ACTIVA'')  '
set @csql = @csql + 'GROUP BY ofi.CodOficina, ofi.NomOficina, ofi.FechaApertura  '
set @csql = @csql + 'ORDER BY CAST(ofi.CodOficina AS int)  '

exec (@csql)

set @csql = 'insert into #tbAux (codoficina,nomoficina,fechaapertura,saldoahorros) '
set @csql = @csql + 'SELECT ofi.CodOficina, ofi.NomOficina, ofi.FechaApertura, '
set @csql = @csql + 'SUM(tCsAhorros.SaldoCuenta + tCsAhorros.IntAcumulado) AS SaldoAhorros '
set @csql = @csql + 'FROM tCsAhorros LEFT OUTER JOIN tClOficinas ofi ON tCsAhorros.CodOficina = ofi.CodOficina '
set @csql = @csql + 'WHERE (tCsAhorros.Fecha = '''+dbo.fduFechaAAAAMMDD(@Fecfin)+''') '
set @csql = @csql + 'GROUP BY ofi.CodOficina, ofi.NomOficina, ofi.FechaApertura '
set @csql = @csql + 'ORDER BY CAST(ofi.CodOficina AS int) '

exec (@csql)

DECLARE @Servidor varchar(50)
DECLARE @BaseDatos varchar(50)

SELECT @BaseDatos=NombreBD, @Servidor=NombreIP FROM tCsServidores WHERE (Tipo = 2) AND (IdTextual = substring(@periodo,1,4))

set @csql = 'insert into #tbAux (codoficina,NomOficina, FechaApertura, resantes,gastosfijos,gastosvariables,gastos,gastosadm) '
set @csql = @csql + 'SELECT codoficina, NomOficina, FechaApertura, '
set @csql = @csql + '((((((C61+C62)-(C51+C52)))-C54) + (C65-C55))-C57) + (C66-a.C58) resantes, '
set @csql = @csql + 'C51+C52+C54+C55+C5701+C5702+C5703+C5704+ '
set @csql = @csql + 'C5705+C5707+C5711+C5712+C58 gastosfijos,'
set @csql = @csql + 'C5708+C5714+C58 gastosvariables,C51+C52+C54+C55+C57+C58 gastos, C57+C58 gastoadm FROM ( '
set @csql = @csql + 'SELECT codoficina, NomOficina, FechaApertura, sum(C51) C51,sum(C52) C52,sum(C53) C53,sum(C54) C54,sum(C55) C55,'
set @csql = @csql + 'sum(C57) C57,sum(C5701) C5701,sum(C5702) C5702,sum(C5703) C5703,sum(C5704) C5704,sum(C5705) C5705,sum(C5707) C5707,'
set @csql = @csql + 'sum(C5708) C5708,sum(C5711) C5711,sum(C5712) C5712,sum(C5714) C5714,sum(C58) C58, '
set @csql = @csql + 'sum(C61) C61,sum(C62) C62,sum(C65) C65,sum(C66) C66 FROM ( '
set @csql = @csql + 'SELECT codoficina, NomOficina, FechaApertura, '
set @csql = @csql + 'case codcta when ''51'' then saldocta else 0 end C51, '
set @csql = @csql + 'case codcta when ''52'' then saldocta else 0 end C52, '
set @csql = @csql + 'case codcta when ''53'' then saldocta else 0 end C53, '
set @csql = @csql + 'case codcta when ''54'' then saldocta else 0 end C54, '
set @csql = @csql + 'case codcta when ''55'' then saldocta else 0 end C55, '
set @csql = @csql + 'case codcta when ''57'' then saldocta else 0 end C57, '
set @csql = @csql + 'case codcta when ''5701'' then saldocta else 0 end C5701, '
set @csql = @csql + 'case codcta when ''5702'' then saldocta else 0 end C5702, '
set @csql = @csql + 'case codcta when ''5703'' then saldocta else 0 end C5703, '
set @csql = @csql + 'case codcta when ''5704'' then saldocta else 0 end C5704, '
set @csql = @csql + 'case codcta when ''5705'' then saldocta else 0 end C5705, '
set @csql = @csql + 'case codcta when ''5707'' then saldocta else 0 end C5707, '
set @csql = @csql + 'case codcta when ''5708'' then saldocta else 0 end C5708, '
set @csql = @csql + 'case codcta when ''5711'' then saldocta else 0 end C5711, '
set @csql = @csql + 'case codcta when ''5712'' then saldocta else 0 end C5712, '
set @csql = @csql + 'case codcta when ''5714'' then saldocta else 0 end C5714, '
set @csql = @csql + 'case codcta when ''58'' then saldocta else 0 end C58, '
set @csql = @csql + 'case codcta when ''61'' then saldocta else 0 end C61, '
set @csql = @csql + 'case codcta when ''62'' then saldocta else 0 end C62, '
set @csql = @csql + 'case codcta when ''65'' then saldocta else 0 end C65, '
set @csql = @csql + 'case codcta when ''66'' then saldocta else 0 end C66 '
set @csql = @csql + 'from ( '
set @csql = @csql + 'SELECT ofi.codoficinaasociada codoficina, ofi.NomOficina, ofi.FechaApertura, cm.codcta, case substring(cm.codcta,1,1) when ''6'' then (sum(cm.antdebe)+sum(cm.mesdebe)-sum(cm.anthaber)-sum(cm.meshaber))*-1 '
set @csql = @csql + 'else sum(cm.antdebe)+sum(cm.mesdebe)-sum(cm.anthaber)-sum(cm.meshaber) end saldocta '
set @csql = @csql + 'FROM ['+@Servidor+'].'+@BaseDatos+'.dbo.tCoMayores cm'

set @csql = @csql + ' inner join ( select ofias.codoficinaasociada, ofias.codoficina,ofior.nomoficina,ofior.fechaapertura from tcloficinas ofias inner join  '
set @csql = @csql + ' (select codoficina,nomoficina,fechaapertura from tcloficinas) ofior on ofias.codoficinaasociada = ofior.codoficina '
set @csql = @csql + ') ofi on ofi.codoficina=cm.codoficina '

set @csql = @csql + 'WHERE (cm.Gestion = '+substring(@periodo,1,4)+') AND (cm.Mes = '+substring(@periodo,5,2)+') AND (cm.CodCta in '
set @csql = @csql + '(''51'',''52'',''53'',''54'',''55'',''57'',''58'',''61'',''62'',''65'',''66'',''5701'',''5702'', '
set @csql = @csql + '''5703'',''5704'',''5705'',''5707'',''5708'',''5711'',''5712'',''5714'')) '
set @csql = @csql + 'group by ofi.codoficinaasociada, cm.codcta, ofi.NomOficina, ofi.FechaApertura) saldoscta ) saldosoficinas '
set @csql = @csql + 'group by codoficina, NomOficina, FechaApertura  ) a '

exec (@csql)

declare @meses int
set @meses = cast(substring(@periodo,5,2) as int)

declare @gasto decimal(16,6)
declare @resantes decimal(16,4)
select  @gasto = sum(gastos), @resantes = sum(resantes)  from #tbAux where cast(codoficina as int) in (1,98,99)

declare @numofi int
select  @numofi = count(distinct codoficina) from #tbAux where cast(codoficina as int) < 70 --and cast(codoficina as int) <> 1

declare @totalmeses decimal(16,6)
--select @totalmeses= sum(isnull(nroprestamosant,0))+sum(nroprestamos) from #tbAux where cast(codoficina as int) < 70 and cast(codoficina as int) <> 1
select @totalmeses = sum(mes) from (
select codoficina,case when year(fechaapertura) = cast(substring(@periodo,1,4) as int) then case when @meses - month(fechaapertura) = 0 then 1 
else @meses - month(fechaapertura) end else @meses end mes
from #tbAux where cast(codoficina as int) < 70 and cast(codoficina as int) NOT IN (1)  
group by codoficina,fechaapertura) ax

--select codoficina,case when year(fechaapertura) = cast(substring(@periodo,1,4) as int) then case when @meses - month(fechaapertura) = 0 then 1 
--else @meses - month(fechaapertura) end else @meses end mes
--from #tbAux where cast(codoficina as int) < 70 and cast(codoficina as int) <> 1
--group by codoficina,fechaapertura

--SET @gasto = @gasto/@numofi
--SET @resantes = @resantes/@numofi

SELECT codoficina,nomoficina,fechaapertura,saldocartera,montodesembolso,nroprestamos,nroprestamosant,saldoahorros,resantes,resantescorpo,gastos,gastosfijos,gastosvariables,
CostoxAcreditado,CostoxAcreditadoCorpo, Puntoequilibrio,PuntoequilibrioCorpo,IndiceAbsorcion,MargenProUtilidad,margenseguridad,gastosadm,@resantes gastototal, mesesantiguedad,GastoPonderado
FROM (
SELECT codoficina,nomoficina,fechaapertura,saldocartera,montodesembolso,nroprestamos,nroprestamosant,saldoahorros,resantes,resantes+@resantes*(mesesantiguedad/@totalmeses) resantescorpo,
gastos,gastosfijos,gastosvariables,gastosadm,
case nroprestamos when 0 then 0 else (( (gastos)/mesesantiguedad)*12)/((case nroprestamosant when 0 then nroprestamos else nroprestamosant end +nroprestamos)/2) end  CostoxAcreditado, 
case nroprestamos when 0 then 0 else (( (gastos+@gasto*(mesesantiguedad/@totalmeses))/mesesantiguedad)*12)/((case nroprestamosant when 0 then nroprestamos else nroprestamosant end+nroprestamos)/2) end  CostoxAcreditadoCorpo, 
case saldocartera when 0 then 0 else (gastos)/ ( 0.0491 * mesesantiguedad) end Puntoequilibrio,
case saldocartera when 0 then 0 else (gastos+@gasto*(mesesantiguedad/@totalmeses) )/ ( 0.0491 * mesesantiguedad) end PuntoequilibrioCorpo,
case saldocartera when 0 then 0 else ( ( (gastos+@gasto)/ ( 0.0491 * mesesantiguedad))/saldocartera)*100 end IndiceAbsorcion,
case saldocartera when 0 then 0 else (1-(((gastos+@gasto)/(0.0491*mesesantiguedad))/saldocartera))*100 end MargenProUtilidad,
montodesembolso - (case saldocartera when 0 then 0 else (gastos)/ ( 0.0491 * mesesantiguedad) end) margenseguridad,
montodesembolso - (case saldocartera when 0 then 0 else (gastos+@gasto*(mesesantiguedad/@totalmeses) )/ ( 0.0491 * mesesantiguedad) end) margenseguridadCorpo, 
mesesantiguedad,
@gasto*(mesesantiguedad/@totalmeses) GastoPonderado
FROM(
select codoficina,nomoficina,fechaapertura,sum(saldocartera) saldocartera,sum(nroprestamos) nroprestamos, sum(isnull(nroprestamosant,0)) nroprestamosant,
sum(saldoahorros) saldoahorros, sum(resantes) resantes,sum(gastos) gastos,sum(gastosadm) gastosadm,sum(gastosfijos) gastosfijos,sum(gastosvariables) gastosvariables, sum(montodesembolso) montodesembolso
,case when year(fechaapertura) = cast(substring(@periodo,1,4) as int) then case when @meses - month(fechaapertura) = 0 then 1 else @meses - month(fechaapertura) end else @meses end mesesantiguedad
from #tbAux
where cast(codoficina as int) < 70 and cast(codoficina as int) NOT IN (1)  
group by codoficina,nomoficina,fechaapertura) A) B

order by fechaapertura

drop table #tbAux
GO