function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function Red
{
    process { Write-Host $_ -ForegroundColor Red }
}

function Remove-Folder {
    param (
        [string]$folderPath
    )
    Remove-Item -Path $folderPath -Recurse -Force
    Write-Output "Dossier $folderPath supprimé." | Red
}

while ($true) {
    # Demander à l'utilisateur de saisir le nom du poste
    $pc = Read-Host "Veuillez saisir le nom du poste"
    $path="\\$pc\c$\users"

    # Vérifier si le chemin existe
    if (-Not (Test-Path -Path $path)) {
        Write-Output "Le chemin spécifié n'existe pas. Veuillez vérifier et réessayer."
        continue
    }

    # Obtenir la liste des dossiers utilisateurs
    $userFolders = Get-ChildItem -Path $path -Directory | Select-Object -ExpandProperty Name

    # Vérifier chaque dossier utilisateur dans Active Directory
    foreach ($user in $userFolders) {
        if ($user -ne "temp" -and $user -ne "public") {
            $adUser = Get-ADUser -Filter {SamAccountName -eq $user} -ErrorAction SilentlyContinue
            if ($adUser) {
                Write-Output "Utilisateur $user (login: $($adUser.SamAccountName)) existe dans Active Directory." | Green
            } else {
                Write-Output "Utilisateur $user n'existe pas dans Active Directory." | Red
                Remove-Folder -folderPath "$path\$user"
            }
        }
    }

    # Demander à l'utilisateur s'il veut recommencer
    $recommencer = Read-Host "Voulez-vous recommencer ? (oui/non)"
    if ($recommencer -ne "oui") {
        break
    }
}
