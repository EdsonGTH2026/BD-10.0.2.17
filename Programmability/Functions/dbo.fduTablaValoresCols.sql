SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduTablaValoresCols] (@Cadena varchar(200),@Valores varchar(200))  
RETURNS @Tabla TABLE (Codigo varchar(20),valor varchar(20))
AS  
BEGIN 

	   	DECLARE @CuentaCampo varchar(200) 
		SET @CuentaCampo = @Cadena

		DECLARE @Cuentavalor varchar(200) 
		SET @Cuentavalor = @Valores


		DECLARE @POS int
		DECLARE @NPOS int

		DECLARE @POS2 int
		DECLARE @NPOS2 int

		SET @POS = CHARINDEX (',',@CuentaCampo)
		SET @NPOS = @POS

		SET @POS2 = CHARINDEX (',',@Cuentavalor)
		SET @NPOS2 = @POS2

		declare @uno bit
		set @uno = 0
		if(@POS2=0) set @uno=1

		if(@POS<>0)
		begin
			INSERT INTO @Tabla (Codigo,valor)
			VALUES (SUBSTRING(@CuentaCampo,0,@POS), case @uno when 0 then SUBSTRING(@Cuentavalor,0,@POS2) else @Cuentavalor end)
			while @POS <> 0
			begin
				SET @POS = CHARINDEX (',',@CuentaCampo,@NPOS+1)
				SET @POS2 = CHARINDEX (',',@Cuentavalor,@NPOS2+1)

				IF (@POS=0) INSERT INTO @Tabla (Codigo,valor) VALUES (SUBSTRING(@CuentaCampo,@NPOS+1,LEN(@CuentaCampo)-@NPOS), case @uno when 0 then SUBSTRING(@Cuentavalor,@NPOS2+1,LEN(@Cuentavalor)-@NPOS2) else @Cuentavalor end)

				ELSE INSERT INTO @Tabla (Codigo,valor) VALUES (SUBSTRING(@Cuentacampo,@NPOS+1,@POS-@NPOS-1), case @uno when 0 then SUBSTRING(@Cuentavalor,@NPOS2+1,@POS2-@NPOS2-1) else @Cuentavalor end)


				SET @NPOS = @POS
				SET @NPOS2 = @POS2
			end
		end
		else
		begin
			--significa que es un solo valor
			--INSERT INTO @Tabla (Codigo) VALUES ( @CuentaCampo) 
			INSERT INTO @Tabla (Codigo,valor) VALUES (@CuentaCampo,@Cuentavalor)
		end


return
END




GO