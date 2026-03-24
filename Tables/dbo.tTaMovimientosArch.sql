CREATE TABLE [dbo].[tTaMovimientosArch] (
  [Fecha_sub] [smalldatetime] NOT NULL,
  [Hora_sub] [datetime] NOT NULL,
  [nomarchivo] [varchar](20) NOT NULL,
  [nrotarjeta] [varchar](20) NOT NULL,
  [codtipomov] [varchar](3) NOT NULL,
  [fecha] [smalldatetime] NULL,
  [hora] [datetime] NULL,
  [documento1] [varchar](15) NOT NULL,
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
  [procesado] [char](1) NULL,
  CONSTRAINT [PK_tTaMovimientos] PRIMARY KEY CLUSTERED ([Fecha_sub], [Hora_sub], [nomarchivo], [nrotarjeta], [codtipomov], [documento1])
)
ON [PRIMARY]
GO