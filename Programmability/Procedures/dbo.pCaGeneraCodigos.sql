SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCaGeneraCodigos](
	@TipoCodigo varchar(15),
	@TipoPrestamoProd varchar(15),
	@CodOficina varchar(5),
	@Codigo varchar(30) OUTPUT)
--WITH ENCRYPTION
AS
set nocount on -- <-- Optimizacion Noel

DECLARE @QueCodigo varchar(15)
DECLARE @SecCodigo varchar(15)
DECLARE @TipoPrestamo varchar(15)
DECLARE @idTipoPrestamo varchar(2)
DECLARE @PesoSecuencial int

-- (Modificado por Eric)
-- Verifica que exista el registro para la oficina
IF NOT EXISTS(Select 1 From tCaCodigosParametros Where CodOficina = @CodOficina)
   INSERT INTO tCaCodigosParametros
          (SiglaSolicitud, SecSolicitud, SecGrupo, idComercial, idMicroempresa, idConsumo, idHipotecario, idFideicomiso, SecCodComercial, SecCodMicroempresa, SecCodConsumo, SecCodHipotecario, SecCodFideicomiso, SecAprobaDesembolso, SecTransCaja, CodOficina)
   VALUES ('SOL-',         '0',          '0',      1,           2,              3,         4,             5,             0,               0,                  0,             0,                 0,                 0,                   0,           @CodOficina)

IF NOT EXISTS(Select 1 From tCaCodigosParametros Where SiglaSolicitud = 'BOL-')
   INSERT INTO tCaCodigosParametros
          (SiglaSolicitud, SecBoletas, SecBolOperacion, SecBolCobro, SecRFA, CodOficina) 
   VALUES ('BOL-',         0,          0,               0,           0,      @CodOficina )

/*************************************************
 *   Que código va ha generar el SP.
 *       PROD = Productos
 *       SOL  = Solicitud
 *************************************************/
Set @QueCodigo = @TipoCodigo
/*************************************************
 *   Tipo de préstamo puede ser
 *       1. Comercial
 *       2. Microempresa
 *       3. Consumo
 *       4. Hipotecario
 *************************************************/
Set @TipoPrestamo = @TipoPrestamoProd

/**************************************************
 *     GENERA EL SECUENCIAL DEL DESEMBOLSO        *
 **************************************************/
if (@QueCodigo = 'SecDesembolso')
   Begin
   Select @SecCodigo = SecAprobaDesembolso + 1 from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
   if exists (Select SecDesemb From tCaDesemb Where SecDesemb = @SecCodigo)
      SET @SecCodigo = IsNull((Select Max(SecDesemb) From tCaDesemb), 0) + 1
   Update tCaCodigosParametros Set SecAprobaDesembolso = @SecCodigo Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
   End

/**************************************************
 * GENERA EL SECUENCIAL DEL  TRANSACCION DE CAJA  *
 **************************************************/
if (@QueCodigo = 'TransCaja')
   Begin
   Select @SecCodigo = SecTransCaja + 1 from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
   Update tCaCodigosParametros Set SecTransCaja = @SecCodigo Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
   End

/**************************************************
 *            GENERA EL CODIGO DE GRUPO           *
 **************************************************/
DECLARE @SecGrupo varchar (20)

if (@QueCodigo = 'Grupo') or (@QueCodigo = 'GRUPO')
   Begin
   Select @SecGrupo = SecGrupo + 1 from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
  	Update tCaCodigosParametros Set SecGrupo = @SecGrupo Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	-- corregido por noel:
	Select @SecCodigo = @CodOficina + '-' + right('0000000' + rtrim(SecGrupo), 7) from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
   end

/**************************************************
 *         GENERA EL CODIGO DEL PRODUCTO          *
 **************************************************/
