CREATE TABLE [dbo].[tCsCFDI_CodigoPostal] (
  [c_CodigoPostal] [varchar](10) NOT NULL,
  [c_Estado] [varchar](6) NULL,
  [c_Municipio] [varchar](6) NULL,
  [c_Localidad] [varchar](6) NULL,
  [Estímulo Franja Fronteriza] [int] NULL,
  [Fecha inicio de vigencia ] [datetime] NULL,
  [Fecha fin de vigencia] [datetime] NULL,
  [Descripción del Huso Horario] [varchar](255) NULL,
  [Mes_Inicio_Horario_Verano] [varchar](255) NULL,
  [Día_Inicio_Horario_Verano] [varchar](255) NULL,
  [Día_Inicio_Horario_Verano1] [varchar](255) NULL,
  [Diferencia_Horaria_Verano] [varchar](255) NULL,
  [Mes_Inicio_Horario_Invierno] [varchar](255) NULL,
  [Día_Inicio_Horario_Invierno] [varchar](255) NULL,
  [Día_Inicio_Horario_Invierno1] [varchar](255) NULL,
  [Diferencia_Horaria_Invierno] [varchar](255) NULL,
  CONSTRAINT [PK_c_CodigoPostal] PRIMARY KEY CLUSTERED ([c_CodigoPostal])
)
ON [PRIMARY]
GO