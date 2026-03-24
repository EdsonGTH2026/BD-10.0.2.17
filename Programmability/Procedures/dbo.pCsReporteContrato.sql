SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsReporteContrato  
--sp_helptext pCsReporteContrato
--Exec pCsReporteContrato 20, 'rgarciah', 'ZZZ', '028-105-06-2-2-00151-0-0'  
CREATE Procedure [dbo].[pCsReporteContrato]  
@Dato   Int,  
@Usuario  Varchar(50) ,  
@Ubicacion  Varchar(500),  
@Prestamo     Varchar(25) = ''  
AS  
  
--DATO  
-- 1: Se usa para Pagare y Contrato conectado al servidor de la operativa directamente y utiliza la nueva configuración de la Operativa para generar la   
--    tabla Reporte más Rapida.   
-- 2: Este parámetro esta libre por el momento. El codigo anterior fue eliminado.  
-- 3: Se usa para Pagare y Contrato conectado al servidor alterno directamente y utiliza la nueva configuración más rapida de la Operativa para   
--    generar la table Reporte más Rapida. Esta opción se usa para realizar pruebas.  
-- 4: Se usa para las cartas que se envían cuando el cliente se atrasa. (Cartas de Cobranza y Cartas Finales)  
  
Declare @Sistema   Varchar(2)   
Declare @Firma    Varchar(100)  
Declare @Cadena   Varchar(8000)  
Declare @Servidor  Varchar(50),  @BaseDatos  Varchar(50),  @Contador  Int  
Declare @CUbicacion  Varchar(500),  @OtroDato  Varchar(100),  @IP   Varchar(50)  
Declare @CodOficina  Varchar(100),  @CodPrestamo  Varchar(50)  
Declare @TempVC   Varchar(8000)  
Declare @TempVC1  Varchar(8000)  
Declare @TempVC2  Varchar(8000)  
Declare @TempVC3  Varchar(8000)  
Declare @TempVC4  Varchar(8000)  
Declare @TempVC5  Varchar(8000)  
Declare @TempVC6  Varchar(8000)  
Declare @TempVC7  Varchar(8000)  
Declare @TempVC8  Varchar(8000)  
Declare @TempDC   Decimal(20,8)  
Declare @TempDC1  Decimal(20,8)  
Declare @TempIT   Int  
Declare @TempIT1  Int  
Declare @TempIT2  Int  
Declare @TempIT3  Int  
Declare @TempIT4  Int  
Declare @Fecha   SmallDateTime  
Declare @MDireccion  Varchar(500)  
Declare @ODireccion  Varchar(500)  
Declare @SiPl   Varchar(1)  
Declare @SiPlAval  Varchar(1)  
Declare @SiPlGL   Varchar(1)  
Declare @SiPlGarantia Varchar(1)  
Declare @Acreditados Int  
Declare @NoAvales  Int  
Declare @NoGarantias Int  
Declare @TipoClausula Varchar(50)  
Declare @Sexo    Int  
Declare @PaginaWeb  Varchar(50)  
Declare @LineaGratuita Varchar(50)  
---->>>-<<<----  
Declare @DenoSujeto   Varchar(500)  
Declare @MontoNum   Varchar(100)  
Declare @MontoLet   Varchar(100)  
--I Cuadros  
Declare @Partida    Varchar(4000)  
Declare @CuadroAmortizacion  Varchar(8000)  
Declare @CuadroAmortizacion1 Varchar(8000)  
Declare @CuadroAmortizacion2 Varchar(8000)  
Declare @Garantia    Varchar(8000)  
--F Cuadros, Se usa para las Variables de las etiquetas.  
Declare @TasaMensual  Varchar(10)  
Declare @TasaLet   Varchar(100)  
Declare @MoraNum   Varchar(10)  
Declare @MoraLet   Varchar(100)  
Declare @MoratorioNum  Varchar(10)  
Declare @MoratorioLet  Varchar(100)  
Declare @ComisionNum  Varchar(10)  
Declare @ComisionLet  Varchar(100)  
Declare @HAPLV    Varchar(20)  
Declare @HAPSA    Varchar(20)  
Declare @Frecuencia   Varchar(10)  
Declare @Plazo    Varchar(5)  
Declare @FrecuenciaS  Varchar(15)  
Declare @FrecuenciaP  Varchar(15)  
Declare @FrecuenciaC  Varchar(20)  
Declare @TipoPlanD   Varchar(100)  
Declare @DCorporativo  Varchar(500)  
Declare @DAgencia   Varchar(500)  
Declare @EAgencia   Varchar(500)  
Declare @DCliente   Varchar(8000)  
Declare @SRA    Varchar(50)  
Declare @Nombres   Varchar(500)   
Declare @Avales    Varchar(500)   
Declare @NAval    Varchar(50)  
Declare @DAval    Varchar(8000)  
Declare @Desembolso   Varchar(100)   
Declare @CalculoINTE  Varchar(50)  
Declare @GLCuenta   Varchar(100)  
Declare @GLMonto   Varchar(100)  
Declare @ResumenCuotaT  Varchar(4000)  
Declare @CATNum    Varchar(10)  
Declare @CATLet    Varchar(100)  
--Valores Fijos  
Declare @VFCDPS    Varchar(500)  
Declare @VFCDSI    Varchar(8000)  
---->>>-<<<----  
--Para manejo de Viñetas  
Declare @SecuenciaN   Int  
Declare @SecuenciaL   Int  
Declare @LetraNumero  Varchar(1)  
Declare @Mayuscula   Bit  
Declare @Comodin   Varchar(5)  
--Variables Auxiliares   
Declare @AUX    Varchar(8000)  
Declare @AUXv    Varchar(100)  
Declare @AUXi    Int      
  
Set @Fecha  = dbo.FduFechaATexto(GetDate(), 'AAAAMMDD')  
set @Prestamo = Ltrim(Rtrim(@Prestamo))  
Set @CodOficina = @Ubicacion  
  
If Len(@Prestamo) = 19  
Begin  
 Set @Sistema = 'CA'   
End  
Else  
Begin  
 Set @Sistema = 'AH'   
End  
  
Exec pGnlCalculaParametros 1, @Ubicacion,  @CUbicacion  Out,  @Ubicacion  Out,  @OtroDato Out  
  
If @Prestamo <> '' Begin Set @CUbicacion = Cast(Substring(@Prestamo, 1, 3) as Int)  end   
  
--DEFINICION DE TABLAS TEMPORALES  
CREATE TABLE #Valor (  
 [Valor]   [varchar] (8000) COLLATE Modern_Spanish_CI_AI NULL)   
  
CREATE TABLE #Oficina (  
 [CodOficina]   [varchar] (4) COLLATE Modern_Spanish_CI_AI NOT NULL,  
 [Orden]   [int] NULL,  
 [Direccion]   [varchar] (500) COLLATE Modern_Spanish_CI_AI NULL,  
 [DescOficina]   [varchar] (100) COLLATE Modern_Spanish_CI_AI NULL)   
  
CREATE TABLE #Etiqueta (  
 [Fila]    [int] NOT NULL,  
 [Etiqueta]   [varchar] (50) COLLATE Modern_Spanish_CI_AI NOT NULL,  
 [Texto]   [varchar] (8000) COLLATE Modern_Spanish_CI_AI NULL)   
  
CREATE TABLE #Reporte (  
 [CodPrestamo]   [varchar]  (25)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [Coordinador]   [int]   NOT NULL ,  
 [NombreCompleto]  [varchar]  (120)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [CodUsuario]   [varchar]  (15)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [FechaAprobacion]  [datetime]  NOT NULL ,   
 [FechaDesembolso]  [datetime]  NOT NULL  ,  
 [MontoDesembolso]  [money]  NOT NULL  ,  
 [Fondo]    [varchar]  (5)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [Estado]    [varchar]  (50)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [CodDocIden]   [varchar]  (5)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [DI]     [varchar]  (20)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [LabActividad]   [varchar]  (50)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [UsOcupacion]   [varchar]  (30)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [CodUbiGeo]   [varchar]  (6)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [CodPais]    [varchar]  (6)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Direccion]   [varchar]  (150)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [NumExterno]   [varchar]  (10)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [NumInterno]   [varchar]  (10)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Ubicacion]   [varchar]  (150)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [CodPostal]   [varchar]  (10)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Telefono]    [varchar]  (50)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [SecCuota]    [smallint]  NOT NULL ,  
 [FechaVencimiento]  [datetime]  NOT NULL ,  
 [FechaNacimiento]  [datetime]  NOT NULL ,  
 [MontoCuota]   [money]  NOT NULL ,  
 [MontoPago]   [money]  NOT NULL ,  
 [CodOficina]   [varchar]  (4)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [CodConcepto]   [varchar]  (5)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [ValorConcepto]  [money]  NULL ,  
 [MorParam]    [char]   (2)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [MorValor]    [money]  NULL ,  
 [ComParam]    [char]   (2)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [ComValor]    [money]  NULL ,  
 [IMoParam]    [char]   (2)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [IMoValor]    [money]  NULL ,  
 [Frecuencia]   [char]   (1)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [Plazo]    [int]   NOT NULL ,  
 [CodTipoPlan]   [tinyint]  NOT NULL ,  
 [CodProducto]   [char]   (3)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [CodEstadoCivil]  [char]   (1)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Sexo]     [bit]   NOT NULL ,  
 [Salud]    [varchar]  (200)  COLLATE Modern_Spanish_CI_AI NULL,  
 [Codeudor]    [varchar]  (120)  COLLATE Modern_Spanish_CI_AI NULL,  
 [TPCliente]   [varchar]  (2)  COLLATE Modern_Spanish_CI_AI NULL,  
 [CalculoINTE]   [varchar]  (2)  COLLATE Modern_Spanish_CI_AI NULL,  
 [cdCodUsuario]   [char]   (15)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [cdCodUbiGeo]   [varchar]  (6)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [cdDireccion]   [varchar]  (150)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [cdNumExterno]   [varchar]  (10)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [cdNumInterno]   [varchar]  (10)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [cdUbicacion]   [varchar]  (150)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [cdCodPostal]   [varchar]  (10)  COLLATE Modern_Spanish_CI_AI NULL,  
 [CodGrupo]    [varchar]  (15)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Grupo]    [varchar]  (100)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [SaldoAtrasado]  [decimal] (18, 4) NULL ,  
 [SaldoOtros]   [decimal] (18, 4) NULL,  
 [CResponsable]   [varchar]  (150)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [CAsesor]    [varchar]  (150)  COLLATE Modern_Spanish_CI_AI NULL,  
 [CCoordinador]   [varchar]  (150)  COLLATE Modern_Spanish_CI_AI NULL,  
 [Peso]     [decimal] (10, 2) NULL,  
 [Estatura]    [decimal] (10, 2) NULL,  
 [Acta]     [varchar]  (50)  COLLATE Modern_Spanish_CI_AI NULL,  
 [CodConyuge]  [varchar]  (15)  COLLATE Modern_Spanish_CI_AI NULL,  
 [Conyuge]    [varchar]  (100)  COLLATE Modern_Spanish_CI_AI NULL,  
 [Comisiones]   [varchar]  (3000)  COLLATE Modern_Spanish_CI_AI NULL  
  )   
  
CREATE TABLE #Garantia (   
 [Codigo]   [varchar]  (25)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [Descripcion]   [varchar]  (110)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Primero]   [varchar]  (286)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Segundo]   [varchar]  (67)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Tercero]   [varchar]  (62)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Cuarto]   [varchar]  (59)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Quinto]   [varchar]  (71)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Valor]   [varchar]  (105)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [Ubicacion]   [varchar]  (512)  COLLATE Modern_Spanish_CI_AI NULL ,  
 [DesTipoAvaluo]  [varchar]  (50)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [NoRegAval]   [varchar]  (10)  COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [CodTipoAvaluo]  [smallint]  NOT NULL)   
  
