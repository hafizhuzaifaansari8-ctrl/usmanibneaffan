$root = "c:\Users\HP\usmanibneaffan"

# Function to clean up any remaining directory-style links and force .html
function Final-Cleanup($filePath) {
    if (-not (Test-Path $filePath)) { return }
    $c = Get-Content $filePath -Raw
    
    # 1. Fix Root Links
    $c = $c -replace 'href="\./"', 'href="index.html"'
    $c = $c -replace 'href="\.\./"', 'href="../index.html"'
    if ($filePath -like "*courses\index.html") {
        $c = $c -replace 'href="index\.html"', 'href="index.html"' # stays relative
    }
    
    # 2. Fix Directory Links back to .html
    # Root level
    $c = $c -replace 'href="faq/"', 'href="faq.html"'
    $c = $c -replace 'href="blog/"', 'href="blog.html"'
    $c = $c -replace 'href="courses/"', 'href="courses/index.html"'
    $c = $c -replace 'href="\./faq/"', 'href="faq.html"'
    $c = $c -replace 'href="\./blog/"', 'href="blog.html"'
    $c = $c -replace 'href="\./courses/"', 'href="courses/index.html"'

    # Parent level (from inside courses folder)
    $c = $c -replace 'href="\.\./faq/"', 'href="../faq.html"'
    $c = $c -replace 'href="\.\./blog/"', 'href="../blog.html"'
    
    # Double parent (Depth 2 left-overs)
    $c = $c -replace 'href="\.\./\.\./blog/"', 'href="../blog.html"'
    $c = $c -replace 'href="\.\./\.\./faq/"', 'href="../faq.html"'
    $c = $c -replace 'href="\.\./\.\./"', 'href="../index.html"'

    # Course individual links
    $c = $c -replace 'href="courses/([^/"]+)/"', 'href="courses/$1.html"'
    $c = $c -replace 'href="\.\./([^/"]+)/"', 'href="$1.html"' # relative in courses
    $c = $c -replace 'href="([^/"]+)/"', 'href="$1.html"' # relative in courses hub
    
    # 3. Fix Assets (Double depth check)
    $c = $c -replace 'src="\.\./\.\./assets/', 'src="../assets/'
    $c = $c -replace 'href="\.\./\.\./assets/', 'href="../assets/'
    $c = $c -replace 'href="\.\./\.\./style\.css"', 'href="../style.css"'

    # 4. Final duplicate cleanup
    $c = $c -replace '\.html\.html', '.html'
    $c = $c -replace 'index\.html\.html', 'index.html'

    Set-Content $filePath $c
}

# Apply to all
$allHtml = Get-ChildItem -Path "$root" -Filter "*.html" -Recurse
foreach ($f in $allHtml) {
    Final-Cleanup $f.FullName
}
