# Script PowerShell pour créer des port-forwards pour tous les services
Write-Host "Demarrage des port-forwards pour tous les microservices..." -ForegroundColor Green

# Fonction pour démarrer un port-forward en arrière-plan
function Start-PortForward {
    param(
        [string]$ServiceName,
        [int]$LocalPort,
        [int]$ServicePort
    )
    
    $job = Start-Job -ScriptBlock {
        param($svc, $lport, $sport)
        kubectl port-forward service/$svc ${lport}:${sport}
    } -ArgumentList $ServiceName, $LocalPort, $ServicePort
    
    Write-Host "Port-forward demarre pour $ServiceName : localhost:$LocalPort -> $ServicePort" -ForegroundColor Yellow
    return $job
}

# Démarrer tous les port-forwards
$jobs = @()
$jobs += Start-PortForward -ServiceName "user-service" -LocalPort 3001 -ServicePort 3001
$jobs += Start-PortForward -ServiceName "product-service" -LocalPort 3002 -ServicePort 3002
$jobs += Start-PortForward -ServiceName "order-service" -LocalPort 3003 -ServicePort 3003
$jobs += Start-PortForward -ServiceName "notification-service" -LocalPort 3004 -ServicePort 3004

Write-Host ""
Write-Host "🌐 Services accessibles sur :" -ForegroundColor Cyan
Write-Host "   User Service: http://localhost:3001/health" -ForegroundColor White
Write-Host "   Product Service: http://localhost:3002/health" -ForegroundColor White
Write-Host "   Order Service: http://localhost:3003/health" -ForegroundColor White
Write-Host "   Notification Service: http://localhost:3004/health" -ForegroundColor White
Write-Host "   API Documentation: http://localhost:3004/docs" -ForegroundColor White
Write-Host ""
Write-Host "Attente de 5 secondes pour que les port-forwards se stabilisent..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "Test de connectivite..." -ForegroundColor Green

# Tester chaque service
$services = @(
    @{Name="User Service"; Url="http://localhost:3001/health"},
    @{Name="Product Service"; Url="http://localhost:3002/health"},
    @{Name="Order Service"; Url="http://localhost:3003/health"},
    @{Name="Notification Service"; Url="http://localhost:3004/health"}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $($service.Name) : OK" -ForegroundColor Green
        } else {
            Write-Host "❌ $($service.Name) : Status $($response.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "Erreur de connexion au $($service.Name)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Instructions :" -ForegroundColor Cyan
Write-Host "   - Les port-forwards sont maintenant actifs en arriere-plan" -ForegroundColor White
Write-Host "   - Vous pouvez acceder aux services via les URLs ci-dessus" -ForegroundColor White
Write-Host "   - Pour arreter tous les port-forwards, utilisez : Get-Job | Stop-Job" -ForegroundColor White
Write-Host "   - Pour voir l'etat des jobs : Get-Job" -ForegroundColor White
