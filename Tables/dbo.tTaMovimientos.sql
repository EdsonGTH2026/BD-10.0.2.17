CREATE TABLE [dbo].[tTaMovimientos] (
  [nrotarjeta] [varchar](20) NOT NULL,
  [codtipomov] [varchar](3) NOT NULL,
  [fecha] [smalldatetime] NOT NULL,
  [hora] [datetime] NOT NULL,
  [consecutivo] [varchar](15) NOT NULL,
  [documento1] [varchar](15) NULL,
  [documento2] [varchar](15) NULL,
  [F] [char](1) NULL,
  [E] [char](1) NULL,
  [consumo] [smalldatetime] NULL,
  [tarjeta] [varchar](25) NULL,
  [nombre] [varchar](250) NULL,
  [comercio] [varchar](15) NULL,
  [comision] [decimal](16, 2) NULL,
  [MO] [varchar](2) NULL,
  [Monto] [decimal](16, 2) NULL,
  [usuario] [varchar](15) NULL,
  [fechaproceso] [smalldatetime] NULL,
  CONSTRAINT [PK_tTaMovimientos2] PRIMARY KEY CLUSTERED ([nrotarjeta], [codtipomov], [fecha], [hora], [consecutivo])
)
ON [PRIMARY]
GO