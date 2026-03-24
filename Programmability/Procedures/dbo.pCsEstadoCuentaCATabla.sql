SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*  
Exec pCsEstadoCuentaCATabla 2, '5370330032000004', '20111031', 'Ninguno'  
Exec pCsEstadoCuentaCATabla 3, '5370330032000004', '20111031', 'Ninguno'  
drop proc pCsEstadoCuentaCATabla
*/  
CREATE Procedure [dbo].[pCsEstadoCuentaCATabla]  
 @Dato   Int,  
 @CodPrestamo  Varchar(25),  
 @Corte   SmallDateTime,  
 @Motivo   Varchar(100)  
As  
  
Declare @Sistema  Varchar(2)  
  
If Len(@CodPrestamo) = 19  
Begin  
 Set @Sistema = 'CA'  
End  
If Len(@CodPrestamo) > 19  
Begin  
 Set @Sistema = 'AH'  
End  
If Len(@CodPrestamo) < 19  
Begin  
 Set @Sistema = 'TA'  
End  
  
If @Dato In (1)  
Begin  
 SELECT     Estado, SUM(Cuotas) AS Cuotas, SUM(Devengado) AS Devengado, SUM(Pagado) AS Pagado, SUM(Saldo) AS Saldo  
 FROM         (SELECT     Estado, COUNT(*) AS Cuotas, SUM(Devengado) AS Devengado, SUM(Pago) AS Pagado, SUM(Devengado) - SUM(Pago) AS Saldo  
         FROM          (SELECT     CodPrestamo, SecCuota, Devengado, Pago, FechaVencimiento, Corte,   
                    CASE WHEN Pago >= Devengado THEN '1PAGADO'   
                    WHEN Corte >= FechaInicio And Corte <= FechaVencimiento Then '3VIGENTE'  
                    WHEN FechaVencimiento > Corte THEN '4PENDIENTE' WHEN DateDiff(Day,   
                    FechaVencimiento, Corte) > 0 THEN '2ATRASADO' END AS Estado  
               FROM          (SELECT     Corte, CodPrestamo, SecCuota, SUM(Devengado) AS Devengado, SUM(Pago) AS Pago, FechaInicio, FechaVencimiento  
                 FROM         tCsEstadoCuentaCronograma  
                 Where CodPrestamo = @CodPrestamo and Corte = @Corte  
                 GROUP BY CodPrestamo, SecCuota, FechaInicio, FechaVencimiento, Corte) AS Datos)   
              AS Datos  
         GROUP BY Estado  
         UNION  
         SELECT     '1PAGADO' AS Estado, 0 AS Cuotas, 0 AS Devengado, 0 AS Pagado, 0 AS Saldo  
         UNION  
         SELECT     '2ATRASADO' AS Estado, 0 AS Cuotas, 0 AS Devengado, 0 AS Pagado, 0 AS Saldo  
         UNION  
         SELECT     '3VIGENTE' AS Estado, 0 AS Cuotas, 0 AS Devengado, 0 AS Pagado, 0 AS Saldo  
         UNION  
         SELECT     '4PENDIENTE' AS Estado, 0 AS Cuotas, 0 AS Devengado, 0 AS Pagado, 0 AS Saldo) AS Datos  
 GROUP BY Estado  
