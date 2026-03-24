CREATE TABLE [dbo].[tCsOpRecuperablesDet] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [SecPago] [int] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodConcepto] [varchar](6) NOT NULL,
  [SecCuota] [smallint] NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [MontoOp] [decimal](19, 4) NULL,
  CONSTRAINT [PK_tCsOpRecuperablesDet] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [SecPago], [CodPrestamo], [CodConcepto], [SecCuota], [CodUsuario])
)
ON [PRIMARY]
GO