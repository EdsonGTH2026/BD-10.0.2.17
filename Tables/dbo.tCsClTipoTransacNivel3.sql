CREATE TABLE [dbo].[tCsClTipoTransacNivel3] (
  [TipoTransacNivel3] [tinyint] NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [EsComision] [bit] NULL,
  [codsistema] [varchar](5) NOT NULL,
  CONSTRAINT [PK_tCsClTipoTransacNivel3] PRIMARY KEY CLUSTERED ([codsistema], [TipoTransacNivel3])
)
ON [PRIMARY]
GO