R -e "path <- '../varexternalinstrument'; system(paste(shQuote(file.path(R.home('bin'), 'R')), 'CMD', 'Rd2pdf', shQuote(path)))"

rm -rf out || exit 0;
mkdir out;

GH_REPO="@github.com/angusmoore/varexternalinstrument.git"

FULL_REPO="https://$GH_TOKEN$GH_REPO"

for files in '*.tar.gz'; do
        tar xfz $files
done

cd out
git init
git config user.name "travis"
git config user.email "travis"
cp ../varexternalinstrument.pdf varexternalinstrument.pdf

git add .
git commit -m "Rebuilt PDF package documentation and deployed to gh-pages"
git push --force --quiet $FULL_REPO master:gh-pages
