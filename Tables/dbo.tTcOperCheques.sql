CREATE TABLE [dbo].[tTcOperCheques] (
  [CodOficina] [varchar](4) NOT NULL,
  [CodEntidadTipo] [varchar](3) NOT NULL,
  [CodEntidad] [varchar](3) NOT NULL,
  [NroCuenta] [varchar](30) NOT NULL,
  [NroOper] [decimal] NOT NULL,
  [CodArt] [varchar](10) NOT NULL,
  [NumIngreso] [int] NOT NULL,
  [NumArt] [decimal] NOT NULL,
  [CodConcepto] [int] NULL,
  [ANombreDe] [varchar](50) NULL,
  [Monto] [money] NULL,
  [Estado] [char](2) NULL,
  [Referencia] [varchar](25) NULL,
  [Fecha] [datetime] NULL,
  [CodConceptoAnula] [int] NULL,
  [FechaQAnula] [datetime] NULL,
  [CodUsuario] [char](15) NULL
)
ON [PRIMARY]
GO