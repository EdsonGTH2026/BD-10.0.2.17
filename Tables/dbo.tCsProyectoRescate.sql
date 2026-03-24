CREATE TABLE [dbo].[tCsProyectoRescate] (
  [CodOficina] [varchar](4) NOT NULL,
  [Inicio] [smalldatetime] NOT NULL,
  [Fin] [smalldatetime] NOT NULL,
  [Rubro] [varchar](100) NOT NULL,
  [Corte] [smalldatetime] NULL,
  [DAI] [int] NULL,
  [DAF] [int] NULL,
  [Cartera] [varchar](50) NULL,
  [CondonacionInteres] [varchar](50) NULL,
  [CondonacionOtros] [varchar](50) NULL,
  [ObjetivoDias] [int] NULL,
  [PorcComisionSinIVA] [decimal](18, 4) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsProyectoRescate] PRIMARY KEY CLUSTERED ([CodOficina], [Inicio], [Fin], [Rubro])
)
ON [PRIMARY]
GO