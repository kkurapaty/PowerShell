Import-Module oh-my-posh
oh-my-posh prompt init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/v$(oh-my-posh --version)/themes/mt.omp.json | Invoke-Expression

## Install-Module PSReadLine -Force
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView