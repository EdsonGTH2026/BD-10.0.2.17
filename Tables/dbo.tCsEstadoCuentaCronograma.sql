CREATE TABLE [dbo].[tCsEstadoCuentaCronograma] (
  [Corte] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [SecCuota] [smallint] NOT NULL,
  [CodConcepto] [varchar](5) NOT NULL,
  [Devengado] [money] NULL,
  [Pago] [money] NULL,
  [FechaInicio] [smalldatetime] NOT NULL,
  [FechaVencimiento] [smalldatetime] NOT NULL,
  [FechaPago] [smalldatetime] NULL,
  [Estado] [varchar](50) NULL,
  [Validacion] [bit] NULL,
  CONSTRAINT [PK_tCsEstadoCuentaCA] PRIMARY KEY CLUSTERED ([Corte], [CodPrestamo], [SecCuota], [CodConcepto])
)
ON [PRIMARY]
GO