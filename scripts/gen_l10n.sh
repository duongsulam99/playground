#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FVM_CHECK=$(command -v fvm 2> /dev/null)
if [[ -z "$FVM_CHECK" ]]; then
  FLUTTER="flutter"
else
  FLUTTER="fvm flutter"
fi

echo -e "${YELLOW}Generating Flutter localizations (l10n.yaml)...${NC}"

$FLUTTER gen-l10n

if [[ $? -eq 0 ]]; then
  echo -e "${GREEN}Flutter localizations generated successfully.${NC}"
  echo -e "   lib/l10n/app_en.arb  ← edit this"
  echo -e "   lib/l10n/app_vi.arb  ← edit this"
  echo -e "   lib/l10n/localization/app_localizations*.dart"
else
  echo -e "${RED}Failed to generate Flutter localizations${NC}"
  exit 1
fi
