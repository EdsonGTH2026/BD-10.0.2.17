SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dev_cchavezd].[pCscalidadImor] @categoria varchar(15)  ,@calidad varchar(10),@Crecimiento  money  
as  
set nocount on 


--declare @categoria varchar(15)
--set @categoria = 'MASTER 1.5'
--declare @calidad varchar(10)
--SET @calidad= 'menorA10'
--declare @Crecimiento  money
--set @Crecimiento=5000

declare @traineeJunior table  (CrecVigente money,menorA2 int,menorA4 int,menorA5 int,menorA6 int
						, menorA8 int,menorA10 int, mayorA10 int )
insert into @traineeJunior values(60000,120,115,110,70,40,10,0)
insert into @traineeJunior values(50000,115,110,105,65,35,5,0)
insert into @traineeJunior values(40000,110,105,100,60,30,0,0)
insert into @traineeJunior values(20000,90,85,80,40,10,00,0)
insert into @traineeJunior values(10000,70,65,60,20,0,0,0)
insert into @traineeJunior values(0,50,45,40,0,0,0,0)
insert into @traineeJunior values(-10000,30,25,20,0,0,0,0)
--select * from @traineeJunior


declare @senior table(CrecVigente money,menorA2 int,menorA4 int,menorA5 int,menorA6 int
						, menorA8 int,menorA10 int, mayorA10 int )
insert into @senior  values(50000,120,115,110,70,40,10,0)
insert into @senior  values(40000,115,110,105,65,35,5,0)
insert into @senior values(30000,110,105,100,60,30,0,0)
insert into @senior values(20000,90,85,80,40,10,00,0)
insert into @senior values(10000,70,65,60,20,0,0,0)
insert into @senior values(0,50,45,40,0,0,0,0)
insert into @senior values(-5000,30,25,20,0,0,0,0)

--select * from @senior

declare @Master table(CrecVigente money,menorA2 int,menorA4 int,menorA5 int,menorA6 int
						, menorA8 int,menorA10 int, mayorA10 int )
insert into @Master  values(15000,120,115,115,75,45,15,0)
insert into @Master  values(10000,115,110,110,70,40,10,0)
insert into @Master values(5000,110,105,105,65,35,5,0)
insert into @Master values(0,105,100,100,60,30,0,0)
insert into @Master values(-5000,90,85,80,40,10,0,0)
insert into @Master values(-7500,70,65,60,20,0,0,0)
insert into @Master values(-10000,60,55,50,10,0,0,0)
  
--create table #calImor15(  
-- calidaImor15 int )   
--insert  
select   
(case when @categoria ='TRAINEE' or @categoria='JUNIOR' then(select (case when @calidad = 'menorA2' then menorA2 
																		when @calidad = 'menorA4' then menorA4
																		when @calidad = 'menorA5' then menorA5
																		when @calidad = 'menorA6' then menorA6 
																		when @calidad = 'menorA8' then menorA8
																		when @calidad = 'menorA10' then menorA10
																		when @calidad = 'mayorA10' then mayorA10 end) from @traineeJunior where CrecVigente= @Crecimiento)
	when @categoria ='SENIOR' then(select (case when @calidad = 'menorA2' then menorA2 
																		when @calidad = 'menorA4' then menorA4
																		when @calidad = 'menorA5' then menorA5
																		when @calidad = 'menorA6' then menorA6 
																		when @calidad = 'menorA8' then menorA8
																		when @calidad = 'menorA10' then menorA10
																		when @calidad = 'mayorA10' then mayorA10 end)from @senior where CrecVigente= @Crecimiento)
			
	when @categoria ='MASTER 1.5' or @categoria='MASTER 2.0'or @categoria='MASTER 2.5' then(select (case when @calidad = 'menorA2' then menorA2 
																		when @calidad = 'menorA4' then menorA4
																		when @calidad = 'menorA5' then menorA5
																		when @calidad = 'menorA6' then menorA6 
																		when @calidad = 'menorA8' then menorA8
																		when @calidad = 'menorA10' then menorA10
																		when @calidad = 'mayorA10' then mayorA10 end)from @Master where CrecVigente= @Crecimiento)
	end) calidaImor15
		
into #calImor15
--select * from #calImor15
drop table #calImor15


----------------------------------------------------------------
GO