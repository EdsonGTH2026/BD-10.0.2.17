CREATE TABLE [dbo].[tCsAnalisisCtaOrdenNuevo] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [Codusuario] [varchar](25) NOT NULL,
  [SaldoInteres] [decimal](19, 4) NOT NULL,
  [SaldoMoratorio] [decimal](19, 4) NOT NULL,
  [InteresVigente] [decimal](19, 4) NULL,
  [InteresVencido] [decimal](19, 4) NULL,
  [InteresCtaOrden] [decimal](19, 4) NULL,
  [MoratorioVigente] [decimal](19, 4) NULL,
  [MoratorioVencido] [decimal](19, 4) NULL,
  [MoratorioCtaOrden] [decimal](19, 4) NULL,
  CONSTRAINT [PK_tCsAnalisisCtaOrdenNuevo] PRIMARY KEY CLUSTERED ([Fecha], [CodPrestamo], [Codusuario])
)
ON [PRIMARY]
GO