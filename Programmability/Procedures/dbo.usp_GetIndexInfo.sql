SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[usp_GetIndexInfo]
    @DbName varchar(40)
  , @IncludeStatistics tinyint
  , @Debug tinyint = 0
As


Create Table dbo.#TempSysindexes
   (
     DbName nvarchar(128)
   , TableID int
   , TableName nvarchar(128)
   , TableOwner nvarchar(128)
   , IndexName nvarchar(128)
   , IndexID int
   , IndexKeyString nvarchar(2048)
   , IsPrimaryKey tinyint
   , CnstIsClustKey tinyint
   , IsUniqueConstraint tinyint
   , IndexFillFactor tinyint
   , IsClustered tinyint
   , IsStatistics tinyint
   , IsAutoStatistics tinyint
   , IsHypothetical tinyint
   , IsPadIndex tinyint
   , IsUniqueIndex tinyint
   , IsPageLockDisallowed tinyint
   , IsRowLockDisallowed tinyint
   , CnstIsNonclustKey tinyint
   , CnstIsNotTrusted tinyint
   , FileGroupID int
   , FileGroupName nvarchar(128)
   )



Declare
  @SqlString varchar(4000)

-- Fill temp table with sysindexes information
Set @SqlString = '
Use ' + @DbName + '
Declare
    @TableID int
  , @TableOwner nvarchar(128)
  , @TableName nvarchar(128)
  , @KeyString nvarchar(2048)
  , @IndexName nvarchar(128)
  , @SqlString nvarchar(2000)
  , @cr char(1)


Insert Into dbo.#TempSysindexes
  Select
    DB_NAME() As DbName
  , si.id
  , Object_name(si.id)
  , User_Name(ObjectProperty(si.id, ''OwnerId''))
  , si.name As IndexName
  , si.indid As IndexID
  , '''' As IndexKeyString
  , Coalesce(ObjectProperty(Object_id(si.name), ''IsPrimaryKey''), 0)
  , Coalesce(ObjectProperty(Object_id(si.name), ''CnstIsClustKey''), 0)
  , Coalesce(ObjectProperty(Object_id(si.name), ''IsUniqueCnst''), 0)
  , Coalesce(IndexProperty(si.id, name, ''IndexFillFactor''), 0)
  , Coalesce(IndexProperty(si.id, name, ''IsClustered''), 0)
  , Coalesce(IndexProperty(si.id, name, ''IsStatistics''), 0)
  , Coalesce(IndexProperty(si.id, name, ''IsAutoStatistics''), 0)
  , Coalesce(IndexProperty(si.id, name, ''IsHypothetical''), 0)
  , Coalesce(IndexProperty(si.id, name, ''IsPadIndex''), 0)
  , Coalesce(IndexProperty(si.id, name, ''IsUnique''), 0)
  , Coalesce(IndexProperty(si.id, name, ''IsPageLockDisallowed''), 0)
  , Coalesce(IndexProperty(si.id, name, ''IsRowLockDisallowed''), 0)
  , Coalesce(ObjectProperty(si.id, ''CnstIsNonclustKey''), 0)
  , Coalesce(ObjectProperty(si.id, ''CnstIsNotTrusted''), 0)
  , groupid
  , '''' As FileGroupName
  From sysindexes si
  Where ObjectProperty(si.id, ''IsUserTable'') = 1
  And ObjectProperty(si.id, ''TableHasIndex'') = 1
  And Object_name(si.id) Not Like ''dtproperties''
  And si.indid > 0 and si.indid < 255'
  + Case When @IncludeStatistics = 0 Then '
  And IndexProperty(si.id, name, ''IsStatistics'') = 0' Else '' End +'
  Order By 1,2

Set @TableID = (Select Min(TableID)
  From dbo.#TempSysindexes
  Where IsHypothetical =0)
Select @TableOwner = TableOwner, @TableName = TableName
  From dbo.#TempSysindexes
  Where TableID = @TableID
While @TableID Is Not Null
Begin
  Set @IndexName = (Select Min(IndexName)
    From dbo.#TempSysindexes
    Where TableID = @TableID And IsHypothetical =0)
  While @IndexName Is Not Null
  Begin
    Exec finamigoconsolidado.dbo.usp_GetIndexColumns ' + @DbName+ ', @TableOwner, @TableName, @IndexName, @KeyString OUTPUT, 0
    If @KeyString Is Not Null
      Update dbo.#TempSysindexes
      Set IndexKeyString = @KeyString
      Where TableID = @TableID And IndexName = @IndexName
    Update dbo.#TempSysindexes
      Set FileGroupName = (Select groupname from sysfilegroups where groupid = #TempSysindexes.FileGroupID)
      Where TableID = @TableID and IndexName = @IndexName

    Set @IndexName = (Select Min(IndexName)
      From dbo.#TempSysindexes
      Where TableID = @TableID And IsHypothetical =0
        And IndexName > @IndexName)
   Exec finamigoconsolidado.dbo.usp_ScriptOneIndex ' + @DbName+ ', @TableOwner, @TableName, @IndexName, 1,1, 1
  End
  Set @TableID = (Select Min(TableID)
    From dbo.#TempSysindexes
    Where IsHypothetical =0
      And TableID > @TableID)
  Select @TableOwner = TableOwner, @TableName = TableName
    From dbo.#TempSysindexes
    Where TableID = @TableID

End'
--If @Debug = 1 
Print @SqlString
Exec(@SqlString)

--If @Debug = 1 
Select * From dbo.#TempSysindexes

Return
GO