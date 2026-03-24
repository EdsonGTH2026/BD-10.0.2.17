CREATE TABLE [dbo].[tCsCHEncuestados] (
  [CodUsuario] [varchar](15) NOT NULL,
  [Codigo] [int] NOT NULL,
  [NroEncuesta] [int] NOT NULL,
  [FechaMod] [smalldatetime] NULL,
  [HoraMod] [datetime] NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Hora] [datetime] NULL,
  [Estado] [bit] NULL,
  [Usuario] [varchar](50) NULL,
  CONSTRAINT [PK_tCsCHEncuestados] PRIMARY KEY CLUSTERED ([CodUsuario], [Codigo], [NroEncuesta])
)
ON [PRIMARY]
GO