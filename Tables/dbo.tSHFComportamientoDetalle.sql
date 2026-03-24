CREATE TABLE [dbo].[tSHFComportamientoDetalle] (
  [ReporteInicio] [smalldatetime] NOT NULL,
  [ReporteFin] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [MovFecha] [smalldatetime] NOT NULL,
  [MovTipo] [int] NOT NULL,
  [MovClave] [varchar](3) NOT NULL,
  [MovAplica] [int] NOT NULL,
  [MovMonto] [decimal](16, 4) NULL,
  [MovDenominacion] [decimal](18, 4) NOT NULL,
  [SecCuota] [int] NOT NULL,
  [CodConcepto] [varchar](50) NOT NULL,
  [Monto] [decimal](18, 4) NULL,
  CONSTRAINT [PK_tSHFComportamientoDetalle] PRIMARY KEY CLUSTERED ([ReporteInicio], [ReporteFin], [CodPrestamo], [CodUsuario], [MovFecha], [MovTipo], [SecCuota], [CodConcepto])
)
ON [PRIMARY]
GO