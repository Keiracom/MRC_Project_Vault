@echo off
echo Setting up git repository for MRC Project Vault...
cd /d "C:\Users\dvids\MRC\MRC_Project_Vault"

echo Initializing git repository...
git init

echo Adding GitHub remote...
git remote add origin https://github.com/Keiracom/MRC_Project_Vault.git

echo Adding all files...
git add .

echo Creating initial commit...
git commit -m "Initial Obsidian vault setup with MRC project structure"

echo Creating main branch and pushing to GitHub...
git branch -M main
git push -u origin main

echo Done! Your Obsidian vault is now connected to GitHub.
pause
