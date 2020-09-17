#This is Powershell Scrip
#This script get the required attributes to export all BluePrism Processes and Business Objects

#The output is a dependency matrix in form of a CSV file

 

 

cls 

Write-Output "This will export the dependency matrix of all Processes and Business Objects in BluePrism"

#$WindowsAccount=Read-Host -Prompt 'Input your Windows Account (e.g: "absd-dev1")'

$appvve =Read-Host -Prompt 'Blue Prism appvve (e.g: /appvve:B1956CFC-15FC...) Blank for defalut.'

$dbconname = Read-Host -Prompt 'Blue Prism Connection'

$User=Read-Host -Prompt 'Blue Prism Username'

$Password= Read-Host -assecurestring 'Blue Prism Password'

 

#Decyrpt password

$Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($Password)

$SPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)

 

if (-not $appvve)

{

    $appvve = Read-Host -Prompt "Optional: Blue Prism appvve (e.g: /appvve:B1956CFC-15FC)"

    if (-not $appvve)

    {

        $appvve = "/appvve:B1956CFC-15FC-448D-A4C3-DB4450C316FA_28128CF7-0280-4811-9718-DCE76FEDDE15"

        Write-Host "Using $appvve"

    }

}

 

#cd 'C:\ProgramData\App-V\B1956CFC-15FC-448D-A4C3-DB4450C316FA\28128CF7-0280-4811-9718-DCE76FEDDE15\Root\VFS\ProgramFilesX64\Blue Prism Limited\Blue Prism Automate'

cd 'C:\ProgramData\Microsoft\AppV\Client\Integration\B1956CFC-15FC-448D-A4C3-DB4450C316FA\Root\VFS\ProgramFilesX64\Blue Prism Limited\Blue Prism Automate'

 

$ProcessList=  .\Automatec.exe  $appvve /dbconname $dbconname /user $User $SPassword /listprocesses

cls

if(-not ($ProcessList.Count -gt 1)){

Write-Output $ProcessList

Break

 

}

 

$WorkingDirectory = "H:\BluePrismObjects\$dbconname"

New-Item -ItemType directory -Path "$WorkingDirectory" -Force

pushd "$WorkingDirectory"

