SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Drop Procedure pCsCaDesembolsosRecuperaciones 
-- Exec pCsCaDesembolsosRecuperacionesVs2  '20150620'
CREATE PROCEDURE  [dbo].[pCsCaDesembolsosRecuperacionesVs2] 
 @Fecha SmalldateTime
AS
Declare @Cadena Varchar(8000)

declare @periodo varchar(6)
set @periodo=dbo.fduFechaAPeriodo(@fecha)

CREATE TABLE #Kemy (
	[Fecha]				[smalldatetime] NULL ,
	[CodOficina]		[varchar] (4) COLLATE Modern_Spanish_CI_AI NULL ,
	[DescOficina]		[varchar] (40) COLLATE Modern_Spanish_CI_AI NULL ,
	[NueNroDesembolso]		[int] NOT NULL ,
	[NueDesembolso]		[money] NOT NULL ,
	[NueNropordesembolsar] [int] NOT NULL ,
	[NuePordesembolsar]	[money] NOT NULL ,
	[RepNroDesembolso]		[int] NOT NULL ,
	[RepDesembolso]		[money] NOT NULL ,
	[RepNropordesembolsar] [int] NOT NULL ,
	[RepPordesembolsar]	[money] NOT NULL ,	
	[MontoPagado]		[money] NOT NULL ,
	[Capital]			[money] NOT NULL ,
	[Interes]			[money] NOT NULL ,
	[Moratorio]			[money] NOT NULL ,
	[CargoxMora]		[money] NOT NULL ,
	[IVAInteres]		[money] NOT NULL ,
	[IVAMoratorio]		[money] NOT NULL ,
	[IVACargoxMora]		[money] NOT NULL ,
	[NroOper]			[int] NOT NULL,
	[CC]				[money] NOT NULL ,
	[PKProgramado]		[money] NOT NULL ,
	[PKAtrasado]		[money] NOT NULL ,
	[PKAdelantado]		[money] NOT NULL 
) ON [PRIMARY]

Insert Into #Kemy Exec [10.0.2.14].finmas.dbo.pCsCaDesembolsosRecuperacionesVS2 @Fecha

CREATE TABLE #Kemy1 (
	[CodOficina]		[varchar] (4) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[SaldoCapital]		[decimal](38, 6) NULL ,
	[InteresTotal]		[decimal](38, 6) NULL ,
	[InteresBalance]	[decimal](38, 6) NULL ,
	[InteresCtaOrden]	[decimal](38, 6) NULL 
) ON [PRIMARY]

create table #desemxpese(
  codoficina varchar(4),
  nrodesemperiodoN int,
  montodesemperiodoN decimal(16,2),
  nrodesemperiodoR int,
  montodesemperiodoR decimal(16,2),
  
  nrodesemsemanaN int,
  montodesemsemanaN decimal(16,2),
  nrodesemsemanaR int,
  montodesemsemanaR decimal(16,2),
  
  nrodesemanualN int,
  montodesemanualN decimal(16,2),
  nrodesemanualR int,
  montodesemanualR decimal(16,2),
  
  nrosemana int
)

