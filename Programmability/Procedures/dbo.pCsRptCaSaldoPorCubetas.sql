SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsRptCaSaldoPorCubetas] (
    @Fecha    SmallDateTime,
    @CodRegional varchar(4)  = '0',
    @CodOficina  varchar(4)  = '0',
    @CodAsesor   varchar(15) = '0',
    @Grupo1      varchar(25) = 'Re',  -- Solo se usa para Crystal reports. Aqui no tiene efecto
    @Grupo2      varchar(25) = 'Pr',   -- Solo se usa para Crystal reports. Aqui no tiene efecto
    @Tipo        char(1)     = 'R'    -- R=Lider Regional, S=Lider Sucursal, P=Promotor
)
As
set nocount on

--set @codregional = 'Z01'
--set @CodOficina = '5'
--set @CodAsesor = 'IRV2812871'

--declare @fecha as datetime
--set @fecha = '20150517'

declare @Tabla table (
    CodProducto    varchar(10),
    Producto       varchar(100),
    CodOficina     varchar(10),
    Sucursal       varchar(100),
    Zona           varchar(10),
    Regional       varchar(100),
    CodAsesor      varchar(15),
    Asesor         varchar(100),
    Estado         char(1),
    NroClie        smallint,
    NroPtmo        smallint,
    MontoDesembolso money,
    t_saldo        Money,
    D0nroclie      smallint,
    D0nroptmo      smallint,
    D0saldo        Money,
    D0a7nroclie    smallint,
    D0a7nroptmo    smallint,
    D0a7saldo      Money,
    D8a15nroclie   smallint,
    D8a15nroptmo   smallint,
    D8a15saldo     Money,
    D16a30nroclie  smallint,
    D16a30nroptmo  smallint,
    D16a30saldo    Money,                   
    D1a30nroclie   smallint,
    D1a30nroptmo   smallint,
    D1a30saldo     Money,
    D31a60nroclie  smallint,
    D31a60nroptmo  smallint,
    D31a60saldo    Money,
    D61a89nroclie  smallint,
    D61a89nroptmo  smallint,
    D61a89saldo    Money,
    Dm90nroclie    smallint,
    Dm90nroptmo    smallint,
    Dm90saldo      Money,
    Dm1nroclie     smallint,
    Dm1nroptmo     smallint,
    Dm1saldo       Money
)

insert into @Tabla
select PC.CodProducto, Producto = PC.Nombreprod,  
       O.CodOficina  , Sucursal = dbo.proper(O.NomOficina), 
       Z.Zona        , Regional = Z.Nombre,
       A.CodAsesor   , Asesor   = dbo.proper(U.nombreCompleto),
       E.Estado,
       NroClie         = count(distinct A.codusuario),
       NroPtmo         = count(distinct A.codprestamo),
       MontoDesembolso,
       --MontoDesembolso = sum(montodesembolso),
       t_saldo         = sum(t_saldo),
       D0nroclie       = count(distinct D0nroclie),
       D0nroptmo       = count(distinct D0nroptmo),
       D0saldo         = sum(D0saldo),
       D0a7nroclie     = count(distinct D0a7nroclie),
       D0a7nroptmo     = count(distinct D0a7nroptmo),
       D0a7saldo       = sum(D0a7saldo),
       D8a15nroclie    = count(distinct D8a15nroclie),
       D8a15nroptmo    = count(distinct D8a15nroptmo),
       D8a15saldo      = sum(D8a15saldo),
       D16a30nroclie   = count(distinct D16a30nroclie),
       D16a30nroptmo   = count(distinct D16a30nroptmo),
       D16a30saldo     = sum(D16a30saldo),
       D1a30nroclie    = count(distinct D1a30nroclie),
       D1a30nroptmo    = count(distinct D1a30nroptmo),
       D1a30saldo      = sum(D1a30saldo),
       D31a60nroclie   = count(distinct D31a60nroclie),
       D31a60nroptmo   = count(distinct D31a60nroptmo),
       D31a60saldo     = sum(D31a60saldo),
       D61a89nroclie   = count(distinct D61a89nroclie),
       D61a89nroptmo   = count(distinct D61a89nroptmo),
       D61a89saldo     = sum(D61a89saldo),
       Dm90nroclie     = count(distinct Dm90nroclie),
       Dm90nroptmo     = count(distinct Dm90nroptmo),
       Dm90saldo       = sum(Dm90saldo),
       Dm1nroclie      = count(distinct Dm1nroclie),
       Dm1nroptmo      = count(distinct Dm1nroptmo),
       Dm1saldo        = sum(Dm1saldo)
