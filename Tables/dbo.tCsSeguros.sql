CREATE TABLE [dbo].[tCsSeguros] (
  [CodAseguradora] [char](2) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [NumPoliza] [varchar](20) NOT NULL,
  [fecha] [smalldatetime] NULL,
  [hora] [datetime] NULL,
  [CodProdSeguro] [int] NULL,
  [codusuarioase] [varchar](15) NULL,
  [codusuariopag] [varchar](15) NULL,
  [montoprima] [decimal](18, 2) NULL,
  [montoseguro] [decimal](18, 2) NULL,
  [estado] [char](1) NULL,
  [nombrecompleto] [varchar](200) NULL,
  [usuario] [varchar](15) NULL,
  [nombrecliente] [varchar](200) NULL,
  [InterruLab] [bit] NULL,
  [Enfermo] [bit] NULL,
  [Ocupacion] [varchar](200) NULL,
  [Direccion] [varchar](500) NULL,
  [Telefono] [varchar](50) NULL,
  [incorporado] [char](1) NULL CONSTRAINT [DF_tCsSeguros_incorporado] DEFAULT (0),
  [idace] [varchar](10) NULL,
  [error] [varchar](200) NULL,
  [Firma] [varchar](100) NULL,
  CONSTRAINT [PK_tCsSeguros] PRIMARY KEY CLUSTERED ([CodAseguradora], [CodOficina], [NumPoliza])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsSeguros]
  ON [dbo].[tCsSeguros] ([NumPoliza])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsSeguros_1]
  ON [dbo].[tCsSeguros] ([fecha])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsSeguros_3]
  ON [dbo].[tCsSeguros] ([Firma])
  ON [PRIMARY]
GO