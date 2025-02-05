 function Green {
    process { Write-Host $_ -ForegroundColor Green }
}

function Red {
    process { Write-Host $_ -ForegroundColor Red }
}

do {
    $pc = Read-Host "Veuillez saisir le nom du poste"
    $path = "\\$pc\c$\users"

    if (-Not (Test-Path -Path $path)) {
        Write-Output "Le chemin spécifié n'existe pas. Veuillez vérifier et réessayer." | Red
        continue
    }

    $userFolders = Get-ChildItem -Path $path -Directory | Select-Object -ExpandProperty Name

    foreach ($user in $userFolders) {
        if ($user -notin @("temp", "public", "Administrateur", "administrator", "default", "postgres")) {
            $adUser = Get-ADUser -Filter {SamAccountName -eq $user} -ErrorAction SilentlyContinue
            if ($adUser) {
                Write-Output "Utilisateur $user (login: $($adUser.SamAccountName)) existe dans Active Directory." | Green
            } else {
                Write-Output "Utilisateur $user n'existe pas dans Active Directory." | Red
                $confirm = Read-Host "Voulez-vous supprimer le contenu du dossier de l'utilisateur $user ? (o/n)"
                if ($confirm -eq 'o') {
                    try {
                        Get-ChildItem -Path "$path\$user" -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                        Write-Output "Contenu du dossier de l'utilisateur $user supprimé." | Green
                    } catch {
                        Write-Output "Erreur lors de la suppression du contenu du dossier de l'utilisateur $user : $_" | Red
                    }
                } else {
                    Write-Output "Contenu du dossier de l'utilisateur $user conservé." | Red
                }
            }
        }
    }

    $continue = Read-Host "Voulez-vous traiter un autre poste ? (o/n)"
} while ($continue -eq 'o')
