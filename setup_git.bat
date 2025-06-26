@echo off
echo Setting up git repository for MRC Project Vault...
cd /d "C:\Users\dvids\MRC\MRC_Project_Vault"

echo Checking if git is already initialized...
if exist .git (
    echo Git repository already exists. Updating configuration...
    git config user.name "Keiracom"
    git config user.email "admin@keiracom.com"
) else (
    echo Initializing git repository...
    git init
    git config user.name "Keiracom"
    git config user.email "admin@keiracom.com"
)

echo Checking for existing remote...
git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    echo Remote already exists. Updating URL...
    echo NOTE: You need to add your PAT token to the URL below
    echo git remote set-url origin https://[YOUR-PAT-TOKEN]@github.com/Keiracom/MRC_Project_Vault.git
) else (
    echo Adding GitHub remote...
    echo NOTE: You need to add your PAT token to the URL below
    echo git remote add origin https://[YOUR-PAT-TOKEN]@github.com/Keiracom/MRC_Project_Vault.git
)

echo.
echo IMPORTANT: Before pushing, update the remote URL with your GitHub PAT token
echo Get your PAT from the MRC Credentials.md file
echo.

echo Adding all files...
git add .

echo Creating commit...
git commit -m "Sync MRC Project Vault with GitHub"

echo Ready to push. Use: git push -u origin main
echo.
echo Done! Remember to update the remote URL with your PAT token first.
pause
