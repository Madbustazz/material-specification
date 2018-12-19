Attribute VB_Name = "update"
Option Compare Text
Option Base 1

Public Const update_version As String = "3.0"

Function CheckVersion()
    If Ping() Then
        msg_upd = ""
        common_git = DownloadMod("common" & ".bas")
        common_local = ConvTxtNum(common_version)
        If common_git > common_local Then msg_upd = msg_upd & "��������� ����� ������ ������ common -" & CStr(common_git) & vbNewLine
        
        calc_git = DownloadMod("calc" & ".bas")
        calc_local = ConvTxtNum(macro_version)
        If calc_git > calc_local Then msg_upd = msg_upd & "��������� ����� ������ ������ calc -" & CStr(calc_git) & vbNewLine
        
        r = DownloadMod("UserForm2.frx")
        form_git = DownloadMod("UserForm2" & ".bas")
        form_local = ConvTxtNum(UserForm2.form_ver.Caption)
        If form_git > form_local Then msg_upd = msg_upd & "��������� ����� ������ ����� -" & CStr(form_git) & vbNewLine
        
        update_git = DownloadMod("update" & ".bas")
        update_local = ConvTxtNum(update_version)
        If update_git > update_local Then msg_upd = msg_upd & "��������� ����� ������ ������ update -" & CStr(update_git) & vbNewLine
        If Len(msg_upd) > 1 Then
            msg_upd = msg_upd & "������� � ��������� �� ����������?"
            intMessage = MsgBox(msg_upd, vbYesNo, "�������� ����������")
            Set objShell = CreateObject("Wscript.Shell")
            If intMessage = vbYes Then objShell.Run ("https://kuvbur.blogspot.com/")
        End If
    End If
End Function

Function Ping() As Boolean
    Dim oPingResult As Variant
    For Each oPingResult In GetObject("winmgmts://./root/cimv2").ExecQuery _
        ("SELECT * FROM Win32_PingStatus WHERE Address = '" & "github.com" & "'")
        If IsObject(oPingResult) Then
            If oPingResult.StatusCode = 0 Then
                Ping = True
                Exit Function
            End If
        End If
    Next
End Function

Function DownloadMod(ByVal namemod As String) As Variant
    Dim gitdir As String
    gitdir = UserForm2.CodePath & "from_git"
    If Not CreateObject("Scripting.FileSystemObject").FolderExists(gitdir) Then
        MkDir (gitdir)
    End If
    Dim myURL As String
    myURL = "https://raw.githubusercontent.com/kuvbur/material-specification/master/data/code/" & namemod
    Dim WinHttpReq As Object
    Set WinHttpReq = CreateObject("Microsoft.XMLHTTP")
    WinHttpReq.Open "GET", myURL, False
    WinHttpReq.send
    myURL = WinHttpReq.responseBody
    If WinHttpReq.Status = 200 Then
        Set oStream = CreateObject("ADODB.Stream")
        oStream.Open
        oStream.Type = 1
        oStream.Write WinHttpReq.responseBody
        oStream.SaveToFile gitdir & "/" & namemod, 2
        oStream.Close
    End If
    If InStr(namemod, ".bas") > 0 Then
        On Error Resume Next
        Set fso = CreateObject("scripting.filesystemobject")
        Set ts = fso.OpenTextFile(gitdir & "/" & namemod, 1, True): txt$ = ts.ReadAll: ts.Close
        Set ts = Nothing: Set fso = Nothing
        txt = Trim(txt): Err.Clear
        For Each tRows In Split(txt, vbNewLine)
            If InStr(tRows, "version As String =") Then
                Version_file = ConvTxtNum(Split(tRows, """")(1))
            End If
        Next
    Else
        Version_file = 0
    End If
    DownloadMod = Version_file
End Function

Function ExportAllMod() As Boolean
    If Not CreateObject("Scripting.FileSystemObject").FolderExists(UserForm2.CodePath) Then
        MkDir (UserForm2.CodePath)
    End If
    r = ExportMod("UserForm2")
    r = ExportMod("calc")
    r = ExportMod("common")
    r = ExportMod("update")
End Function


Function NameAllMod() As Boolean
    Application.ScreenUpdating = False
    Application.EnableEvents = False
    r = CheckName("UserForm2")
    r = CheckName("calc")
    r = CheckName("common")
    Application.EnableEvents = True
    Application.ScreenUpdating = True
End Function

Function ExportMod(ByVal namemod As String, Optional ByVal pathtmp As String = "") As Boolean
        tdate = ""
        If pathtmp = "old\" Then tdate = "_" & CStr(in_ver) & "_" & Replace(Right(Str(DatePart("yyyy", Now)), 2) & Str(DatePart("m", Now)) & Str(DatePart("d", Now)), " ", "")
        On Error Resume Next
        ThisWorkbook.VBProject.VBComponents.Item(namemod).Export UserForm2.CodePath & pathtmp & namemod & tdate & ".bas"
orkbook.VBProject.VBComponents.Item(namemod).Export UserForm2.CodePath & pathtmp & CStr(in_ver) & "_" & namemod & tdate & ".bas"
End Function

Function IsModFileEx(ByVal namemod As String, Optional ByVal pathtmp As String = "") As Boolean
    On Error Resume Next
    IsModFileEx = CBool(Len(Dir$(UserForm2.CodePath & pathtmp & namemod & ".bas")))
End Function

Function IsModEx(ByVal namemod As String) As Boolean
    On Error Resume Next
    IsModEx = CBool(Len(ThisWorkbook.VBProject.VBComponents(namemod).Name))
End Function

Function ConvTxtNum(ByVal x As Variant) As Variant
    If IsNumeric(x) Then
        out = CDbl(x)
    Else
        x = Trim(x)
        x = Replace(x, ".", ",")
        If IsNumeric(x) Then
            out = CDbl(x)
        Else
            x = Replace(x, ",", ".")
            If IsNumeric(x) Then
                out = CDbl(x)
            Else
                If x = "0" Then
                    out = 0
                Else
                    out = x
                End If
            End If
        End If
    End If
    ConvTxtNum = out
End Function
