CREATE TABLE [dbo].[tCsCaSegAgenda] (
  [codusuario] [varchar](15) NOT NULL,
  [fecha] [smalldatetime] NOT NULL,
  [hora] [datetime] NOT NULL,
  [codactividad] [int] NULL,
  [titulo] [varchar](50) NULL,
  [descripcion] [text] NULL,
  [fechafin] [smalldatetime] NULL,
  [horafin] [datetime] NULL,
  [codorigen] [varchar](15) NULL,
  [estado] [char](1) NULL,
  [codprestamo] [varchar](25) NULL,
  CONSTRAINT [PK_tCsCaSegAsesor] PRIMARY KEY CLUSTERED ([codusuario], [fecha], [hora])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO