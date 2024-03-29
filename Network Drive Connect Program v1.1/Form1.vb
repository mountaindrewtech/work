'Title: EnterpriseData Reconnect Program
'Version: 1.3
'Author: Drew Schmidt
'Date: 03/06/2023

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
            Dim cmdClose As New Process()
            Dim clsInfo As New ProcessStartInfo("cmd.exe", "/c net use z: /delete /y")
            clsInfo.UseShellExecute = False
            clsInfo.CreateNoWindow = True
            cmdClose.StartInfo = clsInfo
            cmdClose.Start()

            Dim cmdConnect As New Process()
            Dim cntInfo As New ProcessStartInfo("cmd.exe", "/c cls & cmdkey /add:255.255.255.255 /user:XXXX\%username% /pass:" + txtPassword.Text + "& net use z: \\255.255.255.255\Folder /p:yes")
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

            ' Tell the user if the password is incorrect and clear the text box, connect and open, or let the user know they can't reach it.
            If cmdOutput.Contains("The network name cannot be found.") Then
                MessageBox.Show("Cannot reach EnterpriseData, please check your network connection/VPN!")
                txtPassword.Text = String.Empty
            ElseIf cmdOutput.Contains("The specified network password is not correct.") Then
                MessageBox.Show("Incorrect password!")
                txtPassword.Text = String.Empty
            Else
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
