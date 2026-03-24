CREATE TABLE [dbo].[tCsUsuariosRH] (
  [Codigo] [varchar](25) NULL,
  [CodOficina] [varchar](4) NULL,
  [TablaOrigen] [varchar](50) NULL,
  [CodUsuario] [varchar](20) NULL,
  [Fecha] [smalldatetime] NULL,
  [FechaLarga] [datetime] NULL,
  [Tipo1] [varchar](5) NULL,
  [Tipo2] [varchar](5) NULL,
  [Tipo3] [varchar](5) NULL,
  [Tipo4] [varchar](5) NULL,
  [Tipo5] [varchar](5) NULL,
  [Tipo6] [varchar](5) NULL,
  [Tipo7] [varchar](5) NULL,
  [Tipo8] [varchar](5) NULL,
  [Entero1] [int] NULL,
  [Entero2] [int] NULL,
  [Entero3] [int] NULL,
  [Entero4] [int] NULL,
  [Bit1] [bit] NULL,
  [Bit2] [bit] NULL,
  [Bit3] [bit] NULL,
  [Varchar1] [varchar](200) NULL,
  [Varchar2] [varchar](200) NULL,
  [Varchar3] [varchar](200) NULL,
  [Varchar4] [varchar](200) NULL,
  [Varchar5] [varchar](200) NULL,
  [Varchar6] [varchar](200) NULL,
  [Decimal1] [decimal](19, 4) NULL,
  [Decimal2] [decimal](19, 4) NULL,
  [Decimal3] [decimal](19, 4) NULL,
  [Decimal4] [decimal](19, 4) NULL,
  [Decimal5] [decimal](19, 4) NULL
)
ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [IX_tCsUsuariosRH_FechaTablaOrigenCodOficinaCodUsuarioCodigo]
  ON [dbo].[tCsUsuariosRH] ([Fecha], [TablaOrigen], [CodOficina], [CodUsuario], [Codigo])
  ON [PRIMARY]
GO