CREATE TABLE [dbo].[tCsACAReestructurasCCE] (
  [codprestamo] [char](19) NOT NULL,
  [cliente] [varchar](200) NULL,
  [fechadesembolso] [smalldatetime] NULL,
  [fechareprog] [datetime] NULL,
  [fechavencimiento] [smalldatetime] NULL,
  [fechavencimiento_anterior] [smalldatetime] NULL,
  [tasaint] [money] NULL,
  [monto_capitalizar] [money] NULL,
  [pago_intencion] [money] NULL,
  [monto_condonado] [money] NULL,
  [monto_diferido] [money] NULL,
  [cuotas] [smallint] NULL,
  [cuotas_anterior] [smallint] NULL,
  [codtipoplaz] [char](1) NULL,
  [usuario_autoriza] [varchar](200) NULL,
  [codoficina] [varchar](4) NULL,
  [sucursal] [varchar](200) NULL,
  [region] [varchar](100) NULL,
  [conpagosostenido] [tinyint] NULL,
  [fechapagosostenido] [smalldatetime] NULL,
  [nropagosacum] [tinyint] NULL,
  [tipocredito] [varchar](10) NULL,
  [actividad] [varchar](200) NULL
)
ON [PRIMARY]
GO