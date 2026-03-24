SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaLiqrrVisitas] @codoficina varchar(4)
as
SELECT codusuario,cliente,codprestamo,monto,datediff(day,cancelacion,getdate()) DSC,atrasomaximo,cancelacion
FROM tCsACaLIQUI_RR with(nolock)
where estado='Sin Renovar' and codoficina=@codoficina
order by cliente
GO