CREATE TABLE [dbo].[tCsAPLDClientes] (
  [Numero_Cliente] [varchar](15) NOT NULL,
  [Relacion_Contratual] [varchar](7) NOT NULL,
  [paterno] [varchar](50) NOT NULL,
  [materno] [varchar](50) NOT NULL,
  [nombres] [varchar](80) NOT NULL,
  [Razon_Social] [varchar](300) NULL,
  [Tipo_Persona] [varchar](6) NOT NULL,
  [Estatus_cliente] [varchar](9) NOT NULL,
  [Fecha_inicio] [varchar](50) NOT NULL,
  [Clasificacion_riesgo] [varchar](5) NOT NULL,
  [Fecha_clas_riesgo] [varchar](50) NOT NULL,
  [PEP] [varchar](2) NOT NULL,
  [Nacionalidad] [varchar](10) NOT NULL,
  [Pais_nacimiento] [varchar](10) NOT NULL,
  [Actividad_generica] [varchar](255) NOT NULL,
  [Actividad_especifica] [varchar](50) NOT NULL,
  [Entidad_federativa] [varchar](60) NOT NULL,
  [Telefono] [varchar](50) NOT NULL,
  [CURP] [varchar](8000) NULL,
  [RFC] [varchar](8000) NULL,
  [Fecha_nacimiento] [varchar](50) NULL,
  [Fecha_termino] [varchar](50) NOT NULL,
  [Nombre_apoderado_legal] [varchar](300) NOT NULL,
  [Domicilio] [varchar](301) NOT NULL,
  [correo] [varchar](100) NOT NULL
)
ON [PRIMARY]
GO