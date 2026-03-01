# 1. Root index.html fixes
$root = "c:\Users\HP\usmanibneaffan"
$idx = Get-Content "$root\index.html" -Raw
$idx = $idx -replace 'href="index\.html"', 'href="./"'
$idx = $idx -replace 'href="faq\.html"', 'href="faq/"'
$idx = $idx -replace 'href="blog\.html"', 'href="blog/"'
$idx = $idx -replace 'href="courses/index\.html"', 'href="courses/"'
# Update course detail links inside root index.html
$idx = $idx -replace 'href="courses/([^"]+)\.html"', 'href="courses/$1/"'
Set-Content "$root\index.html" $idx

# 2. FAQ and Blog Fixes (Depth 1)
$folders1 = @("faq", "blog")
foreach ($f in $folders1) {
    $path = "$root\$f\index.html"
    if (Test-Path $path) {
        $c = Get-Content $path -Raw
        # Fix assets and styles (ensure they point one level up)
        $c = $c -replace '(?<!\.\./)assets/', '../assets/'
        $c = $c -replace '(?<!\.\./)style\.css', '../style.css'
        
        # Navigation
        $c = $c -replace 'href="index\.html"', 'href="../"'
        $c = $c -replace 'href="faq\.html"', 'href="../faq/"'
        $c = $c -replace 'href="blog\.html"', 'href="../blog/"'
        $c = $c -replace 'href="courses/"', 'href="../courses/"'
        $c = $c -replace 'href="courses/index\.html"', 'href="../courses/"'
        
        # Fix hash links
        $c = $c -replace '(?<!\.\./)index\.html#', '../#'
        
        Set-Content $path $c
    }
}

# 3. Courses Hub (Already at Depth 1)
$path = "$root\courses\index.html"
if (Test-Path $path) {
    $c = Get-Content $path -Raw
    $c = $c -replace 'href="\.\./index\.html"', 'href="../"'
    $c = $c -replace 'href="\.\./faq\.html"', 'href="../faq/"'
    $c = $c -replace 'href="\.\./blog\.html"', 'href="../blog/"'
    $c = $c -replace 'href="index\.html"', 'href="./"'
    
    # Update individual course links in Hub
    $c = $c -replace 'href="([^"]+)\.html"', 'href="$1/"'
    
    # Ensure assets stay ../
    $c = $c -replace '(?<!\.\./)assets/', '../assets/'
    
    Set-Content $path $c
}

# 4. Individual Courses (Depth 2 from root, Depth 1 from Courses Hub)
$courseDirs = Get-ChildItem -Path "$root\courses" -Directory
foreach ($dir in $courseDirs) {
    $path = "$($dir.FullName)\index.html"
    if (Test-Path $path) {
        $c = Get-Content $path -Raw
        
        # Fix base root links (need ../../)
        $c = $c -replace '(?<!\.\./\.\./)assets/', '../../assets/'
        $c = $c -replace '(?<!\.\./\.\./)style\.css', '../../style.css'
        $c = $c -replace 'href="\.\./index\.html"', 'href="../../"'
        $c = $c -replace 'href="\.\./faq\.html"', 'href="../../faq/"'
        $c = $c -replace 'href="\.\./blog\.html"', 'href="../../blog/"'
        
        # Fix link to Courses Hub (need ../)
        $c = $c -replace 'href="index\.html"', 'href="../"'
        
        # Fix hash links
        $c = $c -replace '\.\./index\.html#', '../../#'
        
        # Clean up any potential triple levels from previous run
        $c = $c -replace '\.\./\.\./\.\./', '../../'
        
        Set-Content $path $c
    }
}
