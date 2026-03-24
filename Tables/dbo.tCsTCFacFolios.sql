CREATE TABLE [dbo].[tCsTCFacFolios] (
  [codoficina] [varchar](4) NOT NULL,
  [CodTipoFactura] [varchar](5) NOT NULL,
  [idcontrol] [int] NOT NULL,
  [serie] [varchar](15) NULL,
  [folioini] [numeric](10) NULL,
  [foliofin] [numeric](10) NULL,
  [folioact] [bigint] NULL,
  [estado] [char](1) NULL,
  [digitosformato] [int] NULL,
  [nroaprobacion] [varchar](15) NULL,
  [añoaprobacion] [int] NULL,
  [nroseriecerti] [varchar](50) NULL,
  CONSTRAINT [PK_tCsTCFacFolios] PRIMARY KEY CLUSTERED ([codoficina], [CodTipoFactura], [idcontrol])
)
ON [PRIMARY]
GO