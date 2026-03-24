SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsMBSolicitudxCliente] @nombre varchar(200)
as 
SELECT top 1 s.codoficina+'|'+s.codsolicitud + '|' + u.nombrecompleto solcli
FROM [10.0.2.14].FinMas.dbo.tCaSolicitud s --with(nolock)
inner join [10.0.2.14].FinMas.dbo.tususuarios u --with(nolock) 
on u.codusuario=s.codusuario
where s.codproducto=168 and codasesor is not null
and s.codestado in('TRAMITE','APROBADO')
and len(s.codsolicitud)=11
and u.nombrecompleto like '%'+@nombre+'%'
GO