CREATE TABLE [dbo].[tCsConceptosPrestamo] (
  [CodPrestamo] [varchar](25) NOT NULL CONSTRAINT [DF_tCsConceptoPrestamo_CodPrestamo] DEFAULT (''),
  [CodOficina] [varchar](4) NULL,
  [Consolidacion] [smalldatetime] NOT NULL,
  [CodConcepto] [varchar](5) NOT NULL CONSTRAINT [DF_tCsConceptoPrestamo_CodConcepto] DEFAULT (''),
  [TipoConcepto] [char](1) NOT NULL CONSTRAINT [DF_tCsConceptoPrestamo_TipoConcepto] DEFAULT (''),
  [TipoCobro] [char](1) NOT NULL CONSTRAINT [DF_tCsConceptoPrestamo_TipoCobro] DEFAULT (''),
  [OrdenAfecta] [smallint] NOT NULL CONSTRAINT [DF_tCsConceptoPrestamo_OrdenAfecta] DEFAULT (0),
  [ValorCalculo] [smallint] NULL,
  [NroCuotas] [int] NOT NULL CONSTRAINT [DF_tCsConceptoPrestamo_NroCuotas] DEFAULT (0),
  [ConceptoInicial] [bit] NOT NULL CONSTRAINT [DF_tCsConceptoPrestamo_ConceptoInicial] DEFAULT (0),
  [CalculaDevengado] [bit] NOT NULL CONSTRAINT [DF_tCsConceptoPrestamo_CalculaDevengado] DEFAULT (0),
  [CalculaMora] [bit] NOT NULL CONSTRAINT [DF_tCsConceptoPrestamo_CalculaMora] DEFAULT (0),
  [ConceptoDeCalculo] [varchar](5) NULL,
  [ValorConcepto] [decimal](19, 4) NULL,
  [TotalCuota] [decimal](19, 4) NULL CONSTRAINT [DF_tCsConceptoPrestamo_TotalCuota] DEFAULT (0),
  [TotalDevengado] [decimal](19, 4) NULL CONSTRAINT [DF_tCsConceptoPrestamo_TotalDevengado] DEFAULT (0),
  [TotalPagado] [decimal](19, 4) NULL CONSTRAINT [DF_tCsConceptoPrestamo_TotalPagado] DEFAULT (0),
  [TotalCondonado] [decimal](19, 4) NULL CONSTRAINT [DF_tCsConceptoPrestamo_TotalCondonado] DEFAULT (0),
  CONSTRAINT [PK_tCsConceptosPrestamo] PRIMARY KEY CLUSTERED ([CodPrestamo], [CodConcepto])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del Prestamo', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'CodPrestamo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'El codigo del Concepto: CAPI, INTE, etc', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'CodConcepto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'V=Valor, P=Porcentaje, M=ValorMensual', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'TipoConcepto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'A = Anticipado, F=Al final, C=Cuota; O=por operacion, T=cada N cuotas; N debe estar en el campo "NroCUota"', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'TipoCobro'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'El orden en que va a afectar el pago de cuotas', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'OrdenAfecta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'0=capital del prestamo, 1=saldo capital total, 2=cuota capital, 3=cuota capital+interes, 4=saldo total (capital +interes corriente), 5=saldo capital cuota, 9=sobre otro concepto -definido en el campo "conceptodecalculo"', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'ValorCalculo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Cada Cuantas cuotas', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'NroCuotas'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'0=no es concepto inicial, 1=Es concepto inicial', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'ConceptoInicial'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'0=No calcula devengamiento diario, 1=Calcula devengamiento diario', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'CalculaDevengado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'0=No calcula mora, 1=Calcula Mora', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'CalculaMora'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'El campo sobre el cual se hara el calculo, valor de calculo tiene que estar a 9, ademas que "tipoconcepto" solo puede ser "P"', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'ConceptoDeCalculo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'El valor que se aplicara al concepto dependiendo de los atributos del concepto ej: Tasa de interes INTE que se aplicara al calculo del plan de pagos, tambien se usa para otros conceptos', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'ValorConcepto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Sumatoria de Todas las Cuotas', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'TotalCuota'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Sumatoria de todo lo devengado', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'TotalDevengado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Sumatoria de todo lo pagado', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'TotalPagado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Sumatoria de todo lo Condonado', 'SCHEMA', N'dbo', 'TABLE', N'tCsConceptosPrestamo', 'COLUMN', N'TotalCondonado'
GO