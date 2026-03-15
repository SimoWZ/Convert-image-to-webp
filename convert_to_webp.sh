#!/bin/bash

# ============================================================
#  convert_to_webp.sh
#  Converte tutti i file JPG e PNG in WebP in una cartella
#  Requisiti: cwebp  →  brew install webp
# ============================================================

set -euo pipefail

# ---------- colori per l'output ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ---------- configurazione di default ----------
QUALITY=85          # qualità WebP (0-100)
DELETE_ORIGINALS=0  # 1 = cancella i file originali dopo la conversione
RECURSIVE=0         # 1 = elabora anche le sottocartelle

# ---------- funzione di aiuto ----------
usage() {
  echo -e "${CYAN}Utilizzo:${NC}"
  echo "  $0 [opzioni] /percorso/cartella"
  echo ""
  echo -e "${CYAN}Opzioni:${NC}"
  echo "  -q QUALITÀ     Qualità WebP da 0 a 100 (default: 85)"
  echo "  -d             Cancella i file originali dopo la conversione"
  echo "  -r             Elabora le sottocartelle in modo ricorsivo"
  echo "  -h             Mostra questo aiuto"
  echo ""
  echo -e "${CYAN}Esempi:${NC}"
  echo "  $0 ~/Desktop/immagini"
  echo "  $0 -q 90 -r ~/Desktop/immagini"
  echo "  $0 -q 75 -d ~/Desktop/immagini"
  exit 0
}

# ---------- parsing degli argomenti ----------
while getopts ":q:drh" opt; do
  case $opt in
    q) QUALITY="$OPTARG" ;;
    d) DELETE_ORIGINALS=1 ;;
    r) RECURSIVE=1 ;;
    h) usage ;;
    \?) echo -e "${RED}Opzione non valida: -$OPTARG${NC}" >&2; exit 1 ;;
    :)  echo -e "${RED}L'opzione -$OPTARG richiede un argomento.${NC}" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# ---------- verifica cartella ----------
TARGET_DIR="${1:-}"
if [[ -z "$TARGET_DIR" ]]; then
  echo -e "${RED}Errore: specifica la cartella da elaborare.${NC}"
  usage
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo -e "${RED}Errore: la cartella '$TARGET_DIR' non esiste.${NC}"
  exit 1
fi

# ---------- verifica cwebp ----------
if ! command -v cwebp &>/dev/null; then
  echo -e "${RED}Errore: 'cwebp' non trovato.${NC}"
  echo -e "Installalo con:  ${YELLOW}brew install webp${NC}"
  exit 1
fi

# ---------- costruzione del comando find ----------
if [[ "$RECURSIVE" -eq 1 ]]; then
  FIND_DEPTH=""
else
  FIND_DEPTH="-maxdepth 1"
fi

# Conta i file trovati
TOTAL=$(find "$TARGET_DIR" $FIND_DEPTH -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) 2>/dev/null | wc -l | tr -d ' ')

if [[ "$TOTAL" -eq 0 ]]; then
  echo -e "${YELLOW}Nessun file JPG o PNG trovato in '$TARGET_DIR'.${NC}"
  exit 0
fi

# ---------- riepilogo ----------
echo -e "${CYAN}===============================${NC}"
echo -e "${CYAN}  Conversione in WebP${NC}"
echo -e "${CYAN}===============================${NC}"
echo -e "  Cartella : ${TARGET_DIR}"
echo -e "  File trovati : ${TOTAL}"
echo -e "  Qualità : ${QUALITY}"
echo -e "  Ricorsivo : $([ $RECURSIVE -eq 1 ] && echo sì || echo no)"
echo -e "  Elimina originali : $([ $DELETE_ORIGINALS -eq 1 ] && echo sì || echo no)"
echo -e "${CYAN}-------------------------------${NC}"
echo ""

CONVERTED=0
SKIPPED=0
ERRORS=0

# ---------- conversione ----------
while IFS= read -r -d '' FILE; do
  BASENAME=$(basename "$FILE")
  DIR=$(dirname "$FILE")
  NAME="${BASENAME%.*}"
  OUTPUT="${DIR}/${NAME}.webp"

  # Salta se il file WebP esiste già
  if [[ -f "$OUTPUT" ]]; then
    echo -e "  ${YELLOW}SALTATO${NC}  $BASENAME  →  esiste già ${NAME}.webp"
    ((SKIPPED++)) || true
    continue
  fi

  if cwebp -q "$QUALITY" "$FILE" -o "$OUTPUT" &>/dev/null; then
    ORIG_SIZE=$(du -sh "$FILE" | cut -f1)
    WEBP_SIZE=$(du -sh "$OUTPUT" | cut -f1)
    echo -e "  ${GREEN}OK${NC}  $BASENAME  →  ${NAME}.webp  (${ORIG_SIZE} → ${WEBP_SIZE})"
    ((CONVERTED++)) || true

    if [[ "$DELETE_ORIGINALS" -eq 1 ]]; then
      rm "$FILE"
    fi
  else
    echo -e "  ${RED}ERRORE${NC}  $BASENAME"
    ((ERRORS++)) || true
  fi
done < <(find "$TARGET_DIR" $FIND_DEPTH -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
  -print0 2>/dev/null)

# ---------- riepilogo finale ----------
echo ""
echo -e "${CYAN}===============================${NC}"
echo -e "  ${GREEN}Convertiti : ${CONVERTED}${NC}"
echo -e "  ${YELLOW}Saltati   : ${SKIPPED}${NC}"
echo -e "  ${RED}Errori    : ${ERRORS}${NC}"
echo -e "${CYAN}===============================${NC}"
