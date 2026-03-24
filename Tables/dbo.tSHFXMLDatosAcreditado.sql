CREATE TABLE [dbo].[tSHFXMLDatosAcreditado] (
  [Periodo] [varchar](6) NOT NULL,
  [Fila] [int] NOT NULL,
  [Cadena] [varchar](949) NOT NULL,
  [Usados] [int] NULL,
  [ReporteInicio] [varchar](22) NOT NULL,
  [ReporteFin] [varchar](22) NOT NULL,
  [CodPrestamo] [varchar](19) NOT NULL,
  [Nombres] [varchar](101) NOT NULL,
  [Paterno] [varchar](85) NOT NULL,
  [Materno] [varchar](85) NOT NULL,
  [Genero] [varchar](18) NOT NULL,
  [Nacimiento] [varchar](57) NOT NULL,
  [EstadoCivil] [varchar](22) NOT NULL,
  [Estudios] [varchar](32) NOT NULL,
  [Dependientes] [varchar](51) NOT NULL,
  [TipoPropiedad] [varchar](60) NOT NULL,
  [Antiguedad] [varchar](56) NOT NULL,
  [Municipio] [varchar](62) NOT NULL,
  [TipoEmpleo] [varchar](26) NOT NULL,
  [Ingresos] [varchar](65) NOT NULL,
  [DeudaTotal] [varchar](55) NOT NULL,
  [IngresosConyuge] [varchar](69) NOT NULL,
  [DeudaConyuge] [varchar](59) NOT NULL
)
ON [PRIMARY]
GO