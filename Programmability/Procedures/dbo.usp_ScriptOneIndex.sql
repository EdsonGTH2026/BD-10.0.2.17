SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[usp_ScriptOneIndex]
    @DbName nvarchar(128)
  , @TableName nvarchar(128)
  , @TableOwner nvarchar(128)
  , @IndexName nvarchar(128)
  , @Create tinyint
  , @Drop tinyint
  , @Debug tinyint = 0
As

Declare
  @SqlString varchar(4000)
  , @Message varchar(100)
  , @cr char(1)
  , @IsPrimaryKey tinyint
  , @IsUniqueConstraint tinyint
  , @IsUniqueIndex tinyint
  , @IsClustered tinyint
  , @IsStatistics tinyint
  , @CnstIsNotTrusted tinyint
  , @IndexFillFactor tinyint
  , @IndexKeyString nvarchar(1000)
  , @FileGroupName nvarchar(128)
Select
    @IsPrimaryKey = IsPrimaryKey
  , @IsUniqueConstraint = IsUniqueConstraint
  , @IsUniqueIndex = IsUniqueIndex
  , @IsClustered = IsClustered
  , @IsStatistics = IsStatistics
  , @IndexKeyString = IndexKeyString
  , @CnstIsNotTrusted = CnstIsNotTrusted
  , @IndexFillFactor = IndexFillFactor
  , @FileGroupName = FileGroupName
From dbo.#TempSysindexes
Where TableName = @TableName And IndexName = @IndexName And TableOwner = @TableOwner

Set @cr = CHAR(13)

-- Test parameters:
If @IsStatistics = 1 And (@IsPrimaryKey = 1 Or @IsUniqueConstraint = 1 Or @IsUniqueIndex =1 Or @IsClustered = 1)
  Begin
    Set @Message = 'Statistics cannot have index properties'
  Select @IndexName
    Goto ErrorLabel
  End
If @IsPrimaryKey = 1 And @IsUniqueConstraint = 1
  Begin
    Set @Message = 'You cannot have both a primary key and a unique constraint'
    Goto ErrorLabel
  End

