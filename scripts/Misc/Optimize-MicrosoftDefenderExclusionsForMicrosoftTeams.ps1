<#
      .SYNOPSIS
      Add Defender Antivirus Exclusions for the Teams Desktop Client for a given User

      .DESCRIPTION
      Add Defender Antivirus Exclusions for the Teams Desktop Client for a given User

      .PARAMETER Username
      Username to apply the exclusion to.
      Please Note: The user 'john.doe' in the domain 'CONTOSO' will have the username 'john.doe.CONTOSO'. This is the case to have the connect Directory (Windows naming convention).

      .EXAMPLE
      PS C:\> .\Optimize-MicrosoftDefenderExclusionsForMicrosoftTeams.ps1 -Username 'john.doe.CONTOSO'

      Apply the Defender Antivirus Exclusions for the user 'john.doe' in the domain 'CONTOSO'.
      In this case, the $env:USERPROFILE Directory will be 'C:\Users\john.doe.CONTOSO'

      .NOTES
      This is a more flexible version of Add-DefenderExclusionsForMicrosoftteams.ps1 that brings username as a parameter.
      I crerated this because my user does NOT have Admin permissions on my local windows boxes and with this version, I can apply it with my admin account, biut for my regular user (or any other user on the local system)

      Do not just use set-mppreference here, this might remove any existing exclusions.
      Might be the right thing to do, but with add-mppreference you append to the list (if exists).

      .LINK
      https://gist.github.com/jhochwald/866ce1c5ac894397979f38fa9720b8ff

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/defender/add-mppreference

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param
(
   [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 0,
      HelpMessage = 'Username to apply the exclusion to.')]
   [ValidateNotNullOrEmpty()]
   [Alias('User', 'Name')]
   [string]
   $Username
)

begin
{
   $ExcludePathList = @(
      ('C:\Users\' + $Username + '\Microsoft\Teams\Update.exe'),
      ('C:\Users\' + $Username + '\Microsoft\Teams\current\Teams.exe'),
      ('C:\Users\' + $Username + '\Microsoft\Teams\'),
      ('C:\Users\' + $Username + '\Microsoft\Teams\')
   )
}

process
{
   # Loop over the list we created
   foreach ($ExcludePath in $ExcludePathList)
   {
      try
      {
         # Splat the parameters for Add-MpPreference
         $SplatAddMpPreference = @{
            ExclusionPath = $ExcludePath
            Force         = $true
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
         }
         $null = (Add-MpPreference @SplatAddMpPreference)
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = @{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         # Error Stack
         $info | Out-String | Write-Verbose

         # Just display the info on continue with the rest of the list
         Write-Warning -Message ($info.Exception) -ErrorAction Continue -WarningAction Continue

         # Cleanup
         $info = $null
         $e = $null
         #endregion ErrorHandler
      }
   }
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2021, enabling Technology
   All rights reserved.

   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
   DISCLAIMER:
   - Use at your own risk, etc.
   - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
   - This is a third-party Software
   - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
   - The Software is not supported by Microsoft Corp (MSFT)
   - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
