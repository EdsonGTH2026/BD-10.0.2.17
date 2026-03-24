SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--drop function fCsAntiguedad
CREATE FUNCTION [dbo].[fCsAntiguedad]
              ( @FechaIngreso DATETIME,
                @FechaActual DATETIME
              )
RETURNS varchar(25)

Begin
 Declare @FechaAñoActual datetime  --Fecha que tiene el mismo año que fecha actual (para calculo interno)
 Declare @FechaAñoActualMES datetime --Fecha que tiene el mismo año y mes que fecha actual (para calcular diff días)


 Declare @DiffAño int
 Declare @DiffMes int 
 Declare @DiffDia int 


 --set @FechaIngreso=getdate()-1549  DATOS DE PRUEBA
 --set @FechaActual=getdate()


 SET @DiffAño = dbo.fCsDateDiff('yy',@FechaIngreso,@FechaActual) 


 -- FechaAñoActual se posiciona a fecha sin diff en años, para calcular diff en mes
 SET @FechaAñoActual = Dateadd(yy, @DiffAño,@FechaIngreso) 
 SET @DiffMes = dbo.fCsDateDiff('mm',@FechaAñoActual,@FechaActual)


 -- FechaAñoActualMes se posiciona a fecha sin diff en años-meses, para calcular diff en días
 SET @FechaAñoActualMES = DateADD(mm,@DiffMes,@FechaAñoActual)  
 SET @DiffDia = dbo.fCsDateDiff('dd', @FechaAñoActualMES,@FechaActual)


 --Formatea la salida
 Declare @sAño varchar(8)
 Declare @sMes varchar(9)
 Declare @sDia varchar(8)
 Declare @sSalida varchar(25) 


 set @sAño=        case when @DiffAño = 0   then ''
        when @DiffAño = 1   then Cast(@DiffAño as varchar) + ' Año '
        when @DiffAño > 1   then Cast(@DiffAño as varchar) + ' Años '
      end


 set @sMes=        case when @DiffMes = 0   then ''
        when @DiffMes = 1   then Cast(@DiffMes as varchar) + ' Mes '
        when @DiffMes > 1   then Cast(@DiffMes as varchar) + ' Meses '
      end


 set @sDia=      case when @DiffDia = 0   then ''
        when @DiffDia = 1   then Cast(@DiffDia as varchar) + ' Día '
        when @DiffDia > 1   then Cast(@DiffDia as varchar) + ' Días '
     end
 set @sSalida= Case when @sAño + @sMes + @sDia ='' then 'Sin Antiguedad' else @sAño + @sMes + @sDia end


 Return @sSalida
END
GO