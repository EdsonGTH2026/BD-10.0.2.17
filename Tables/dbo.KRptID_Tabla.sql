CREATE TABLE [dbo].[KRptID_Tabla] (
  [Fecha] [smalldatetime] NOT NULL,
  [Parametro] [varchar](100) NOT NULL,
  [Tabla] [varchar](50) NOT NULL,
  [Hora] [datetime] NOT NULL,
  [Agrupado] [varchar](100) NOT NULL,
  [Cuenta] [varchar](50) NULL,
  [Signo] [varchar](1) NULL,
  [Debe] [money] NULL,
  [Haber] [money] NULL,
  [Saldo] [money] NULL,
  CONSTRAINT [PK_KRptID_Tabla2] PRIMARY KEY CLUSTERED ([Fecha], [Parametro], [Tabla], [Hora], [Agrupado])
)
ON [PRIMARY]
GO