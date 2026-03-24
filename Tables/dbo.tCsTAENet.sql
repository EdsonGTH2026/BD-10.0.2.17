CREATE TABLE [dbo].[tCsTAENet] (
  [codoficina] [varchar](5) NOT NULL,
  [idtrans] [bigint] NOT NULL,
  [idrespta] [char](2) NULL,
  [foltelcel] [varchar](10) NULL,
  [foltaenet] [varchar](10) NULL,
  [numero] [varchar](20) NULL,
  [monto] [decimal](10, 2) NULL,
  [fecha] [smalldatetime] NULL,
  [hora] [datetime] NULL,
  [nroopecj] [varchar](10) NULL,
  [usuario] [varchar](15) NULL,
  [usuariotae] [varchar](15) NULL,
  [codusuario] [varchar](15) NULL,
  CONSTRAINT [PK_tCsTAENet] PRIMARY KEY CLUSTERED ([codoficina], [idtrans])
)
ON [PRIMARY]
GO