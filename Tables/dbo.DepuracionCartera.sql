CREATE TABLE [dbo].[DepuracionCartera] (
  [CodUsuario] [varchar](15) NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [Can] [varchar](25) NOT NULL,
  [NombreCompleto] [varchar](300) NULL,
  [Inicial] [int] NULL
)
ON [PRIMARY]
GO