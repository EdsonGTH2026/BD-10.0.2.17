CREATE TABLE [dbo].[tUsClSexo] (
  [Sexo] [int] NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Genero] [varchar](50) NULL,
  [SHF] [char](1) NULL,
  [INTF] [char](1) NULL,
  CONSTRAINT [PK_tUsClSexo] PRIMARY KEY CLUSTERED ([Sexo])
)
ON [PRIMARY]
GO