End  
If @Dato In (2,3)   
Begin  
 Create Table #A  
 (  
  Concepto  Varchar(100) Null,  
  ConceptoFinal Varchar(100) Null,  
  MontoReal  Decimal(18,4) Null,  
  Monto   Decimal(18,4) Null,  
  Orden   Decimal(10,0) Null  
 )  
 If @Sistema in ('AH')  
 Begin  
  Insert Into #A  
  SELECT     Concepto, CASE WHEN SUM(Monto) < 0 THEN '(-) ' WHEN SUM(Monto) > 0 THEN '(+) ' ELSE '   ' END + Concepto AS ConceptoFinal, SUM(Monto) AS MontoReal,   
         ABS(SUM(Monto)) AS Monto, MAX(Orden) AS Orden  
  FROM         (SELECT     Replace(Replace(SUBSTRING(Concepto, 1, CHARINDEX('en Oficina', Concepto, 1) - 2) + CASE WHEN RIGHT(SubString(Concepto, 1, CharIndex('en Oficina', ConCepto, 1) - 2), 1)   
               IN ('a', 'e', 'i', 'o', 'u') THEN 's' ELSE '' END, 'Credito', 'Abono'), 'Debito', 'Cargo') AS Concepto, Cargo + Abono * - 1 AS Monto, Orden  
          FROM          tCsEstadoCuentaMO  
          WHERE      (Cuenta = @CodPrestamo) AND (Fecha >= Cast(dbo.fduFechaATexto(@Corte, 'AAAAMM')+ '01' As SmallDateTime)) AND (Fecha <= @Corte)  
      UNION  
      --SELECT Concepto = 'Abonos', Monto = 0, Orden = 2  
      --UNION  
      --SELECT Concepto = 'Cargos', Monto = 0, Orden = 3  
      --UNION  
      SELECT Concepto = 'Depositos', Monto = 0, Orden = 1  
      UNION  
      SELECT Concepto = 'Impuesto Sobre la Renta ISR', Monto = 0, Orden = 999999  
      UNION  
      SELECT Concepto = 'Retiros', Monto = 0, Orden = 3  
      UNION  
      SELECT Concepto = 'Capitalizacion de intereses', Monto = 0, Orden = 99999  
      --UNION  
      --SELECT Concepto = 'Mantenimiento de cuentas', Monto = 0, Orden = 99999999  
          ) AS Datos  
  GROUP BY Concepto  
 End  
 If @Sistema In ('TA')  
 Begin  
  Insert Into #A  
  SELECT     Concepto, CASE WHEN SUM(Monto) < 0 THEN '(-) ' WHEN SUM(Monto) > 0 THEN '(+) ' ELSE '   ' END + Concepto AS ConceptoFinal, SUM(Monto) AS MontoReal,   
         ABS(SUM(Monto)) AS Monto, MAX(Orden) AS Orden  
  FROM         (SELECT     tTaTipoMovimientos.EstadoCuenta AS Concepto, tCsEstadoCuentaMO.Cargo + tCsEstadoCuentaMO.Abono * - 1 AS Monto, tCsEstadoCuentaMO.Orden  
      FROM         tCsEstadoCuentaMO LEFT OUTER JOIN  
             tTaTipoMovimientos ON REPLACE(REPLACE(SUBSTRING(tCsEstadoCuentaMO.Concepto, 1, CHARINDEX('Oper. Nro.', tCsEstadoCuentaMO.Concepto, 1) - 2)   
             + CASE WHEN RIGHT(SubString(Concepto, 1, CharIndex('Oper. Nro.', ConCepto, 1) - 2), 1) IN ('a', 'e', 'i', 'o', 'u') THEN 's' ELSE '' END, ' en Establecimiento Externo.',   
             ''), ' en Finamigo.', '') = tTaTipoMovimientos.Descripcion  
      WHERE     (tCsEstadoCuentaMO.Cuenta = @CodPrestamo) AND (tCsEstadoCuentaMO.Fecha >= CAST(dbo.fduFechaATexto('20111001', 'AAAAMM') + '01' AS SmallDateTime))   
           AND (tCsEstadoCuentaMO.Fecha <= '20111031')  
      UNION  
      SELECT     EstadoCuenta, 0 AS Monto, Orden  
      FROM       tTaTipoMovimientos  
          ) AS Datos  
  GROUP BY Concepto  
 End  
 If @Dato = 3  
 Begin  
  Insert Into #A  
  Select Concepto, ConceptoFinal, Sum(MontoReal) as MontoReal, Sum(Monto) as Monto, Orden = 0  
  From  
  (   
   SELECT     'Saldo Inicial' AS Concepto, 'Saldo Inicial' AS ConceptoFinal, SUM(Devengado - Pago) AS MontoReal, SUM(Devengado - Pago) AS Monto, 0 AS Orden  
   FROM         tCsEstadoCuentaCronograma  
   WHERE     (Corte = CAST(dbo.fduFechaATexto(@Corte, 'AAAAMM') + '01' AS SmallDateTime) - 1) AND (CodPrestamo = @CodPrestamo)  
   UNION  
   SELECT     'Saldo Inicial' AS Concepto, 'Saldo Inicial' AS ConceptoFinal, 0 AS MontoReal, 0 AS Monto, 0 AS Orden    
  ) Datos  
  Group by Concepto, ConceptoFinal  
    
  Insert Into #A  
  Select Concepto, ConceptoFinal, Sum(MontoReal) as MontoReal, Sum(Monto) as Monto, Orden = 99999999  
  From  
  (   
   SELECT     'Saldo Final' AS Concepto, 'Saldo Final' AS ConceptoFinal, SUM(Devengado - Pago) AS MontoReal, SUM(Devengado - Pago) AS Monto, 0 AS Orden  
   FROM         tCsEstadoCuentaCronograma  
   Where Corte = @Corte and CodPrestamo = @CodPrestamo  
   UNION  
   SELECT     'Saldo Final' AS Concepto, 'Saldo Final' AS ConceptoFinal, 0 AS MontoReal, 0 AS Monto, 0 AS Orden    
  ) Datos  
  Group by Concepto, ConceptoFinal    
 End  
 Select * From #A  
 --union all
 --select 'Comisión Seguro', '   Comisión Seguro', 0,0,8000000
 Drop Table #A  
End
GO