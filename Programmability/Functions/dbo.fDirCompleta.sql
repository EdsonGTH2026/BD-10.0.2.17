SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fDirCompleta](@dir as varchar(200), @numext as varchar(10))  
RETURNS varchar(200)  
--WITH SCHEMABINDING   
AS  
BEGIN  
  
--declare @dir as varchar(200)  
--declare @numext as varchar(10)  
--set @dir = 'CLL MEZCALAPA'  
--set @numext = 'MZ 5'  
  
 declare @direccion as varchar(200);  
 declare @numexterno as varchar(10);  
  
 set @direccion = ltrim(rtrim(@dir))  
 set @numexterno = ltrim(rtrim(isnull(@numext,'SN')))  
   
  
 --Quita estas palabras  
 --set @numexterno = replace(@numexterno,'SN','')  
    set @numexterno = replace(@numexterno,'SIN NUMERO','')  
 set @numexterno = replace(@numexterno,'S/N','')  
    set @numexterno = replace(@numexterno,'  ',' ')  
    set @numexterno = replace(@numexterno,'_',' ')  
 --set @numexterno = replace(@numexterno,'00','SN')  
    set @numexterno = replace(@numexterno,'n/a','SN')  
 set @numexterno = replace(@numexterno,'*','SN')  
 set @numexterno = replace(@numexterno,'NA','SN')  
    set @numexterno = replace(@numexterno,'null','SN')  
 set @numexterno = replace(@numexterno,'MZ','')  
 set @numexterno = replace(@numexterno,'M','')  
 if (len(@numexterno)=1 and @numexterno='0') set @numexterno=''  
  
 set @direccion = replace(@direccion,'  ',' ')  
    set @direccion = replace(@direccion,'SIN NUMERO','SN')  
 set @direccion = replace(@direccion,'S N','SN')  
 set @direccion = replace(@direccion,'_',' ')  
 set @direccion = replace(@direccion,'-',' ')  
 set @direccion = replace(@direccion,'*',' ')  
 set @direccion = replace(@direccion,'null','')  
   
 --select @direccion  
  
 if CHARINDEX(' SN ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' SN ', @direccion))  
   set @direccion = @direccion + ' SN'  
  end  
  
 if CHARINDEX(' sin numero ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' sin numero ', @direccion))  
   set @direccion = @direccion + ' SN'  
  end  
--select @direccion  
 if CHARINDEX(',', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(',', @direccion))  
  end  
  
 if CHARINDEX(' colonia ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' colonia ', @direccion))  
  end  
   
 if CHARINDEX(' col ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' col ', @direccion))  
  end  
   
 if CHARINDEX(' col.', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' col.', @direccion))  
  end  
  
 if CHARINDEX(' barr ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' barr ', @direccion))  
  end  
  
 if CHARINDEX(' barr.', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' barr.', @direccion))  
  end  
  
 if CHARINDEX(' fracc ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' fracc ', @direccion))  
  end  
  
 if CHARINDEX(' fracc.', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' fracc.', @direccion))  
  end  
  
 if CHARINDEX(' fraccionamiento.', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' fraccionamiento.', @direccion))  
  end  
  
 if CHARINDEX(' fraccionamiento', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' fraccionamiento', @direccion))  
  end  
  
 if CHARINDEX(' esq ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' esq ', @direccion))  
  end  
  
 if CHARINDEX(' esq,', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' esq,', @direccion))  
  end  
  
 if CHARINDEX(' esq.', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' esq.', @direccion))  
  end  
  
 if CHARINDEX(' loc ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' loc ', @direccion))  
  end  
  
 if CHARINDEX(' loc.', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' loc.', @direccion))  
  end  
  
 if CHARINDEX(' barrio ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' barrio ', @direccion))  
  end  
  
 if CHARINDEX(' barr.', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' barr.', @direccion))  
  end  
  
 if CHARINDEX(' cp.', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' cp.', @direccion))  
  end  
  
 if CHARINDEX(' cp ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' cp ', @direccion))  
  end  
  
 if CHARINDEX(' c.p.', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' c.p.', @direccion))  
  end  
  
 if CHARINDEX(' bo ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' bo ', @direccion))  
  end  
  
 if CHARINDEX(' ejido ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' ejido ', @direccion))  
  end  
  
 if CHARINDEX(' localidad ', @direccion) > 0   
  begin  
   set @direccion = substring(@direccion, 0, CHARINDEX(' localidad ', @direccion))  
  end  
  
    if CHARINDEX('domicilio conocido', @direccion) > 0   
  begin  
   set @direccion = 'DOMICILIO CONOCIDO SN'  
  end  
  
 if CHARINDEX('sin nombre', @direccion) > 0   
  begin  
   set @direccion = 'DOMICILIO CONOCIDO SN'  
  end  
  
 --si empieza con colonia  
 if @direccion like 'colonia%'  
  begin    
   set @direccion = 'DOMICILIO CONOCIDO SN'  
  end  
  
 --si empiea con numero poner C  
 if @direccion like '[0-9]%'  
  begin    
   set @direccion = 'C ' + @direccion  
  end  
   
 --si no termina en numero y no tiene SN, le pone SN  
 if @direccion not like '% SN' and  @direccion not like '%[0-9]'  
  begin  
   set @direccion = @direccion + ' SN'  
  end  
  
 if len(@direccion) >= 35 and len(@direccion) <= 50   
  begin  
   --si la direccion contiene numero, le quita el texto desde el ultimo numero  
   if @direccion like '%[0-9]%'  
    begin  
     set @direccion =  left(@direccion, (len(@direccion) - patindex('%[0-9]%', reverse(@direccion)) + 1))  
    end  
   else  
     begin  
     set @direccion = 'DOMICILIO CONOCIDO SN'  
    end  
  end  
   
 if len(@direccion) >= 50  
  begin  
   set @direccion = 'DOMICILIO CONOCIDO SN'  
  end  
  
 --select @direccion  
  
  
    --set @direccion = replace(@direccion,'SN','')  
  
 if len(@numexterno) = 2  
  begin  
   set @numexterno = replace(@numexterno,'00','SN')  
  end   
 --Quita caracteres raros cuando el numero ser de longitud = 1  
 if len(@numexterno) = 1  
  begin  
   set @numexterno = replace(@numexterno,'-','')  
   set @numexterno = replace(@numexterno,'#','')  
   set @numexterno = replace(@numexterno,'/','')  
   set @numexterno = replace(@numexterno,'_','')  
   set @numexterno = replace(@numexterno,',','')  
   set @numexterno = replace(@numexterno,'.','')  
   set @numexterno = replace(@numexterno,'0','SN')  
  end   
 else  
  --Si es mayor a 1, solo le quita los caracteres en la primer y ultima posicion  
  begin  
   if left(@numexterno,1) in ('_','-','#','/',',','.')  
    begin  
     set @numexterno =  substring(@numexterno,2,10)  
    end   
  
   if right(@numexterno,1) in ('_','-','#','/',',','.')  
    begin  
     set @numexterno =  substring(@numexterno,0,len(@numexterno))  
    end   
  end  
   
 --si num externo diferente SN y tiene numero, entonce le queita SN a la direccion  
 if @numexterno <> 'SN' and @numexterno like '%[0-9]%'  
 begin  
  if right(@direccion,2) = 'SN'  
  begin  
   set @direccion = replace(@direccion, ' SN', '')  
  end  
 end  
 --select @direccion  
 --Si trae numero se lo pega a la direccion  
 if len(@numexterno) > 0  
  begin  
   --Si el numero es igual al posible numero que tenga la direccion, entonces no concatena nada  
   --CUM 2020.11.24 se concatena SN  
   if right(@direccion, len(@numexterno)) <> @numexterno  
    begin  
     set @direccion = @direccion + ' ' + @numexterno;  
    end  
   else  
    begin  
     set @direccion = @direccion + ' SN';  
    end  
  end  
  
 --si la direccion completa empieza con C y solo tiene un numero, entonces le pega un SN  
 if @direccion like 'c [0-9]' or @direccion like 'c [0-9][0-9]' or @direccion like 'c [0-9][0-9][0-9]'  
  begin  
   set @direccion = @direccion + 'SN'  
  end  
  
 --si la direccion completa empieza con CALLE y solo tiene un numero, entonces le pega un SN  
 if @direccion like 'calle [0-9]' or @direccion like 'calle [0-9][0-9]' or @direccion like 'calle [0-9][0-9][0-9]'  
  begin  
   set @direccion = @direccion + 'SN'  
  end  
   
 --select @direccion  
  
 return @direccion;  
END  
  
GO