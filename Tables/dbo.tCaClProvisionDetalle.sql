CREATE TABLE [dbo].[tCaClProvisionDetalle] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](25) NOT NULL,
  [CodTipoCredito] [tinyint] NULL,
  [TipoReprog] [varchar](6) NULL,
  [Estado] [varchar](50) NULL,
  [NroDiasAtraso] [smallint] NULL,
  [SaldoCapital] [money] NULL,
  [Interes] [money] NULL,
  [Garantia] [money] NOT NULL,
  [GReal] [money] NOT NULL
)
ON [PRIMARY]
GO