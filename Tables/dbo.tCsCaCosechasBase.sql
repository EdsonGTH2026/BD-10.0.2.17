CREATE TABLE [dbo].[tCsCaCosechasBase] (
  [IdReg] [int] IDENTITY,
  [CodPrestamo] [varchar](20) NULL,
  [CodUsuario] [varchar](15) NULL,
  [CodOficina] [varchar](3) NULL,
  [sucursal] [varchar](50) NULL,
  [CodProducto] [varchar](3) NULL,
  [Desembolso] [datetime] NULL,
  [Monto] [money] NULL,
  [PrimerAsesor] [varchar](15) NULL,
  [UltimoAsesor] [varchar](15) NULL,
  [Estadocalculado] [varchar](15) NULL,
  [NroDiasAtraso] [int] NULL,
  [saldo] [money] NULL,
  [PromotorReporte] [varchar](250) NULL,
  [PromotorReporteNombre] [varchar](250) NULL,
  [codverificadorData] [varchar](250) NULL,
  [Trimestre] [varchar](12) NULL,
  [Saldo2] [money] NULL,
  [ContarSaldo2] [money] NULL,
  [prestamoid] [int] NULL,
  CONSTRAINT [PK_tCsCaCosechasBase] PRIMARY KEY CLUSTERED ([IdReg])
)
ON [PRIMARY]
GO