insert into #desemxpese
select isnull(p.codoficina,a.codoficina) codoficina
,p.nrodesemperiodoN,p.montodesemperiodoN,p.nrodesemperiodoR,p.montodesemperiodoR
,isnull(s.nrodesemsemanaN,0) nrodesemsemanaN
,isnull(s.montodesemsemanaN,0) montodesemsemanaN
,isnull(s.nrodesemsemanaR,0) nrodesemsemanaR
,isnull(s.montodesemsemanaR,0) montodesemsemanaR
,a.nrodesemanualN,a.montodesemanualN,nrodesemanualR,montodesemanualR
,s.nrosemana
from 
(
  SELECT CodOficina
  ,count(case when secuenciacliente=1 then codusuario else null end) nrodesemanualN
  ,sum(case when secuenciacliente=1 then monto else null end) montodesemanualN
  ,count(case when secuenciacliente>1 then codusuario else null end) nrodesemanualR
  ,sum(case when secuenciacliente>1 then monto else null end) montodesemanualR
  FROM tCsPadronCarteraDet with(nolock)
  where desembolso>=substring(@periodo,1,4)+'0101' and desembolso<=@fecha
  and TipoReprog='SINRE'
  group by CodOficina
) a left outer join 
  (
  SELECT CodOficina
  ,count(case when secuenciacliente=1 then codusuario else null end) nrodesemperiodoN
  ,sum(case when secuenciacliente=1 then monto else null end) montodesemperiodoN
  ,count(case when secuenciacliente>1 then codusuario else null end) nrodesemperiodoR
  ,sum(case when secuenciacliente>1 then monto else null end) montodesemperiodoR
  FROM tCsPadronCarteraDet with(nolock)
  where dbo.fduFechaAPeriodo(desembolso)=@periodo--'201404'
  and TipoReprog='SINRE'
  group by CodOficina
) p on a.codoficina=p.codoficina
left outer join (
  SELECT c.CodOficina,p.nrosemana
  --,count(c.codusuario) nrodesemsemana,sum(c.Monto) montodesemsemana
  ,count(case when c.secuenciacliente=1 then c.codusuario else null end) nrodesemsemanaN
  ,sum(case when c.secuenciacliente=1 then c.monto else null end) montodesemsemanaN
  ,count(case when c.secuenciacliente>1 then c.codusuario else null end) nrodesemsemanaR
  ,sum(case when c.secuenciacliente>1 then c.monto else null end) montodesemsemanaR
  FROM tCsPadronCarteraDet c with(nolock)
  inner join (
--    select fechaini,fechafin,nrosemana from dbo.fduTablaSemanaPeriodos('201404') where fechaini<='20140423' and fechafin>='20140423'
      select fechaini,fechafin,nrosemana from dbo.fduTablaSemanaPeriodos(@periodo) where fechaini<=@fecha and fechafin>=@fecha
  ) p on c.desembolso>=p.fechaini and c.desembolso<=p.fechafin
  where c.TipoReprog='SINRE'
  group by c.CodOficina,p.nrosemana
) s on p.codoficina=s.codoficina

--select p.codoficina
--,p.nrodesemperiodoN,p.montodesemperiodoN,p.nrodesemperiodoR,p.montodesemperiodoR
--,isnull(s.nrodesemsemanaN,0) nrodesemsemanaN
--,isnull(s.montodesemsemanaN,0) montodesemsemanaN
--,isnull(s.nrodesemsemanaR,0) nrodesemsemanaR
--,isnull(s.montodesemsemanaR,0) montodesemsemanaR
--,s.nrosemana
--from (
--  SELECT CodOficina
--  ,count(case when secuenciacliente=1 then codusuario else null end) nrodesemperiodoN
--  ,sum(case when secuenciacliente=1 then monto else null end) montodesemperiodoN
--  ,count(case when secuenciacliente>1 then codusuario else null end) nrodesemperiodoR
--  ,sum(case when secuenciacliente>1 then monto else null end) montodesemperiodoR
--  FROM tCsPadronCarteraDet with(nolock)
--  where dbo.fduFechaAPeriodo(desembolso)=@periodo--'201404'
--  and TipoReprog='SINRE'
--  group by CodOficina
--) p
--left outer join (
--  SELECT c.CodOficina,p.nrosemana
--  --,count(c.codusuario) nrodesemsemana,sum(c.Monto) montodesemsemana
--  ,count(case when c.secuenciacliente=1 then c.codusuario else null end) nrodesemsemanaN
--  ,sum(case when c.secuenciacliente=1 then c.monto else null end) montodesemsemanaN
--  ,count(case when c.secuenciacliente>1 then c.codusuario else null end) nrodesemsemanaR
--  ,sum(case when c.secuenciacliente>1 then c.monto else null end) montodesemsemanaR
--  FROM tCsPadronCarteraDet c with(nolock)
--  inner join (
----    select fechaini,fechafin,nrosemana from dbo.fduTablaSemanaPeriodos('201404') where fechaini<='20140423' and fechafin>='20140423'
--select fechaini,fechafin,nrosemana from dbo.fduTablaSemanaPeriodos(@periodo) where fechaini<=@fecha and fechafin>=@fecha
--  ) p on c.desembolso>=p.fechaini and c.desembolso<=p.fechafin
--  where c.TipoReprog='SINRE'
--  group by c.CodOficina,p.nrosemana
--) s on p.codoficina=s.codoficina