from (
  SELECT c.codproducto, cd.codusuario, c.CodPrestamo, C.CodAsesor, C.CodOficina
      ,cd.saldocapital + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido t_saldo
      --,cd.sreservacapital + cd.sreservainteres MontoDesembolso
      ,C.MontoDesembolso
      ,case when c.Estado <> 'VENCIDO'
            then case when c.NroDiasAtraso = 0 then cd.codusuario else null end
            else null end D0nroclie
      ,case when c.Estado <>'VENCIDO' then
        case when c.NroDiasAtraso = 0 then cd.codprestamo else null end
       else null end D0nroptmo
      ,case when c.Estado <>'VENCIDO' then
        case when c.NroDiasAtraso = 0
        then cd.saldocapital + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido
        else 0 end
       else 0 end D0saldo
       
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso > 0 and c.NroDiasAtraso<8 then cd.codusuario else null end
       else null end D0a7nroclie
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso > 0 and c.NroDiasAtraso<8 then cd.codprestamo else null end
       else null end D0a7nroptmo
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso > 0 and c.NroDiasAtraso<8
        then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
        else 0 end 
       else 0 end D0a7saldo
       
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<16 then cd.codusuario else null end
       else null end D8a15nroclie
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<16 then cd.codprestamo else null end
       else null end D8a15nroptmo
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=8 and c.NroDiasAtraso<16
        then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
        else 0 end
       else 0 end D8a15saldo
       
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<31 then cd.codusuario else null end
       else null end D16a30nroclie
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<31 then cd.codprestamo else null end
       else null end D16a30nroptmo
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=16 and c.NroDiasAtraso<31
        then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
        else 0 end
       else 0 end D16a30saldo
       
      ,case when c.Estado <> 'VENCIDO' then
        case when c.NroDiasAtraso between 1 and 30 then cd.codusuario else null end
       else null end D1a30nroclie
      ,case when c.Estado <> 'VENCIDO' then
        case when c.NroDiasAtraso between 1 and 30 then cd.codprestamo else null end
       else null end D1a30nroptmo
      ,case when c.Estado <> 'VENCIDO' then
        case when c.NroDiasAtraso between 1 and 30
        then cd.saldocapital + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido
        else 0 end
       else 0 end D1a30saldo
       
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<61 then cd.codusuario else null end
       else null end D31a60nroclie
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<61 then cd.codprestamo else null end
       else null end D31a60nroptmo
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=31 and c.NroDiasAtraso<61
        then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
        else 0 end
       else 0 end D31a60saldo
       
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90 then cd.codusuario else null end
       else null end D61a89nroclie
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90 then cd.codprestamo else null end
       else null end D61a89nroptmo
      ,case when c.Estado<>'VENCIDO' then
        case when c.NroDiasAtraso>=61 and c.NroDiasAtraso<90
        then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
        else 0 end 
       else 0 end D61a89saldo
       
      ,case when c.Estado = 'VENCIDO' then cd.codusuario else null end Dm90nroclie
      ,case when c.Estado = 'VENCIDO' then cd.codprestamo else null end Dm90nroptmo
      ,case when c.Estado = 'VENCIDO' then cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido
       else 0 end Dm90saldo
       
      , Dm1nroclie = case when c.NroDiasAtraso >= 1 then cd.codusuario  else null end
      , Dm1nroptmo = case when c.NroDiasAtraso >= 1 then cd.codprestamo else null end
      , Dm1saldo   = case when c.NroDiasAtraso >= 1 then cd.saldocapital + cd.interesvigente + cd.interesvencido + cd.moratoriovigente + cd.moratoriovencido else 0 end 
  FROM tCsCartera C with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
  where C.cartera = 'ACTIVA' and C.fecha = @fecha
) A
inner join tCsPadronClientes U on A.CodAsesor = U.CodUsuario
inner JOIN tClOficinas       O ON A.CodOficina = O.CodOficina 
inner JOIN tClZona           Z ON Z.Zona = O.Zona 
left  join tcspadroncarteraotroprod op on op.codprestamo = A.codprestamo
inner join tcaproducto      pc on pc.codproducto = isnull(op.codproducto,A.codproducto)
left  join tCsEmpleados      E on A.CodAsesor = E.CodUsuario
where (@CodRegional = '0' or (@CodRegional <> '0' and O.Zona       = @CodRegional))
and   (@CodOficina  = '0' or (@CodOficina  <> '0' and O.CodOficina = @CodOficina))
and   (@CodAsesor   = '0' or (@CodAsesor   <> '0' and A.CodAsesor  = @CodAsesor))
group by PC.codproducto, PC.Nombreprod, CodAsesor, U.nombreCompleto, O.CodOficina, O.NomOficina, Z.Zona, Z.Nombre, MontoDesembolso, E.Estado

