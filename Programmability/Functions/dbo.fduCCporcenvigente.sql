SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  User Defined Function dbo.fduCCporcenvigente    Script Date: 08/03/2023 09:14:53 pm ******/
CREATE FUNCTION [dbo].[fduCCporcenvigente] (@Cadena varchar(200))
RETURNS decimal(5,2)
AS  
BEGIN 
    
    --declare @Cadena varchar(200)
    --set @Cadena='01 V V V V V V V V V-- V'--'151514131211100908070605'--' V V V V V V V V V V V01'
    declare @CuentaCampo varchar(200)
    set @CuentaCampo=@Cadena
    declare @Tabla TABLE (RFC varchar(20),item int identity,Codigo varchar(2))
	
		DECLARE @FIN int
		set @FIN = len(@Cadena)
		if(@FIN<>2)
		begin
			while @FIN<>0
			begin
				INSERT INTO @Tabla (Codigo) VALUES (SUBSTRING(@CuentaCampo,1,2))
				set @CuentaCampo=SUBSTRING(@CuentaCampo,3,len(@CuentaCampo))
				SET @FIN=@FIN-2
			end
		end
		else
		begin
			INSERT INTO @Tabla (Codigo) VALUES (@CuentaCampo) 
		end

    return (
      select cast(cast(vigente as decimal(5,2))/cast(todos as decimal(5,2))*100 as decimal(5,2)) porvige
      from (
        select sum(case when codigo in(' V','--') then 1 else 0 end) 'VIGENTE'
        --,sum(case when codigo='--' then 1 else 0 end) 'SIN INFO'
        ,sum(case when codigo in ('01','02','03') then 1 else 0 end) 'ATRASADO'
        ,sum(case when codigo not in ('01','02','03',' V','--') then 1 else 0 end) 'VENCIDOS'
        ,count(codigo) todos
        from @Tabla
        group by rfc
      ) a
    )

END

GO