try{

 

$ListofObjects=  New-Object System.Collections.ArrayList

 

foreach($process in $ProcessList){

 

$login=C:\ProgramData\Microsoft\AppV\Client\Integration\B1956CFC-15FC-448D-A4C3-DB4450C316FA\Root\VFS\ProgramFilesX64\"Blue Prism Limited"\"Blue Prism Automate"\Automatec.exe  $appvve /dbconname $dbconname /user $User $SPassword /export $process

Write-Host $login  $process

}

 

 

 

#$SaveDirectory= [System.String]::Concat( 'C:\Users\', $WindowsAccount ,'\AppData\Local\Microsoft\AppV\Client\VFS\B1956CFC-15FC-448D-A4C3-DB4450C316FA\ProgramFilesX64\Blue Prism Limited\Blue Prism Automate')

$SaveDirectory= $WorkingDirectory

$xmllist= ls $SaveDirectory

 

$ListofObjects=@()

$ListofObjects.Clear()

 

foreach($xmlfile in $xmllist){

 

 

try{

 

$Path=[System.String]::concat($SaveDirectory, "\", $xmlfile.Name)

 

if(-not (Test-Path -LiteralPath  $Path)) {

 

Write-Host "Path is not found:  " $Path

Continue

}

 

[xml]$xml = Get-Content -LiteralPath $Path

$nodes=$xml.selectNodes('/process/stage/resource') | select object

$nodename=$xml.selectNodes('/process')

$type=[System.String]::Empty

$type=$xml.SelectNodes('/process') | select type

$type=$type.type

if($nodes.Count -eq 0 ){

 

$name=$nodename.name

if(-not $type -eq "object" ){

$name= [string]::Concat(" Process - ",$name)

}

 

 

$ListofObjects+=,($name,[System.String]::Empty)

 

}

 

foreach($node in $nodes){

 

 

$name=$nodename.name

$objectname=$node.object.ToString()

 

if(-not $type -eq "object" ){

$name= [string]::Concat(" Process - ",$name)

}

 

$ListofObjects+=,($name,$objectname)

 

}

}

 

catch [System.Exception] {

   echo $_.Exception.GetType().FullName, $_.Exception.Message

   Continue

  }

}

Write-Host -NoNewline "$(Get-Date -Format G): Searching for objects..."

$ListofObjects= $ListofObjects | select -Unique

 

$parents=@()

$parents.Clear()

 

$children=@()

$children.Clear()

 

 

foreach($obj in $ListofObjects){

Write-Host -NoNewline "."

if(-not ($parents -contains $obj[0])){

 

 

    $parents+=,$obj[0]

   

   

}

 

if(-not ($children -contains $obj[1])){

 

    $children+=,$obj[1]

  

 

}

 

}

Write-Host "Done"

Write-Host -NoNewline "$(Get-Date -Format G): Creating Dependency Matrix Table..."

$totalparents= $parents + $children

 $totalparents=$totalparents | select -Unique

$totalparents=$totalparents | sort

$parents= $totalparents

$children= $totalparents

 

$dataTable= New-Object  System.Data.DataTable

$dataTable.Columns.add((New-Object System.Data.DataColumn  "Column1",([System.String])))

foreach($object in $children){

    Write-Host -NoNewline "."

    if((-not( $object -eq [System.String]::Empty)) )

    {

        $dataTable.Columns.add((New-Object System.Data.DataColumn  $object,([System.String])))

    }

 

}

Write-Host "Done"

 

Write-Host -NoNewline "$(Get-Date -Format G): Searching for direct references"

foreach($parent in $parents)

{

    Write-Host -NoNewline "."

    $row= $dataTable.NewRow()

    $row.Column1=$parent

    foreach($column in $dataTable.Columns)

    {

        if($column.ColumnName -eq $parent)

        {

            $row.$column="S"

        }

        $searchitem= ($parent,$column.ColumnName)

        foreach($lobj in $ListofObjects)

        {

            if(($lobj[0] -eq $searchitem[0]) -and ($lobj[1] -eq $searchitem[1]))

            {

                $row.$column="U"

            }

        }

    }

 

    $dataTable.Rows.Add($row)

}

Write-Host "Done"

$matrixModified = $True

$it = 0

while($matrixModified -eq $True)

{

    $it = $it + 1

    $matrixModified = $False

    Write-Host -NoNewline "$(Get-Date -Format G): Searching for Indirect references $it"

    foreach( $row in $dataTable.Rows)

    {

        Write-Host -NoNewline "."

        foreach($column in $dataTable.Columns)

        {

            if($row.$column.ToString() -eq "U")

            {

                $columnName= $column.ColumnName

                $correspondingRow= $dataTable.NewRow()

                $correspondingRow=$dataTable.Select([System.String]::Format("Column1='{0}'",$columnName))

                if(-not ($row.Column1 -eq $correspondingRow.Column1))

                {

                    foreach($col in $dataTable.Columns)

                    {

                        if( ($correspondingRow.$col.ToString() -eq "U") -or ($correspondingRow.$col.ToString() -eq "IU"))

                        {

                            if ([System.String]::IsNullOrEmpty($row.$col.ToString()))

                            {

                                $matrixModified = $True

                                $row.$col="IU"

                            }

                        }

                    }

                }

            }

        }

    }

    Write-Host "Done"

}

 

$dataTable | Export-csv -Path "H:\$dbconname - DependencyMatrix.csv" -Encoding Unicode -NoTypeInformation

Write-Host "$(Get-Date -Format G): Dependency Matrix exported to H:\$dbconname - DependencyMatrix.csv"

}finally{

popd

Remove-Item -Path $WorkingDirectory -Recurse -Force

}

Pause
