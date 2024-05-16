echo "Install SFDX Scanner Plugin"
# https://forcedotcom.github.io/sfdx-scanner/en/getting-started/install/
sfdx plugins:install @salesforce/sfdx-scanner
echo "Code Scanning: Run Scanner"
CLASS_PATH="./output/force-app/main/default/classes"
TRIGGER_PATH="./output/force-app/main/default/triggers"
SCAN_CATEGORIES="Best Practices,Code Style,Design,Documentation,Error,Error Prone,Stylistic Issues,Performance,Possible Errors,ECMAScript 6,Security,Variables"
sfdx scanner:run --target "$CLASS_PATH/*.cls" --category "$SCAN_CATEGORIES"


echo "Code Scanning: Run Scanner and save output as junit"
sfdx scanner:run --target "$CLASS_PATH/*.cls" --category "$SCAN_CATEGORIES" --format junit --outfile "./output/junit-apex-classes.xml"
sfdx scanner:run --target "$TRIGGER_PATH/*.cls" --format junit --outfile "./output/junit-apex-triggers.xml" --category "$SCAN_CATEGORIES"