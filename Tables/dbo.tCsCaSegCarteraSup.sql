CREATE TABLE [dbo].[tCsCaSegCarteraSup] (
  [CodUsuario] [char](15) NOT NULL,
  [TipoSeguimiento] [char](1) NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Hora] [datetime] NOT NULL,
  [FechaSup] [smalldatetime] NOT NULL,
  [HoraSup] [datetime] NOT NULL,
  [CodUsuarioSup] [char](15) NULL,
  [ObsSupervision] [text] NULL,
  [Consulta] [text] NULL,
  [Revisada] [char](1) NULL CONSTRAINT [DF_tCsCaSegCarteraSup_Revisada] DEFAULT (0),
  CONSTRAINT [PK_tCsCaSegCarteraSup] PRIMARY KEY CLUSTERED ([CodUsuario], [TipoSeguimiento], [Fecha], [Hora], [FechaSup], [HoraSup])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsCaSegCarteraSup] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsCaSegCarteraSup_tCsCaSegCartera] FOREIGN KEY ([CodUsuario], [TipoSeguimiento], [Fecha], [Hora]) REFERENCES [dbo].[tCsCaSegCartera] ([CodUsuario], [TipoSeguimiento], [Fecha], [Hora]) ON DELETE CASCADE ON UPDATE CASCADE
GO