CREATE TABLE [dbo].[tSgLogError] (
  [Log] [numeric] NOT NULL,
  [TipoLog] [char](2) NULL,
  [Aplicacion] [varchar](22) NULL,
  [Version] [varchar](10) NULL,
  [Modulo] [varchar](22) NULL,
  [Menu] [varchar](22) NULL,
  [Tabla] [varchar](50) NULL,
  [Usuario] [varchar](12) NULL CONSTRAINT [DF_tSgLogError_Usuario] DEFAULT (suser_sname()),
  [Fecha] [datetime] NULL,
  [Hora] [varchar](20) NULL,
  [Terminal] [varchar](30) NULL,
  [IpMaquina] [varchar](15) NULL,
  [Excepcion] [varchar](500) NULL,
  [Source] [varchar](100) NULL,
  CONSTRAINT [PK_tSgLogError] PRIMARY KEY CLUSTERED ([Log])
)
ON [PRIMARY]
GO