param(
    [string]$Root = 'D:\RP_GCP\BTS',
    [switch]$WhatIf
)

$nl = "`r`n"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
$btprojFiles = Get-ChildItem -Path $Root -Filter *.btproj -Recurse -File

foreach ($file in $btprojFiles) {
    $old = [IO.File]::ReadAllText($file.FullName)
    $isBroken = ($old -match 'ToolsVersion="14') -or ($old -match '<ProjectType>local</ProjectType>') -or ($old -match '<VisualStudioProject')
    if (-not $isBroken) {
        Write-Host "Skipped (not broken): $($file.FullName)"
        continue
    }

    $projDir = $file.DirectoryName
    $name = [IO.Path]::GetFileNameWithoutExtension($file.Name)
    $solDir = Split-Path $projDir -Parent

    # Old format keeps the GUID as an attribute of <BIZTALK>; the solution refers to it, so keep it
    $isLegacy = $old -match '<VisualStudioProject'
    if ($isLegacy) {
        $projGuid = [regex]::Match($old, 'ProjectGuid\s*=\s*"(\{[^}]+\})"').Groups[1].Value
    }
    else {
        $projGuid = [regex]::Match($old, '<ProjectGuid>\s*(\{[^}]+\})\s*</ProjectGuid>').Groups[1].Value
    }
    if (-not $projGuid) {
        $projGuid = '{' + ([guid]::NewGuid().ToString().ToUpper()) + '}'
    }

    # Schemas
    $schemaLines = @()
    foreach ($x in Get-ChildItem -Path (Join-Path $projDir 'Schemas') -Filter *.xsd -File -ErrorAction SilentlyContinue) {
        $type = [IO.Path]::GetFileNameWithoutExtension($x.Name)
        $schemaLines += "    <Schema Include=`"Schemas\$($x.Name)`">"
        $schemaLines += "      <TypeName>$type</TypeName>"
        $schemaLines += "      <Namespace>$name.Schemas</Namespace>"
        $schemaLines += '      <SubType>Task</SubType>'
        $schemaLines += '    </Schema>'
    }

    # Orchestrations
    $xlangLines = @()
    foreach ($x in Get-ChildItem -Path (Join-Path $projDir 'Orchestrations') -Filter *.odx -File -ErrorAction SilentlyContinue) {
        $type = [IO.Path]::GetFileNameWithoutExtension($x.Name)
        $xlangLines += "    <XLang Include=`"Orchestrations\$($x.Name)`">"
        $xlangLines += '      <SubType>Task</SubType>'
        $xlangLines += "      <TypeName>$type</TypeName>"
        $xlangLines += "      <Namespace>$name</Namespace>"
        $xlangLines += '    </XLang>'
    }

    # Pipelines
    $pipeLines = @()
    foreach ($x in Get-ChildItem -Path (Join-Path $projDir 'Pipelines') -Filter *.btp -File -ErrorAction SilentlyContinue) {
        $type = [IO.Path]::GetFileNameWithoutExtension($x.Name)
        $pipeLines += "    <Pipeline Include=`"Pipelines\$($x.Name)`">"
        $pipeLines += "      <TypeName>$type</TypeName>"
        $pipeLines += "      <Namespace>$name.Pipelines</Namespace>"
        $pipeLines += '      <SubType>Task</SubType>'
        $pipeLines += '    </Pipeline>'
    }

    # AssemblyInfo and signing key
    $compileLines = @()
    if (Test-Path (Join-Path $projDir 'Properties\AssemblyInfo.cs')) {
        $compileLines += '    <Compile Include="Properties\AssemblyInfo.cs" />'
    }
    $signingLines = @()
    $noneLines = @()
    $snk = Get-ChildItem -Path (Join-Path $projDir 'Fichiers') -Filter *.snk -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($snk) {
        $signingLines += '  <PropertyGroup>'
        $signingLines += '    <SignAssembly>true</SignAssembly>'
        $signingLines += "    <AssemblyOriginatorKeyFile>Fichiers\$($snk.Name)</AssemblyOriginatorKeyFile>"
        $signingLines += '    <DelaySign>False</DelaySign>'
        $signingLines += '  </PropertyGroup>'
        $noneLines += "    <None Include=`"Fichiers\$($snk.Name)`" />"
    }

    # Old format: read references and file items from the XML; the helper is named in its Reference entry
    $helperGuid = ''
    $helperRefName = ''
    $refLines = @()
    if ($isLegacy) {
        $biz = ([xml]$old).VisualStudioProject.BIZTALK
        foreach ($r in $biz.Build.References.Reference) {
            if ($r.GetAttribute('Project')) {
                $helperGuid = $r.GetAttribute('Project')
                $helperRefName = $r.GetAttribute('Name')
                continue
            }
            $asmName = $r.GetAttribute('AssemblyName')
            if ($asmName -match '^(System|System\.Xml|System\.Configuration|Microsoft\.BizTalk\.(DefaultPipelines|GlobalPropertySchemas|Pipeline\.Components))$') {
                continue
            }
            $refLines += "    <Reference Include=`"$asmName`">"
            $refLines += "      <Name>$($r.GetAttribute('Name'))</Name>"
            if ($r.GetAttribute('HintPath')) { $refLines += "      <HintPath>$($r.GetAttribute('HintPath'))</HintPath>" }
            if ($r.GetAttribute('Private')) { $refLines += "      <Private>$($r.GetAttribute('Private'))</Private>" }
            $refLines += '    </Reference>'
        }

        # Web References and other files not already found on disk; Folder entries are not needed
        foreach ($f in $biz.Files.Include.File) {
            $rel = $f.GetAttribute('RelPath')
            if ($rel -match '^(Schemas|Orchestrations|Pipelines|Fichiers)\\') { continue }
            $ext = [IO.Path]::GetExtension($rel).ToLower()
            $tag = 'None'
            if ($ext -eq '.xsd') { $tag = 'Schema' }
            elseif ($ext -eq '.odx') { $tag = 'XLang' }
            $block = @("    <$tag Include=`"$rel`">")
            if ($tag -ne 'None') { $block += '      <SubType>Task</SubType>' }
            if ($f.GetAttribute('DependentUpon')) { $block += "      <DependentUpon>$($f.GetAttribute('DependentUpon'))</DependentUpon>" }
            if ($f.GetAttribute('Generator')) { $block += "      <Generator>$($f.GetAttribute('Generator'))</Generator>" }
            if ($f.GetAttribute('Namespace')) { $block += "      <Namespace>$($f.GetAttribute('Namespace'))</Namespace>" }
            if ($f.GetAttribute('Type')) { $block += "      <TypeName>$($f.GetAttribute('Type'))</TypeName>" }
            $block += "    </$tag>"
            if ($tag -eq 'Schema') { $schemaLines += $block }
            elseif ($tag -eq 'XLang') { $xlangLines += $block }
            else { $noneLines += $block }
        }
    }

    # Helper project: *_Helper.csproj found by name under the root; fall back to the GUID and conventional path from the old file
    $hName = if ($helperRefName) { $helperRefName } else { "$($name)_Helper" }
    $helperLines = @()
    $hGuid = ''
    $hRel = ''
    $helper = Get-ChildItem -Path $Root -Filter "$hName.csproj" -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($helper) {
        $hGuid = [regex]::Match([IO.File]::ReadAllText($helper.FullName), '<ProjectGuid>\s*(\{[^}]+\})\s*</ProjectGuid>').Groups[1].Value
        $hRel = '..\' + $helper.FullName.Substring($solDir.Length + 1)
    }
    if (-not $hGuid) { $hGuid = $helperGuid }
    if ($hGuid -and -not $helper) {
        Write-Host "Warning: $hName.csproj not found under $Root; using ..\$hName\$hName.csproj for $name"
        $hRel = "..\$hName\$hName.csproj"
    }
    if ($hGuid) {
        $helperLines += '  <ItemGroup>'
        $helperLines += "    <ProjectReference Include=`"$hRel`">"
        $helperLines += "      <Project>$hGuid</Project>"
        $helperLines += "      <Name>$hName</Name>"
        $helperLines += '    </ProjectReference>'
        $helperLines += '  </ItemGroup>'
    }

    # External references from the old file (MSBuild format), skipping framework refs and the helper
    foreach ($m in [regex]::Matches($old, '(?s)<Reference Include="([^"]+)"(?:(?!/>).)*?</Reference>')) {
        $inc = $m.Groups[1].Value
        if ($inc -match '^(System|Microsoft\.BizTalk\.)' -or $inc -match '_Helper$') {
            continue
        }
        $refLines += '    ' + $m.Value
    }
    $refLines += '    <Reference Include="Microsoft.BizTalk.DefaultPipelines"><Name>Microsoft.BizTalk.DefaultPipelines</Name></Reference>'
    $refLines += '    <Reference Include="Microsoft.BizTalk.GlobalPropertySchemas"><Name>Microsoft.BizTalk.GlobalPropertySchemas</Name></Reference>'
    $refLines += '    <Reference Include="Microsoft.BizTalk.Pipeline.Components"><Name>Microsoft.BizTalk.Pipeline.Components</Name></Reference>'
    $refLines += '    <Reference Include="System"><Name>System</Name></Reference>'
    $refLines += '    <Reference Include="System.Configuration"><Name>System.configuration</Name></Reference>'
    $refLines += '    <Reference Include="System.Xml"><Name>System.XML</Name></Reference>'

    $template = @'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <Configuration Condition=" '$(Configuration)' == '' ">Development</Configuration>
    <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
    <SchemaVersion>2.0</SchemaVersion>
    <ProjectGuid>{PROJECTGUID}</ProjectGuid>
    <ProjectTypeGuids>{EF7E3281-CD33-11D4-8326-00C04FA0CE8D};{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}</ProjectTypeGuids>
    <OutputType>library</OutputType>
    <GenericProcessing>true</GenericProcessing>
    <RootNamespace>{NAME}</RootNamespace>
    <AssemblyName>{NAME}</AssemblyName>
    <TargetFrameworkVersion>v2.0</TargetFrameworkVersion>
    <BpelCompliance>True</BpelCompliance>
    <TargetFrameworkProfile />
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Development|AnyCPU' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <OutputPath>bin\Development\</OutputPath>
    <DefineConstants>DEBUG;TRACE</DefineConstants>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <WarningLevel>4</WarningLevel>
    <ErrorReport>prompt</ErrorReport>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Deployment|AnyCPU' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <OutputPath>bin\Deployment\</OutputPath>
    <DefineConstants>TRACE</DefineConstants>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <WarningLevel>4</WarningLevel>
    <ErrorReport>prompt</ErrorReport>
  </PropertyGroup>
{SIGNING}
  <ItemGroup>
{REFS}
  </ItemGroup>
  <ItemGroup>
{COMPILE}
{NONE}
  </ItemGroup>
  <ItemGroup>
{SCHEMAS}
  </ItemGroup>
  <ItemGroup>
{XLANG}
  </ItemGroup>
  <ItemGroup>
{PIPELINES}
  </ItemGroup>
{HELPER}
  <Import Project="$(MSBuildToolsPath)\Microsoft.CSharp.targets" />
  <Import Project="$(MSBuildExtensionsPath)\Microsoft\BizTalk\BizTalkC.targets" />
</Project>
'@

    $text = $template.Replace('{PROJECTGUID}', $projGuid).Replace('{NAME}', $name)
    $text = $text.Replace('{SIGNING}', ($signingLines -join $nl))
    $text = $text.Replace('{REFS}', ($refLines -join $nl))
    $text = $text.Replace('{COMPILE}', ($compileLines -join $nl))
    $text = $text.Replace('{NONE}', ($noneLines -join $nl))
    $text = $text.Replace('{SCHEMAS}', ($schemaLines -join $nl))
    $text = $text.Replace('{XLANG}', ($xlangLines -join $nl))
    $text = $text.Replace('{PIPELINES}', ($pipeLines -join $nl))
    $text = $text.Replace('{HELPER}', ($helperLines -join $nl))
    $text = $text.Replace("`r`n", "`n").Replace("`n", $nl)

    if ($WhatIf) {
        Write-Host "Would fix: $($file.FullName)"
        continue
    }

    Copy-Item -Path $file.FullName -Destination ($file.FullName + '.bak') -Force
    [IO.File]::WriteAllText($file.FullName, $text, $utf8Bom)

    # Old per-user file is rejected by MSBuild; move it aside so Visual Studio recreates it
    $userFile = $file.FullName + '.user'
    if ((Test-Path $userFile) -and ([IO.File]::ReadAllText($userFile) -match '<VisualStudioProject')) {
        Move-Item -Path $userFile -Destination ($userFile + '.bak') -Force
        Write-Host "Moved old user file aside: $userFile (.bak)"
    }
    Write-Host "Fixed: $($file.FullName) (backup saved as .bak)"
}
