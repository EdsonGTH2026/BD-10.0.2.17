CREATE TABLE [dbo].[tClImpuestosDetalle] (
  [CodOficina] [varchar](4) NOT NULL,
  [CodImpuesto] [varchar](8) NOT NULL,
  [CodMoneda] [varchar](2) NOT NULL,
  [Porcentaje] [smallmoney] NOT NULL,
  [FechaDesde] [smalldatetime] NULL,
  [FechaHasta] [smalldatetime] NOT NULL,
  [PorcInstitucion] [smallmoney] NOT NULL,
  [PorcCliente] [smallmoney] NOT NULL,
  [Activo] [bit] NOT NULL,
  [Orden] [smallint] NULL
)
ON [PRIMARY]
GO