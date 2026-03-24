CREATE TABLE [dbo].[tCaClEstados] (
  [CodEstado] [varchar](10) NOT NULL,
  [SiguienteEstado] [varchar](10) NULL,
  [DiasEstado] [smallint] NULL,
  [AceptaPago] [bit] NOT NULL,
  [Procesa] [bit] NOT NULL,
  [OrdEstado] [tinyint] NOT NULL,
  [MontoEstado] [money] NOT NULL,
  [MinAtraso] [int] NULL,
  [MaxAtraso] [int] NULL,
  CONSTRAINT [PK_tCaClEstados] PRIMARY KEY CLUSTERED ([CodEstado])
)
ON [PRIMARY]
GO