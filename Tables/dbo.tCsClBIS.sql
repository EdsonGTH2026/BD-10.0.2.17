CREATE TABLE [dbo].[tCsClBIS] (
  [Bis] [int] NOT NULL,
  [Nombre] AS ('B' + convert(varchar(10),[Bis]) + case [Bis] when 0 then '(Responsabilidad Total.)' else ('(' + convert(varchar(10),[Inicio]) + '-' + convert(varchar(10),[Fin]) + ') Dias de atraso.') end),
  [Rubro] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  [Inicio] [int] NULL,
  [Fin] [int] NULL,
  [DuracionMeses] [int] NULL,
  [Sistema] [bit] NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsClBIS] PRIMARY KEY CLUSTERED ([Bis])
)
ON [PRIMARY]
GO