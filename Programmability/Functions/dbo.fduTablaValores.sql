SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduTablaValores] (@Cadena varchar(2000))  
RETURNS @Tabla TABLE (Codigo varchar(20))
AS  
BEGIN 

	   	DECLARE @CuentaCampo varchar(2000) 
		SET @CuentaCampo = @Cadena -- '1120000000,1120000000,1140000000'--'1120000'
		--print @CuentaCampo
		DECLARE @POS int
		DECLARE @NPOS int
		DECLARE @NUM int
		SET @POS = CHARINDEX (',',@CuentaCampo)
		SET @NPOS = @POS		
		if(@POS<>0)
		begin
			INSERT INTO @Tabla (Codigo) VALUES (SUBSTRING(@CuentaCampo,0,@POS))
			SET @NUM=1
			while @POS <> 0
			begin
				SET @POS = CHARINDEX (',',@CuentaCampo,@NPOS+1)
				--PRINT @POS
				--PRINT @NPOS
				IF (@POS=0) INSERT INTO @Tabla (Codigo) VALUES (SUBSTRING(@CuentaCampo,@NPOS+1,LEN(@CuentaCampo)-@NPOS))
				ELSE INSERT INTO @Tabla (Codigo) VALUES ( SUBSTRING(@CuentaCampo,@NPOS+1,@POS-@NPOS-1))
				SET @NPOS = @POS
				SET @NUM=@NUM+1
			end
		end
		else
		begin
			--significa que es un solo valor
			INSERT INTO @Tabla (Codigo) VALUES ( @CuentaCampo) 
		end


return
END
GO

GRANT SELECT ON [dbo].[fduTablaValores] TO [marista]
GO

GRANT SELECT ON [dbo].[fduTablaValores] TO [jarriagaa]
GO