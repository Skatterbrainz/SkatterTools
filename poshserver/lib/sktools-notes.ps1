$Global:SkToolsLibNotes = "1.0.0"

function New-NoteAttachment {
    param (
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] 
            [ValidateLength(1,255)]
            [string] $Comment,
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] [string] $ObjectType,
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] [string] $ObjectID
    )
    $xmlfile = Join-Path -Path $HomeDirectory -ChildPath "notes\notes.xml"
    if (!(Test-Path $xmlfile)) {
        return -1
    }
    else {
        try {
            $doc = [xml](Get-Content -Path $xmlfile)
            $note = $doc.notes.note[0].clone()
            $note.date = "$(Get-Date)"
            $note.author = $PoshUserName
            $note.otype = $ObjectType
            $note.oid = $ObjectID
            $note.comment = $Comment
            $doc.DocumentElement.AppendChild($note)
            $doc.Save($xmlfile)
            return 0
        }
        catch {
            return $Error[0].Exception.Message
        }
    }
}

function Get-NoteAttachments {
    param (
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] [string] $ObjectType,
        [parameter(Mandatory=$True)] [ValidateNotNullOrEmpty()] [string] $ObjectID
    )
    $xmlfile = Join-Path -Path $HomeDirectory -ChildPath "notes\notes.xml"
    if (!(Test-Path $xmlfile)) {
        return -1
    }
    else {
        try {
            $doc = [xml](Get-Content -Path $xmlfile)
            return $doc.notes.note | ?{$_.otype -eq $ObjectType -and $_.oid -eq $ObjectID}
        }
        catch {
            return ""
        }
    }
}

function Show-NoteAttachments {
    param (
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ObjectType,
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ObjectName,
        [parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string] $ReturnBaseLink,
        [parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string] $ReturnBaseSearchField = ""
    )
    $notes = Get-NoteAttachments -ObjectType $ObjectType -ObjectID $ObjectName
    $output = "<table id=table1>"
    $output += "<tr><th style=`"width:200px`">Date</th>"
    $output += "<th style=`"width:200px`">Author</th><th>Comment</th></tr>"
    if ($notes.count -gt 0) {
        foreach ($note in $notes) {
            $output += "<tr><td>$($note.date)</td>"
            $output += "<td>$($note.author)</td>"
            $output += "<td>$($note.comment)</td></tr>"
        }
    }
    else {
        $output += "<tr><td colspan='3'>No Notes were found</td></tr>"
    }
    $output += "</table><br/>"
    $output += "<form name='form1' id='form1' method='post' action='attachnote.ps1'>"
    $output += "<input type='hidden' name='otype' id='otype' value='$ObjectType' />"
    $output += "<input type='hidden' name='oid' id='oid' value='$ObjectName' />"
    $output += "<input type='submit' class='button1' name='ok' id='ok' value='Add Note' />"
    $output += "</form>"
    return $output
}

