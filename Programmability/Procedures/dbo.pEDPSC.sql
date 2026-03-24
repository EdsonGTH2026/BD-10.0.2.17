SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pEDPSC]
    @UsKeep   varchar(100),
    @UsBorrar varchar(100)
WITH ENCRYPTION
as
set nocount on -- <-- Noel. Optimizacion

--Declare @UsBorrar varchar(100)
--Declare @UsKeep   varchar(100)
--declare @codanterior varchar(20)

--DECLARE CU CURSOR FOR 
--    select * from (
--        select codanterior, UKeep = max(B.UKeep), UBorrar = max(B.UBorrar)
--        from (
--            select *, UKeep   = case when Sexo =  SexoU then codusuario else null end,
--                      UBorrar = case when Sexo <> SexoU then codusuario else null end
--            from (
--                select codusuario, FechaNac = convert(char(8), FechaNacimiento, 112), di, Sexo = case when sexo = 1 then 'M' else 'F' end,
--                       sexoU = substring(codusuario, 10,1), nombrecompleto, codanterior
--                from [10.0.2.14].finmas.dbo.tususuarios 
--                where codanterior in (
--                    SELECT codanterior--, count(*) 
--                    from [10.0.2.14].finmas.dbo.tususuarios
--                    where cast(codoficina as int) >100
--                    group by codanterior
--                    having count(*) > 1
--                )
--            ) A
--        ) B
--        group by B.CodAnterior
--    ) C where C.UKeep is not null and C.UBorrar is not null
--    order by 2 
--open CU
--FETCH NEXT FROM CU INTO @codanterior, @UsKeep, @UsBorrar
--WHILE @@FETCH_STATUS = 0
--BEGIN

--set @UsKeep   = 'LHM490814F4AP7'
--set @UsBorrar = 'LHM490814FM4001'
    
    ----set @UsKeep   = upper('ARP551005F5EK1')

     
    UPDATE TCSCARTERA SET CODUSUARIO = @UsKeep WHERE CODUSUARIO = @UsBorrar
    UPDATE TCSCARTERA SET CODAsesor  = @UsKeep WHERE codAsesor  = @UsBorrar

    UPDATE tcscarteradet SET CODUSUARIO = @UsKeep WHERE CODUSUARIO = @UsBorrar

    UPDATE tcspadroncarteradet SET CODUSUARIO = @UsKeep WHERE CODUSUARIO = @UsBorrar
    UPDATE tcspadroncarteradet SET primerasesor = @UsKeep WHERE primerasesor = @UsBorrar
    UPDATE tcspadroncarteradet SET ultimoasesor = @UsKeep WHERE ultimoasesor = @UsBorrar

    UPDATE tCsTransaccionDiaria SET CODUSUARIO = @UsKeep WHERE CODUSUARIO = @UsBorrar
    UPDATE tCsTransaccionDiaria SET CODAsesor  = @UsKeep WHERE CODAsesor  = @UsBorrar


    delete tcsCLIENTES WHERE CODUSUARIO in (@UsBorrar)
    delete tcspadronCLIENTES WHERE CODUSUARIO in (@UsBorrar)

    UPDATE tcsCLIENTES SET CODUSUARIO = @UsKeep, CODORIGEN = @UsKeep WHERE CODUSUARIO in (@UsKeep)
    UPDATE tcsPADRONCLIENTES SET CODUSUARIO = @UsKeep, CODORIGEN = @UsKeep, CODORIGINAL = @UsKeep  WHERE CODUSUARIO in (@UsKeep)

    /*
    select * from tcscartera where codusuario in ('AAM810630MVR06 ', 'AAM810630F09Z4 ')
    select * from tcscarteradet where codusuario in ('AAM810630MVR06 ', 'AAM810630F09Z4 ')
    select * from tcspadroncarteradet where codusuario in ('AAM810630MVR06 ', 'AAM810630F09Z4 ')
    select * from tcsCLIENTES where codusuario in ('AAM810630MVR06 ', 'AAM810630F09Z4 ')
    select * from tcspadronCLIENTES where codusuario in ('AAM810630MVR06 ', 'AAM810630F09Z4 ')
    --AAA820912F0912 	01	NAT	ASCENCIO	ALVAREZ	ALEJANDRA FABIOLA
    --AAA821209M0912 	01	NAT	ASCENCIO	ALVAREZ	ALEJANDRA FABIOLA
    --AAC690727F7143 	01	NAT	ALMENDRA	ANTONIO	CELESTINA		ALMENDRA ANTONIO CELESTINA	RFC	AEAC690727143	1969-07-27 00:00:00	U	0	4024		122	2016-06-30 00:00:00	2016-06-30 11:21:47.917	               	21792878	0	2016-06-30 11:21:47.917	NULL	1	AAC690727F7143
    --AAC690727M7143 	01	NAT	ALMENDRA	ANTONIO	CELESTINA		ALMENDRA ANTONIO CELESTINA	RFC	AEAC690727143	1969-07-27 00:00:00	U	0	4024		122	2016-02-25 00:00:00	2016-02-25 16:43:56.617	               	21792878	0	2016-02-25 16:43:56.617	NULL	1	AAC690727F7143    
    */
    select * from tcspadronCLIENTES where codusuario in (@UsKeep)

--	FETCH NEXT FROM CU INTO @codanterior, @UsKeep, @UsBorrar
--END
--CLOSE CU
--DEALLOCATE CU
GO