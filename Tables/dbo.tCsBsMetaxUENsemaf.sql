CREATE TABLE [dbo].[tCsBsMetaxUENsemaf] (
  [Fecha] [smalldatetime] NOT NULL,
  [iCodTipoBS] [int] NOT NULL,
  [iCodIndicador] [int] NOT NULL,
  [ItemColor] [int] NOT NULL,
  [NCamValor] [varchar](50) NOT NULL,
  [ValorMin] [decimal](18, 2) NULL,
  [ValorMax] [decimal](18, 2) NULL,
  [ValorProg] [decimal](18, 2) NULL,
  [Operando] [varchar](50) NULL
)
ON [PRIMARY]
GO