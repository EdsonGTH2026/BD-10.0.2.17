CREATE TABLE [dbo].[tSgRegAtencionDet] (
  [NroReporte] [int] NOT NULL,
  [idArea] [int] NOT NULL,
  [Itera] [int] NOT NULL,
  [Usuario] [varchar](20) NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Hora] [datetime] NOT NULL,
  [CodUsuarioCall] [varchar](20) NULL,
  [NombreCompleto] [varchar](100) NULL,
  [Solucion] [varchar](300) NULL,
  [UsuarioRegistro] [bit] NULL,
  CONSTRAINT [PK_tSgRegAtencionDet] PRIMARY KEY CLUSTERED ([NroReporte], [idArea], [Itera])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tSgRegAtencionDet] WITH NOCHECK
  ADD CONSTRAINT [FK_tSgRegAtencionDet_tSgRegAtencion] FOREIGN KEY ([NroReporte], [idArea]) REFERENCES [dbo].[tSgRegAtencion] ([NroReporte], [idarea]) ON DELETE CASCADE ON UPDATE CASCADE
GO