$root = "c:\Users\HP\usmanibneaffan"

# Individual Courses (Depth 2) header fix
$courseDirs = Get-ChildItem -Path "$root\courses" -Directory
foreach ($dir in $courseDirs) {
    $path = "$($dir.FullName)\index.html"
    if (Test-Path $path) {
        $c = Get-Content $path -Raw
        
        # Navigation in Header
        # Home
        $c = $c -replace 'href="\.\./\.\./index\.html"', 'href="../../"'
        # Courses Link (should go back one level to courses hub)
        $c = $c -replace 'href="\.\./\.\./"', 'href="../"'
        
        # Articles (blog)
        $c = $c -replace 'href="\.\./\.\./blog\.html"', 'href="../../blog/"'
        
        # Canonical link fix if any
        $c = $c -replace 'https://usmanibneaffan.com/courses/([^/"]+)\.html', 'https://usmanibneaffan.com/courses/$1'
        
        Set-Content $path $c
    }
}

# Root index.html cleanup
$ridx = Get-Content "$root\index.html" -Raw
$ridx = $ridx -replace 'href="faq/"', 'href="./faq/"'
$ridx = $ridx -replace 'href="blog/"', 'href="./blog/"'
$ridx = $ridx -replace 'href="courses/"', 'href="./courses/"'
Set-Content "$root\index.html" $ridx
