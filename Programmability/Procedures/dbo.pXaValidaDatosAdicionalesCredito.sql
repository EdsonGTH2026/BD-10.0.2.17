SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaValidaDatosAdicionalesCredito] @codsolicitud varchar(25),@codoficina varchar(4)
as
	declare @codusuario varchar(20)
	declare @codproducto varchar(3)

	select @codusuario=codusuario,@codproducto=codproducto
	from [10.0.2.14].finmas.dbo.tcasolicitud --with(nolock)
	where codoficina=@codoficina and codsolicitud=@codsolicitud

	exec [10.0.2.14].finmas.dbo.pCaValidarDatosAdicionalesCredito @codusuario, @codproducto
GO