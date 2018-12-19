Attribute VB_Name = "common"
Option Compare Text
Option Base 1

Public Const common_version As String = "3.6"
Public Const Pi As Double = 3.141592653589
Public ank_data As Variant
Public Function GetLeghtByID(id As String, table As Range, n_col_id As Integer, n_col_l As Integer) As Variant
    Sum_l = 0
    For i = 1 To table.Rows.Count
        If table(i, n_col_id) = id Then Sum_l = Sum_l + table(i, n_col_l)
    Next i
    GetLeghtByID = Sum_l
End Function

Public Function SetPlast_T(diam As Integer) As String
    Select Case diam
        Case 16
            SetPlast_T = "-- 8"
        Case 20, 22
            SetPlast_T = "-- 10"
        Case 25, 28
            SetPlast_T = "-- 14"
    End Select
End Function

Private Function set_ank_data()
    Set ank_data = CreateObject("Scripting.Dictionary")
    'Rbt
    ank_data.Item("7.5") = 0.48
    ank_data.Item("10") = 0.57
    ank_data.Item("12.5") = 0.66
    ank_data.Item("15") = 0.75
    ank_data.Item("20") = 0.9
    ank_data.Item("25") = 1.05
    ank_data.Item("30") = 1.2
    ank_data.Item("35") = 1.3
    ank_data.Item("40") = 1.4
    ank_data.Item("45") = 1.45
    ank_data.Item("50") = 1.55
    ank_data.Item("55") = 1.6
    ank_data.Item("60") = 1.65
    'Rs
    ank_data.Item("A-I(A240)") = 210
    ank_data.Item("A-III(A400)") = 350
    ank_data.Item("A500C") = 435
    'n
    ank_data.Item("���_������") = 0.75
    ank_data.Item("���_����������") = 1
    ank_data.Item("���_�������") = 2
    
    ank_data.Item("����_������") = 0.9
    ank_data.Item("����_����������") = 1.2
    ank_data.Item("����_�������") = 2
End Function

Private Function get_lo_arm(ByVal diam As Integer, ByVal class As String, beton As String) As Double
    set_ank_data
    beton = Trim(Replace(Replace(beton, "B", ""), "�", ""))
    Rs = ank_data.Item(class)
    Rbt = ank_data.Item(beton)
    Rbond = 2.5 * 1 * Rbt
    Areas = Pi * (diam * diam) / 4
    Perims = Pi * diam
    lo = (Rs * Areas) / (Rbond * Perims)
    get_lo_arm = lo
End Function

Public Function ���_���������(ByVal diam As Integer, ByVal class As String, ByVal beton As String, _
                            Optional ByVal kseism As Double = 1, _
                            Optional ByVal type_arm As String = "����������", _
                            Optional ByVal type_out As String = "L") As Variant
    type_out = StrConv(type_out, vbUpperCase)
    If type_out <> "L" And type_out <> "D" Then type_out = "L"
    type_arm = "���_" + StrConv(type_arm, vbLowerCase)
    If type_arm <> "���_����������" And type_arm <> "���_������" And type_arm <> "���_�������" Then type_arm = "���_����������"
    If kseism <= 0.9 Then kseism = 1
    If kseism >= 2 Then kseism = 1.3
    
    lo = get_lo_arm(diam, class, beton)
    al = ank_data.Item(type_arm)
    L = al * lo * kseism
    l1 = 15 * diam
    l2 = 200
    l3 = 0.3 * lo
    lout = Application.WorksheetFunction.Max(L, l1, l2, l3)
    krat = "5��"
    lout = ���_����������(lout, krat)
    Select Case StrConv(type_out, vbUpperCase)
        Case "L"
            ���_��������� = lout
        Case "D"
            ���_��������� = Round((lout / diam), 2) & "d"
    End Select
    If Not ank_data.Exists(class) Then ���_��������� = "������ ������"
    If Not ank_data.Exists(beton) Then ���_��������� = "������ ������"
End Function

