CREATE TABLE [dbo].[tTcCorresponsales] (
  [idCorresponsal] [int] NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [codusuario] [varchar](15) NULL,
  [cau] [varchar](20) NULL,
  [codcontable] [varchar](15) NULL,
  CONSTRAINT [PK_tTcCorresponsales] PRIMARY KEY CLUSTERED ([idCorresponsal])
)
ON [PRIMARY]
GO