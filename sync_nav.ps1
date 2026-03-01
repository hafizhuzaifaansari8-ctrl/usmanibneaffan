$root = "c:\Users\HP\usmanibneaffan"

# --- 1. Fix Individual Courses (Depth 2) ---
$header2 = @"
            <nav class="nav-menu">
                <a href="../../" class="nav-link">Home</a>
                <a href="../" class="nav-link">Courses</a>
                <a href="../../#plans" class="nav-link">Plans</a>
                <a href="../../blog/" class="nav-link">Articles</a>
                <a href="../../faq/" class="nav-link">FAQ</a>
                <a href="../../#contact" class="nav-link">Contact</a>
            </nav>
            <a href="../../#contact" class="btn btn-primary">Enroll Now</a>
"@

$courseDirs = Get-ChildItem -Path "$root\courses" -Directory
foreach ($dir in $courseDirs) {
    $path = "$($dir.FullName)\index.html"
    if (Test-Path $path) {
        $c = Get-Content $path -Raw
        # Replace the entire nav and enroll button block
        $c = $c -replace '(?s)<nav class="nav-menu">.*?</nav>\s*<a href="[^"]+" class="btn btn-primary">Enroll Now</a>', $header2
        # Also fix the footer logo path if needed
        $c = $c -replace 'src="(?!\.\./\.\./)assets/', 'src="../../assets/'
        # Enroll Button/Links in body
        $c = $c -replace 'href="\.\./index\.html#contact"', 'href="../../#contact"'
        $c = $c -replace 'href="\.\./#contact"', 'href="../../#contact"'
        Set-Content $path $c
    }
}

# --- 2. Fix FAQ & Blog (Depth 1) ---
$header1 = @"
        <div style="display:flex;gap:1.5rem;flex-wrap:wrap;">
            <a href="../">Home</a>
            <a href="../courses/">Courses</a>
            <a href="../#plans">Plans</a>
            <a href="../#reviews">Reviews</a>
            <a href="./" style="color: var(--mint);">FAQ</a>
            <a href="../blog/">Articles</a>
            <a href="../#contact">Contact</a>
        </div>
"@
# (Adjust for blog specifically for the active link color)

$faqPath = "$root\faq\index.html"
if (Test-Path $faqPath) {
    $c = Get-Content $faqPath -Raw
    $c = $c -replace '(?s)<div style="display:flex;gap:1.5rem;flex-wrap:wrap;">.*?</div>', $header1
    $c = $c -replace 'src="assets/', 'src="../assets/'
    Set-Content $faqPath $c
}

$blogHeader = $header1 -replace 'href="\./" style="color: var\(--mint\);"', 'href="../faq/"' `
    -replace 'href="\.\./blog/"', 'href="./" style="color: var(--mint);"'
$blogPath = "$root\blog\index.html"
if (Test-Path $blogPath) {
    $c = Get-Content $blogPath -Raw
    $c = $c -replace '(?s)<div style="display:flex;gap:1.5rem;flex-wrap:wrap;">.*?</div>', $blogHeader
    $c = $c -replace 'src="assets/', 'src="../assets/'
    Set-Content $blogPath $c
}

# --- 3. Fix Courses Hub (Depth 1) ---
$hubHeader = @"
            <nav class="nav-menu">
                <a href="../" class="nav-link">Home</a>
                <a href="./" class="nav-link" style="color: var(--teal); font-weight: 700;">Courses</a>
                <a href="../#plans" class="nav-link">Plans</a>
                <a href="../#reviews" class="nav-link">Reviews</a>
                <a href="../faq/" class="nav-link">FAQ</a>
                <a href="../blog/" class="nav-link">Articles</a>
                <a href="../#contact" class="nav-link">Contact</a>
            </nav>
"@
$hubPath = "$root\courses\index.html"
if (Test-Path $hubPath) {
    $c = Get-Content $hubPath -Raw
    $c = $c -replace '(?s)<nav class="nav-menu">.*?</nav>', $hubHeader
    $c = $c -replace 'href="\.\./index\.html#contact"', 'href="../#contact"'
    Set-Content $hubPath $c
}
