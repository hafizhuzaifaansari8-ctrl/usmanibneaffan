$rootFiles = Get-ChildItem -Path "c:\Users\HP\usmanibneaffan\*.html"
$courseFiles = Get-ChildItem -Path "c:\Users\HP\usmanibneaffan\courses\*.html"
$allFiles = $rootFiles + $courseFiles

foreach ($file in $allFiles) {
    if ($file.Name -eq "google1f8556e1c77311a5.html") { continue }
    
    $content = Get-Content $file.FullName -Raw
    
    # Root links fixes
    $content = $content -replace 'href="\./"', 'href="index.html"'
    $content = $content -replace 'href="\./#', 'href="index.html#'
    $content = $content -replace 'href="\.\./#', 'href="../index.html#'
    
    # Extension fixes if any missed
    $content = $content -replace 'href="faq"', 'href="faq.html"'
    $content = $content -replace 'href="blog"', 'href="blog.html"'
    $content = $content -replace 'href="index"', 'href="index.html"'
    
    # Remove duplicates like .html.html
    $content = $content -replace '\.html\.html', '.html'
    
    Set-Content $file.FullName $content
}
