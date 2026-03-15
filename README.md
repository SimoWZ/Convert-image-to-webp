# 🖼️ convert_to_webp

A lightweight Bash script for macOS that batch-converts **JPG** and **PNG** images to **WebP** format — with recursive support, quality control, and colored output.

---

## ✨ Features

- Converts `.jpg`, `.jpeg`, `.png` (case-insensitive) to `.webp`
- Adjustable output quality (`0–100`)
- Optional **recursive** processing of subdirectories
- Skips files that have already been converted
- Optionally **deletes originals** after conversion
- Shows file size before/after each conversion
- Colored summary report (converted / skipped / errors)
- Compatible with **macOS default Bash 3.2**

---

## 📦 Requirements

- macOS (Bash 3.2+)
- [`cwebp`](https://developers.google.com/speed/webp) — install via Homebrew:

```bash
brew install webp
```

---

## 🚀 Usage

```bash
./convert_to_webp.sh [options] /path/to/folder
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `-q QUALITY` | WebP quality from `0` (smallest) to `100` (best) | `85` |
| `-r` | Process subdirectories recursively | off |
| `-d` | Delete original files after conversion | off |
| `-h` | Show help message | — |

### Examples

```bash
# Basic conversion
./convert_to_webp.sh ~/Desktop/images

# High quality, recursive
./convert_to_webp.sh -q 90 -r ~/Desktop/images

# Aggressive compression, delete originals
./convert_to_webp.sh -q 60 -d ~/Desktop/images

# All options combined
./convert_to_webp.sh -q 75 -r -d ~/Desktop/images
```

---

## 📋 Sample Output

```
===============================
  Conversione in WebP
===============================
  Cartella : /Users/you/Desktop/images
  File trovati : 5
  Qualità : 85
  Ricorsivo : no
  Elimina originali : no
-------------------------------

  ✓ photo1.jpg  →  photo1.webp  (2.4M → 890K)
  ✓ photo2.png  →  photo2.webp  (1.1M → 410K)
  ~ banner.jpg  →  esiste già banner.webp
  ✓ icon.png    →  icon.webp    (340K → 98K)

===============================
  Convertiti : 3
  Saltati    : 1
  Errori     : 0
===============================
```

---

## ⚙️ Installation

```bash
# Clone the repo
git clone https://github.com/your-username/convert-to-webp.git
cd convert-to-webp

# Make the script executable
chmod +x convert_to_webp.sh
```

Optionally, move it to a directory in your `$PATH` to use it anywhere:

```bash
mv convert_to_webp.sh /usr/local/bin/convert_to_webp
```

---

## 🗒️ Notes

- Files that already have a `.webp` counterpart in the same directory are **automatically skipped** — safe to re-run.
- The script uses `find -print0` and `while read -d ''` for correct handling of filenames with spaces or special characters.
- Written for **Bash 3.2** (macOS default) — no `mapfile`, no Bash 4+ features required.

---

## 📄 License

MIT — feel free to use, modify, and distribute.