if (@QueCodigo = 'PROD')
   Begin
   	if (@TipoPrestamo = 'COMERCIAL')
      	   Begin
	   	Select @SecCodigo = SecCodcomercial + 1 from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Select @idTipoPrestamo = idComercial from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Update tCaCodigosParametros Set SecCodcomercial = @SecCodigo Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	if Len(@SecCodigo) = 1 
	      	   Begin
		   	Select @SecCodigo = @idTipoPrestamo + '0' + @SecCodigo
	       	   End
	     Else
		Begin
		     Select @SecCodigo = @idTipoPrestamo + @SecCodigo
	        End
           End

	if (@TipoPrestamo = 'MICROEMPRESA')
      	   Begin
	   	Select @SecCodigo = SecCodMicroempresa + 1 from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Select @idTipoPrestamo = idMicroempresa from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Update tCaCodigosParametros Set SecCodMicroempresa = @SecCodigo Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	if Len(@SecCodigo) = 1 
	            Begin
		   	Select @SecCodigo = @idTipoPrestamo + '0' + @SecCodigo
	            End
	     Else 
	        Begin
		     Select @SecCodigo = @idTipoPrestamo + @SecCodigo
	        End	
           End

        if (@TipoPrestamo = 'CONSUMO')
      	   Begin
	   	Select @SecCodigo = SecCodConsumo + 1 from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Select @idTipoPrestamo = idConsumo from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Update tCaCodigosParametros Set SecCodConsumo = @SecCodigo Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	if Len(@SecCodigo) = 1 
	      	   Begin
		   	Select @SecCodigo = @idTipoPrestamo + '0' + @SecCodigo
	      	   End
	      Else 
	        Begin
		     Select @SecCodigo = @idTipoPrestamo + @SecCodigo
	        End
           End

        if (@TipoPrestamo = 'HIPOTECARIO')
      	   Begin
	   	Select @SecCodigo = SecCodHipotecario + 1 from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Select @idTipoPrestamo = idHipotecario from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Update tCaCodigosParametros Set SecCodHipotecario = @SecCodigo Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	if Len(@SecCodigo) = 1 
	      	   Begin
		   	Select @SecCodigo = @idTipoPrestamo + '0' + @SecCodigo
	           End
	      Else 
	         Begin
		      Select @SecCodigo = @idTipoPrestamo + @SecCodigo
	         End
           End

        if (@TipoPrestamo = 'FIDEICOMISO')
      	   Begin
	   	Select @SecCodigo = SecCodFideicomiso + 1 from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Select @idTipoPrestamo = idFideicomiso from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	Update tCaCodigosParametros Set SecCodFideicomiso = @SecCodigo Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	   	if Len(@SecCodigo) = 1 
	      	   Begin
		   	Select @SecCodigo = @idTipoPrestamo + '0' + @SecCodigo
	           End
	      Else 
	         Begin
		      Select @SecCodigo = @idTipoPrestamo + @SecCodigo
	         End
           End
end

/**************************************************
 *       GENERA EL CODIGO DE LA SOLICITUD         *
 **************************************************/
if (@QueCodigo = 'SOL')
   Begin
	Update tCaCodigosParametros Set SecSolicitud = SecSolicitud + 1 Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
	-- corregido por noel
	Select @SecCodigo = SiglaSolicitud + right('0000000' + rtrim(SecSolicitud),7) from tCaCodigosParametros Where CodOficina = @CodOficina and SiglaSolicitud <> 'BOL-'
   end


/**************************************************
 *       GENERA EL CODIGO DE LA BOLETAS           *
 **************************************************/
if (@QueCodigo = 'BOL') begin

	update tCaCodigosParametros set 
        SecBoletas = SecBoletas + 1 
        where SiglaSolicitud = 'BOL-'

	select @SecCodigo = SiglaSolicitud +  right('000' + rtrim(@CodOficina), 3) + '-' + right('0000000' + rtrim(SecBoletas),7) 
        from tCaCodigosParametros 
        where SiglaSolicitud = 'BOL-'

   end

/**************************************************
 *       GENERA EL CODIGO DE LA OPERACIONBOLETAS  *
 **************************************************/
if (@QueCodigo = 'OPE') begin
	update tCaCodigosParametros set 
	SecBolOperacion = SecBolOperacion + 1 
	where SiglaSolicitud = 'BOL-'

	select @SecCodigo = SecBolOperacion 
	from tCaCodigosParametros 
	where SiglaSolicitud = 'BOL-'
   end

/**************************************************
 *       GENERA EL CODIGO DE COBRO BOLETAS        *
 **************************************************/
if (@QueCodigo = 'COB') begin
	Update tCaCodigosParametros Set 
	SecBolCobro = SecBolCobro + 1 
	where SiglaSolicitud = 'BOL-'

	Select @SecCodigo = SecBolCobro 
	from tCaCodigosParametros 
	where SiglaSolicitud = 'BOL-'
   end

Select @Codigo = @SecCodigo

return 0

--------------------------------------------------------------------------------

GO