update #desemxpese
set nrosemana=(select max(nrosemana) from #desemxpese)
where nrosemana is null

--select * from #desemxpese

Declare @P Int

Set @P = 0
If (Select DateDiff(Day, FechaConsolidacion, @Fecha) From vCsFechaConsolidacion ) = 1
Begin
	Set @P = 1
End

Print @P

If @P = 0
Begin 
	Insert Into #Kemy1
	SELECT        CodOficina, AVG(SaldoCapital) AS SaldoCapital, AVG(InteresTotal) / AVG(SaldoCapital) * 100 AS InteresTotal, AVG(InteresBalance) 
											/ AVG(SaldoCapital) * 100 AS InteresBalance, AVG(InteresCtaOrden) / AVG(SaldoCapital) * 100 AS InteresCtaOrden
	           
	FROM            (SELECT        tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina, SUM(tCsCarteraDet.SaldoCapital) AS SaldoCapital, 
													  SUM(tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio) AS InteresTotal, 
													  SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido)
													   AS InteresBalance, SUM(tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioCtaOrden) AS InteresCtaOrden
							FROM            tCsCarteraDet INNER JOIN
													  tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
							WHERE     (tCsCarteraDet.Fecha = @Fecha) AND (tCsCartera.Cartera IN ('ACTIVA', 'ADMINISTRATIVA')) 
							GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina) AS Datos
	GROUP BY CodOficina  
End 

