SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop function fCsDateDiff
CREATE FUNCTION [dbo].[fCsDateDiff]
(
  @type char(2),
        @FromDate DATETIME,
        @ToDate DATETIME
)
RETURNS INT
BEGIN
        RETURN  
     CASE
               WHEN @FromDate > @ToDate THEN NULL --Filtra fecha invertida
   ELSE


       Case
        When upper(@type) not in ('YY','MM','DD') THEN NULL    
        WHEN upper(@type)='YY' THEN       --AÑO
        CASE 
           WHEN DATEPART(day, @FromDate) > DATEPART(day, @ToDate) THEN DATEDIFF(month, @FromDate, @ToDate) - 1
           ELSE DATEDIFF(month, @FromDate, @ToDate)
        END / 12
        WHEN upper(@type)='MM' THEN       --MES
        CASE     
          WHEN DATEPART(day, @FromDate) > DATEPART(day, @ToDate) THEN DATEDIFF(month, @FromDate, @ToDate) - 1
          ELSE DATEDIFF(month, @FromDate, @ToDate)
        END
        WHEN upper(@type)='DD' THEN       --MES
        CASE     
          WHEN convert(nvarchar,@FromDate,108) > convert(nvarchar,@ToDate,108)  THEN DATEDIFF(dd, @FromDate, @ToDate) - 1
          ELSE DATEDIFF(dd, @FromDate, @ToDate)
       END
      end


   END
END
GO