-- Lider Regional ---------------------------------------------------------------------------------------------------------------------
if @Tipo = 'R'
    select Banda = 'Detalle ' + Regional, * from @tabla 
    union all
    select Banda = 'Resumen Sucursales', CodOficina, Sucursal, Zona, Regional, Zona, Regional, CodAsesor = '', Asesor = '', Estado = '1',
                 NroClie = sum(      NroClie),       NroPtmo = sum(      NroPtmo), MontoDesembolso = sum(MontoDesembolso), t_saldo = sum(t_saldo),
               D0nroclie = sum(    D0nroclie),     D0nroptmo = sum(    D0nroptmo),     D0saldo = sum(    D0saldo),
             D0a7nroclie = sum(  D0a7nroclie),   D0a7nroptmo = sum(  D0a7nroptmo),   D0a7saldo = sum(  D0a7saldo),
            D8a15nroclie = sum( D8a15nroclie),  D8a15nroptmo = sum( D8a15nroptmo),  D8a15saldo = sum( D8a15saldo),
           D16a30nroclie = sum(D16a30nroclie), D16a30nroptmo = sum(D16a30nroptmo), D16a30saldo = sum(D16a30saldo),
            D1a30nroclie = sum( D1a30nroclie),  D1a30nroptmo = sum( D1a30nroptmo),  D1a30saldo = sum( D1a30saldo),
           D31a60nroclie = sum(D31a60nroclie), D31a60nroptmo = sum(D31a60nroptmo), D31a60saldo = sum(D31a60saldo),
           D61a89nroclie = sum(D61a89nroclie), D61a89nroptmo = sum(D61a89nroptmo), D61a89saldo = sum(D61a89saldo),
             Dm90nroclie = sum(  Dm90nroclie),   Dm90nroptmo = sum(  Dm90nroptmo),   Dm90saldo = sum(  Dm90saldo),
              Dm1nroclie = sum(   Dm1nroclie),    Dm1nroptmo = sum(   Dm1nroptmo),    Dm1saldo = sum(   Dm1saldo)
    from @tabla 
    group by CodOficina, Sucursal, Zona, Regional
    union all
                                      --CodProducto, Producto, CodOficina, Sucursal, Zona, Regional, CodAsesor, Asesor,
    select Banda = 'Resumen Productos', CodProducto, Producto, Zona, Regional, Zona, Regional, CodAsesor = '', Asesor = '', Estado = '1',
                 NroClie = sum(      NroClie),       NroPtmo = sum(      NroPtmo), MontoDesembolso = sum(MontoDesembolso), t_saldo = sum(t_saldo),
               D0nroclie = sum(    D0nroclie),     D0nroptmo = sum(    D0nroptmo),     D0saldo = sum(    D0saldo),
             D0a7nroclie = sum(  D0a7nroclie),   D0a7nroptmo = sum(  D0a7nroptmo),   D0a7saldo = sum(  D0a7saldo),
            D8a15nroclie = sum( D8a15nroclie),  D8a15nroptmo = sum( D8a15nroptmo),  D8a15saldo = sum( D8a15saldo),
           D16a30nroclie = sum(D16a30nroclie), D16a30nroptmo = sum(D16a30nroptmo), D16a30saldo = sum(D16a30saldo),
            D1a30nroclie = sum( D1a30nroclie),  D1a30nroptmo = sum( D1a30nroptmo),  D1a30saldo = sum( D1a30saldo),
           D31a60nroclie = sum(D31a60nroclie), D31a60nroptmo = sum(D31a60nroptmo), D31a60saldo = sum(D31a60saldo),
           D61a89nroclie = sum(D61a89nroclie), D61a89nroptmo = sum(D61a89nroptmo), D61a89saldo = sum(D61a89saldo),
             Dm90nroclie = sum(  Dm90nroclie),   Dm90nroptmo = sum(  Dm90nroptmo),   Dm90saldo = sum(  Dm90saldo),
              Dm1nroclie = sum(   Dm1nroclie),    Dm1nroptmo = sum(   Dm1nroptmo),    Dm1saldo = sum(   Dm1saldo)
    from @tabla 
    group by CodProducto, Producto, Zona, Regional