Public Function ���_����������(ByVal L As Long, Optional ByVal krat As String = "10��") As Long
    lout = L
    krat_n = 5
    If krat = "5��" Then krat_n = 5
    If krat = "10��" Then krat_n = 10
    l_round = Round(L / krat_n) * krat_n
    If l_round < L Then
        lout = l_round + krat_n
    Else
        lout = l_round
    End If
    ���_���������� = lout
End Function

Public Function ���_������(ByVal diam As Integer, ByVal class As String, ByVal beton As String, _
                            Optional ByVal kseism As Double = 1, _
                            Optional ByVal type_arm As String = "����������", _
                            Optional ByVal type_out As String = "L") As Variant
    If diam > 40 Then
        ������ = "������� ������ 40"
        Exit Function
    End If
    type_out = StrConv(type_out, vbUpperCase)
    If type_out <> "L" And type_out <> "D" Then type_out = "L"
    type_arm = "����_" + StrConv(type_arm, vbLowerCase)
    If type_arm <> "����_����������" And type_arm <> "����_������" And type_arm <> "����_�������" Then type_arm = "����_����������"
    If kseism <= 0.9 Then kseism = 1
    If kseism >= 2 Then kseism = 1.3
    lo = get_lo_arm(diam, class, beton)
    al = ank_data.Item(type_arm)
    L = al * lo * kseism
    l1 = 20 * diam
    l2 = 250
    l3 = 0.4 * al * lo
    lout = Application.WorksheetFunction.Max(L, l1, l2, l3)
    krat = "5��"
    lout = ���_����������(lout, krat)
    Select Case StrConv(type_out, vbUpperCase)
        Case "L"
            ���_������ = lout
        Case "D"
            ���_������ = Round((lout / diam), 2) & "d"
    End Select
End Function

Public Function ���_���������(ByVal diam As Integer, ByVal class As String) As Double
    d_opr = 0
    If class = "A-I(A240)" Or class = "��-I" Then
        If diam < 20 Then
            d_opr = 2.5 * diam
        Else
            d_opr = 4 * diam
        End If
    Else
        If diam < 20 Then
            d_opr = 5 * diam
        Else
            d_opr = 8 * diam
        End If
    End If
    r_opr = d_opr / 2
    r_arm = diam / 2
    ���_��������� = r_opr + r_arm
End Function

Public Function ���_�������_�(ByVal L As Variant, ByVal H As Variant, ByVal diam As Integer, ByVal class As String, Optional ByVal Lniz As Integer = 0) As Double
    If Lniz = 0 Then Lniz = L
    agib = 90
    r = ���_���������(diam, class)
    lr = (Pi * r * agib) / 180
    lout = L + Lniz + H - 4 * r + 2 * lr
    krat = "10��"
    lout = ���_����������(lout, krat)
    ���_�������_� = lout
End Function

Public Function ���_�������_�(ByVal L As Variant, ByVal H As Variant, ByVal diam As Integer, ByVal class As String) As Double
    agib = 90
    r = ���_���������(diam, class)
    lr = (Pi * r * agib) / 180
    lout = L + H - 2 * r + lr
    krat = "10��"
    lout = ���_����������(lout, krat)
    ���_�������_� = lout
End Function

Public Function ���_�����_��(ByVal L As Variant, ByVal lnahl As Variant, Optional ByVal led As Variant = 11700) As Long
    n_nahl = Round(L / led)
    If n_nahl * led < L Then n_nahl = n_nahl + 1
    lout = L + lnahl * n_nahl
    lout = ���_����������(lout)
    ���_�����_�� = lout
End Function

Public Function ���_���������(S As Variant, shag As Variant, ByVal lnahl As Integer, Optional ByVal led As Integer = 11700) As Long
    L = Sqr(S) + (S / shag)
    lout = ���_�����_��(L, lnahl, led)
    ���_��������� = lout
End Function

Public Function SetPlast_Razm(diam As Integer) As String
    Select Case diam
        Case 16
            SetPlast_Razm = "100*100"
        Case 20, 22
            SetPlast_Razm = "120*120"
        Case 25, 28
            SetPlast_Razm = "150*150"
    End Select
End Function




