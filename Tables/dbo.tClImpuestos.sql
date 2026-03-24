CREATE TABLE [dbo].[tClImpuestos] (
  [CodImpuesto] [varchar](8) NOT NULL,
  [Impuesto] [varchar](50) NULL,
  [PorcentajeBase] [smallmoney] NULL,
  [Activo] [bit] NOT NULL,
  [Orden] [smallint] NULL,
  [ContaCodigo] [varchar](25) NULL,
  [ContaCodigoCxPAsumeEmp] [varchar](25) NOT NULL,
  [ContaCodigoGastoAsumeEmp] [varchar](25) NOT NULL,
  [ContaCodigoGastoPropio] [varchar](25) NOT NULL,
  [ContaCodigoPropio] [varchar](25) NOT NULL
)
ON [PRIMARY]
GO