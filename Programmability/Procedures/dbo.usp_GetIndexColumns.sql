SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[usp_GetIndexColumns]
    @DbName varchar(40)
  , @TableOwner nvarchar(128)
  , @TableName nvarchar(128)
  , @IndName varchar(100)
  , @KeyString varchar(1000) OUTPUT
  , @Debug tinyint = 0
As
-- Declare variables to use in this example.
DECLARE @KeyNo int
  , @cmd varchar(1000)

CREATE TABLE #keycolumns (
  KeyNo int
  , ColName sysname
  , ColOrderDesc tinyint)


Set @cmd = '
  Use ' + @DbName + '
  Declare @KeysTableID int
  Set @KeysTableID = Object_ID(''' + rtrim(@TableOwner) + '.' + rtrim(@TableName) + ''')
  Insert Into #keycolumns
  Select
      sk.keyno
    , ''['' + Rtrim(sc.name) + '']''
    , Case When Indexkey_Property(@KeysTableID, si.indid, sk.keyno, ''IsDescending'') = 1 Then 1 Else 0 End
    From ' + @DbName + '.dbo.Syscolumns sc
    Join ' + @DbName + '.dbo.Sysobjects so
      On so.id = sc.id And so.id = @KeysTableID
    Join ' + @DbName + '.dbo.Sysindexes si
      On si.id = so.id And si.name = ''' + @IndName + '''
    Join ' + @DbName + '.dbo.Sysindexkeys sk
      On sk.id = so.id
      And sk.indid = si.indid
      And sk.colid = sc.colid
  Order by sk.keyno'
If @Debug = 1 Print @cmd
Exec (@cmd)
If @Debug = 1 Select * From #keycolumns
-- Create the string
Set @KeyNo = Null
Set @KeyNo = (Select Min(KeyNo) From #Keycolumns)
If @KeyNo Is Not Null
  Begin
  Set @KeyString = (Select ColName + Case When ColOrderDesc = 1 Then ' DESC' Else '' End
    From #Keycolumns Where KeyNo = @KeyNo)
  End
Set @KeyNo = (Select Min(KeyNo) From #Keycolumns Where KeyNo > @KeyNo)
While @KeyNo Is Not Null
Begin
  Set @KeyString = @KeyString + ', ' + (Select ColName + Case When ColOrderDesc = 1 Then ' DESC' Else '' End
    From #Keycolumns Where KeyNo = @KeyNo)
  If @Debug = 1 Print @KeyString
  Set @KeyNo = (Select Min(KeyNo) From #Keycolumns Where KeyNo > @KeyNo)
End
GO