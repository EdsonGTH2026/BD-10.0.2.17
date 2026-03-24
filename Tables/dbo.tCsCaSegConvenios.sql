CREATE TABLE [dbo].[tCsCaSegConvenios] (
  [codusuario] [varchar](15) NOT NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [nroconvenio] [int] NOT NULL,
  [fecha] [smalldatetime] NULL,
  [estado] [int] NULL,
  [fechacierre] [smalldatetime] NULL,
  [codusuarioreg] [varchar](15) NULL,
  CONSTRAINT [PK_tCsCaSegConvenios] PRIMARY KEY CLUSTERED ([codusuario], [codprestamo], [nroconvenio])
)
ON [PRIMARY]
GO