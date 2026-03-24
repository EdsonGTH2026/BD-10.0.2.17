CREATE TABLE [dbo].[tCREmpresas] (
  [Empresa] [varchar](2) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [NombreLegal] [varchar](100) NULL,
  [RepresentanteLegal] [varchar](50) NULL,
  [FuncionarioFacultado] [varchar](15) NULL,
  [CodOficina] [varchar](4) NULL,
  CONSTRAINT [PK_tCREmpresas] PRIMARY KEY CLUSTERED ([Empresa])
)
ON [PRIMARY]
GO