-- Test Drop first
If @Drop = 1
  If @IsStatistics = 0
    If @IsPrimaryKey = 1 Or @IsUniqueConstraint = 1
      Begin
        Set @SqlString = 'If Not Exists(Select * From INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS' + @cr
        Set @SqlString = @SqlString + ' Where Unique_Constraint_Name = ''' + @IndexName + ''') ' + @cr
        Set @SqlString = @SqlString + ' And IndexProperty(Object_Id(''' + @TableOwner+'.[' + @TableName + ']''), '''+ @IndexName + ''', ''IsClustered'') Is Not Null ' + @cr
        Set @SqlString = @SqlString + ' Alter Table ' + @DbName + '.' + @TableOwner + '.[' + @TableName + '] Drop Constraint ' + @IndexName + @cr
        Set @SqlString = @SqlString + 'Else' + @cr
        Set @SqlString = @SqlString + ' Begin' + @cr
        Set @SqlString = @SqlString + ' Print ''Could not drop index ' + @IndexName + ' for table ' + Rtrim(@TableOwner) + '.[' + Rtrim(@TableName) + ']''' + @cr
        Set @SqlString = @SqlString + ' Print '' because it is referenced by at least one foreign key constraint.'' ' + @cr
        Set @SqlString = @SqlString + ' Print ''Drop the foreign key constraint(s) first.''' + @cr
        Set @SqlString = @SqlString + ' Print ''''' + @cr
        Set @SqlString = @SqlString + ' End' + @cr
        Set @SqlString = @SqlString + 'Go ' + @cr
        Print @SqlString
      End
    Else
      Begin
        Set @SqlString = 'If IndexProperty(Object_Id(''' + @TableOwner+'.[' + @TableName + ']''), '''+ @IndexName + ''', ''IsClustered'') Is Not Null ' + @cr
        Set @SqlString = @SqlString + ' Drop Index [' + @TableName + '].' + @IndexName + @cr
        Set @SqlString = @SqlString + 'Go ' + @cr
        Print @SqlString
      End
  Else
    Begin
      Set @SqlString = 'If IndexProperty(Object_Id(''' + @TableOwner+'.[' + @TableName + ']''), '''+ @IndexName + ''', ''IsStatistics'') Is Not Null ' + @cr
      Set @SqlString = @SqlString + ' Drop Statistics [' + @TableName + '].' + @IndexName + @cr
      Set @SqlString = @SqlString + 'Go ' + @cr
      Print @SqlString
    End


-- Now test for Create
If @Create = 1
  If @IsStatistics = 0
    If @IsPrimaryKey = 1 Or @IsUniqueConstraint = 1
      Begin
        Set @SqlString = 'If IndexProperty(Object_Id(''' + @TableOwner+'.['+ @TableName + ']''), '''+ @IndexName + ''', ''IsClustered'') Is Null ' + @cr
        Set @SqlString = @SqlString + ' Alter Table ' + @DbName + '.[' + @TableOwner + '].' + @TableName + @cr
        Set @SqlString = @SqlString + Case When @CnstIsNotTrusted = 1 Then ' With Nocheck ' Else '' End
        Set @SqlString = @SqlString + ' Add Constraint ' + @IndexName
        Set @SqlString = @SqlString + Case When @IsPrimaryKey = 1 Then ' Primary Key ' Else ' Unique ' End
        Set @SqlString = @SqlString + Case When @IsClustered = 1 Then ' Clustered ' Else ' NonClustered ' End
        Set @SqlString = @SqlString + '(' + @IndexKeyString + ')' + @cr
        Set @SqlString = @SqlString + Case When @IndexFillFactor > 0 then ' With Fillfactor = ' + Cast(@IndexFillFactor As varchar(5)) + @cr Else '' End
        Set @SqlString = @SqlString + ' On [' + @FilegroupName + ']' + @cr
        Set @SqlString = @SqlString + @cr + 'Go ' + @cr + @cr
        Print @SqlString
      End
    Else
      Begin
        Set @SqlString = 'If IndexProperty(Object_Id(''' + @TableOwner+'.['+ @TableName + ']''), '''+ @IndexName + ''', ''IsClustered'') Is Null ' + @cr
        Set @SqlString = @SqlString + ' Create'
        Set @SqlString = @SqlString + Case When @IsUniqueIndex = 1 Then ' Unique ' Else '' End
        Set @SqlString = @SqlString + Case When @IsClustered = 1 Then ' Clustered ' Else ' NonClustered ' End
        Set @SqlString = @SqlString + 'Index ' + @IndexName + ' On ' + @TableOwner+'.['+@TableName +']'
        Set @SqlString = @SqlString + ' (' + @IndexKeyString + ')' + @cr
        Set @SqlString = @SqlString + Case When @IndexFillFactor > 0 then ' With Fillfactor = ' + Cast(@IndexFillFactor As varchar(5)) + @cr Else '' End
        Set @SqlString = @SqlString + ' On [' + @FilegroupName + ']' + @cr
        Set @SqlString = @SqlString + 'Go ' + @cr
        Print @SqlString
      End
  Else
    Begin
      Set @SqlString = 'If IndexProperty(Object_Id(''' + @TableOwner+'.['+ @TableName + ']''), '''+ @IndexName + ''', ''IsStatistics'') Is Null ' + @cr
      Set @SqlString = @SqlString + ' Create Statistics ' + @IndexName + ' On ' + @TableOwner+'.['+ @TableName +']'
      Set @SqlString = @SqlString + ' (' + @IndexKeyString + ')' + @cr
      Set @SqlString = @SqlString + 'Go ' + @cr
      Print @SqlString
    End
Print @cr
Return

ErrorLabel:
  RaisError(@Message, 1,1)
  Return
GO