CREATE TABLE #Aval (  
 [Sistema]    [varchar] (2) COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [NombreCompleto]  [varchar] (120) COLLATE Modern_Spanish_CI_AI NULL ,  
 [Sexo]     [bit] NOT NULL ,  
 [CodTPersona]   [varchar] (2) COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [CodEstadoCivil]  [char] (1) COLLATE Modern_Spanish_CI_AI NULL ,  
 [LabActividad]   [varchar] (50) COLLATE Modern_Spanish_CI_AI NULL ,  
 [UsOcupacion]   [varchar] (30) COLLATE Modern_Spanish_CI_AI NULL ,  
 [CodDocIden]   [varchar] (5) COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [DI]     [varchar] (20) COLLATE Modern_Spanish_CI_AI NULL ,  
 [CodUbiGeo]   [varchar] (6) COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [Direccion]   [varchar] (150) COLLATE Modern_Spanish_CI_AI NOT NULL ,  
 [NumExterno]   [varchar] (6) COLLATE Modern_Spanish_CI_AI NULL ,  
 [NumInterno]   [varchar] (6) COLLATE Modern_Spanish_CI_AI NULL ,  
 [CodPostal]   [varchar] (10) COLLATE Modern_Spanish_CI_AI NULL ,  
 [CodPrestamo]   [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL,  
 [CodPais]    [varchar] (6) COLLATE Modern_Spanish_CI_AI NULL,  
 [CodCuenta]   [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL,  
 [MoAFavor]    [money] NULL,  
 [CodMoneda]   [varchar] (2) COLLATE Modern_Spanish_CI_AI NULL)  
  
Set @Cadena = 'Insert Into #Oficina (CodOficina) Select CodOficina from tClOficinas Where CodOficina in ('+ @CUbicacion +')'  
Exec(@Cadena)  
  
Update tCsFirmaElectronica  
Set Activo = 0  
where Usuario = @Usuario And Activo = 1  
  
If Isnumeric(@CUbicacion) = 1 And Ltrim(rtrim(@Usuario)) = 'kvalera'    
Begin  
 Update  tSgUsuarios  
 Set  CodOficina  = @CUbicacion  
 Where  Usuario  = @Usuario  
End  
  
Declare curOficina Cursor For   
 SELECT   DISTINCT Servidor, BaseDatos  
 FROM         tClOficinas  
 WHERE     (CodOficina In (Select CodOficina from #Oficina))  
Open curOficina  
Fetch Next From curOficina Into @IP, @BaseDatos  
While @@Fetch_Status = 0  
Begin    
 Truncate Table #Oficina  
 Insert Into #Oficina  
 Exec pCsOficinasDireccion 'Matriz', @Fecha  
  
 Set @Cadena = ''  
   
 Declare curReporte Cursor For   
  Select Direccion   
  from #Oficina    
  Where Direccion Is Not Null  
  Order by Orden  
 Open curReporte  
 Fetch Next From curReporte Into @TempVC  
 While @@Fetch_Status = 0  
 Begin    
  Set @Cadena = @Cadena + ', ' + Ltrim(Rtrim(@TempVC))  
 Fetch Next From curReporte Into  @TempVC  
 End   
 Close   curReporte  
 Deallocate  curReporte  
  
 Set @MDireccion = Substring(Rtrim(Ltrim(@Cadena)), 3, 1000)  
 Set @Contador = 0  
   
 Select @Contador = Count(*) From tCsServidores   
 Where Tipo = 3 And NombreIP = @IP And Rtrim(Ltrim(Isnull(NombreServidor, ''))) <> '' And idTextual = @CodOficina  
   
 If @Contador Is null Begin Set @Contador = 0 end  
   
 If @Contador = 0 and @Dato <> 3  
 Begin  
  if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[B]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
  Begin   
   drop table [dbo].[B]  
  End  
  Set @Cadena = 'CREATE TABLE [dbo].[B] ( '  
  Set @Cadena = @Cadena + '[Cadena] [varchar] (1157) COLLATE Modern_Spanish_CI_AI NULL '   
  Set @Cadena = @Cadena + ') ON [PRIMARY] '  
  Exec(@Cadena)  
  Set @Cadena = 'NBTSTAT -a '+ Ltrim(rTrim(@IP))  
  Insert Into B  
  Exec master..xp_cmdshell @Cadena  
    
  SELECT   @Servidor =  RTRIM(LTRIM(SUBSTRING(LTRIM(RTRIM(Cadena)), 1, CHARINDEX('<00>', LTRIM(RTRIM(Cadena)), 1) - 1)))   
  FROM         B  
  WHERE     (Cadena LIKE '%<00>  UNIQUE%') OR (Cadena LIKE '%<00>  Único%')  
   
  Select @Contador = Count(*) From tCsServidores   
    
  Set @Contador = @Contador + 1  
   
  Insert Into tCsServidores (IdServidor, Descripcion, NombreIP, NombreBD, Tipo, IdTextual, NombreServidor, Registro)  
  Values(@Contador, 'PROCESO INTERNO', @IP, @BaseDatos, 3, @CodOficina, @Servidor, GetDate())  
 End  
   
 Select Top 1 @Servidor = NombreServidor From tCsServidores Where Tipo = 3 And NombreIP = @IP And Rtrim(Ltrim(Isnull(NombreServidor, ''))) <> '' and IdTextual = @CodOficina  
   
 If @Dato = 3  
 Begin  
  Set @Servidor   = 'DC-FINAMIGO-SRV'  
  Set @BaseDatos  = 'Finamigo_Conta_AAs'  
 End  
  
 Truncate Table #Reporte  
 If @Dato In (1,3, 4)   
 Begin   
  Set @Cadena =  'Exec ['+ @Servidor +'].['+ @BaseDatos +'].dbo.pRptDocumentos ''' + @CUbicacion + ''', ''' + @Prestamo + ''''  
  Set @Cadena =  @Cadena + ' INSERT INTO #Reporte SELECT * FROM ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tRptDocumentos WHERE CodPrestamo = ''' + @Prestamo + ''''  
 End  
  
 If @Dato = 2  
 Begin  
  Print 'FALTA CODIGO'    
 End   
 Print 'PARA REPORTE'  
 Print @Cadena  
 Exec (@Cadena)  
   
 If @Dato In (1, 2, 3) And @Sistema = 'CA'  
 Begin   
  --DATOS DE GARANTIAS  
  Truncate Table #Garantia  
    
  Set @Cadena = 'Insert Into #Garantia SELECT DISTINCT '  
  Set @Cadena = @Cadena + 'tGaGarantias.Codigo, CASE WHEN tGaAvaluo.Codtipoavaluo IN (3, 7) THEN ''Descripción                    : '' + Upper(tGaClTipoVehiculo.Descripcion) '  
  Set @Cadena = @Cadena + '+ ''('' + tGaClTipoAvaluo.DesTipoAvaluo + '')'' WHEN tGaAvaluo.Codtipoavaluo IN (1, 2, 8, 10, 18, 15) '  
  Set @Cadena = @Cadena + 'THEN ''Descripción                    : '' + tGaClTipoAvaluo.DesTipoAvaluo WHEN tGaAvaluo.Codtipoavaluo IN (6, 5) '  
  Set @Cadena = @Cadena + 'THEN ''Descripción                    : '' + upper(tGaAvaluoPrendarias.PDescripcion) '  
  Set @Cadena = @Cadena + '+ '' ('' + tGaClTipoAvaluo.DesTipoAvaluo + '')'' ELSE ''LLamar a Sistemas'' END AS Descripcion, CASE WHEN tGaAvaluo.Codtipoavaluo IN (3, 7) '  
  Set @Cadena = @Cadena + 'THEN ''Marca                                      : '' + upper(tGaAvaluo.VhMarca) WHEN tGaAvaluo.Codtipoavaluo IN (1, 2, 8, 10, 18) '  
  Set @Cadena = @Cadena + 'THEN '' Datos Escritura        : '' + upper(Isnull(tGaClTipoDocCustodia.Descripcion, OBS)) + '' Nro. Reg. '' + upper(INNoinscripcion) WHEN tGaAvaluo.Codtipoavaluo IN (6, '  
  Set @Cadena = @Cadena + '5, 15) THEN ''Detalle                                  : '' + upper(tGaAvaluoPrendarias.PDetalle) + '' '' + ISnull(upper(PMarca), '''') ELSE ''Llamar a Sistemas'' END AS Primero, '  
  Set @Cadena = @Cadena + 'CASE WHEN tGaAvaluo.Codtipoavaluo IN (3) THEN ''Modelo                                  : '' + Upper(tGaAvaluo.VhModelo) WHEN tGaAvaluo.Codtipoavaluo IN (5, 7) '  
  Set @Cadena = @Cadena + 'THEN ''Modelo   : '' + isnull(Upper(PModelo), '''') WHEN tGaAvaluo.Codtipoavaluo IN (1, 2, 6, 8, 10, 18, 15) '  
  Set @Cadena = @Cadena + 'THEN '''' ELSE ''Llamar a Sistemas'' END AS Segundo, CASE WHEN tGaAvaluo.Codtipoavaluo IN (3) THEN ''No. Motor                          : '' + upper(tGaAvaluo.VhNoMotor) '  
  Set @Cadena = @Cadena + 'WHEN tGaAvaluo.Codtipoavaluo IN (5, 7) THEN ''No. Serie                          : '' + upper(Pserie) WHEN tGaAvaluo.Codtipoavaluo IN (1, 2, 6, 8, 10, 18, 15) '  
  Set @Cadena = @Cadena + 'THEN '''' ELSE ''LLamar a Sistemas'' END AS Tercero, CASE WHEN tGaAvaluo.Codtipoavaluo IN (3) THEN ''No. Chasis                      : '' + upper(tGaAvaluo.VhNoChasis) '  
  Set @Cadena = @Cadena + 'WHEN tGaAvaluo.Codtipoavaluo IN (1, 2, 5, 6, 8, 10, 18, 7, 15) THEN '''' ELSE ''LLamar a Sistemas'' END AS Cuarto, CASE WHEN tGaAvaluo.Codtipoavaluo IN (3, 7, 6, 15) '  
  Set @Cadena = @Cadena + 'THEN ''Factura                                : '' + CASE WHEN tGaAvaluo.Codtipoavaluo IN (3, 7) THEN upper(tGaAvaluo.VhPropiedad) '  
  Set @Cadena = @Cadena + 'ELSE upper(tGaAvaluoPrendarias.noregistro) END WHEN tGaAvaluo.Codtipoavaluo IN (1, 2, 5, 6, 8, 10, 18) THEN '''' ELSE ''LLamar a Sistemas'' END AS Quinto, '  
  Set @Cadena = @Cadena + 'CASE WHEN tGaAvaluo.Codtipoavaluo IN (3, 7, 6, 5, 15) '  
  Set @Cadena = @Cadena + 'THEN ''Valor Liquidación : '' + CASE WHEN tgaavaluo.Codmoneda = 6 THEN ''$'' ELSE ''Moneda No Especificada'' END + CASE WHEN tGaAvaluo.Codtipoavaluo IN (6, 5, 7, 15) '  
  Set @Cadena = @Cadena + 'THEN dbo.fdunumerotexto(pvalorgravamen, 2) ELSE dbo.fdunumerotexto(tGaAvaluo.ValorGravamen, 2) END WHEN tGaAvaluo.Codtipoavaluo IN (1, 2, 8, 10, 18) '  
  Set @Cadena = @Cadena + 'THEN ''Valor                                        : '' + CASE WHEN tgaavaluo.Codmoneda = 6 THEN ''$'' ELSE ''Moneda No Especificada'' END + dbo.fdunumerotexto(tGaAvaluo.ValorGravamen, '  
  Set @Cadena = @Cadena + ' 2) ELSE ''LLamar a Sistemas'' END AS Valor, CASE WHEN tGaAvaluo.Codtipoavaluo IN (3, 7) '  
  Set @Cadena = @Cadena + 'THEN ''Ubicación                         : Localidad '' + tCPLugar.Lugar + '',  Mpio. '' + tCPClMunicipio.Municipio + '', Edo. '' + tCPClEstado.Estado + ''.'' WHEN tGaAvaluo.Codtipoavaluo '  
  Set @Cadena = @Cadena + ' IN (1, 2, 5, 6, 8, 10, 18, 15) THEN ''Ubicación                         : '' + CASE WHEN tGaAvaluo.Codtipoavaluo IN (5, 6, 15) '  
  Set @Cadena = @Cadena + 'THEN CASE Pubicacion WHEN ''D'' THEN ''Domicilio'' WHEN ''N'' THEN ''Negocio'' ELSE ''No se específica'' END ELSE upper(Inzona) + ''/'' + upper(inUbi) + ''/'' + UPPER(Indir) '  
  Set @Cadena = @Cadena + ' END ELSE ''Llamar a Sistemas'' END AS Ubicacion, tGaClTipoAvaluo.DesTipoAvaluo, CAST(tGaAvaluo.NoRegAval AS varchar(10)) '  
  Set @Cadena = @Cadena + '+ ISNULL(CAST(tGaAvaluoPrendarias.Item AS Varchar(10)), '''') AS NoRegAval, tGaClTipoAvaluo.CodTipoAvaluo '  
  Set @Cadena = @Cadena + 'FROM #Reporte Reporte INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tCaPrestamos tCaPrestamos ON Reporte.CodPrestamo = tCaPrestamos.CodPrestamo LEFT OUTER JOIN '  
  Set @Cadena = @Cadena + '(SELECT     Datos.CodUsuario, tUsUsuarioDireccion.CodUbiGeo '  
  Set @Cadena = @Cadena + 'FROM          (SELECT     tUsUsuarioDireccion.CodUsuario, MAX(tUsUsuarioDireccion.IdDireccion) AS IdDireccion '  
  Set @Cadena = @Cadena + 'FROM          (SELECT     CodUsuario, IdDireccion, MAX(CAST(EsPrincipal AS Int)) AS EsPrincipal '  
  Set @Cadena = @Cadena + 'FROM          ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioDireccion tUsUsuarioDireccion '  
  Set @Cadena = @Cadena + 'GROUP BY CodUsuario, IdDireccion) Datos INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioDireccion tUsUsuarioDireccion ON '  
  Set @Cadena = @Cadena + 'Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tUsUsuarioDireccion.CodUsuario AND '  
  Set @Cadena = @Cadena + 'Datos.IdDireccion = tUsUsuarioDireccion.IdDireccion AND Datos.EsPrincipal = tUsUsuarioDireccion.EsPrincipal '  
  Set @Cadena = @Cadena + 'GROUP BY tUsUsuarioDireccion.CodUsuario) Datos INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioDireccion tUsUsuarioDireccion ON '   
  Set @Cadena = @Cadena + 'Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tUsUsuarioDireccion.CodUsuario AND Datos.IdDireccion = tUsUsuarioDireccion.IdDireccion) '  
  Set @Cadena = @Cadena + 'Direccion INNER JOIN '  
  Set @Cadena = @Cadena + 'tClUbigeo ON Direccion.CodUbiGeo COLLATE Modern_Spanish_CI_AI = tClUbigeo.CodUbiGeo INNER JOIN '  
  Set @Cadena = @Cadena + 'tCPLugar ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND '   
  Set @Cadena = @Cadena + 'tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN '  
  Set @Cadena = @Cadena + 'tCPClMunicipio ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN '  
  Set @Cadena = @Cadena + 'tCPClEstado ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado ON tCaPrestamos.CodUsuario = Direccion.CodUsuario INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tGaGarantias tGaGarantias INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tGaAvaluo tGaAvaluo ON tGaGarantias.CodOficina = tGaAvaluo.CodOficina AND '   
  Set @Cadena = @Cadena + 'tGaGarantias.NoAvaluo = tGaAvaluo.NoRegAval INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tGaClTipoAvaluo tGaClTipoAvaluo ON tGaAvaluo.CodTipoAvaluo = tGaClTipoAvaluo.CodTipoAvaluo ON '  
  Set @Cadena = @Cadena + 'tCaPrestamos.CodPrestamo = tGaGarantias.Codigo LEFT OUTER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tGaClTipoDocCustodia tGaClTipoDocCustodia ON tGaGarantias.CDTipoDoc = tGaClTipoDocCustodia.Codigo LEFT OUTER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tGaAvaluoPrendarias tGaAvaluoPrendarias ON tGaAvaluo.NoRegAval = tGaAvaluoPrendarias.NoRegAval AND '   
  Set @Cadena = @Cadena + 'tGaAvaluo.CodOficina = tGaAvaluoPrendarias.CodOficina LEFT OUTER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tGaClTipoVehiculo tGaClTipoVehiculo ON tGaAvaluo.VhClase = CAST(tGaClTipoVehiculo.Codigo AS Varchar(100)) '  
   
  Print 'PARA GARANTIA'  
  Print @Cadena  
  Exec (@Cadena)  
 End  
 If @Dato In (1, 2, 3, 4) And @Sistema = 'CA'  
 Begin   
  --DATOS DE AVALES  
  Truncate Table #Aval  
    
  Set @Cadena = 'INSERT INTO #Aval SELECT * FROM (SELECT DISTINCT '  
  Set @Cadena = @Cadena + 'Sistema = ''AV'', tUsUsuarios.NombreCompleto, tUsUsuarios.Sexo, tUsUsuarios.CodTPersona, tUsUsuarios.CodEstadoCivil, Isnull(tUsUsuarioSecundarios.LabActividad, '''') As LabActividad, '  
  Set @Cadena = @Cadena + 'Isnull(tUsUsuarioSecundarios.UsOcupacion, '''') as UsOcupacion, tUsUsuarios.CodDocIden, tUsUsuarios.DI, Direccion.CodUbiGeo, Direccion.Direccion, Direccion.NumExterno, '   
  Set @Cadena = @Cadena + 'Direccion.NumInterno, Direccion.CodPostal, Reporte.CodPrestamo, tUsUsuarios.CodPais, CodCuenta = '''', MoAFavor, tGaGarantias.CodMOneda '  
  Set @Cadena = @Cadena + 'FROM ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tGaGarantias tGaGarantias INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarios tUsUsuarios ON tGaGarantias.DocPropiedad = tUsUsuarios.CodUsuario INNER JOIN '  
  Set @Cadena = @Cadena + '(SELECT Datos.CodUsuario, tUsUsuarioDireccion.CodUbiGeo, tUsUsuarioDireccion.Direccion, IsNull(tUsUsuarioDireccion.NumExterno, '''') as NumExterno, '   
  Set @Cadena = @Cadena + 'Isnull(tUsUsuarioDireccion.NumInterno, '''') as NumInterno, tUsUsuarioDireccion.CodPostal '  
  Set @Cadena = @Cadena + 'FROM (SELECT tUsUsuarioDireccion.CodUsuario, MAX(tUsUsuarioDireccion.IdDireccion) AS IdDireccion '  
  Set @Cadena = @Cadena + 'FROM (SELECT CodUsuario, IdDireccion, MAX(CAST(EsPrincipal AS Int)) AS EsPrincipal '  
  Set @Cadena = @Cadena + 'FROM ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioDireccion tUsUsuarioDireccion '  
  Set @Cadena = @Cadena + 'GROUP BY CodUsuario, IdDireccion) Datos INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioDireccion tUsUsuarioDireccion ON '  
  Set @Cadena = @Cadena + 'Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tUsUsuarioDireccion.CodUsuario AND '  
  Set @Cadena = @Cadena + 'Datos.IdDireccion = tUsUsuarioDireccion.IdDireccion AND Datos.EsPrincipal = tUsUsuarioDireccion.EsPrincipal '  
  Set @Cadena = @Cadena + 'GROUP BY tUsUsuarioDireccion.CodUsuario) Datos INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioDireccion tUsUsuarioDireccion ON '  
  Set @Cadena = @Cadena + 'Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tUsUsuarioDireccion.CodUsuario AND Datos.IdDireccion = tUsUsuarioDireccion.IdDireccion) '  
  Set @Cadena = @Cadena + 'Direccion ON tUsUsuarios.CodUsuario = Direccion.CodUsuario COLLATE Modern_Spanish_CI_AI INNER JOIN '  
  Set @Cadena = @Cadena + '#Reporte Reporte ON tGaGarantias.Codigo = Reporte.CodPrestamo LEFT OUTER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioSecundarios tUsUsuarioSecundarios ON tUsUsuarios.CodUsuario = tUsUsuarioSecundarios.CodUsuario '  
  Set @Cadena = @Cadena + 'UNION '  
  Set @Cadena = @Cadena + 'SELECT DISTINCT '  
  Set @Cadena = @Cadena + '''AH'' AS Sistema, tUsUsuarios.NombreCompleto, tUsUsuarios.Sexo, tUsUsuarios.CodTPersona, tUsUsuarios.CodEstadoCivil, tUsUsuarioSecundarios.LabActividad, '  
  Set @Cadena = @Cadena + 'tUsUsuarioSecundarios.UsOcupacion, tUsUsuarios.CodDocIden, tUsUsuarios.DI, Direccion.CodUbiGeo, Direccion.Direccion, Direccion.NumExterno, '  
  Set @Cadena = @Cadena + 'Direccion.NumInterno, Direccion.CodPostal, Reporte.CodPrestamo, tUsUsuarios.CodPais, '  
  Set @Cadena = @Cadena + 'tAhCuenta.CodCuenta + ''-'' + tAhCuenta.FraccionCta + ''-'' + CAST(tAhCuenta.Renovado AS varchar(5)) AS CodCuenta, MoAFavor, tGaGarantias.CodMOneda '  
  Set @Cadena = @Cadena + 'FROM ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tAhCuenta tAhCuenta INNER JOIN '  
  Set @Cadena = @Cadena + '#Reporte Reporte INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tGaGarantias tGaGarantias ON Reporte.CodPrestamo = tGaGarantias.Codigo ON '  
  Set @Cadena = @Cadena + 'tAhCuenta.CodCuenta = tGaGarantias.DocPropiedad INNER JOIN '  
  Set @Cadena = @Cadena + '(SELECT Datos.CodUsuario, tUsUsuarioDireccion.CodUbiGeo, tUsUsuarioDireccion.Direccion, tUsUsuarioDireccion.NumExterno, '  
  Set @Cadena = @Cadena + 'tUsUsuarioDireccion.NumInterno, tUsUsuarioDireccion.CodPostal '  
  Set @Cadena = @Cadena + 'FROM (SELECT tUsUsuarioDireccion.CodUsuario, MAX(tUsUsuarioDireccion.IdDireccion) AS IdDireccion '  
  Set @Cadena = @Cadena + 'FROM (SELECT CodUsuario, IdDireccion, MAX(CAST(EsPrincipal AS Int)) AS EsPrincipal '  
  Set @Cadena = @Cadena + 'FROM ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioDireccion tUsUsuarioDireccion '  
  Set @Cadena = @Cadena + 'GROUP BY CodUsuario, IdDireccion) Datos INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioDireccion tUsUsuarioDireccion ON '  
  Set @Cadena = @Cadena + 'Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tUsUsuarioDireccion.CodUsuario AND '  
  Set @Cadena = @Cadena + 'Datos.IdDireccion = tUsUsuarioDireccion.IdDireccion AND Datos.EsPrincipal = tUsUsuarioDireccion.EsPrincipal '  
  Set @Cadena = @Cadena + 'GROUP BY tUsUsuarioDireccion.CodUsuario) Datos INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioDireccion tUsUsuarioDireccion ON '  
  Set @Cadena = @Cadena + 'Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tUsUsuarioDireccion.CodUsuario AND Datos.IdDireccion = tUsUsuarioDireccion.IdDireccion) '  
  Set @Cadena = @Cadena + 'Direccion INNER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarios tUsUsuarios ON Direccion.CodUsuario COLLATE Modern_Spanish_CI_AI = tUsUsuarios.CodUsuario ON '  
  Set @Cadena = @Cadena + 'tAhCuenta.CodUsTitular = tUsUsuarios.CodUsuario LEFT OUTER JOIN '  
  Set @Cadena = @Cadena + '['+ @Servidor +'].['+ @BaseDatos +'].dbo.tUsUsuarioSecundarios tUsUsuarioSecundarios ON tUsUsuarios.CodUsuario = tUsUsuarioSecundarios.CodUsuario)DATOS '  
  
  Print 'PARA AVAL'  
  Print @Cadena  
  Exec (@Cadena)  
 End  
 --CURSOR QUE BARRE PRESTAMO A PRESTAMO  
  
 Declare curPrestamo Cursor For   
  Select Distinct CodPrestamo from #Reporte  
 Open curPrestamo  
 Fetch Next From curPrestamo Into @CodPrestamo  
 While @@Fetch_Status = 0  
 Begin    
  Print 'Inicio del Prestamo: ' + @CodPrestamo  
    
  SELECT   @TempVC = Tipo, @CodOficina = CodOficina   
  FROM         tClOficinas  
  WHERE     (CodOficina IN (Select Distinct CodOficina From #Reporte Where CodPrestamo = @CodPrestamo))  
  
  Truncate Table #Oficina  
  Insert Into #Oficina  
  Exec pCsOficinasDireccion @TempVC , @Fecha  
  ------------------------------------------  
  --01 TRABAJANDO CON: tCsFirmaElectornica  
  -----------------------------------------  
  Set @Cadena = ''  
  Declare curReporte Cursor For   
   Select Direccion   
   From #Oficina  
   Where CodOficina = @CodOficina And Direccion Is not Null  
   Order by Orden  
  Open curReporte  
  Fetch Next From curReporte Into @TempVC  
  While @@Fetch_Status = 0  
  Begin    
   Set @Cadena = @Cadena + ', ' + Ltrim(Rtrim(@TempVC))  
  Fetch Next From curReporte Into  @TempVC  
  End   
  Close   curReporte  
  Deallocate  curReporte  
    
  Set @ODireccion = Substring(Ltrim(Rtrim(@Cadena)), 3, 1000)  
    
  Exec pCsFirmaElectronica @Usuario, 'CA', @CodPrestamo, @Firma Out   
    
  Print 'Firma : ' + @Firma  
    
  ------------------->>>>PARA AVALES, se define @Avales  
  Set @NoAvales   = 0    
  Select @NoAvales  =  Count(*) from (Select Distinct NombreCompleto from #Aval  
  Where CodPrestamo  = @CodPrestamo and Sistema = 'AV') Datos  
  If @NoAvales Is Null Begin Set @NoAvales = 0 End  
  Set @Avales   = ''  
  Set @Contador   = 0  
  Declare curReporte Cursor For   
   Select Aval from (Select Distinct NombreCompleto as Aval from #Aval  
   Where CodPrestamo = @CodPrestamo And Sistema = 'AV') Datos     
  Open curReporte  
  Fetch Next From curReporte Into @TempVC  
  While @@Fetch_Status = 0  
  Begin    
   Set @Contador  = @Contador + 1  
   If  @Contador  = @NoAvales  
   Begin  
    Set @Avales  = @Avales + ' Y ' + Ltrim(Rtrim(@TempVC))  
   End  
   Else  
   Begin  
    Set @Avales  = @Avales + ', ' + Ltrim(Rtrim(@TempVC))   
   End     
  Fetch Next From curReporte Into  @TempVC  
  End   
  Close   curReporte  
  Deallocate  curReporte  
  Set @Avales  = Substring(Ltrim(@Avales), 3, 1000)   
  Print 'Número de Avales : ' + Cast(@NoAvales As Varchar(100))   
  If @NoAvales = 0 Begin Set @SiPlAval = 'N' End  
  If @NoAvales = 1 Begin Set @SiPlAval = 'S' End  
  If @NoAvales > 1 Begin Set @SiPlAval = 'P' End   
  ------------------->>>>PARA GARANTIAS LIQUIDAS, se denife @GLCuenta, @GLMonto  
  Set @TempIT   = 0    
  Select @TempIT   =  Count(*) from (Select Distinct CodCuenta from #Aval  
  Where CodPrestamo  = @CodPrestamo and Sistema = 'AH') Datos  
  If @TempIT Is Null Begin Set @TempIT = 0 End  
  Set @GLCuenta   = ''  
  Set @Contador   = 0  
  Set @TempDC  = 0  
  Declare curReporte Cursor For   
   SELECT     CodCuenta, SUM(Pesos) AS Pesos  
   FROM         (SELECT DISTINCT Aval.CodCuenta, Aval.MoAFavor * TC.TFijo AS Pesos  
                          FROM     #Aval Aval LEFT OUTER JOIN  
                                                     (SELECT DISTINCT CodMoneda, TFijo  
                                                       FROM          tClTipoCambio) TC ON Aval.CodMoneda = TC.CodMoneda COLLATE Modern_Spanish_CI_AI  
                          WHERE      (Aval.Sistema = 'AH') AND (Aval.CodPrestamo = @CodPrestamo)) Datos  
   GROUP BY CodCuenta     
  Open curReporte  
  Fetch Next From curReporte Into @TempVC, @TempDC1  
  While @@Fetch_Status = 0  
  Begin    
   Set @Contador  = @Contador + 1  
   If  @Contador  = @TempIT  
   Begin  
    Set @GLCuenta  = @GLCuenta + ' Y ' + Ltrim(Rtrim(@TempVC))  
   End  
   Else  
   Begin  
    Set @GLCuenta  = @GLCuenta + ', ' + Ltrim(Rtrim(@TempVC))   
   End  
   Set @TempDC = @TempDC + @TempDC1  
  Fetch Next From curReporte Into  @TempVC, @TempDC1  
  End   
  Close   curReporte  
  Deallocate  curReporte  
  Set @GLCuenta  = Substring(Ltrim(@GLCuenta), 3, 1000)  
  Set @GLMonto = '$' + dbo.fduNumeroTexto(@TempDC,2)  
  Print 'Número de Garantías Liquidas : ' + Cast(@TempIT As Varchar(100))   
  If @TempIT = 0 Begin Set @SiPlGL = 'N' End  
  If @TempIT = 1 Begin Set @SiPlGL = 'S' End  
  If @TempIT > 1 Begin Set @SiPlGL = 'P' End  
  ------------------->>>>PARA OTRAS GARANTIAS, no se define nada  
  Set @TempIT   = 0    
  Select @TempIT   =  Count(*) from (Select Distinct * from #Garantia Where Codigo = @CodPrestamo) Datos  
  If @TempIT Is Null Begin Set @TempIT = 0 End  
  Print 'Número de Otras Garantías : ' + Cast(@TempIT As Varchar(100))   
  If @TempIT = 0 Begin Set @SiPlGarantia = 'N' End  
  If @TempIT = 1 Begin Set @SiPlGarantia = 'S' End  
  If @TempIT > 1 Begin Set @SiPlGarantia = 'P' End  
  -------------------------------------  
  --02 TRABAJANDO CON: tCsFirmaReporte  
  ------------------------------------  
  ------------------->>>>PARA ACREDITADOS  
  Set @Acreditados  = 0    
  Select @Acreditados  =  Count(*) from (Select Distinct NombreCompleto, Coordinador from #Reporte  
  Where CodPrestamo  = @CodPrestamo) Datos  
  If @Acreditados Is Null Begin Set @Acreditados = 0 End  
  Set @Nombres   = ''  
  Set @Contador   = 0  
  Declare curReporte Cursor For   
   Select NombreCompleto from (Select Distinct NombreCompleto, Coordinador from #Reporte  
   Where CodPrestamo = @CodPrestamo) Datos  
   Order by Coordinador Desc  
  Open curReporte  
  Fetch Next From curReporte Into @TempVC  
  While @@Fetch_Status = 0  
  Begin    
   Set @Contador  = @Contador + 1  
   If  @Contador  = @Acreditados  
   Begin  
    Set @Nombres  = @Nombres + ' Y ' + Ltrim(Rtrim(@TempVC))  
   End  
   Else  
   Begin  
    Set @Nombres  = @Nombres + ', ' + Ltrim(Rtrim(@TempVC))   
   End     
  Fetch Next From curReporte Into  @TempVC  
  End   
  Close   curReporte  
  Deallocate  curReporte  
  Set @Nombres  = Substring(Ltrim(@Nombres), 3, 1000)  
  If @Acreditados = 1  -- CREDITOS INDIVIDUALES  
  Begin   
   Set @SiPl = 'S'  
     
   Select Distinct @Sexo  = Sexo  
   FROM   #Reporte Reporte LEFT OUTER JOIN  
                        tCaProducto ON Reporte.CodProducto = tCaProducto.CodProducto  
   WHERE     (Reporte.CodPrestamo = @CodPrestamo)  
      
   Insert Into tCsFirmaReporte ( DGarantia,  Firma,   Sujeto,   Sujeto2,  Fecha1,  Fecha2,   
       Saldo1,  Direccion,  DireccionAgencia,  Denominacion,  Denominacion1,  Denominacion2,    
       Dato7,   Dato9,   Dato10,   Dato11,  CodOficina)  
   Select Distinct   
   CASE   
    When tCaProducto.GarantiaDPF   = 1 And tCaProducto.GarantiaAval = 0 THEN 'Con Garantía Líquida'  
    When tCaProducto.GarantiaPrendaria  = 1 And tCaProducto.GarantiaAval = 0 THEN 'Con Garantía Prendaria'   
    When tCaProducto.GarantiaPrendaria  = 0 And tCaProducto.GarantiaAval = 1 THEN 'Con Aval'  
    When tCaProducto.GarantiaPrendaria  = 1 And tCaProducto.GarantiaAval = 1 THEN 'MALA CONFIGURACION DE PRODUCTO'   
    ELSE ''   
   END as DG,   
   @Firma, @Nombres, @Avales, FechaDesembolso, FechaAprobacion, MontoDesembolso, @MDireccion, @ODireccion,    
   Case Sexo  WHEN 0 THEN 'La Señora'   
     WHEN 1 THEN 'El Señor'   
     ELSE 'El(la) sr(a).'   
   End, 'El Acreditado', 'y/o Codeudores',  
   CASE Reporte.CalculoINTE   
    When 'SG' Then 'Monto'  
    When 'SI' Then 'Saldo Insoluto'  
    When 'AH' Then Reporte.Comisiones  
    Else 'CALCULO INTERES ERRONEO'  
   End, Fondo, Reporte.Estado, Reporte.CodGrupo, Reporte.CodOficina   
   FROM   #Reporte Reporte LEFT OUTER JOIN  
                        tCaProducto ON Reporte.CodProducto = tCaProducto.CodProducto  
   WHERE     (Reporte.CodPrestamo = @CodPrestamo)      
  End  
  Print 'Número de Acreditados : ' + Cast(@Acreditados As Varchar(100))   
  If @Acreditados > 1 -- CREDITOS SOLIDARIOS   
  Begin   
   Set @SiPl = 'P'  
   SELECT @Sexo = CASE WHEN COUNT(*) > 1 THEN COUNT(*) ELSE SUM(Sexo) END   
   FROM         (SELECT     CodPrestamo, CAST(Sexo AS Int) AS Sexo  
                          FROM    #Reporte tRptDocumentos  
     Where CodPrestamo = @CodPrestamo  
                          GROUP BY CodPrestamo, Sexo) Datos  
   GROUP BY CodPrestamo  
  
   Insert Into tCsFirmaReporte ( DGarantia,  Firma,   Sujeto,   Sujeto2,  Fecha1,  Fecha2,   
       Saldo1,  Direccion,  DireccionAgencia,  Denominacion,  Denominacion1,  Denominacion2,    
       Dato7,   Dato9,   Dato10,   Dato11,  CodOficina)  
   Select Distinct   
   CASE   
    When tCaProducto.GarantiaDPF   = 1 And tCaProducto.GarantiaAval = 0 THEN 'Con Garantía Líquida'  
    When tCaProducto.GarantiaPrendaria  = 1 And tCaProducto.GarantiaAval = 0 THEN 'Con Garantía Prendaria'   
    When tCaProducto.GarantiaPrendaria  = 0 And tCaProducto.GarantiaAval = 1 THEN 'Con Aval'  
    When tCaProducto.GarantiaPrendaria  = 1 And tCaProducto.GarantiaAval = 1 THEN 'MALA CONFIGURACION DE PRODUCTO'   
    ELSE ''   
   END as DG,  
   @Firma, @Nombres, @Avales, FechaDesembolso, FechaAprobacion, MontoDesembolso, @MDireccion, @ODireccion,   
   Case @Sexo  WHEN 0 THEN 'Las Señoras'   
     WHEN 1 THEN 'Los Señores'   
     ELSE 'Los Señores'   
   End,  
   'Los Acreditados',   
   'y/o Codeudores',  
   CASE Reporte.CalculoINTE   
    When 'SG' Then 'Monto'  
    When 'SI' Then 'Saldo Insoluto'  
    Else 'CALCULO INTERES ERRONEO'  
   End, Fondo, Reporte.Estado, Reporte.CodGrupo, Reporte.CodOficina     
   FROM   #Reporte Reporte LEFT OUTER JOIN  
                        tCaProducto ON Reporte.CodProducto = tCaProducto.CodProducto  
   WHERE     (Reporte.CodPrestamo = @CodPrestamo)     
  End  
  If @Acreditados = 0 -- CREDITOS NO IDENTIFICADOS  
  Begin   
   Set @SiPl = 'N'  
   Set @Sexo = 3  
   Insert Into tCsFirmaReporte ( DGarantia, Firma, Sujeto, Sujeto2, Fecha1, Saldo1, Direccion, DireccionAgencia, Denominacion,   
       Denominacion1, Denominacion2, Dato7)  
   Select Distinct   
   CASE   
    When tCaProducto.GarantiaDPF   = 1 And tCaProducto.GarantiaAval = 0 THEN 'Con Garantía Líquida'  
    When tCaProducto.GarantiaPrendaria  = 1 And tCaProducto.GarantiaAval = 0 THEN 'Con Garantía Prendaria'   
    When tCaProducto.GarantiaPrendaria  = 0 And tCaProducto.GarantiaAval = 1 THEN 'Con Aval'  
    When tCaProducto.GarantiaPrendaria  = 1 And tCaProducto.GarantiaAval = 1 THEN 'MALA CONFIGURACION DE PRODUCTO'   
    ELSE ''   
   END as DG,  
   @Firma, @Nombres, @Avales, FechaDesembolso, MontoDesembolso, @MDireccion, @ODireccion, 'No Identificado.', 'No Identificado.',   
   'No Identificado.',  
   CASE Reporte.CalculoINTE   
    When 'SG' Then 'Monto'  
    When 'SI' Then 'Saldo Insoluto'  
    Else 'CALCULO INTERES ERRONEO'  
   End     
   FROM   #Reporte Reporte LEFT OUTER JOIN  
                        tCaProducto ON Reporte.CodProducto = tCaProducto.CodProducto  
   WHERE     (Reporte.CodPrestamo = @CodPrestamo)       
  End    
  --ACTUALIZACIONES DE tCsFirmaReporte >>>>>>>>>>>>>>>>>>>>::::::<<<<<<<<<<<<<<<<<<<<<<<  
  Update tCsFirmaReporte  
   Set  DireccionAgencia  = Direccion  
   FROM    tCsFirmaReporte INNER JOIN  
                        tCsFirmaElectronica ON tCsFirmaReporte.Firma = tCsFirmaElectronica.Firma   
   WHERE  (tCsFirmaElectronica.Dato = @CodPrestamo) And tCsFirmaElectronica.Firma = @Firma   
    And Ltrim(rtrim(Isnull(DireccionAgencia, ''))) = ''  
  If @NoAvales = 0  
  Begin  
   Update tCsFirmaReporte  
   Set  Dato5  = '',  
    Dato6  = ''  
   FROM         tCsFirmaReporte INNER JOIN  
                       tCsFirmaElectronica ON tCsFirmaReporte.Firma = tCsFirmaElectronica.Firma   
   WHERE (tCsFirmaElectronica.Dato = @CodPrestamo) And tCsFirmaElectronica.Firma = @Firma  
  End  
  If @NoAvales = 1   
  Begin  
   Update tCsFirmaReporte  
   Set Dato5  = 'y como aval ' +  Case Sexo  
          WHEN 0 THEN  'a la señora'   
         WHEN 1 THEN  'al señor'  
         ELSE  'El(la) sr(a).'  
        End,  
   Dato6   = '"EL AVAL"'  
   FROM         tCsFirmaReporte INNER JOIN  
                       tCsFirmaElectronica ON tCsFirmaReporte.Firma = tCsFirmaElectronica.Firma INNER JOIN  
                       #Aval Aval ON tCsFirmaElectronica.Dato = Aval.CodPrestamo  
   WHERE (Aval.CodPrestamo = @CodPrestamo) And tCsFirmaElectronica.Firma = @Firma  
  End  
  If @NoAvales > 1  
  Begin  
   Update tCsFirmaReporte  
   Set Dato5  = 'y como avales a los señores',  
   Dato6   = '"LOS AVAL(ES)"'  
   FROM         tCsFirmaReporte INNER JOIN  
                       tCsFirmaElectronica ON tCsFirmaReporte.Firma = tCsFirmaElectronica.Firma INNER JOIN  
                       #Aval Aval ON tCsFirmaElectronica.Dato = Aval.CodPrestamo  
   WHERE (Aval.CodPrestamo = @CodPrestamo) And tCsFirmaElectronica.Firma = @Firma  
  End  
  UPDATE    tCsFirmaReporte  
  SET             Dato1 = Frecuencia,  
    Dato2 = Case    
         When ComParam = 'PA' Then dbo.fduNumeroTexto(ComValor, 2) + '%' --Funciona Para créditos  
           When ComParam = 'VA' Then '$' + dbo.fduNumeroTexto(ComValor, 2) --Funciona Para créditos  
           When ComParam = 'MA' Then '$' + dbo.fduNumeroTexto(ComValor, 2) --Funciona Para Ahorros  
       End,  
    Dato3 = Case When Isnull(Tecnologia, '') = '2' Then '2' Else '' End,     
    Dato4 = CodProducto,  
    Saldo2  = ValorConcepto,  
    Saldo3 = MorValor,  
    Saldo4  = Plazo,  
    Saldo5 = CodTipoPlan,  
    Saldo6  = IMoValor      
  FROM         (SELECT DISTINCT  Reporte.ValorConcepto, Reporte.Plazo, Reporte.Frecuencia, Reporte.CodTipoPlan, @Firma AS Firma,  
      Reporte.MorValor, Reporte.IMoValor, Reporte.ComParam, Reporte.ComValor, tCaProducto.Tecnologia, Reporte.CodProducto  
                         FROM    #Reporte Reporte LEFT OUTER JOIN tCaProducto ON Reporte.CodProducto = tCaProducto.CodProducto  
                         WHERE      (Reporte.CodPrestamo = @CodPrestamo) AND (Reporte.CodConcepto = 'INTE')) Datos INNER JOIN  
                        tCsFirmaReporte ON Datos.Firma COLLATE Modern_Spanish_CI_AI = tCsFirmaReporte.Firma  
  
  UPDATE  tCsFirmaReporte  
  SET   Dato8 = '',  
     RECA = tCaProducto.RECA  
  FROM  tCsFirmaReporte INNER JOIN  
     tCaProducto ON tCsFirmaReporte.Dato4 = tCaProducto.CodProducto  
  WHERE  GarantiaDPF = 1 And tCsFirmaReporte.Firma = @Firma  
  
  UPDATE  tCsFirmaReporte  
  SET   Dato8 = 'NOGL',  
     RECA = tCaProducto.RECA  
  FROM  tCsFirmaReporte INNER JOIN  
     tCaProducto ON tCsFirmaReporte.Dato4 = tCaProducto.CodProducto  
  WHERE  GarantiaDPF = 0 And tCsFirmaReporte.Firma = @Firma  
  -------------------------------------------  
  --03 TRABAJANDO CON: tCsFirmaReporteDetalle  
  -------------------------------------------  
  Print 'A: PARA LOS ACREDITADOS : ' + @CodPrestamo  
  Insert Into tCsFirmaReporteDetalle ( Firma,   Identificador,  Grupo,   Sujeto,  EstadoCivil,  Actividad,    
       Ocupacion,  Direccion, Identificacion, Saldo1,  Nacionalidad,  Fecha2,  
       Dec1,  Dec2,  Dec3,  Texto, Telefono)  
  SELECT DISTINCT   
                        @Firma AS Firma, Corte.CodUsuario AS Identificador, 'A' AS Grupo, Datos.NombreCompleto AS Sujeto, Datos.EstadoCivil, Datos.LabActividad, Datos.UsOcupacion,   
                        Datos.Direccion + 'Col. ' + tCPLugar.Lugar + ', ' + SUBSTRING(tCPClMunicipio.DelMun, 1, 3)   
                        + '. ' + tCPClMunicipio.Municipio + ', Edo. ' + tCPClEstado.Estado + ' C.P. ' + Datos.CodPostal AS Direccion, Datos.Identificacion, Datos.Coordinador,   
                        tClPaises.Nacionalidad, Datos.FechaNacimiento, Datos.Peso, Datos.Estatura, Datos.Sexo, Datos.Salud, Datos.Telefono  
  FROM         (SELECT     CodUsuario, MAX(Direccion1) AS Direccion  
                         FROM          (SELECT DISTINCT   
                                                 CodUsuario, NombreCompleto,   
                                          CASE Sexo WHEN 0 THEN tUsClEstadoCivil.Femenino WHEN 1 THEN Masculino ELSE 'No identificado' END AS EstadoCivil, LabActividad,   
                                                          UsOcupacion, RTRIM(LTRIM(Direccion)) + ' ' + RTRIM(LTRIM(isnull(NumExterno, ''))) + ' ' + LTRIM(RTRIM(isnull(NumInterno, ''))) AS Direccion,   
                                                          RTRIM(LTRIM(Direccion)) + ' ' + RTRIM(LTRIM(isnull(NumExterno, ''))) + ' ' + LTRIM(RTRIM(isnull(NumInterno, '')))   
                                                          + CodUbigeo + CodPostal AS Direccion1, CodUbiGeo, RTRIM(LTRIM(CodDocIden)) + ' ' + RTRIM(LTRIM(DI)) AS Identificacion  
                                               FROM      #Reporte Reporte LEFT OUTER JOIN  
                                                          tUsClEstadoCivil ON Reporte.CodEstadoCivil = tUsClEstadoCivil.CodEstadoCivil) Datos  
                         GROUP BY CodUsuario) Corte INNER JOIN  
                            (SELECT DISTINCT   
                                                  CodUsuario, NombreCompleto,   
                                                  CASE Sexo  WHEN 0 THEN tUsClEstadoCivil.Femenino   
          WHEN 1 THEN Masculino   
          ELSE 'No identificado'   
        END AS EstadoCivil,   
        LabActividad, UsOcupacion,   
                                                  RTRIM(LTRIM(Direccion)) + ' ' + RTRIM(LTRIM(Isnull(NumExterno, ''))) + ' ' + LTRIM(RTRIM(Isnull(NumInterno, ''))) AS Direccion,   
        RTRIM(LTRIM(Direccion)) + ' ' + RTRIM(LTRIM(Isnull(NumExterno, ''))) + ' ' + LTRIM(RTRIM(Isnull(NumInterno, ''))) + CodUbigeo + CodPostal AS Direccion1,   
        CodUbiGeo, RTRIM(LTRIM(CodDocIden)) + ' ' + RTRIM(LTRIM(DI)) AS Identificacion,   
        CodPostal, CodPrestamo, Coordinador, CodPais, FechaNacimiento, Peso, Estatura, Sexo, Salud, Telefono  
                              FROM           #Reporte Reporte LEFT OUTER JOIN  
                                                     tUsClEstadoCivil ON Reporte.CodEstadoCivil = tUsClEstadoCivil.CodEstadoCivil) Datos ON Corte.CodUsuario = Datos.CodUsuario AND   
                        Corte.Direccion = Datos.Direccion1 INNER JOIN  
                        tClUbigeo ON Datos.CodUbiGeo COLLATE Modern_Spanish_CI_AI = tClUbigeo.CodUbiGeo LEFT OUTER JOIN  
                        tClPaises ON Datos.CodPais COLLATE Modern_Spanish_CI_AI = tClPaises.CodPais LEFT OUTER JOIN  
                        tCPClEstado INNER JOIN  
                        tCPClMunicipio ON tCPClEstado.CodEstado = tCPClMunicipio.CodEstado INNER JOIN  
                        tCPLugar ON tCPClMunicipio.CodMunicipio = tCPLugar.CodMunicipio AND tCPClMunicipio.CodEstado = tCPLugar.CodEstado ON   
                        tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodEstado = tCPLugar.CodEstado AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio  
  WHERE     (Datos.CodPrestamo = @CodPrestamo)  
    
  UPDATE    tCsFirmaReporteDetalle  
  SET              Saldo2 = Cuota  
  FROM         (SELECT     CodPrestamo, CodUsuario, CodConcepto, SUM(MontoCuota) AS Cuota  
                         FROM          (SELECT DISTINCT CodPrestamo, SecCuota, CodUsuario, CodConcepto, MontoCuota  
                                                 FROM        #Reporte  Reporte) Datos  
                         WHERE      (CodConcepto = 'CAPI') AND (CodPrestamo = @CodPrestamo)  
                         GROUP BY CodPrestamo, CodUsuario, CodConcepto) Datos INNER JOIN  
                        tCsFirmaElectronica ON Datos.CodPrestamo = tCsFirmaElectronica.Dato AND tCsFirmaElectronica.Activo = 1 AND tCsFirmaElectronica.Usuario = @Usuario INNER JOIN  
                        tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma AND   
                        Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsFirmaReporteDetalle.Identificador  
  WHERE     (tCsFirmaReporteDetalle.Grupo = 'A')  
  
  UPDATE    tCsFirmaReporteDetalle  
  SET              Saldo3 = Cuota  
  FROM         (SELECT     CodPrestamo, CodUsuario, CodConcepto, SUM(MontoCuota) AS Cuota  
                         FROM          (SELECT DISTINCT CodPrestamo, SecCuota, CodUsuario, CodConcepto, MontoCuota  
                                                 FROM      #Reporte    Reporte) Datos  
                         WHERE      (CodConcepto = 'INTE') AND (CodPrestamo = @CodPrestamo)  
                         GROUP BY CodPrestamo, CodUsuario, CodConcepto) Datos INNER JOIN  
                        tCsFirmaElectronica ON Datos.CodPrestamo = tCsFirmaElectronica.Dato AND tCsFirmaElectronica.Activo = 1 AND tCsFirmaElectronica.Usuario = @Usuario INNER JOIN  
                        tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma AND   
                        Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsFirmaReporteDetalle.Identificador  
  WHERE     (tCsFirmaReporteDetalle.Grupo = 'A')  
  
  UPDATE    tCsFirmaReporteDetalle  
  SET              Saldo4 = Cuota  
  FROM         (SELECT     CodPrestamo, CodUsuario, CodConcepto, SUM(MontoCuota) AS Cuota  
                         FROM          (SELECT DISTINCT CodPrestamo, SecCuota, CodUsuario, CodConcepto, MontoCuota  
                                                 FROM     #Reporte   Reporte) Datos  
                         WHERE      (CodConcepto = 'IVAIT') AND (CodPrestamo = @CodPrestamo)  
                         GROUP BY CodPrestamo, CodUsuario, CodConcepto) Datos INNER JOIN  
                        tCsFirmaElectronica ON Datos.CodPrestamo = tCsFirmaElectronica.Dato AND tCsFirmaElectronica.Activo = 1 AND tCsFirmaElectronica.Usuario = @Usuario INNER JOIN  
                        tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma AND   
                        Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsFirmaReporteDetalle.Identificador  
  WHERE     (tCsFirmaReporteDetalle.Grupo = 'A')  
  
  UPDATE    tCsFirmaReporteDetalle  
  SET              Saldo5 = Cuota  
  FROM         (SELECT     CodPrestamo, CodUsuario, AVG(Cuota) AS Cuota  
    FROM         (SELECT     CodPrestamo, SecCuota, CodUsuario, SUM(MontoCuota) AS Cuota  
                           FROM          ( SELECT DISTINCT CodPrestamo, SecCuota, CodUsuario, CodConcepto, MontoCuota  
                                                   FROM    #Reporte  Reporte  
         WHERE (CodPrestamo = @CodPrestamo)) Datos  
                           GROUP BY CodPrestamo, SecCuota, CodUsuario) Datos  
    GROUP BY CodPrestamo, CodUsuario) Datos INNER JOIN  
                        tCsFirmaElectronica ON Datos.CodPrestamo = tCsFirmaElectronica.Dato AND tCsFirmaElectronica.Activo = 1 AND tCsFirmaElectronica.Usuario = @Usuario INNER JOIN  
                        tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma AND   
                        Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsFirmaReporteDetalle.Identificador  
  WHERE     (tCsFirmaReporteDetalle.Grupo = 'A')  
    
  Print 'B: PARA EL PLAN DE PAGOS GENERAL : ' + @CodPrestamo  
  Insert Into tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Fecha1, Saldo1, Saldo2, Saldo3, Saldo4)  
  SELECT     @Firma AS Firma, SecCuota AS Identificador, 'B' AS Grupo, FechaVencimiento, SUM(CUOTA) AS Saldo, SUM(CAPI) AS Capital, SUM(INTE) AS Interes, SUM(IVAIT)   
                        AS Iva  
  FROM         (SELECT DISTINCT CodPrestamo, CodUsuario, SecCuota, FechaVencimiento, MontoCuota, CodConcepto,   
                          CUOTA  = CASE WHEN CodConcepto In ('CAPI', 'INTE', 'IVAIT')  THEN MontoCuota ELSE 0 END,   
                          CAPI  = CASE CodConcepto WHEN 'CAPI'     THEN MontoCuota ELSE 0 END,   
     INTE = CASE CodConcepto WHEN 'INTE'     THEN MontoCuota ELSE 0 END,   
                          IVAIT  = CASE CodConcepto WHEN 'IVAIT'    THEN MontoCuota ELSE 0 END  
                  FROM   #Reporte Reporte  
    WHERE  (CodPrestamo = @CodPrestamo)) Datos  
  GROUP BY SecCuota, FechaVencimiento   
  
  Print 'C: PARA LOS CODEUDORES : ' + @CodPrestamo  
  Insert Into tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Sujeto, Direccion)  
  SELECT DISTINCT Firma = @Firma, Reporte.Codeudor AS Identificador, 'C' AS Grupo, Reporte.Codeudor AS Sujeto,   
                        Reporte.cdDireccion + ' ' + RTRIM(LTRIM(Reporte.cdNumExterno)) + ' ' + RTRIM(LTRIM(Reporte.cdNumInterno)) + ' Col. ' + tCPLugar.Lugar + ', ' + SUBSTRING(tCPClMunicipio.DelMun, 1, 3)   
                        + '. ' + tCPClMunicipio.Municipio + ', Edo. ' + tCPClEstado.Estado + ' C.P. ' + Reporte.CodPostal AS Direccion  
  FROM         tCPLugar INNER JOIN  
                      tClUbigeo ON tCPLugar.IdLugar = tClUbigeo.IdLugar AND tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio AND   
                      tCPLugar.CodEstado = tClUbigeo.CodEstado INNER JOIN  
                      tCPClMunicipio ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN  
                      tCPClEstado ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado RIGHT OUTER JOIN  
                      #Reporte Reporte ON tClUbigeo.CodUbiGeo = Reporte.cdCodUbiGeo  
  WHERE     (Reporte.CodPrestamo = @CodPrestamo) AND (RTRIM(LTRIM(ISNULL(Reporte.Codeudor, ''))) <> '')  
    
  Print 'D: PARA LAS GARANTIAS : ' + @CodPrestamo  
  Insert Into  tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Direccion, Identificacion)  
  SELECT     @Firma AS Firma, O, NoRegAval, Descripcion, Identificacion  
  FROM             (SELECT DISTINCT 1 AS O, Garantia.NoRegAval, Garantia.Descripcion, 'D' AS Identificacion, CodPrestamo  
                         FROM       #Garantia  Garantia INNER JOIN  
                                                #Reporte   Reporte ON Garantia.Codigo = Reporte.CodPrestamo  
                         UNION  
                         SELECT DISTINCT 2 AS O, Garantia.NoRegAval, Garantia.Primero, 'D' AS Identificacion, CodPrestamo  
                         FROM       #Garantia  Garantia INNER JOIN  
                                               #Reporte   Reporte ON Garantia.Codigo = Reporte.CodPrestamo  
                         UNION  
                         SELECT DISTINCT 3 AS O, Garantia.NoRegAval, Garantia.Segundo, 'D' AS Identificacion, CodPrestamo  
                         FROM       #Garantia  Garantia INNER JOIN  
                                               #Reporte   Reporte ON Garantia.Codigo = Reporte.CodPrestamo  
                         UNION  
                         SELECT DISTINCT 4 AS O, Garantia.NoRegAval, Garantia.Tercero, 'D' AS Identificacion, CodPrestamo  
                         FROM       #Garantia  Garantia INNER JOIN  
                                               #Reporte   Reporte ON Garantia.Codigo = Reporte.CodPrestamo  
                         UNION  
                         SELECT DISTINCT 5 AS O, Garantia.NoRegAval, Garantia.Cuarto, 'D' AS Identificacion, CodPrestamo  
                         FROM       #Garantia  Garantia INNER JOIN  
                                               #Reporte   Reporte ON Garantia.Codigo = Reporte.CodPrestamo  
                         UNION  
                         SELECT DISTINCT 6 AS O, Garantia.NoRegAval, Garantia.Quinto, 'D' AS Identificacion, CodPrestamo  
                         FROM      #Garantia  Garantia INNER JOIN  
                                              #Reporte   Reporte ON Garantia.Codigo = Reporte.CodPrestamo  
                         UNION  
                         SELECT DISTINCT 7 AS O, Garantia.NoRegAval, Garantia.Valor, 'D' AS Identificacion, CodPrestamo  
                         FROM      #Garantia  Garantia INNER JOIN  
                                               #Reporte   Reporte ON Garantia.Codigo = Reporte.CodPrestamo  
                         UNION  
                         SELECT DISTINCT 8 AS O, Garantia.NoRegAval, Garantia.Ubicacion, 'D' AS Identificacion, CodPrestamo  
                         FROM      #Garantia  Garantia INNER JOIN  
                                               #Reporte   Reporte ON Garantia.Codigo = Reporte.CodPrestamo) Datos  
  WHERE     (LTRIM(RTRIM(ISNULL(Descripcion, ''))) <> '') And CodPrestamo = @CodPrestamo  
  ORDER BY NoRegAval, O  
  
  Print 'E: PARA LOS AVALES : ' + @CodPrestamo  
  Insert Into tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Sujeto, Texto, Direccion)  
  SELECT DISTINCT @Firma AS Firma, NombreCompleto AS Identificador, 'E' AS Grupo, NombreCompleto AS Sujeto, REPLACE(Aval.NombreCompleto + ' es una ' + LOWER(tUsClTipoPersona.DescTPersona)   
                        + ' con capacidad legal para contratar y obligarse, de nacionalidad ' + LOWER(tClPaises.Nacionalidad)   
                        + ' identificado con ' + Aval.CodDocIden + '-' + Aval.DI + ', ' + CASE Sexo WHEN 1 THEN tUsClEstadoCivil.Masculino WHEN 0 THEN tUsClEstadoCivil.Femenino ELSE 'Sin Sexo'  
                         END + ', con domicilio en ' + Aval.Direccion + ' ' + RTRIM(LTRIM(Aval.NumExterno)) + ' ' + RTRIM(LTRIM(Aval.NumInterno))   
                        + ', ' + ISNULL('Col. ' + tCPLugar.Lugar + ', ' + SUBSTRING(tCPClMunicipio.DelMun, 1, 3)   
                        + '. ' + tCPClMunicipio.Municipio + ', Edo. ' + tCPClEstado.Estado + ' C.P. ' + Aval.CodPostal, 'LLAMAR A SISTEMAS: FALTA DIRECCION') + ', dedicado a la actividad de ' + ISNULL(Aval.LabActividad, '')   
                        + '\' + ISNULL(Aval.UsOcupacion, '') + '.', '  ', '') AS Dato,   
    ISNULL(Ltrim(Rtrim(Aval.Direccion + ' ' + RTRIM(LTRIM(Aval.NumExterno)) + ' ' + RTRIM(LTRIM(Aval.NumInterno)))) + ' Col. ' + tCPLugar.Lugar + ', ' + SUBSTRING(tCPClMunicipio.DelMun, 1, 3)   
                        + '. ' + tCPClMunicipio.Municipio + ', Edo. ' + tCPClEstado.Estado + ' C.P. ' + Aval.CodPostal, 'LLAMAR A SISTEMAS: FALTA DIRECCION') AS Direccion  
  FROM         tCPClMunicipio INNER JOIN  
                        tCPClEstado ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN  
                        tCPLugar ON tCPClMunicipio.CodMunicipio = tCPLugar.CodMunicipio AND tCPClMunicipio.CodEstado = tCPLugar.CodEstado INNER JOIN  
                        tClUbigeo ON tCPLugar.IdLugar = tClUbigeo.IdLugar AND tCPLugar.CodMunicipio = tClUbigeo.CodMunicipio AND   
                        tCPLugar.CodEstado = tClUbigeo.CodEstado RIGHT OUTER JOIN  
                        #Aval Aval INNER JOIN  
                        tUsClTipoPersona ON Aval.CodTPersona = tUsClTipoPersona.CodTPersona INNER JOIN  
                        tClPaises ON Aval.CodPais = tClPaises.CodPais INNER JOIN  
                        tUsClEstadoCivil ON Aval.CodEstadoCivil = tUsClEstadoCivil.CodEstadoCivil ON tClUbigeo.CodUbiGeo = Aval.CodUbiGeo  
  WHERE     (CodPrestamo = @CodPrestamo) AND (RTRIM(LTRIM(ISNULL(NombreCompleto, ''))) <> '') AND Aval.Sistema = 'AV'  
  
  Print 'F: PARA LAS GARANTIAS LIQUIDAS : ' + @CodPrestamo    
  Insert Into tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Saldo1)  
  SELECT     tCsFirmaReporteDetalle.Firma, Aval.CodCuenta AS Identificador, 'F' AS Grupo, Aval.MoAFavor AS Saldo1  
  FROM         tCsFirmaReporteDetalle INNER JOIN  
                        tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma INNER JOIN  
                        #Aval Aval ON tCsFirmaElectronica.Dato = Aval.CodPrestamo AND tCsFirmaReporteDetalle.Sujeto = Aval.NombreCompleto  
  WHERE     (Aval.Sistema = 'AH') AND (tCsFirmaReporteDetalle.Grupo = 'A') AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = @Usuario) AND   
                        (Aval.CodPrestamo = @CodPrestamo)  
  
  Print 'G: PARA SALDOS DEL CREDITO Y RESPONSABLES: ' + @CodPrestamo -- Se Registra tantas veces como responsables hay en la agencia.  
  Insert Into tCsFirmaReporteDetalle ( Firma,   Identificador, Grupo, Sujeto, Direccion, Fecha1, Saldo1, Texto, Identificacion,   
       Nacionalidad,  EstadoCivil)  
  SELECT     *  
  FROM         (SELECT DISTINCT  -- SALDO VENCIDO Y GERENTE DE AGENCIA  
                                               @Firma AS Firma, 1 AS Identificador, 'G' AS Grupo, tRptDocumentos.CodPrestamo AS Sujeto, CResponsable AS Direccion, GETDATE() AS Fecha1,   
                                               tRptDocumentos.SaldoAtrasado, tClOficinas.DescOficina AS Texto, Identificacion = Telmex, Nacionalidad = Grupo,  
            tRptDocumentos.CodOficina  
                         FROM      #Reporte    tRptDocumentos INNER JOIN  
                                               tClOficinas ON tRptDocumentos.CodOficina = tClOficinas.CodOficina  
                         WHERE      (tRptDocumentos.CodPrestamo = @CodPrestamo)  
                         UNION  
                         SELECT DISTINCT  -- OTROS SALDOS DE LA CUOTA VENCIDA Y ASESOR DE CREDITO  
                                              @Firma AS Firma, 2 AS Identificador, 'G' AS Grupo, tRptDocumentos.CodPrestamo AS Sujeto, CAsesor AS Direccion, GETDATE() AS Fecha1, tRptDocumentos.SaldoOtros,   
                                              tClOficinas.DescOficina AS Texto,  Identificacion = Telmex, Nacionalidad = Grupo, tRptDocumentos.CodOficina  
                         FROM      #Reporte   tRptDocumentos INNER JOIN  
                                              tClOficinas ON tRptDocumentos.CodOficina = tClOficinas.CodOficina  
                         WHERE     (tRptDocumentos.CodPrestamo = @CodPrestamo)  
    UNION  
                         SELECT   -- SALDOS TOTAL DE LA DEUDA Y COORDINADOR DE OPERACIONES  
         @Firma AS Firma, 3 AS Identificador, 'G' AS Grupo, tRptDocumentos.CodPrestamo AS Sujeto, CCoordinador AS Direccion, GETDATE() AS Fecha1, Sum(tRptDocumentos.MontoCuota - tRptDocumentos.MontoPago) as Saldo,   
                                              tClOficinas.DescOficina AS Texto,  Identificacion = Telmex, Nacionalidad = Grupo, tRptDocumentos.CodOficina  
                         FROM      #Reporte   tRptDocumentos INNER JOIN  
                                              tClOficinas ON tRptDocumentos.CodOficina = tClOficinas.CodOficina  
                         WHERE     (tRptDocumentos.CodPrestamo = @CodPrestamo)   
    GROUP BY  tRptDocumentos.CodPrestamo, CCoordinador, tClOficinas.DescOficina,Telmex, Grupo, tRptDocumentos.CodOficina  
  ) Datos  
  
  Print 'H: PARA EL PLAN DE PAGOS POR CLIENTE: ' + @CodPrestamo  
  Insert Into  tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Sujeto, Fecha1, Saldo1, Saldo2, Saldo3, Saldo4, Dec1, Direccion, Texto)  
  SELECT      @Firma AS Firma, LTRIM(RTRIM(CodUsuario)) + CAST(SecCuota AS varchar(5)) AS Identificador, 'H' AS Grupo, CodUsuario AS Sujeto, FechaVencimiento,   
    SUM(CUOTA) AS Saldo, SUM(CAPI) AS Capital, SUM(INTE) AS Interes, SUM(IVAIT) AS Iva, SecCuota, NombreCompleto, Acta  
  FROM          (SELECT DISTINCT CodPrestamo, CodUsuario, SecCuota, FechaVencimiento, MontoCuota, CodConcepto,   
     CUOTA  = CASE WHEN CodConcepto In ('CAPI', 'INTE', 'IVAIT')  THEN MontoCuota ELSE 0 END,   
                          CAPI  = CASE CodConcepto WHEN 'CAPI'     THEN MontoCuota ELSE 0 END,   
     INTE = CASE CodConcepto WHEN 'INTE'     THEN MontoCuota ELSE 0 END,   
                          IVAIT  = CASE CodConcepto WHEN 'IVAIT'    THEN MontoCuota ELSE 0 END,   
     NombreCompleto,   
     Acta = dbo.fduRellena('0', CodOficina, 3, 'D') + '-' + Acta  
                         FROM   #Reporte Reporte  
     WHERE  (CodPrestamo = @CodPrestamo)) Datos  
  GROUP BY SecCuota, FechaVencimiento, CodUsuario, NombreCompleto, Acta  
    
  Print 'I: PARA CONYUGES: ' + @CodPrestamo  
  Insert Into  tCsFirmaReporteDetalle (Firma, Identificador, Grupo, Sujeto, Identificacion)  
  SELECT    DISTINCT  @Firma AS Firma, CodConyuge AS Identificador, 'I' AS Grupo, Conyuge AS Sujeto, CodUsuario AS Identificacion  
  FROM           #Reporte Reporte  
  WHERE        (CodPrestamo = @CodPrestamo) And CodConyuge Is not Null  
    
  --SECCION DE DEFINICION DE ETIQUETAS   
  Truncate Table #Etiqueta  
  Declare curReporte Cursor For   
   SELECT DISTINCT Variable, Nrovariable  
   FROM tCsRPTCaProducto  
   Order by NroVariable      
  Open curReporte  
  Fetch Next From curReporte Into @TempVC, @TempVC5  
  While @@Fetch_Status = 0  
  Begin   
   --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, Cast(@TempVC5 as varchar(4)) + ' ' +  @TempVC, Getdate(), 'Verificando')   
   PRINT '<><><><><><><><><>'  
   Print Getdate()  
   Print Cast(@TempVC5 as varchar(4)) + ' ' +  @TempVC  
   PRINT '<><><><><><><><><>'  
   Set @TempVC4   = ''  
   Set @SecuenciaN  = 0  
   Set @SecuenciaL  = 0  
   Set @LetraNumero = 'S'  
   Set @Mayuscula  = 0  
   Declare curReporte1 Cursor For   
    SELECT     Condicion, Verdad = Isnull(RVerdad, '') + Isnull(RVerdad1, ''), Falso = Isnull(RFalso, '')  
    FROM         tCsRPTCaProducto  
    WHERE     (Variable = @TempVC)  
    Order by Fila  
   Open curReporte1  
   Fetch Next From curReporte1 Into @TempVC1, @TempVC2, @TempVC3  
   While @@Fetch_Status = 0  
   Begin         
    Set @Cadena = 'Insert Into #Etiqueta (Fila, Etiqueta) SELECT COUNT(*) As Fila, ''' + @TempVC + ''' As Etiqueta '  
    Set @Cadena = @Cadena + 'FROM tCaProducto INNER JOIN '  
    Set @Cadena = @Cadena + 'tCsFirmaReporte ON tCaProducto.CodProducto = tCsFirmaReporte.Dato4 '  
    Set @Cadena = @Cadena + 'WHERE (tCsFirmaReporte.Firma = '''+ @Firma +''') AND (' + @TempVC1 + ')'  
      
    Print @Cadena  
    Exec(@Cadena)  
  
    Select @Contador = Fila From #Etiqueta Where Etiqueta = @TempVC  
    Delete From #Etiqueta Where Etiqueta = @TempVC  
  
    If @Contador = 0   
    Begin   
     Set @TempVC6  = @TempVC3       
    End      
    If @Contador = 1  
    Begin  
     Set @TempVC6  = @TempVC2  
    End  
    If @Contador Not in (0, 1)  
    Begin  
     Set @TempVC6  = 'Mala Especificación'       
    End  
    Set @TempVC6 = Replace(@TempVC6, '[[n]]', '[[N]]')  
    If  CharIndex('[[a]]', @TempVC6, 1) <> 0 Or  
     CharIndex('[[A]]', @TempVC6, 1) <> 0 Or  
     CharIndex('[[N]]', @TempVC6, 1) <> 0  
    Begin  
     Set @Comodin  = SubString(@TempVC6, CharIndex('[[', @TempVC6, 1), 5)  
     Set @LetraNumero  = Case Upper(SubString(@Comodin, 3, 1))  
         When 'A' Then 'L'  
         When 'N' Then 'N'  
         Else 'S'  
          End  
     Set @Mayuscula   = Case When @LetraNumero = 'L' And Ascii(SubString(@Comodin, 3, 1)) = 65 Then 1 Else 0 End  
     If @LetraNumero = 'L'  
     Begin  
      Set @SecuenciaL = @SecuenciaL + 1  
      Set @TempVC8  = 'abcdefghijklmnñopqrstuvwxyz'  
      If  @Mayuscula = 1 Begin Set @TempVC8 = Upper(@TempVC8) End  
      Set @TempVC6 = Replace(@TempVC6, @Comodin, SubString(@TempVC8, @SecuenciaL, 1))     
     End  
     If @LetraNumero = 'N'  
     Begin  
      Set @SecuenciaN = @SecuenciaN + 1    
      Set @TempVC6  = Replace(@TempVC6, @Comodin, dbo.fduNumeroTexto(@SecuenciaN, 0))  
     End            
    End  
    If Ltrim(Rtrim(@TempVC6)) <> ''  
    Begin  
     If CharIndex('GARANTIAAVAL=1', Upper(Replace(@TempVC1, ' ', '')), 1) <> 0  
     Begin Exec pCsSingularPlural @SiPlAval, @TempVC6, @TempVC6 Out End  
     If CharIndex('GARANTIADPF=1', Upper(Replace(@TempVC1, ' ', '')), 1) <> 0  
     Begin Exec pCsSingularPlural @SiPlGL, @TempVC6, @TempVC6 Out End  
     If CharIndex('DOCCUSTODIA=1', Upper(Replace(@TempVC1, ' ', '')), 1) <> 0  
     Begin Exec pCsSingularPlural @SiPlGarantia, @TempVC6, @TempVC6 Out End  
     Set @TempVC4  = @TempVC4 + @TempVC6 + Char(10)  
    End      
    --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, @TempVC + ' ' + @TempVC1 + @TempVC2 + @TempVC3, Getdate(), 'Verificando')   
   Fetch Next From curReporte1 Into @TempVC1, @TempVC2, @TempVC3  
   End   
   Close   curReporte1  
   Deallocate  curReporte1     
   Set @Cadena  = 'Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values ('+ @TempVC5 +',  ''' + @TempVC + ''', ''' + @TempVC4 + ''')'  
   Exec(@Cadena)          
  Fetch Next From curReporte Into @TempVC, @TempVC5  
  End   
  Close   curReporte  
  Deallocate  curReporte   
    
  --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, 'I: Paso 01' , Getdate(), 'Bloque Asignación')   
    
  -----------------  
  If @Sexo = 0 And @SiPl = 'S'  Begin Set @SRA = 'a la señora'   End  
  If @Sexo = 0 And @SiPl = 'P'  Begin Set @SRA = 'a las señoras'   End  
  If @Sexo = 1 And @SiPl = 'S'  Begin Set @SRA = 'al señor'    End  
  If @Sexo = 1 And @SiPl = 'P'  Begin Set @SRA = 'a los señores'   End    
  If @Sexo = 2    Begin Set @SRA = 'a los señores'   End  
  If @Sexo = 3    Begin Set @SRA = 'NO IDENTIFICADO'  End    
    
  --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, 'F: Paso 01' , Getdate(), 'Bloque Asignación')  
  --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, 'I: Paso 02' , Getdate(), 'Bloque Asignación')  
    
  SELECT   @AUX = '$' + dbo.fduNumeroTexto(ROUND(AVG(Saldo1), 2), 2) + ' (' + dbo.fduNumeroALetras(ROUND(AVG(Saldo1), 2), 6)   
         + '), incluido el Impuesto al Valor Agregado, en cada una a partir de ' + CASE WHEN day(MIN(fecha1)) = 1 THEN 'el primer día del mes de ' WHEN day(MIN(fecha1))   
         > 1 THEN 'los ' + CAST(day(MIN(fecha1)) AS varchar(5)) + ' días del mes de ' END + dbo.fduNombreMes(MONTH(MIN(Fecha1)))   
         + ' de ' + dbo.fduFechaATexto(MIN(Fecha1), 'AAAA')   
  FROM         tCsFirmaReporteDetalle  
  WHERE     (Grupo = 'B') AND (Identificador = '1') AND (Firma = @Firma)  
  GROUP BY Firma, Grupo  
  
  Select @TipoPlanD  = 'pago' + Case  When tCsFirmaReporte.Saldo4 = 1 Then Lower(tCaClModalidadPlazo.Descripcion) + ' ' + tCaClTipoPlan.ContratoS   
        When tCsFirmaReporte.Saldo4 > 1 Then 's ' + Lower(tCaClModalidadPlazo.Descripcion) + 'es ' + tCaClTipoPlan.ContratoP   
        Else 'No Identificado' End  
  FROM         tCsFirmaReporte LEFT OUTER JOIN  
                      tCaClTipoPlan ON tCsFirmaReporte.Saldo5 = tCaClTipoPlan.CodTipoPlan LEFT OUTER JOIN  
                      tCaClModalidadPlazo ON tCsFirmaReporte.Dato1 = tCaClModalidadPlazo.ModalidadPlazo  
  WHERE  tCsFirmaReporte.Firma = @Firma  
    
  SELECT  --/*  
    @CATNum   = Case @Sistema   
           When 'CA' Then (dbo.fduNumeroTexto(dbo.fduCATPrestamo  
              (3, tCsFirmaReporte.Saldo1, tCsFirmaReporte.Saldo4/tCaClModalidadPlazo.FactorMensual, tCsFirmaReporte.Saldo2/12,   
               Case Right(IsNull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00%'), 1)   
                When '%' Then Cast(Left(Isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)),'0.00%'), Len(isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)),'0.00%')) - 1) as Decimal(10,4))/100.0000 * tCsFirmaReporte.Saldo1  
                Else Cast(Isnull(Ltrim(rtrim(tCsFirmaReporte.Dato2)), '0.00') as Decimal(10,4))   
               End)  
             , 1))  
         Else '0'  
         End,              
    --*/  
    @MontoLet   = dbo.fduNumeroALetras(tCsFirmaReporte.Saldo1, 6),   
    @DenoSujeto  = Upper(tCsFirmaReporte.Denominacion1),   
    @MontoNum   = dbo.fduNumeroTexto(tCsFirmaReporte.Saldo1, 2),  
    @TasaMensual = dbo.fduNumeroTexto(tCsFirmaReporte.Saldo2/12, 2),   
    @TasaLet  = Substring(dbo.fduNumeroALetras(Substring(dbo.fduNumeroTexto(tCsFirmaReporte.Saldo2/12, 2), 1,   
         CharIndex('.', dbo.fduNumeroTexto(tCsFirmaReporte.Saldo2/12, 2), 1) - 1), 6), 1, Len(dbo.fduNumeroALetras(Substring(dbo.fduNumeroTexto(tCsFirmaReporte.Saldo2/12, 2), 1,   
         CharIndex('.', dbo.fduNumeroTexto(tCsFirmaReporte.Saldo2/12, 2), 1) - 1), 6)) -  18) + ' PUNTO ' +  
         Substring(dbo.fduNumeroALetras(Substring(dbo.fduNumeroTexto(tCsFirmaReporte.Saldo2/12, 2),    
         CharIndex('.', dbo.fduNumeroTexto(tCsFirmaReporte.Saldo2/12, 2), 1) + 1, 2), 6), 1, Len(dbo.fduNumeroALetras(Substring(dbo.fduNumeroTexto(tCsFirmaReporte.Saldo2/12, 2),    
         CharIndex('.', dbo.fduNumeroTexto(tCsFirmaReporte.Saldo2/12, 2), 1) + 1, 2), 6)) -  18) + ' POR CIENTO MENSUAL',  
    @MoratorioNum = dbo.fduNumeroTexto(tCsFirmaReporte.Saldo6/12, 2),   
    @MoratorioLet = Substring(dbo.fduNumeroALetras(Substring(dbo.fduNumeroTexto(tCsFirmaReporte.Saldo6/12, 2), 1,   
         CharIndex('.', dbo.fduNumeroTexto(tCsFirmaReporte.Saldo6/12, 2), 1) - 1), 6), 1, Len(dbo.fduNumeroALetras(Substring(dbo.fduNumeroTexto(tCsFirmaReporte.Saldo6/12, 2), 1,   
         CharIndex('.', dbo.fduNumeroTexto(tCsFirmaReporte.Saldo6/12, 2), 1) - 1), 6)) -  18) + ' PUNTO ' +  
         Substring(dbo.fduNumeroALetras(Substring(dbo.fduNumeroTexto(tCsFirmaReporte.Saldo6/12, 2),    
         CharIndex('.', dbo.fduNumeroTexto(tCsFirmaReporte.Saldo6/12, 2), 1) + 1, 2), 6), 1, Len(dbo.fduNumeroALetras(Substring(dbo.fduNumeroTexto(tCsFirmaReporte.Saldo6/12, 2),    
         CharIndex('.', dbo.fduNumeroTexto(tCsFirmaReporte.Saldo6/12, 2), 1) + 1, 2), 6)) -  18) + ' POR CIENTO MENSUAL',      
    @MoraNum  = '$' + dbo.fduNumeroTexto(tCsFirmaReporte.Saldo3, 2),  
    @MoraLet  = dbo.fduNumeroALetras(tCsFirmaReporte.Saldo3, 6),  
    @ComisionNum = IsNull(tCsFirmaReporte.Dato2, ''),  
    @ComisionLet = Isnull(Case  When Left (tCsFirmaReporte.Dato2, 1)  = '$' Then dbo.fduNumeroALetras(SubString(tCsFirmaReporte.Dato2, 2, Len(tCsFirmaReporte.Dato2) - 1), 6)  
         When Right (tCsFirmaReporte.Dato2, 1)  = '%' Then SubString(dbo.fduNumeroALetras(SubString(tCsFirmaReporte.Dato2, 1, Len(tCsFirmaReporte.Dato2) - 1), 6), 1, Len(dbo.fduNumeroALetras(SubString(tCsFirmaReporte.Dato2, 1, Len(tCsFirmaReporte.Dato2) 
- 1), 6)) - 18) + ' POR CIENTO'  
         End, ''),     
    @Frecuencia  = Lower(tCaClModalidadPlazo.Descripcion),   
    @Plazo    = dbo.fduNumeroTexto(tCsFirmaReporte.Saldo4, 0),  
    @FrecuenciaS = Lower(tCaClModalidadPlazo.Singular),   
    @FrecuenciaP = Lower(tCaClModalidadPlazo.Plural),  
    @FrecuenciaC = dbo.fduNumeroTexto(tCsFirmaReporte.Saldo4, 0) + ' ' + Case  When tCsFirmaReporte.Saldo4 = 1 Then tCaClModalidadPlazo.Singular   
             When tCsFirmaReporte.Saldo4 > 1 Then tCaClModalidadPlazo.Plural  
             Else 'No Identificado' End,     
    @DAgencia  = tCsFirmaReporte.DireccionAgencia,  
    @DCorporativo = tCsFirmaReporte.Direccion,  
    @EAgencia  = SUBSTRING(tCsFirmaReporte.DireccionAgencia, CASE WHEN CHARINDEX('Mpo.', tCsFirmaReporte.DireccionAgencia, 1) = 0 THEN CHARINDEX('Del.',   
                         tCsFirmaReporte.DireccionAgencia, 1) + 5 ELSE CHARINDEX('Mpo.', tCsFirmaReporte.DireccionAgencia, 1) + 5 END, CHARINDEX(', C.P.', tCsFirmaReporte.DireccionAgencia, 1)   
                         - CASE WHEN CHARINDEX('Mpo.', tCsFirmaReporte.DireccionAgencia, 1) = 0 THEN CHARINDEX('Del.', tCsFirmaReporte.DireccionAgencia, 1) + 5 ELSE CHARINDEX('Mpo.',   
                         tCsFirmaReporte.DireccionAgencia, 1) + 5 END),  
    @Desembolso  = CASE WHEN day(tCsFirmaReporte.Fecha1) = 1 THEN 'al primer día del mes de ' WHEN day(tCsFirmaReporte.fecha1)   
                          > 1 THEN 'a los ' + cast(day(tCsFirmaReporte.fecha1) AS varchar(5)) + ' días del mes de ' END + dbo.fduNombreMes(MONTH(tCsFirmaReporte.Fecha1))   
                          + ' de ' + dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'AAAA'),  
    @NAval   = tCsFirmaReporte.Dato6,  
    @CalculoINTE = tCsFirmaReporte.Dato7,  
    @ResumenCuotaT = @AUX + ' y así sucesivamente los días establecidos para cada ' + tCaClModalidadPlazo.Singular + ', hasta cubrir el importe total del presente pagaré'   
  FROM         tCsFirmaElectronica INNER JOIN  
                      tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma LEFT OUTER JOIN  
                      tCaClModalidadPlazo ON tCsFirmaReporte.Dato1 = tCaClModalidadPlazo.ModalidadPlazo  
  WHERE     (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Dato = @CodPrestamo)  
   
  --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, 'F: Paso 02' , Getdate(), 'Bloque Asignación')  
  --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, 'I: Paso 03' , Getdate(), 'Bloque Asignación')  
    
  Set @CATLet  = Case @Sistema When 'CA' Then (Substring(dbo.fduNumeroALetras(Substring(@CATNum, 1,   
         CharIndex('.', @CATNum , 1) - 1), 6), 1, Len(dbo.fduNumeroALetras(Substring(@CATNum, 1,   
         CharIndex('.', @CATNum, 1) - 1), 6)) -  18) + ' PUNTO ' +  
         Substring(dbo.fduNumeroALetras(Substring(@CATNum,    
         CharIndex('.', @CATNum, 1) + 1, 2), 6), 1, Len(dbo.fduNumeroALetras(Substring(@CATNum,    
         CharIndex('.', @CATNum, 1) + 1, 2), 6)) -  18) + ' POR CIENTO ANUAL')  
       Else 'GAT'  
       End  
         
    
  --Datos de la Oficina de la tabla tClOficinas:  
  SELECT  @HAPLV   = HAPLunesViernes,   
    @HAPSA   = HAPSabado,  
    @PaginaWeb  = PaginaWeb,  
    @LineaGratuita = LineaGratuita  
  FROM tClOficinas  
  WHERE   (CodOficina = @CodOficina)  
    
  --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, 'F: Paso 03' , Getdate(), 'Bloque Asignación')  
  --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, 'I: Paso 04' , Getdate(), 'Bloque Asignación')  
    
  --Dirección del cliente  
  Set @DCliente   = ''  
  Set @Contador   = 0  
  Declare curReporte Cursor For   
   SELECT     tCsFirmaReporteDetalle.Direccion  
   FROM         tCsFirmaReporteDetalle INNER JOIN  
                         tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma  
   WHERE     (tCsFirmaReporteDetalle.Grupo = 'A') AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Dato = @CodPrestamo) AND   
                         (tCsFirmaElectronica.Usuario = @Usuario)  
   ORDER BY tCsFirmaReporteDetalle.Saldo1 DESC  
  Open curReporte  
  Fetch Next From curReporte Into @TempVC  
  While @@Fetch_Status = 0  
  Begin    
   Set @Contador  = @Contador + 1  
   If  @Contador  = @Acreditados  
   Begin  
    Set @DCliente  = @DCliente + ' Y ' + Ltrim(Rtrim(@TempVC))  
   End  
   Else  
   Begin  
    Set @DCliente  = @DCliente + ', ' + Ltrim(Rtrim(@TempVC))   
   End     
  Fetch Next From curReporte Into  @TempVC  
  End   
  Close   curReporte  
  Deallocate  curReporte  
    
  --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, 'F: Paso 04' , Getdate(), 'Bloque Asignación')  
  --Insert Into tCsRPTControl (Firma, Identificador, Hora, Observacion) Values (@Firma, 'I: Paso 02' , Getdate(), 'Bloque Asignación')  
    
  Set @DCliente = substring(Ltrim(@DCliente), 3, 1000)  
  --PARTIDAS  
  Set @TempIT1  = 200   
  Set @TempVC1  = dbo.fduRellena(' ', '', @TempIT1, 'D') + '-----------------------------------------'  
  Set @Partida   = @TempVC1   
  Declare curReporte Cursor For   
   SELECT     Monto  
   FROM         (  SELECT     O = 1, Monto = '|             Fecha              |            Monto             |'  
                           UNION  
                           SELECT     O = 2, '|     ' + dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'DD') + '/' + dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'MM')   
                                                + '/' + dbo.fduFechaATexto(tCsFirmaReporte.Fecha1, 'AAAA') + '     |       $' + dbo.fduNumeroTexto(tCsFirmaReporte.Saldo1, 2) + '    |' AS Monto  
                           FROM         tCsFirmaReporte INNER JOIN  
                                                tCsFirmaElectronica ON tCsFirmaReporte.Firma = tCsFirmaElectronica.Firma  
                           WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Dato = @CodPrestamo)  
                           UNION  
                           SELECT     O = 3, '|            TOTAL           |       $' + dbo.fduNumeroTexto(SUM(tCsFirmaReporte.Saldo1), 2) + '    |' AS Monto  
                           FROM         tCsFirmaReporte INNER JOIN  
                                                tCsFirmaElectronica ON tCsFirmaReporte.Firma = tCsFirmaElectronica.Firma  
                   WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Dato = @CodPrestamo)) Datos  
   ORDER BY O    
  Open curReporte  
  Fetch Next From curReporte Into @TempVC  
  While @@Fetch_Status = 0  
  Begin    
   Set @Partida = @Partida + Char(10)    
   Set @Partida = @Partida + dbo.fduRellena(' ', '', @TempIT1, 'D') + @TempVC + Char(10) + @TempVC1  
  Fetch Next From curReporte Into  @TempVC  
  End   
  Close   curReporte  
  Deallocate  curReporte   
  --CUADRO DE AMORTIZACION  
  Set @TempIT1  = 190   
  Set @TempVC1  = dbo.fduRellena(' ', '', @TempIT1, 'D') + '-------------------------------------------------'  
  Set @CuadroAmortizacion  = @TempVC1   
  Set @CuadroAmortizacion1 = ''  
  Set @Contador   = 0   
  Declare curReporte Cursor For   
   SELECT     Monto  
   FROM         (SELECT     O = 1, Monto = '|  Cuota  |           Fecha              |            Monto          |'  
                          UNION  
                          SELECT     2 AS O, '|       ' + dbo.fdurellena('0', tCsFirmaReporteDetalle.Identificador, 2, 'D') + '      |     ' + dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'DD')   
                                                + '/' + dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'MM') + '/' + dbo.fduFechaATexto(tCsFirmaReporteDetalle.Fecha1, 'AAAA')   
                                                + '     |     $' + dbo.fduNumeroTexto(tCsFirmaReporteDetalle.Saldo1, 2) + '    |' AS Monto  
                          FROM         tCsFirmaReporteDetalle INNER JOIN  
                                                tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma  
                          WHERE     (tCsFirmaReporteDetalle.Grupo = 'B') AND (tCsFirmaElectronica.Dato = @CodPrestamo) AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = @Usuario)) Datos  
   ORDER BY O, Monto  
  Open curReporte  
  Fetch Next From curReporte Into @TempVC  
  While @@Fetch_Status = 0  
  Begin    
   Set @Contador   = @Contador + 1  
   If @Contador < 3  
   Begin  
    If datalength(@CuadroAmortizacion) > 7000  
    Begin  
     Set @CuadroAmortizacion1 = @CuadroAmortizacion1 + Char(10)  
    End  
    Else  
    Begin  
     Set @CuadroAmortizacion = @CuadroAmortizacion + Char(10)  
    End  
   End  
   Else  
   Begin  
    If datalength(@CuadroAmortizacion) > 7000  
    Begin  
     Set @CuadroAmortizacion1 = @CuadroAmortizacion1 + Char(10) + Char(13)  
    End  
    Else  
    Begin  
     Set @CuadroAmortizacion = @CuadroAmortizacion + Char(10) + Char(13)  
    End  
   End  
   If datalength(@CuadroAmortizacion) > 7000  
   Begin  
    Set @CuadroAmortizacion1 = @CuadroAmortizacion1 + Char(10) + Char(13)  
    Set @CuadroAmortizacion1 = @CuadroAmortizacion1 + dbo.fduRellena(' ', '', @TempIT1, 'D') + @TempVC + Char(10) -- + @TempVC1  
   End  
   Else  
   Begin  
    Set @CuadroAmortizacion = @CuadroAmortizacion + Char(10) + Char(13)  
    Set @CuadroAmortizacion = @CuadroAmortizacion + dbo.fduRellena(' ', '', @TempIT1, 'D') + @TempVC + Char(10) -- + @TempVC1  
   End  
   If @Contador = 1 Begin Set @CuadroAmortizacion = @CuadroAmortizacion + @TempVC1 End   
  Fetch Next From curReporte Into  @TempVC  
  End   
  Close   curReporte  
  Deallocate  curReporte  
  If datalength(@CuadroAmortizacion) > 7000  
  Begin  
   Set @CuadroAmortizacion1 = @CuadroAmortizacion1 + @TempVC1   
  End  
  Else  
  Begin  
   Set @CuadroAmortizacion = @CuadroAmortizacion + @TempVC1      
  End  
  Set @CuadroAmortizacion2 = dbo.fduTablaAmortizacion(@Firma)  
    
  If @Contador > 30  
  Begin  
    Set @CuadroAmortizacion = @CuadroAmortizacion2   
  End  
    
  --Print @CuadroAmortizacion  
  --Print @CuadroAmortizacion1  
  --CUADRO DE GARANTIAS    
  Set @TempIT1  = 80   
  Set @TempVC1  = dbo.fduRellena(' ', '', @TempIT1, 'D') + '-----------------------------------------------------------------------------------------------------------------------'  
  Set @Garantia   = @TempVC1       Declare curReporte Cursor For   
   SELECT DISTINCT tCsFirmaReporteDetalle.Grupo  
   FROM         tCsFirmaReporteDetalle INNER JOIN  
                         tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma  
   WHERE     (tCsFirmaReporteDetalle.Identificacion = 'D') AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Dato = @CodPrestamo) AND   
                         (tCsFirmaElectronica.Usuario = @Usuario)  
  Open curReporte  
  Fetch Next From curReporte Into @TempVC  
  While @@Fetch_Status = 0  
  Begin    
   Print 'Calculando TAB'  
   Print Cast(Datalength(@TempVC1) as Varchar(100))  
   Print @TempIT1   
   Set @TempVC2  = 'REGISTRO DE GARANTÍA NRO ' + dbo.fduRellena('0', @TempVC, 5, 'D')   
   Set @Garantia  = @Garantia + Char(10)    
   Set @Garantia  = @Garantia + dbo.fduRellena(' ', '', @TempIT1, 'D') +   
       dbo.fdurellena(' ', @TempVC2, (ABS(ABS(Datalength(@TempVC1) - @TempIT1) - Len(@TempVC2))/2) * 2.6, 'D') + Char(10) + @TempVC1  
   Declare curReporte1 Cursor For   
    SELECT     tCsFirmaReporteDetalle.Direccion  
    FROM         tCsFirmaReporteDetalle INNER JOIN  
                          tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma  
    WHERE     (tCsFirmaReporteDetalle.Identificacion = 'D') AND (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = @Usuario) AND   
                          (tCsFirmaReporteDetalle.Grupo = @TempVC) AND (tCsFirmaElectronica.Dato = @CodPrestamo)  
    ORDER BY tCsFirmaReporteDetalle.Grupo, tCsFirmaReporteDetalle.Identificador  
   Open curReporte1  
   Fetch Next From curReporte1 Into @TempVC3  
   While @@Fetch_Status = 0  
   Begin    
    Set @Garantia = @Garantia + Char(10)    
    Set @Garantia = @Garantia + dbo.fduRellena(' ', '', @TempIT1 +  3, 'D') + @TempVC3 + Char(10) + Char(13) --+ @TempVC1  
   Fetch Next From curReporte1 Into  @TempVC3  
   End   
   Close   curReporte1  
   Deallocate  curReporte1    
  Fetch Next From curReporte Into  @TempVC  
  End   
  Close   curReporte  
  Deallocate  curReporte   
  If @Garantia = @TempVC1 Begin Set @Garantia = '' End  
  --AVALES  
  Set @DAval   = ''   
  Declare curReporte Cursor For   
   SELECT     tCsFirmaReporteDetalle.Texto  
   FROM         tCsFirmaReporteDetalle INNER JOIN  
                         tCsFirmaElectronica ON tCsFirmaReporteDetalle.Firma = tCsFirmaElectronica.Firma  
   WHERE     (tCsFirmaElectronica.Activo = 1) AND (tCsFirmaElectronica.Usuario = @Usuario) AND (tCsFirmaElectronica.Dato = @CodPrestamo) AND   
                         (tCsFirmaReporteDetalle.Grupo = 'E')  
  Open curReporte  
  Fetch Next From curReporte Into @TempVC  
  While @@Fetch_Status = 0  
  Begin      
   Set @DAval = @DAval + @TempVC + Char(10) + Char(13)  
     
  Fetch Next From curReporte Into  @TempVC  
  End   
  Close   curReporte  
  Deallocate  curReporte  
  --If len(Rtrim(Ltrim(@DAval))) > 1  
  --Begin  
  -- Set @DAval = Substring(Rtrim(Ltrim(@DAval)), 1, len(Rtrim(Ltrim(@DAval))) - 1)    
  --End  
  --REGISTRO DE ETIQUETAS EN TABLA TEMPORAL  
  Set @Contador = 11  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[SRA]',     @SRA    ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[DenoSujeto]',    @DenoSujeto   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[Nombres]',    @Nombres   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[DCliente]',    @DCliente   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[DAgencia]',    @DAgencia   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[EAgencia]',    @EAgencia   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[DCorporativo]',  @DCorporativo  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[MontoNum]',    @MontoNum   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[MontoLet]',    @MontoLet   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[MoraNum]',    @MoraNum   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[MoraLet]',    @MoraLet   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[ComisionNum]',   @ComisionNum  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[ComisionLet]',   @ComisionLet  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[Partida]',    @Partida   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[CuadroAmortizacion]',  @CuadroAmortizacion ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[CuadroAmortizacion1]', @CuadroAmortizacion1) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[CuadroAmortizacion2]', @CuadroAmortizacion2) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[Garantia]',    @Garantia   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[NAval]',     @NAval    ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[DAval]',     @DAval    ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[GLCuenta]',    @GLCuenta   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[GLMonto]',    @GLMonto   ) Set @Contador = @Contador + 1   
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[CalculoINTE]',   @CalculoINTE  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[TasaMensual]',   @TasaMensual  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[TasaLet]',    @TasaLet   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[HAPLV]',     @HAPLV    ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[HAPSA]',     @HAPSA    ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[Frecuencia]',    @Frecuencia   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[Plazo]',     @Plazo    ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[FrecuenciaS]',   @FrecuenciaS  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[FrecuenciaP]',   @FrecuenciaP  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[FrecuenciaC]',   @FrecuenciaC  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[TipoPlanD]',    @TipoPlanD   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[Desembolso]',    @Desembolso   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[ResumenCuotaT]',   @ResumenCuotaT  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[PaginaWeb]',    @PaginaWeb   ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[LineaGratuita]',   @LineaGratuita  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[CATNum]',     @CATNum    ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[CATLet]',     @CATLet    ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[MoratorioNum]',   @MoratorioNum  ) Set @Contador = @Contador + 1  
  Insert Into #Etiqueta (Fila, Etiqueta, Texto) Values (@Contador, '[MoratorioLet]',   @MoratorioLet  ) Set @Contador = @Contador + 1  
    
  If @Sistema <> 'AH'  
  Begin  
   Declare curReporte2 Cursor For   
    SELECT DISTINCT Tipo  
    FROM         tCsRPTClausulas Where Activo = 1   
   Open curReporte2  
   Fetch Next From curReporte2 Into @TipoClausula  
   While @@Fetch_Status = 0  
   Begin       
    Set @Cadena  = ''    
    Set @Contador  = 0  
    
    Declare curReporte Cursor For   
     Select  Rtrim(Ltrim(Isnull(Condicion, ''))), Orden, Titulo, Isnull(Texto1, '') + IsNUll(Texto2, '') as Cadena, Tipo,   
      IsNull(TAdicional, '') As TAdicional, IsNull(DAdicional, '') As DAdicional  
     From tCsRPTClausulas Where Tipo = @TipoClausula And Activo = 1  
     Order by Orden  
    Open curReporte  
    Fetch Next From curReporte Into @TempVC, @TempIT, @OtroDato, @Cadena, @TempVC6, @TempVC7, @TempVC8  
    While @@Fetch_Status = 0  
    Begin    
     Print '@TempVC : ' + Isnull(@TempVC, 'Nulo')   
     Print 'OtroDato : ' + Isnull(@OtroDato, 'Nulo')  
     Print 'Cadena : ' + Isnull(@Cadena, 'Nulo')   
     If @TempVC <> ''  
     Begin  
      Truncate Table #Valor  
      Set @TempVC3 = 'Insert Into #Valor (Valor) SELECT COUNT(*) '  
      Set @TempVC3 = @TempVC3 + 'FROM tCsFirmaElectronica INNER JOIN '  
                          Set @TempVC3 = @TempVC3 + 'tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma INNER JOIN '  
                          Set @TempVC3 = @TempVC3 + 'tCaProducto ON tCsFirmaReporte.Dato4 = tCaProducto.CodProducto LEFT OUTER JOIN '  
                          Set @TempVC3 = @TempVC3 + '(SELECT * FROM tCsCartera WHERE Fecha IN (SELECT Fechaconsolidacion FROM vcsfechaconsolidacion)) '  
      Set @TempVC3 = @TempVC3 + 'tCsCartera ON tCsFirmaElectronica.Dato = tCsCartera.CodPrestamo '  
      Set @TempVC3 = @TempVC3 + 'WHERE (tCsFirmaElectronica.Firma = ''' + @Firma + ''') AND ' + @TempVC  
      --Print 'KEMY: ' + @TempVC3  
      Exec(@TempVC3)  
      Select @TempVC3 = Valor From #Valor   
      --Print @TempVC3  
      If Cast(@TempVC3 As Int) > 0  
      Begin  
       Set @Mayuscula = 1  
      End  
      Else  
      Begin  
       Set @Mayuscula = 0  
      End  
     End   
     Else  
     Begin  
      Set @Mayuscula = 1  
     End  
     If @Mayuscula = 1  
     Begin  
      Set @Contador = @Contador + 1  
      --Se reemplaza etiquetas  
      Declare curReporte1 Cursor For   
       Select Etiqueta, Texto  
       From #Etiqueta  
      Open curReporte1  
      Fetch Next From curReporte1 Into @TempVC4, @TempVC5  
      While @@Fetch_Status = 0  
      Begin    
       --Print 'OtroDato : ' + Isnull(@OtroDato, 'Nulo')  
       --Print 'Cadena : ' + Isnull(@Cadena, 'Nulo')   
       --Print '@TempVC4 : ' + Isnull(@TempVC4, 'Nulo')  
       --Print '@TempVC5 : ' + Isnull(@TempVC5, 'Nulo')   
       Set @Cadena  = Replace(@Cadena,  @TempVC4, @TempVC5)  
       Set @OtroDato  = Replace(@OtroDato,  @TempVC4, @TempVC5)  
       Set @TempVC7  = Replace(@TempVC7,  @TempVC4, @TempVC5)  
      Fetch Next From curReporte1 Into @TempVC4,  @TempVC5  
      End   
      Close   curReporte1  
      Deallocate  curReporte1       
        
      --VEREMOS SI LA CLAUSULA NECESITA DE TEXTO ADICIONAL  
      If  CharIndex('{Adicional}', @Cadena, 1)  <> 0  And  
       @TempVC7     <> ''  And  
       @TempVC8     <> ''    
      Begin  
       Truncate Table #Valor  
       Set @TempVC2 = 'Insert Into #Valor(Valor) Select ' + @TempVC8 + ' From '  
       Set @TempVC2 = @TempVC2 + SubString(@TempVC8, 1, CharIndex('.', @TempVC8, 1) - 1) + ' '  
       Set @TempVC2 = @TempVC2 + 'Where Firma = ''' + @Firma + ''''  
       Exec(@TempVC2)  
       Set @TempVC2 = ''  
       Select @TempVC2 = Valor From #Valor    
       If @TempVC2 Is null Begin Set @TempVC2 = '' end  
       If @TempVC2 = ''  
       Begin  
        Set @TempVC7 = ''  
       End  
      End  
      Else  
      Begin  
       Set @TempVC7 = ''  
      End     
        
      Print 'VALIDA ERROR DE DATO 1'  
      Print 'Firma : ' + Isnull(@Firma, 'Nulo')  
      Print 'Contador : ' + Isnull(Cast(@Contador as Varchar(10)), 'Nulo')  
      Print 'Ordinal : ' + IsNull(dbo.fduNumeroOrdinal(@Contador), 'Nulo')  
      Print 'TempIT : ' + Cast(@TempIT as Varchar(10))  
      Print 'OtroDato : ' + Isnull(@OtroDato, 'Nulo')  
      Print 'Cadena : ' + Isnull(@Cadena, 'Nulo')  
      Print 'TempVC6 : ' + Isnull(@TempVC6, 'Nulo')       
  
      Set @Cadena  = Replace(@Cadena,'{Adicional}', @TempVC7)   
      Set @Cadena  = Replace(@Cadena, '  ', ' ')  
      Set @OtroDato  = Replace(@OtroDato, '  ', ' ')  
      Set @Cadena  = Replace(@Cadena, Char(10)+''+Char(10), '')  
      Set @OtroDato  = Replace(@OtroDato, Char(10)+''+Char(10), '')    
      Set @Cadena  = Replace(@Cadena, ''+char(10)+char(13)+'', '')  
      Set @OtroDato = Replace(@OtroDato, ''+char(10)+char(13)+'', '')     
      Set @Cadena  = Replace(@Cadena, ''+char(10)+'.', '.')  
      Set @OtroDato = Replace(@OtroDato, ''+char(10)+'.', '.')        
      Set @Cadena  = Replace(@Cadena, ''+char(10)+',', ',')  
      Set @OtroDato = Replace(@OtroDato, ''+char(10)+',', ',')  
        
      Print 'VALIDA ERROR DE DATO 2'  
      Print 'Firma : ' + Isnull(@Firma, 'Nulo')  
      Print 'Contador : ' + Isnull(Cast(@Contador as Varchar(10)), 'Nulo')  
      Print 'Ordinal : ' + IsNull(dbo.fduNumeroOrdinal(@Contador), 'Nulo')  
      Print 'TempIT : ' + Cast(@TempIT as Varchar(10))  
      Print 'OtroDato : ' + Isnull(@OtroDato, 'Nulo')  
      Print 'Cadena : ' + Isnull(@Cadena, 'Nulo')  
      Print 'TempVC6 : ' + Isnull(@TempVC6, 'Nulo')   
      
      --Se identifica si se trata de una solicitud que hace referencia a Un cliente o Varios  
      Exec pCsSingularPlural @SiPl, @Cadena, @TempVC1 Out  
      Set @Cadena = @TempVC1  
      Exec pCsSingularPlural @SiPl, @OtroDato, @TempVC1 Out  
      Set @OtroDato = @TempVC1     
        
      Print 'VALIDA ERROR DE DATO 3'  
      Print 'Firma : ' + Isnull(@Firma, 'Nulo')  
      Print 'Contador : ' + Isnull(Cast(@Contador as Varchar(10)), 'Nulo')  
      Print 'Ordinal : ' + IsNull(dbo.fduNumeroOrdinal(@Contador), 'Nulo')  
      Print 'TempIT : ' + Cast(@TempIT as Varchar(10))  
      Print 'OtroDato : ' + Isnull(@OtroDato, 'Nulo')  
      Print 'Cadena : ' + Isnull(@Cadena, 'Nulo')  
      Print 'TempVC6 : ' + Isnull(@TempVC6, 'Nulo')  
      Insert Into tCsFirmaReporteClausula (Firma, Fila, Clausula, Orden, Titulo, Texto, Tipo)  
      Values(@Firma, @Contador, dbo.fduNumeroOrdinal(@Contador), @TempIT, @OtroDato, @Cadena, @TempVC6)   
     End  
    Fetch Next From curReporte Into  @TempVC, @TempIT, @OtroDato, @Cadena, @TempVC6, @TempVC7, @TempVC8  
    End   
    Close   curReporte  
    Deallocate  curReporte   
  
   Fetch Next From curReporte2 Into  @TipoClausula  
   End   
   Close   curReporte2  
   Deallocate  curReporte2   
  
   SELECT  @Contador = COUNT(*)   
   FROM         tCsFirmaReporteClausula  
   WHERE     (Texto LIKE '%[ [ ]clausula:%') AND (tCsFirmaReporteClausula.Firma = @Firma)  
     
   WHILE @Contador > 0  
   Begin  
    UPDATE    tCsFirmaReporteClausula  
    SET              texto = REPLACE(tCsFirmaReporteClausula.Texto, SUBSTRING(tCsFirmaReporteClausula.Texto, CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1),   
           CHARINDEX(']', tCsFirmaReporteClausula.Texto, CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1)) - CHARINDEX('[Clausula:',   
           tCsFirmaReporteClausula.Texto, 1) + 1), UPPER(tCsFirmaReporteClausula_1.Clausula))  
    FROM         tCsFirmaReporteClausula INNER JOIN  
           tCsFirmaReporteClausula tCsFirmaReporteClausula_1 ON tCsFirmaReporteClausula.Firma = tCsFirmaReporteClausula_1.Firma AND   
           SUBSTRING(tCsFirmaReporteClausula.Texto, CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1) + 10, CHARINDEX(']', tCsFirmaReporteClausula.Texto,   
           CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1)) - CHARINDEX('[Clausula:', tCsFirmaReporteClausula.Texto, 1) - 10)   
           = tCsFirmaReporteClausula_1.Titulo  
    WHERE (tCsFirmaReporteClausula.Firma = @Firma) AND (tCsFirmaReporteClausula.Texto LIKE '%[ [ ]clausula:%')   
      
    --If @@RowCount > 0  
    --Begin  
     SELECT  @Contador = COUNT(*)   
     FROM         tCsFirmaReporteClausula  
     WHERE     (Texto LIKE '%[ [ ]clausula:%') AND (tCsFirmaReporteClausula.Firma = @Firma)  
    --End  
    --Else  
    --Begin  
    -- Set @Contador = 0  
    --End  
   End      
   --Set @Cadena = 'UPDATE ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tCaPrestamos Set SelloElectronico = ''' + @Firma + ''' Where CodPrestamo = ''' + @CodPrestamo + ''''  
   --Exec(@Cadena)  
  End  
 Fetch Next From curPrestamo Into  @CodPrestamo  
 End   
 Close   curPrestamo  
 Deallocate  curPrestamo  
Fetch Next From curOficina Into  @IP, @BaseDatos  
End   
Close   curOficina  
Deallocate  curOficina  
  
If @Dato In (1,2,3)  
Begin  
 Delete From tCsFirmaReporteClausula  
 Where Tipo Not In ('Clausula', 'Declaracion', 'Pagare', 'ZURICH') And Firma = @Firma  
End  
If @Dato In (4)  
Begin  
 Delete From tCsFirmaReporteClausula  
 Where Tipo Not In ('Carta') And Firma = @Firma  
  
 Update tCsFirmaReporteClausula  
 Set Texto =  Replace(Texto, ''+char(10)+'', '')  
 Where Firma = @Firma  
   
 --Update tCsFirmaReporteClausula  
 --Set Texto =  Texto + char(10)  
 --Where Firma = @Firma  
End  
  
Drop Table #Reporte  
Drop Table #Etiqueta  
Drop Table #Oficina  
Drop Table #Valor  
Drop Table #Garantia  
--REGISTRO DE SEGUROS  
Exec pCsSegurosRegistro @CodPrestamo, @Firma

GO