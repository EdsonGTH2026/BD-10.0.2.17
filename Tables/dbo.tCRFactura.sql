CREATE TABLE [dbo].[tCRFactura] (
  [Registro] [smalldatetime] NOT NULL,
  [Inicio] [smalldatetime] NOT NULL,
  [Fin] [smalldatetime] NOT NULL,
  [Consulta] [smalldatetime] NULL,
  [Folio] [varchar](9) NOT NULL,
  [Medio] [varchar](27) NULL,
  [Paterno] [varchar](50) NULL,
  [Materno] [varchar](50) NULL,
  [Nombre] [varchar](50) NULL,
  [Servicio] [char](4) NULL,
  [Pago] [char](1) NULL,
  [Monto] [smallmoney] NULL,
  [Usuario] [varchar](20) NULL,
  [ClienteP] [varchar](15) NULL,
  [CodOficina] [varchar](4) NULL,
  CONSTRAINT [PK_tCRFactura] PRIMARY KEY CLUSTERED ([Inicio], [Fin], [Folio])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCRFactura]
  ON [dbo].[tCRFactura] ([Consulta])
  ON [PRIMARY]
GO