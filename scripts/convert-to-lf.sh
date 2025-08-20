#!/bin/bash
# Script to convert all TypeScript files to LF line endings

echo "Converting all TypeScript and related files to LF line endings..."

# Find and convert TypeScript files
find . -name "*.ts" -not -path "./node_modules/*" -not -path "./dist/*" -exec dos2unix {} \;
find . -name "*.tsx" -not -path "./node_modules/*" -not -path "./dist/*" -exec dos2unix {} \;
find . -name "*.js" -not -path "./node_modules/*" -not -path "./dist/*" -exec dos2unix {} \;
find . -name "*.jsx" -not -path "./node_modules/*" -not -path "./dist/*" -exec dos2unix {} \;
find . -name "*.json" -not -path "./node_modules/*" -not -path "./dist/*" -exec dos2unix {} \;
find . -name "*.md" -not -path "./node_modules/*" -not -path "./dist/*" -exec dos2unix {} \;
find . -name "*.yml" -not -path "./node_modules/*" -not -path "./dist/*" -exec dos2unix {} \;
find . -name "*.yaml" -not -path "./node_modules/*" -not -path "./dist/*" -exec dos2unix {} \;

echo "Conversion completed!"
echo "Running Prettier to format all files..."

# Run prettier to format and ensure LF endings
npx prettier --write "src/**/*.{ts,tsx,js,jsx,json}"
npx prettier --write "test/**/*.{ts,tsx,js,jsx,json}"
npx prettier --write "*.{ts,tsx,js,jsx,json,md}"

echo "All files have been converted to LF line endings!"
