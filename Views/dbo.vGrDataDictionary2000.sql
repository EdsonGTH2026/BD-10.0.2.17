SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE view [dbo].[vGrDataDictionary2000]
as

select Tabla = T.name, Columna = C.name, C.colid, Tipo = Y.name, Size = c.length, Descripcion = p.Value
from sysobjects T
inner join syscolumns C on T.id = c.id
inner join systypes   Y on C.xtype = Y.xtype
left  join sysproperties P on T.id = P.Id and c.colid = p.smallid
where T.xtype = 'U'
and T.name not in ('dtproperties', 'sysdiagrams')
GO