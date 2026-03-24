CREATE TABLE [dbo].[tAhClTipoInteres] (
  [CodTipoInteres] [smallint] NOT NULL,
  [Descripcion] [varchar](50) NULL,
  [Estado] [varchar](2) NULL,
  [idTipoProd] [smallint] NULL,
  [NroDias] [int] NULL,
  CONSTRAINT [PK_tAhClTipoInteres] PRIMARY KEY CLUSTERED ([CodTipoInteres])
)
ON [PRIMARY]
GO