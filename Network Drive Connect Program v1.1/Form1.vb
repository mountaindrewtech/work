'Title: EnterpriseData Reconnect Program
'Version: 1.1.0
'Author: Drew Schmidt
'Date: 11/01/2022

Imports System.Windows.Forms.VisualStyles.VisualStyleElement.StartPanel

Public Class Form1

    'Run reconnect command on button click
    Private Sub btnConnect_Click(sender As Object, e As EventArgs) Handles btnConnect.Click

        ' If textbox is empty do not continue
        If (txtPassword.TextLength = 0) Then
            MessageBox.Show("Please enter a password!")
        ElseIf (txtPassword.TextLength > 30) Then
            MessageBox.Show("Please enter a valid password!")
            txtPassword.Text = String.Empty
        Else
            ' Start CMD as a process and run the reconnect command, enable standard error output
            Dim cmdConnect As New Process()
            Dim cntInfo As New ProcessStartInfo("cmd.exe", "/c net use z: /delete /y & cls & net use z: \\networkpath /user:domain\%username% " + txtPassword.Text + " /p:yes")
            cntInfo.UseShellExecute = False
            cntInfo.CreateNoWindow = True
            cntInfo.RedirectStandardError = True
            cmdConnect.StartInfo = cntInfo
            cmdConnect.Start()

            ' Collect and output the standard errors
            Dim cmdOutput As String
            Using cmdStreamReader As System.IO.StreamReader = cmdConnect.StandardError
                cmdOutput = cmdStreamReader.ReadToEnd()
            End Using

            ' Tell the user if the password is incorrect and clear the text box, otherwise open Z: and close
            If cmdOutput.Contains("The specified network password is not correct.") Then
                MessageBox.Show("Incorrect password!")
                txtPassword.Text = String.Empty
            Else
                '' Process.Start("cmd.exe", "/c start Z:")
                Dim cmdOpen As New Process()
                Dim opnInfo As New ProcessStartInfo("cmd.exe", "/c start Z:")
                opnInfo.UseShellExecute = False
                opnInfo.CreateNoWindow = True
                cmdOpen.StartInfo = opnInfo
                cmdOpen.Start()
                Close()
            End If
        End If

    End Sub

    'Run reconnect command on enter key while focused on textbox
    Private Sub txtPassword_KeyUp(sender As Object, e As KeyEventArgs) Handles txtPassword.KeyUp

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
