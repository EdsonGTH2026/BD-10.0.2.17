CREATE TABLE [dbo].[tCsRenegociadosVigentes] (
  [Periodo] [varchar](6) NULL,
  [Registro] [smalldatetime] NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [DiasAcumulado] [int] NULL,
  [Periodos] [int] NULL,
  [TipoReprog] [char](5) NULL,
  [NumReprog] [int] NULL,
  [FechaReprog] [smalldatetime] NULL,
  [PrestamoReprog] [varchar](25) NULL,
  [ReprogProvision] [varchar](6) NULL,
  CONSTRAINT [PK_tCsRenegociadosVigentes] PRIMARY KEY CLUSTERED ([CodPrestamo])
)
ON [PRIMARY]
GO