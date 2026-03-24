CREATE TABLE [dbo].[tTcCLConcepCuentas] (
  [CodConcepto] [int] NOT NULL,
  [DesCorta] [varchar](50) NULL,
  [Descripcion] [varchar](60) NULL,
  [Activo] [bit] NULL,
  [ContaCodigo] [varchar](25) NULL,
  [EsIngreso] [bit] NULL,
  [EditaUsuario] [bit] NULL,
  [CodSistema] [varchar](2) NULL,
  [TipoOper] [varchar](2) NOT NULL
)
ON [PRIMARY]
GO