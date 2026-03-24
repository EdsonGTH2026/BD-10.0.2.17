CREATE TABLE [dbo].[tAhProductos] (
  [idProducto] [int] NOT NULL,
  [idTipoProd] [smallint] NULL,
  [Nombre] [varchar](100) NULL,
  [Abreviatura] [varchar](50) NULL,
  [Descripcion] [varchar](150) NULL,
  [idEstado] [char](2) NULL,
  [Certificado] [bit] NULL,
  [Constancia] [bit] NULL,
  [TiempoInactiva] [smallint] NULL,
  [FechaCreacion] [smalldatetime] NULL,
  [RTitulo] [varchar](100) NULL,
  [RComentario] [varchar](500) NULL,
  [RECA] [varchar](50) NULL,
  [Disposicion] [varchar](1000) NULL,
  [AlternativaUso] [varchar](50) NULL,
  [SaldoMinimo] [varchar](50) NULL,
  CONSTRAINT [PK_tAhProductos] PRIMARY KEY CLUSTERED ([idProducto])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tAhProductos]
  ON [dbo].[tAhProductos] ([idTipoProd])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tAhProductos_1]
  ON [dbo].[tAhProductos] ([idProducto], [idTipoProd])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tAhProductos_2]
  ON [dbo].[tAhProductos] ([Abreviatura])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tAhProductos] TO [public]
GO