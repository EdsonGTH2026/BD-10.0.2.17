SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Autores: Edosn, Edith, Noel
-- Fecha:  10-06-2005

create procedure [dbo].[pGrDescripciones] 
@Tabla nvarchar(100),
@Campo nvarchar(100) = null,
@Descripcion nvarchar(2000)
with encryption
as
set nocount on
if @Campo = '' or @Campo is null  -- Descripcion de la Tabla
   if exists (select 1 from sysobjects O where O.Name = @Tabla)
      if exists (select 1 from sysobjects O 
                 inner join sysproperties P on O.id = P.id 
                 where O.Name = @Tabla and P.type = 3)
         exec sp_updateextendedproperty N'MS_Description', @Descripcion, N'user', N'dbo', N'table', @Tabla, null, null
      else
         exec sp_addextendedproperty N'MS_Description', @Descripcion, N'user', N'dbo', N'table', @Tabla, null, null
   else
      print 'No existe la tabla ' + @Tabla
else                              -- Descripcion de la columna de la tabla
   if exists (select 1 from sysobjects O 
              inner join sysColumns C on O.id = C.id 
              where O.Name = @Tabla and C.Name = @Campo)
      if exists (select 1 from sysobjects O 
                 inner join sysColumns C on O.id = C.id 
                 inner join sysproperties P on O.id = P.id and C.colid = P.smallid
                 where O.Name = @Tabla and C.Name = @Campo and P.type = 4)
         exec sp_updateextendedproperty N'MS_Description', @Descripcion, N'user', N'dbo', N'table', @Tabla, N'column', @Campo
      else
         exec sp_addextendedproperty N'MS_Description', @Descripcion, N'user', N'dbo', N'table', @Tabla, N'column', @Campo
   else
      print 'No existe el campo ' + @Campo + ' en la tabla ' + @Tabla
GO