-- Lider Sucursal ---------------------------------------------------------------------------------------------------------------------
if @Tipo = 'S'
    select Banda = 'Detalle ' + Sucursal, * from @tabla 
    union all
                                       --CodProducto, Producto, CodOficina, Sucursal, Zona, Regional, CodAsesor, Asesor,
    select Banda = 'Resumen Promotores', CodAsesor, Asesor, CodOficina, Sucursal, Zona, Regional, CodOficina, Sucursal, Estado, 
                 NroClie = sum(      NroClie),       NroPtmo = sum(      NroPtmo), MontoDesembolso = sum(MontoDesembolso), t_saldo = sum(t_saldo),
               D0nroclie = sum(    D0nroclie),     D0nroptmo = sum(    D0nroptmo),     D0saldo = sum(    D0saldo),
             D0a7nroclie = sum(  D0a7nroclie),   D0a7nroptmo = sum(  D0a7nroptmo),   D0a7saldo = sum(  D0a7saldo),
            D8a15nroclie = sum( D8a15nroclie),  D8a15nroptmo = sum( D8a15nroptmo),  D8a15saldo = sum( D8a15saldo),
           D16a30nroclie = sum(D16a30nroclie), D16a30nroptmo = sum(D16a30nroptmo), D16a30saldo = sum(D16a30saldo),
            D1a30nroclie = sum( D1a30nroclie),  D1a30nroptmo = sum( D1a30nroptmo),  D1a30saldo = sum( D1a30saldo),
           D31a60nroclie = sum(D31a60nroclie), D31a60nroptmo = sum(D31a60nroptmo), D31a60saldo = sum(D31a60saldo),
           D61a89nroclie = sum(D61a89nroclie), D61a89nroptmo = sum(D61a89nroptmo), D61a89saldo = sum(D61a89saldo),
             Dm90nroclie = sum(  Dm90nroclie),   Dm90nroptmo = sum(  Dm90nroptmo),   Dm90saldo = sum(  Dm90saldo),
              Dm1nroclie = sum(   Dm1nroclie),    Dm1nroptmo = sum(   Dm1nroptmo),    Dm1saldo = sum(   Dm1saldo)
    from @tabla 
    group by CodOficina, Sucursal, Zona, Regional, CodAsesor, Asesor, Estado
    union all
                                      --CodProducto, Producto, CodOficina, Sucursal, Zona, Regional, CodAsesor, Asesor,
    select Banda = 'Resumen Productos', CodProducto, Producto, CodOficina, Sucursal, Zona, Regional, CodOficina, Sucursal, Estado = '1',
                 NroClie = sum(      NroClie),       NroPtmo = sum(      NroPtmo), MontoDesembolso = sum(MontoDesembolso), t_saldo = sum(t_saldo),
               D0nroclie = sum(    D0nroclie),     D0nroptmo = sum(    D0nroptmo),     D0saldo = sum(    D0saldo),
             D0a7nroclie = sum(  D0a7nroclie),   D0a7nroptmo = sum(  D0a7nroptmo),   D0a7saldo = sum(  D0a7saldo),
            D8a15nroclie = sum( D8a15nroclie),  D8a15nroptmo = sum( D8a15nroptmo),  D8a15saldo = sum( D8a15saldo),
           D16a30nroclie = sum(D16a30nroclie), D16a30nroptmo = sum(D16a30nroptmo), D16a30saldo = sum(D16a30saldo),
            D1a30nroclie = sum( D1a30nroclie),  D1a30nroptmo = sum( D1a30nroptmo),  D1a30saldo = sum( D1a30saldo),
           D31a60nroclie = sum(D31a60nroclie), D31a60nroptmo = sum(D31a60nroptmo), D31a60saldo = sum(D31a60saldo),
           D61a89nroclie = sum(D61a89nroclie), D61a89nroptmo = sum(D61a89nroptmo), D61a89saldo = sum(D61a89saldo),
             Dm90nroclie = sum(  Dm90nroclie),   Dm90nroptmo = sum(  Dm90nroptmo),   Dm90saldo = sum(  Dm90saldo),
              Dm1nroclie = sum(   Dm1nroclie),    Dm1nroptmo = sum(   Dm1nroptmo),    Dm1saldo = sum(   Dm1saldo)
    from @tabla 
    group by CodProducto, Producto, Zona, Regional,CodOficina, Sucursal

-- Promotor ---------------------------------------------------------------------------------------------------------------------
if @Tipo = 'P'
    select Banda = 'Detalle ' + Asesor, * from @tabla

GO