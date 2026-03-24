CREATE TABLE [dbo].[tTaCuentasArch] (
  [Fecha] [smalldatetime] NOT NULL,
  [Hora] [datetime] NOT NULL,
  [nomarchivo] [varchar](20) NOT NULL,
  [nrocuenta] [varchar](20) NOT NULL,
  [nrotarjeta] [varchar](20) NULL,
  [estado] [varchar](4) NULL,
  [nombrecliente] [varchar](200) NULL,
  [fecemision] [smalldatetime] NULL,
  [fecexpira] [smalldatetime] NULL,
  [fecativa] [smalldatetime] NULL,
  [hechopor] [varchar](20) NULL,
  [procesado] [char](1) NULL,
  CONSTRAINT [PK_tTaCuentasArch] PRIMARY KEY CLUSTERED ([Fecha], [Hora], [nomarchivo], [nrocuenta])
)
ON [PRIMARY]
GO