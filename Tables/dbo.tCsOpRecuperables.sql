CREATE TABLE [dbo].[tCsOpRecuperables] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [SecPago] [int] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [TipoOp] [varchar](5) NULL,
  [NumeroPlan] [smallint] NULL,
  [FechaRegistro] [datetime] NULL,
  [CodMotivo] [smallint] NULL,
  [CodOfiOperacion] [varchar](4) NOT NULL,
  [TasaIntAnt] [decimal](19, 4) NOT NULL,
  [TasaIntNueva] [decimal](19, 4) NOT NULL,
  CONSTRAINT [PK_tCsOpRecuperables] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [SecPago], [CodPrestamo])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_FechaRegistro]
  ON [dbo].[tCsOpRecuperables] ([FechaRegistro])
  INCLUDE ([CodPrestamo])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsOpRecuperables] TO [jarriagaa]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1=condonacion, 2=castigo', 'SCHEMA', N'dbo', 'TABLE', N'tCsOpRecuperables', 'COLUMN', N'TipoOp'
GO