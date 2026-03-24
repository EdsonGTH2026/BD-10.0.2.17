CREATE TABLE [dbo].[tCsBsMetaxUEN] (
  [Fecha] [smalldatetime] NOT NULL,
  [iCodTipoBS] [int] NOT NULL,
  [iCodIndicador] [int] NOT NULL,
  [NCamValor] [varchar](50) NOT NULL,
  [ValorMin] [decimal](18, 2) NULL,
  [ValorMax] [decimal](18, 2) NULL,
  [ValorProg] [decimal](18, 2) NULL,
  [Operando] [varchar](50) NULL,
  CONSTRAINT [PK_tCsBsMetaxUEN] PRIMARY KEY CLUSTERED ([Fecha], [iCodTipoBS], [iCodIndicador], [NCamValor])
)
ON [PRIMARY]
GO