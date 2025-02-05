function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function Red
{
    process { Write-Host $_ -ForegroundColor Red }
}

do {
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
        if ($user -ne "temp" -and $user -ne "public" -and $user -ne "Administrateur" -and $user -ne "administrator" -and $user -ne "default" -and $user -ne "postgres") {
            $adUser = Get-ADUser -Filter {SamAccountName -eq $user} -ErrorAction SilentlyContinue
            if ($adUser) {
                Write-Output "Utilisateur $user (login: $($adUser.SamAccountName)) existe dans Active Directory." | Green
            } else {
                Write-Output "Utilisateur $user n'existe pas dans Active Directory." | Red
                $confirm = Read-Host "Voulez-vous supprimer le dossier de l'utilisateur $user ? (o/n)"
                if ($confirm -eq 'o') {
                    Remove-Item -Path "$path\$user" -Recurse -Force
                    Write-Output "Dossier de l'utilisateur $user supprimé." | Green
                } else {
                    Write-Output "Dossier de l'utilisateur $user conservé." | Red
                }
            }
        }
    }

    # Demander à l'utilisateur s'il veut traiter un autre poste
    $continue = Read-Host "Voulez-vous traiter un autre poste ? (o/n)"
} while ($continue -eq 'o')