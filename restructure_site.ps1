# Helper function to update paths
function Update-Paths($filePath, $newPrefix) {
    if (-not (Test-Path $filePath)) { return }
    $content = Get-Content $filePath -Raw
    
    # 1. Update relative links that point to root entries
    # If the file moved from root to folder/, links like "assets/" need to become "../assets/"
    # If it moved from courses/ to courses/folder/, links like "../assets/" need to become "../../assets/"
    
    # Static Assets & Styles
    $content = $content -replace '(?<=href="|src=")assets/', "${newPrefix}assets/"
    $content = $content -replace '(?<=href="|src=")style\.css', "${newPrefix}style.css"
    
    # Base links (Home, FAQ, Blog)
    $content = $content -replace '(?<=href="|src=")index\.html', "${newPrefix}"
    $content = $content -replace '(?<=href="|src=")faq\.html', "${newPrefix}faq/"
    $content = $content -replace '(?<=href="|src=")blog\.html', "${newPrefix}blog/"
    
    # Courses Hub
    $content = $content -replace '(?<=href="|src=")courses/index\.html', "${newPrefix}courses/"
    $content = $content -replace '(?<=href="|src=")courses/(?!index\.html)', "${newPrefix}courses/"
    
    # Fix Course Detail Links (they are folder based now)
    # This is tricky without knowing all names, but I can target the list
    $names = @("qaida-basics", "quran-reading", "quran-memorization", "quran-translation", "tafseer-quran", "arabic-grammar", "new-muslim-course", "seerat-un-nabi", "quran-tajweed", "dars-e-nizami", "shariah-basics", "essential-islamic-knowledge")
    foreach ($name in $names) {
        # If the file is in courses/folder/index.html, links to other courses were "quran-reading.html"
        # Since it's now in courses/something/index.html, it should be "../quran-reading/"
        # Actually in the Courses HUB it was "quran-reading.html"
        # In individual pages it was "index.html" (header) or other courses? Wait. 
        # Usually they link back to HUB carefully.
        $content = $content -replace "href=`"$name\.html`"", "href=`"../$name/`""
    }

    # Fix existing parent links (e.g. if Depth 2, ../ becomes ../../)
    # This only applies to files moving from subdirectories
    if ($newPrefix -eq "../../") {
        $content = $content -replace '(?<=href="|src=")\.\./', "../../"
    }

    Set-Content $filePath $content
}

# 1. Create directories
New-Item -ItemType Directory -Path "c:\Users\HP\usmanibneaffan\blog" -Force
New-Item -ItemType Directory -Path "c:\Users\HP\usmanibneaffan\faq" -Force

# 2. Move root pages
if (Test-Path "c:\Users\HP\usmanibneaffan\blog.html") {
    Move-Item -Path "c:\Users\HP\usmanibneaffan\blog.html" -Destination "c:\Users\HP\usmanibneaffan\blog\index.html" -Force
}
if (Test-Path "c:\Users\HP\usmanibneaffan\faq.html") {
    Move-Item -Path "c:\Users\HP\usmanibneaffan\faq.html" -Destination "c:\Users\HP\usmanibneaffan\faq\index.html" -Force
}

# 3. Update Root index.html links
$rootIdx = Get-Content "c:\Users\HP\usmanibneaffan\index.html" -Raw
$rootIdx = $rootIdx -replace 'href="index\.html"', 'href="./"'
$rootIdx = $rootIdx -replace 'href="faq\.html"', 'href="faq/"'
$rootIdx = $rootIdx -replace 'href="blog\.html"', 'href="blog/"'
$rootIdx = $rootIdx -replace 'href="courses/index\.html"', 'href="courses/"'
# For individual course links in root (if any)
$names = @("qaida-basics", "quran-reading", "quran-memorization", "quran-translation", "tafseer-quran", "arabic-grammar", "new-muslim-course", "seerat-un-nabi", "quran-tajweed", "dars-e-nizami", "shariah-basics", "essential-islamic-knowledge")
foreach ($name in $names) {
    $rootIdx = $rootIdx -replace "href=`"courses/$name\.html`"", "href=`"courses/$name/`""
}
Set-Content "c:\Users\HP\usmanibneaffan\index.html" $rootIdx

# 4. Restructure courses
$courseFiles = Get-ChildItem -Path "c:\Users\HP\usmanibneaffan\courses\*.html" | Where-Object { $_.Name -ne "index.html" }
foreach ($file in $courseFiles) {
    $folderName = $file.BaseName
    $newPath = Join-Path "c:\Users\HP\usmanibneaffan\courses" $folderName
    New-Item -ItemType Directory -Path $newPath -Force
    Move-Item -Path $file.FullName -Destination (Join-Path $newPath "index.html") -Force
}

# 5. Fix moved file contents
Update-Paths "c:\Users\HP\usmanibneaffan\blog\index.html" "../"
Update-Paths "c:\Users\HP\usmanibneaffan\faq\index.html" "../"
Update-Paths "c:\Users\HP\usmanibneaffan\courses\index.html" "../" # Depth 1 from root

$subCourses = Get-ChildItem -Path "c:\Users\HP\usmanibneaffan\courses" -Directory
foreach ($folder in $subCourses) {
    Update-Paths (Join-Path $folder.FullName "index.html") "../../"
}
