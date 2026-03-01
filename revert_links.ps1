$rootFiles = Get-ChildItem -Path "c:\Users\HP\usmanibneaffan\*.html"
$courseFiles = Get-ChildItem -Path "c:\Users\HP\usmanibneaffan\courses\*.html"
$allFiles = $rootFiles + $courseFiles

foreach ($file in $allFiles) {
    if ($file.Name -eq "google1f8556e1c77311a5.html") { continue }
    
    $content = Get-Content $file.FullName -Raw
    
    # Root links
    $content = $content -replace 'href="\./"', 'href="index.html"'
    $content = $content -replace 'href="faq"', 'href="faq.html"'
    $content = $content -replace 'href="blog"', 'href="blog.html"'
    
    # Course links (relative and direct)
    $content = $content -replace 'href="\.\./"', 'href="../index.html"'
    $content = $content -replace 'href="index"', 'href="index.html"'
    $content = $content -replace 'href="\.\./blog"', 'href="../blog.html"'
    $content = $content -replace 'href="\.\./faq"', 'href="../faq.html"'
    
    # Specific course details (this is harder with regex if they don't have .html)
    # But I know I removed .html from things like "qaida-basics"
    # I'll look for href="[anything-without-dot-or-hash-or-slash]"
    # Actually, I'll just target the ones I know I changed in courses hub
    $content = $content -replace 'href="qaida-basics"', 'href="qaida-basics.html"'
    $content = $content -replace 'href="quran-reading"', 'href="quran-reading.html"'
    $content = $content -replace 'href="quran-memorization"', 'href="quran-memorization.html"'
    $content = $content -replace 'href="quran-translation"', 'href="quran-translation.html"'
    $content = $content -replace 'href="tafseer-quran"', 'href="tafseer-quran.html"'
    $content = $content -replace 'href="arabic-grammar"', 'href="arabic-grammar.html"'
    $content = $content -replace 'href="new-muslim-course"', 'href="new-muslim-course.html"'
    $content = $content -replace 'href="seerat-un-nabi"', 'href="seerat-un-nabi.html"'
    $content = $content -replace 'href="quran-tajweed"', 'href="quran-tajweed.html"'
    $content = $content -replace 'href="dars-e-nizami"', 'href="dars-e-nizami.html"'
    $content = $content -replace 'href="shariah-basics"', 'href="shariah-basics.html"'
    $content = $content -replace 'href="essential-islamic-knowledge"', 'href="essential-islamic-knowledge.html"'
    
    Set-Content $file.FullName $content
}

# Update sitemap
$sitemap = Get-Content "c:\Users\HP\usmanibneaffan\sitemap.xml" -Raw
$sitemap = $sitemap -replace 'com/"', 'com/index.html"'
$sitemap = $sitemap -replace 'courses/"', 'courses/index.html"'
$sitemap = $sitemap -replace 'qaida-basics"', 'qaida-basics.html"'
$sitemap = $sitemap -replace 'quran-tajweed"', 'quran-tajweed.html"'
$sitemap = $sitemap -replace 'quran-translation"', 'quran-translation.html"'
$sitemap = $sitemap -replace 'hadith-studies"', 'hadith-studies.html"'
$sitemap = $sitemap -replace 'arabic-grammar"', 'arabic-grammar.html"'
$sitemap = $sitemap -replace 'blog"', 'blog.html"'
$sitemap = $sitemap -replace 'faq"', 'faq.html"'
Set-Content "c:\Users\HP\usmanibneaffan\sitemap.xml" $sitemap
