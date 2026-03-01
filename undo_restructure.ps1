$root = "c:\Users\HP\usmanibneaffan"

# 1. Move root level pages back
if (Test-Path "$root\faq\index.html") {
    Move-Item -Path "$root\faq\index.html" -Destination "$root\faq.html" -Force
}
if (Test-Path "$root\blog\index.html") {
    Move-Item -Path "$root\blog\index.html" -Destination "$root\blog.html" -Force
}

# 2. Move course pages back
$courseSubDirs = Get-ChildItem -Path "$root\courses" -Directory
foreach ($dir in $courseSubDirs) {
    $indexPath = Join-Path $dir.FullName "index.html"
    if (Test-Path $indexPath) {
        $newName = "$($dir.Name).html"
        Move-Item -Path $indexPath -Destination (Join-Path "$root\courses" $newName) -Force
    }
}

# 3. Define a function to fix the links/paths back to simple flat .html
function Revert-Paths($filePath, $isSubDir) {
    if (-not (Test-Path $filePath)) { return }
    $c = Get-Content $filePath -Raw
    
    # Fix Assets
    if ($isSubDir) {
        # Was ../../assets/ now should be ../assets/
        $c = $c -replace '(?<=href="|src=")\.\./\.\./assets/', '../assets/'
        $c = $c -replace '(?<=href="|src=")\.\./\.\./style\.css', '../style.css'
        
        # Navigation in courses/*.html
        $c = $c -replace 'href="\.\./\.\./"', 'href="../index.html"'
        $c = $c -replace 'href="\.\./\.\./index\.html"', 'href="../index.html"'
        $c = $c -replace 'href="\.\./"', 'href="index.html"' # Back to courses hub
        $c = $c -replace 'href="\.\./faq/"', 'href="../faq.html"'
        $c = $c -replace 'href="\.\./blog/"', 'href="../blog.html"'
        
        # Fix hash links
        $c = $c -replace '\.\./\.\./#', '../index.html#'
    }
    else {
        # For index.html, faq.html, blog.html, courses/index.html
        $prefix = if ($filePath -like "*courses\index.html") { "../" } else { "./" }
        $targetPrefix = if ($filePath -like "*courses\index.html") { "" } else { "courses/" }

        $c = $c -replace 'href="\./"', 'href="index.html"'
        $c = $c -replace 'href="\.\./"', 'href="../index.html"'
        $c = $c -replace 'href="\./faq/"', 'href="faq.html"'
        $c = $c -replace 'href="faq/"', 'href="faq.html"'
        $c = $c -replace 'href="\.\./faq/"', 'href="../faq.html"'
        $c = $c -replace 'href="\./blog/"', 'href="blog.html"'
        $c = $c -replace 'href="blog/"', 'href="blog.html"'
        $c = $c -replace 'href="\.\./blog/"', 'href="../blog.html"'
        $c = $c -replace 'href="courses/"', 'href="courses/index.html"'
        $c = $c -replace 'href="\./courses/"', 'href="courses/index.html"'
        
        # Fix hash links in root index
        $c = $c -replace 'href="\./#', 'href="index.html#'
        
        # Course detail links
        # href="courses/qaida-basics/" -> href="courses/qaida-basics.html"
        $c = $c -replace 'href="courses/([^/"]+)/"', 'href="courses/$1.html"'
        # If inside courses/index.html: href="qaida-basics/" -> href="qaida-basics.html"
        $c = $c -replace 'href="([^/"]+)/"', 'href="$1.html"'
        
        # Cleanup double .html (if any)
        $c = $c -replace '\.html\.html', '.html'
        # Fix courses/index.html.html back to courses/index.html
        $c = $c -replace 'courses/index\.html\.html', 'courses/index.html'
    }
    
    # Logo in footer / assets cleanup
    $c = $c -replace '(?<!\.\./)assets/', 'assets/' # if depth 0
    # But wait, courses/index.html needs ../assets/
    if ($filePath -like "*courses\index.html") {
        $c = $c -replace '(?<!\.\./)assets/', '../assets/'
    }

    Set-Content $filePath $c
}

# 4. Apply fixes
Revert-Paths "$root\index.html" $false
Revert-Paths "$root\faq.html" $false
Revert-Paths "$root\blog.html" $false
Revert-Paths "$root\courses\index.html" $false

$courseFiles = Get-ChildItem -Path "$root\courses\*.html" | Where-Object { $_.Name -ne "index.html" }
foreach ($file in $courseFiles) {
    Revert-Paths $file.FullName $true
}

# 5. Cleanup empty directories
$dirsToRemove = @("faq", "blog")
foreach ($d in $dirsToRemove) {
    if (Test-Path "$root\$d") { Remove-Item -Path "$root\$d" -Recurse -Force }
}
foreach ($dir in $courseSubDirs) {
    if (Test-Path $dir.FullName) { Remove-Item -Path $dir.FullName -Recurse -Force }
}
