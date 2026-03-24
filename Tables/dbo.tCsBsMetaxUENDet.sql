CREATE TABLE [dbo].[tCsBsMetaxUENDet] (
  [Fecha] [smalldatetime] NOT NULL,
  [iCodTipoBS] [int] NOT NULL,
  [iCodIndicador] [int] NOT NULL,
  [NCamProducto] [varchar](5) NOT NULL,
  [NCamValor] [varchar](50) NOT NULL,
  [ValorProg] [decimal](18, 2) NULL,
  CONSTRAINT [PK_tCsBsMetaxUENDet] PRIMARY KEY CLUSTERED ([Fecha], [iCodTipoBS], [iCodIndicador], [NCamProducto], [NCamValor])
)
ON [PRIMARY]
GO