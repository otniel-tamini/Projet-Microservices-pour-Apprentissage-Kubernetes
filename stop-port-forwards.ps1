# Script PowerShell pour arrêter tous les port-forwards
Write-Host "🛑 Arrêt des port-forwards..." -ForegroundColor Yellow

# Arrêter tous les jobs en cours
$jobs = Get-Job
if ($jobs) {
    Write-Host "📋 Jobs trouvés : $($jobs.Count)" -ForegroundColor Cyan
    foreach ($job in $jobs) {
        Write-Host "   - Arrêt du job $($job.Id) : $($job.Name)" -ForegroundColor White
        Stop-Job -Job $job
        Remove-Job -Job $job
    }
    Write-Host "✅ Tous les port-forwards ont été arrêtés" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Aucun port-forward actif trouvé" -ForegroundColor Blue
}

# Vérifier s'il reste des processus kubectl port-forward
$processes = Get-Process kubectl -ErrorAction SilentlyContinue
if ($processes) {
    Write-Host "🔍 Processus kubectl trouvés, arrêt en cours..." -ForegroundColor Yellow
    $processes | Stop-Process -Force
    Write-Host "✅ Processus kubectl arrêtés" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Aucun processus kubectl actif" -ForegroundColor Blue
}

Write-Host ""
Write-Host "🎯 Nettoyage terminé !" -ForegroundColor Green
