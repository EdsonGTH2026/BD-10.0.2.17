CREATE TABLE [dbo].[tCsAPLDClivsCtas] (
  [Numero_Cliente] [varchar](15) NOT NULL,
  [paterno] [varchar](50) NOT NULL,
  [materno] [varchar](50) NOT NULL,
  [nombres] [varchar](80) NOT NULL,
  [Razon_Social] [varchar](300) NULL,
  [Tipo_Persona] [varchar](6) NOT NULL,
  [Numero_Cuenta] [varchar](25) NULL,
  [Tipo_Cuenta] [varchar](17) NOT NULL,
  [Nivel_Operacion] [varchar](4) NOT NULL,
  [Estatus_Cuenta] [varchar](6) NOT NULL,
  [Fecha_Alta] [varchar](50) NOT NULL,
  [Fecha_Baja] [varchar](50) NOT NULL,
  [Saldo_Final_Periodo] [money] NULL,
  [Nombre_apoderado_legal] [varchar](300) NOT NULL
)
ON [PRIMARY]
GO