If @P = 1
Begin 
	
	Declare @Contador	Int
	Declare @F			SmallDateTime
	Set @Contador	= 0
	Set @F			= @Fecha
		
	Create Table #K 
	(
		F SmallDateTime
	)

	While @Contador <= 5
	Begin
		Insert Into #K (F) Values(@F)
		Set @F			= DateAdd(Month, -1, @Fecha)
		Set @Contador	= @Contador		+ 1
	End

	Insert Into #Kemy1
	SELECT        CodOficina, AVG(SaldoCapital) AS SaldoCapital, AVG(InteresTotal) / AVG(SaldoCapital) * 100 AS InteresTotal, AVG(InteresBalance) 
											/ AVG(SaldoCapital) * 100 AS InteresBalance, AVG(InteresCtaOrden) / AVG(SaldoCapital) * 100 AS InteresCtaOrden
	           
	FROM            (SELECT        tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina, SUM(tCsCarteraDet.SaldoCapital) AS SaldoCapital, 
													  SUM(tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio) AS InteresTotal, 
													  SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido)
													   AS InteresBalance, SUM(tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioCtaOrden) AS InteresCtaOrden
							FROM            tCsCarteraDet INNER JOIN
													  tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
							WHERE       (tCsCarteraDet.Fecha = @Fecha - 1) AND (tCsCartera.Cartera IN ('ACTIVA', 'ADMINISTRATIVA')) 
							GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina) AS Datos
	GROUP BY CodOficina  

	UPDATE    #Kemy1
	SET			InteresTotal	= 2 * #Kemy1.InteresTotal		- Kemy2.InteresTotal,
				InteresBalance	= 2 * #Kemy1.InteresBalance		- Kemy2.InteresBalance,
				InteresCtaOrden	= 2 * #Kemy1.InteresCtaOrden	- Kemy2.InteresCtaOrden					
	FROM         #Kemy1 INNER JOIN
							  (SELECT     CodOficina, AVG(SaldoCapital) AS SaldoCapital, AVG(InteresTotal) / AVG(SaldoCapital) * 100 AS InteresTotal, AVG(InteresBalance) / AVG(SaldoCapital) 
													   * 100 AS InteresBalance, AVG(InteresCtaOrden) / AVG(SaldoCapital) * 100 AS InteresCtaOrden
								FROM          (SELECT     tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina, SUM(tCsCarteraDet.SaldoCapital) AS SaldoCapital, 
																			   SUM(tCsCarteraDet.SaldoInteres + tCsCarteraDet.SaldoMoratorio) AS InteresTotal, 
																			   SUM(tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido + tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido) 
																			   AS InteresBalance, SUM(tCsCarteraDet.InteresCtaOrden + tCsCarteraDet.MoratorioCtaOrden) AS InteresCtaOrden
														FROM          tCsCarteraDet INNER JOIN
																			   tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo
														--WHERE   (tCsCarteraDet.Fecha <= @Fecha - 2) AND (tCsCarteraDet.Fecha >= @Fecha - 9) AND
														WHERE   (tCsCarteraDet.Fecha IN (Select F From #K)) AND
																(tCsCartera.Cartera IN ('ACTIVA', 'ADMINISTRATIVA'))
														GROUP BY tCsCarteraDet.Fecha, tCsCarteraDet.CodOficina) AS Datos
								GROUP BY CodOficina) Kemy2 ON #Kemy1.CodOficina = Kemy2.CodOficina COLLATE Modern_Spanish_CI_AI
								
	Drop Table #K								
End
If @P = 0
Begin
	SELECT     Zona, NomZon, @Fecha AS Fecha, CodOficina, Oficina
	          --, NroDesembolso, Desembolso, Nropordesembolsar, Pordesembolsar
	          ,NueNroDesembolso,NueDesembolso,NueNropordesembolsar,NuePordesembolsar
	          ,RepNroDesembolso,RepDesembolso,RepNropordesembolsar,RepPordesembolsar
	          , MontoPagado, Capital, Interes, 
						  Moratorio, CargoxMora, IVAInteres, IVAMoratorio, IVACargoxMora, NroOper, 0 AS CapitalAyer, CapitalAyer AS CapitalActual, CapitalAyer AS CapitalPendiente, 
						  CapitalAyer * InteresTotal / 100 + CapitalAyer AS SaldoKIM, CapitalAyer * InteresBalance / 100 + CapitalAyer AS SaldoCartera, CC, Tipo, PKProgramado, PKAtrasado, 
						  PKAdelantado
						  ,nrodesemperiodoN,montodesemperiodoN,nrodesemperiodoR,montodesemperiodoR
						  ,nrodesemsemanaN,montodesemsemanaN,nrodesemsemanaR,montodesemsemanaR
						  ,nrodesemanualN,montodesemanualN,nrodesemanualR,montodesemanualR
						  ,nrosemana						  
	FROM         (SELECT  dbo.fdurellena('0', tClZona.Orden, 2, 'D')+ tClOficinas.Zona As Zona, ISNULL(tClZona.Nombre, 'Zona No Especificada') AS NomZon, [#Kemy1].CodOficina, dbo.fduRellena('0', [#Kemy1].CodOficina, 2, 'D') 
												  + ' ' + tClOficinas.NomOficina AS Oficina
												  
												  , ISNULL([#Kemy].NueNroDesembolso, 0) AS NueNroDesembolso, ISNULL([#Kemy].NueDesembolso, 0) AS NueDesembolso
												  , ISNULL([#Kemy].NueNropordesembolsar, 0) AS NueNropordesembolsar, ISNULL([#Kemy].NuePordesembolsar, 0) AS NuePordesembolsar
												  , ISNULL([#Kemy].RepNroDesembolso, 0) AS RepNroDesembolso, ISNULL([#Kemy].RepDesembolso, 0) AS RepDesembolso
												  , ISNULL([#Kemy].RepNropordesembolsar, 0) AS RepNropordesembolsar, ISNULL([#Kemy].RepPordesembolsar, 0) AS RepPordesembolsar
												  
												  , ISNULL([#Kemy].MontoPagado, 0) AS MontoPagado, ISNULL([#Kemy].Capital, 0) AS Capital, ISNULL([#Kemy].Interes, 0) AS Interes, ISNULL([#Kemy].Moratorio, 0) AS Moratorio, 
												  ISNULL([#Kemy].CargoxMora, 0) AS CargoxMora, ISNULL([#Kemy].IVAInteres, 0) AS IVAInteres, ISNULL([#Kemy].IVAMoratorio, 0) AS IVAMoratorio, 
												  ISNULL([#Kemy].IVACargoxMora, 0) AS IVACargoxMora, ISNULL([#Kemy].NroOper, 0) AS NroOper, [#Kemy1].SaldoCapital AS CapitalAyer, 
												  [#Kemy1].InteresTotal, [#Kemy1].InteresBalance, [#Kemy1].InteresCtaOrden, ISNULL([#Kemy].CC, 0) AS CC, tClOficinas.Tipo, 
												  ISNULL([#Kemy].PKProgramado, 0) AS PKProgramado, ISNULL([#Kemy].PKAtrasado, 0) AS PKAtrasado, ISNULL([#Kemy].PKAdelantado, 0) 
												  AS PKAdelantado
												  ,dps.nrodesemperiodoN,dps.montodesemperiodoN,dps.nrodesemperiodoR,dps.montodesemperiodoR
												  ,dps.nrodesemsemanaN,dps.montodesemsemanaN,dps.nrodesemsemanaR,dps.montodesemsemanaR
												  ,dps.nrodesemanualN,dps.montodesemanualN,dps.nrodesemanualR,dps.montodesemanualR
												  ,dps.nrosemana 
						   FROM          tClOficinas INNER JOIN
												  [#Kemy1] ON tClOficinas.CodOficina = [#Kemy1].CodOficina LEFT OUTER JOIN
												  tClZona ON tClOficinas.Zona = tClZona.Zona LEFT OUTER JOIN
												  [#Kemy] ON [#Kemy1].CodOficina = [#Kemy].CodOficina
												  left outer join #desemxpese dps on dps.codoficina=tClOficinas.codoficina
				--where tClOficinas.tipo<>'Cerrada'				
		) AS Datos
	ORDER BY Zona, Oficina
End
If @P = 1
Begin 
	BEGIN DISTRIBUTED TRANSACTION
	Set @Cadena = 'SELECT dbo.fdurellena(''0'', tClZona.Orden, 2, ''D'')+ tClOficinas.Zona As Zona, ISNULL(tClZona.Nombre, ''Zona No Especificada'') AS '
	Set @Cadena = @Cadena + 'NomZon, Cast(''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD') + ''' as SmallDateTime) AS Fecha, Datos.Codoficina, dbo.fduRellena'
	Set @Cadena = @Cadena + '(''0'', Datos.Codoficina, 2, ''D'') + '' '' + tClOficinas.NomOficina + ISNULL(Cajas.R, '' (SA)'') AS Oficina '
	--Set @Cadena = @Cadena + 'Datos.NroDesembolso, Datos.Desembolso, Datos.Nropordesembolsar, Datos.Pordesembolsar, Datos.MontoPagado, Datos.Capital, '
	Set @Cadena = @Cadena + ',Datos.NueNroDesembolso,Datos.NueDesembolso,Datos.NueNropordesembolsar,Datos.NuePordesembolsar '
	Set @Cadena = @Cadena + ',Datos.RepNroDesembolso,Datos.RepDesembolso,Datos.RepNropordesembolsar,Datos.RepPordesembolsar'
	
	Set @Cadena = @Cadena + ',Datos.MontoPagado, Datos.Capital'	
	Set @Cadena = @Cadena + ',Datos.Interes, Datos.Moratorio, Datos.CargoxMora, Datos.IVAInteres, Datos.IVAMoratorio, Datos.IVACargoxMora, Datos.NroOper, '
	Set @Cadena = @Cadena + 'Datos.CapitalAyer, Datos.CapitalAyer + Datos.NueDesembolso+Datos.RepDesembolso - Datos.Capital AS CapitalActual, Datos.CapitalAyer + Datos.NueDesembolso+Datos.RepDesembolso '
	Set @Cadena = @Cadena + '+ Datos.NuePordesembolsar+Datos.RepPordesembolsar - Datos.Capital - Datos.CC AS CapitalPendiente, (Datos.CapitalAyer + Datos.NueDesembolso+Datos.RepDesembolso + '
	Set @Cadena = @Cadena + 'Datos.NuePordesembolsar+Datos.RepPordesembolsar - Datos.Capital - Datos.CC) * Datos.InteresTotal / 100 + (Datos.CapitalAyer + Datos.NueDesembolso+Datos.RepDesembolso + '
	Set @Cadena = @Cadena + 'Datos.NuePordesembolsar+Datos.RepPordesembolsar - Datos.Capital - Datos.CC) AS SaldoKIM, (Datos.CapitalAyer + Datos.NueDesembolso+Datos.RepDesembolso + Datos.NuePordesembolsar+Datos.RepPordesembolsar - '
	Set @Cadena = @Cadena + 'Datos.Capital - Datos.CC) * Datos.InteresBalance / 100 + (Datos.CapitalAyer + Datos.NueDesembolso+Datos.RepDesembolso + Datos.NuePordesembolsar+Datos.RepPordesembolsar - '
	Set @Cadena = @Cadena + 'Datos.Capital - Datos.CC) AS SaldoCartera, Datos.CC, case when tClOficinas.Tipo=''Cerrada'' then tClOficinas.Tipo else ''Activa'' end Tipo, Datos.PKProgramado, Datos.PKAtrasado, Datos.PKAdelantado '
	
	Set @Cadena = @Cadena + ',isnull(dps.nrodesemperiodoN,0) nrodesemperiodoN,isnull(dps.montodesemperiodoN,0) montodesemperiodoN '
	Set @Cadena = @Cadena + ',isnull(dps.nrodesemperiodoR,0) nrodesemperiodoR,isnull(dps.montodesemperiodoR,0) montodesemperiodoR '
	Set @Cadena = @Cadena + ',isnull(dps.nrodesemsemanaN,0) nrodesemsemanaN,isnull(dps.montodesemsemanaN,0) montodesemsemanaN '
	Set @Cadena = @Cadena + ',isnull(dps.nrodesemsemanaR,0) nrodesemsemanaR,isnull(dps.montodesemsemanaR,0) montodesemsemanaR '
	Set @Cadena = @Cadena + ',isnull(dps.nrodesemanualN,0) nrodesemanualN,isnull(dps.montodesemanualN,0) montodesemanualN '
	Set @Cadena = @Cadena + ',isnull(dps.nrodesemanualR,0) nrodesemanualR,isnull(dps.montodesemanualR,0) montodesemanualR '
	Set @Cadena = @Cadena + ',dps.nrosemana '
	
	Set @Cadena = @Cadena + 'FROM (SELECT ISNULL([#Kemy1].CodOficina, [#Kemy].CodOficina) AS Codoficina, ISNULL([#Kemy].NueNroDesembolso, 0) AS NueNroDesembolso, ISNULL([#Kemy].RepNroDesembolso, 0) AS RepNroDesembolso, '
	Set @Cadena = @Cadena + 'ISNULL([#Kemy].NueDesembolso, 0) AS NueDesembolso,ISNULL([#Kemy].RepDesembolso, 0) AS RepDesembolso, ISNULL([#Kemy].NueNropordesembolsar, 0) AS NueNropordesembolsar,ISNULL([#Kemy].RepNropordesembolsar, 0) AS RepNropordesembolsar, '
	Set @Cadena = @Cadena + 'ISNULL([#Kemy].NuePordesembolsar, 0) AS NuePordesembolsar,ISNULL([#Kemy].RepPordesembolsar, 0) AS RepPordesembolsar, ISNULL([#Kemy].MontoPagado, 0) AS MontoPagado, ISNULL([#Kemy].Capital, 0) '
	Set @Cadena = @Cadena + 'AS Capital, ISNULL([#Kemy].Interes, 0) AS Interes, ISNULL([#Kemy].Moratorio, 0) AS Moratorio, ISNULL([#Kemy].CargoxMora, 0) AS '
	Set @Cadena = @Cadena + 'CargoxMora, ISNULL([#Kemy].IVAInteres, 0) AS IVAInteres, ISNULL([#Kemy].IVAMoratorio, 0) AS IVAMoratorio, '
	Set @Cadena = @Cadena + 'ISNULL([#Kemy].IVACargoxMora, 0) AS IVACargoxMora, ISNULL([#Kemy].NroOper, 0) AS NroOper, ISNULL([#Kemy1].SaldoCapital, 0) AS '
	Set @Cadena = @Cadena + 'CapitalAyer, ISNULL([#Kemy1].InteresTotal, 0) AS InteresTotal, ISNULL([#Kemy1].InteresBalance, 0) AS InteresBalance, '
	Set @Cadena = @Cadena + 'ISNULL([#Kemy1].InteresCtaOrden, 0) AS InteresCtaOrden, ISNULL([#Kemy].CC, 0) AS CC, ISNULL([#Kemy].PKProgramado, 0) AS '
	Set @Cadena = @Cadena + 'PKProgramado, ISNULL([#Kemy].PKAtrasado, 0) AS PKAtrasado, ISNULL([#Kemy].PKAdelantado, 0) AS PKAdelantado FROM [#Kemy1] FULL '
	Set @Cadena = @Cadena + 'OUTER JOIN [#Kemy] ON [#Kemy].CodOficina = [#Kemy1].CodOficina) AS Datos INNER JOIN tClOficinas ON Datos.Codoficina = '
	Set @Cadena = @Cadena + 'tClOficinas.CodOficina LEFT OUTER JOIN (SELECT CodOficina, CASE R WHEN 0 THEN '''' WHEN 1 THEN '' (CjPr.)'' WHEN 2 '
	Set @Cadena = @Cadena + 'THEN '' (CjDe.)'' WHEN 3 THEN '' (BoPr.)'' WHEN 4 THEN '' (C)'' END AS R FROM (SELECT Codoficina, MIN(CjaPre) + MIN(CjaDef) + '
	Set @Cadena = @Cadena + 'MIN(BovPre) + MIN(BovDef) AS R FROM (SELECT CAST(tTcBoveda.CodOficina AS Int) AS Codoficina, CAST(tTcCajas.CierrePreliminar AS '
	Set @Cadena = @Cadena + 'Int) AS CjaPre, CAST(tTcCajas.CierreDefinitivo AS Int) AS CjaDef, CAST(tTcBoveda.CierrePreliminar AS Int) AS BovPre, '
	Set @Cadena = @Cadena + 'CAST(tTcBoveda.CierreDefinitivo AS INt) AS BovDef FROM [10.0.2.14].finmas.dbo.tTcCajas AS tTcCajas RIGHT OUTER JOIN '
	Set @Cadena = @Cadena + '[10.0.2.14].finmas.dbo.tTcBoveda AS tTcBoveda ON tTcCajas.CodOficina = tTcBoveda.CodOficina AND tTcCajas.FechaPro = '
	Set @Cadena = @Cadena + 'tTcBoveda.FechaPro WHERE (tTcBoveda.FechaPro = ''' + dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD') + ''')) AS Datos_1 GROUP BY '
	Set @Cadena = @Cadena + 'Codoficina) AS Datos_2) AS Cajas ON Datos.Codoficina = Cajas.CodOficina LEFT OUTER JOIN tClZona ON tClOficinas.Zona = '
	Set @Cadena = @Cadena + 'tClZona.Zona left outer join #desemxpese dps on dps.codoficina=datos.codoficina ORDER BY tClOficinas.Zona, Oficina '
	
	Print	@Cadena
	Exec   (@Cadena)
	
	COMMIT TRANSACTION
End

Drop Table #Kemy
Drop Table #Kemy1
drop table #desemxpese
GO