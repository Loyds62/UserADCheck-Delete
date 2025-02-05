Ce script powershell permet d'aller dans C:/users/ d'un pc distant. Pour chaque utilisateur il va vérifier si le compte existe toujours dans active directory. Si il n'existe plus dans active directory, le programme demande si vous voulez supprimer le dossier.


Les dossiers suivants sont exclus : 

- TEMP
- Public
- Administrateur
- Administrator
- Default
- Postgres
