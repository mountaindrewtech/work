'Title: EnterpriseData Reconnect Program
'Author: Drew Schmidt
'Date: 11/01/2022

Imports System.Windows.Forms.VisualStyles.VisualStyleElement.StartPanel

Public Class Form1

    'Run reconnect command on button click
    Private Sub btnConnect_Click(sender As Object, e As EventArgs) Handles btnConnect.Click

        Dim command = "/c net use z: /delete /y & cls & net use z: \\networkpath /user:domain\" + txtUsername.Text + " " + txtPassword.Text + " /p:yes || Timeout 5"

        Process.Start("cmd.exe", command)

        txtUsername.Text = String.Empty
        txtPassword.Text = String.Empty

    End Sub

    'Run reconnect command on enter key - username textbox
    Private Sub txtUsername_KeyDown(sender As Object, e As KeyEventArgs) Handles txtUsername.KeyDown
        If e.KeyCode = Keys.Enter Then
            btnConnect_Click(Nothing, Nothing)
        Else
            Exit Sub
        End If
        e.SuppressKeyPress = True
    End Sub

    'Run reconnect command on enter key - password textbox
    Private Sub txtPassword_KeyDown(sender As Object, e As KeyEventArgs) Handles txtPassword.KeyDown
        If e.KeyCode = Keys.Enter Then
            btnConnect_Click(Nothing, Nothing)
        Else
            Exit Sub
        End If
        e.SuppressKeyPress = True
    End Sub

    'Close program on button click
    Private Sub btnClose_Click(sender As Object, e As EventArgs) Handles btnClose.Click
        Close()
    End Sub

End Class
