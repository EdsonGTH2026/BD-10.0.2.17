CREATE TABLE [dbo].[TmpROCAPermaClientes] (
  [fechacorte] [smalldatetime] NULL,
  [cosechaGeneracion] [varchar](30) NULL,
  [añoGeneracion] [int] NULL,
  [nroCliNuevos] [int] NULL,
  [nroVigentes] [int] NULL,
  [nroLiquiBueno] [int] NULL,
  [nroLiquiMalo] [int] NULL,
  [PorVigentes] [decimal](33, 19) NULL,
  [PorBuenosNR] [decimal](33, 19) NULL,
  [PorMalos] [decimal](33, 19) NULL,
  [MoNuevo] [decimal](38, 4) NULL,
  [MoVigentes] [decimal](38, 4) NULL,
  [MoLiquiBueno] [decimal](38, 4) NULL,
  [MoLiquiMalo] [decimal](38, 4) NULL,
  [ObjetivoVigente] [int] NOT NULL
)
ON [PRIMARY]
GO