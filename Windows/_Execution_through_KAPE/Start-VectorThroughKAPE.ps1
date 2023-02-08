function Start-VectorThroughKAPE {
  <#
  .SYNOPSIS

  Execute Vector Windows pipelines through KAPE, to send files to the specified sink(s).

  .PARAMETER TargetPath

  Path with the files to process with Vector.

  .PARAMETER OutputPath

  Path to store Vector console outputs and temporary data directory.

  .PARAMETER Sink

  Specifies the sink(s) to configure, as a comma-separated list.
  Supported sinks: blackhole, console, elk, splunk.

  .PARAMETER Sink

  Specifies the environnement variables to set, as a comma-separted list of key-value pairs (EnvVarName=EnvVarValue).
  The variables may vary depending on the sink(s) configured.
  No checks are performed through the script to ensure that the necessary variables are configured.

  #>

  Param(
    [Parameter(Mandatory=$True)][String] $TargetPath,
    [Parameter(Mandatory=$True)][String] $OutputPath,
    [Parameter(Mandatory=$True)] $Sinks,
    [Parameter(Mandatory=$False)] $EnvVariables
  )

  # Define the Vector_for_IR root folder (.\KAPE\Modules\bin\Vector_for_IR).

  $RootFolder = [IO.Path]::Combine($PSScriptRoot, '..', '..')

  # Set the INPUT_FOLDER containing the files to process with Vector.
  [Environment]::SetEnvironmentVariable("INPUT_FOLDER", $TargetPath.Replace("\", "\\"))
  [Environment]::SetEnvironmentVariable("VECTOR_TEMP_FOLDER", $OutputPath.Replace("\", "\\"))

  # Set the configs under Windows.
  $ConfigCmd = "$([IO.Path]::Combine($RootFolder, 'Windows', 'EZTools', 'Vector_*.toml')),"
  $ConfigCmd += "$([IO.Path]::Combine($RootFolder, 'Windows', 'LogParser', 'Vector_*.toml')),"
  $ConfigCmd += "$([IO.Path]::Combine($RootFolder, 'Windows', 'Winlogbeat', 'Vector_*.toml')),"
  # Set the config(s) for the specified sink(s).
  $SinkArray = $Sinks -Split ','
  Foreach ($Sink in $SinkArray) {
    $ConfigCmd += "$([IO.Path]::Combine($RootFolder, '_Sinks', $($Sink.ToLower() + '.toml'))),"
  }

  # Set the enable API config.
  $ConfigCmd += "$([IO.Path]::Combine($RootFolder, '_Sinks', 'enable_api.toml'))"

  # Sets the environnement variables from the specified comma sepated list $EnvVariables of EnvVarName=EnvVarValue.
  $EnvVariablesArray = $EnvVariables -Split ','
  Foreach ($EnvVariable in $EnvVariablesArray) {
    $EnvVariableSplited = $EnvVariable.Split('=')
    [Environment]::SetEnvironmentVariable($EnvVariableSplited[0], $EnvVariableSplited[1])
  }

  Start-Process -NoNewWindow -Wait "vector.exe" -ArgumentList "-c $($ConfigCmd)" -RedirectStandardOutput "$(Join-Path $OutputPath "Vector_stdout.log")" -RedirectStandardError "$(Join-Path $OutputPath "Vector_stderr.log")"

}
