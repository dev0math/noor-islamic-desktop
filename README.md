# Noor (نور) - Islamic Desktop Application

<p align="center">
  <img src="src/build/icons/icon.png" width="128" height="128" alt="Noor Logo">
</p>

<p align="center">
  <b>Open Source Islamic Desktop Application</b><br>
  <b>تطبيق إسلامي مفتوح المصدر لسطح المكتب</b>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/version-3.0.1-blue"></a>
  <a href="#"><img src="https://img.shields.io/badge/license-MIT-green"></a>
  <a href="#"><img src="https://img.shields.io/badge/platform-Windows%20%7C%20Linux-orange"></a>
</p>

---

## Quick Install (One Line)

### Linux / macOS / WSL
```bash
curl -sL https://raw.githubusercontent.com/dev0math/noor-islamic-desktop/main/install.sh | bash
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/dev0math/noor-islamic-desktop/main/install.ps1 | iex
```

---

## Manual Installation

### Prerequisites
- [Node.js](https://nodejs.org/) (v16+)
- [Git](https://git-scm.com/)

### Clone & Install
```bash
git clone https://github.com/dev0math/noor-islamic-desktop.git
cd noor-islamic-desktop
npm install
```

### Run (Development)
```bash
npm run dev
# or
npm start
```

### Build
```bash
# Windows
npm run packwin

# Linux
npm run packlinux

# All platforms
npm run dist
```

---

## Features

| Feature | Description |
|---------|-------------|
| **Quran** | Read the Holy Quran with beautiful fonts |
| **Reciters** | Listen to Quran from various reciters |
| **Adhkar** | Morning, evening, sleep, food, and prayer remembrances |
| **Hisn Al-Muslim** | Fortress of the Muslim - authentic supplications |
| **Prayer Times** | Accurate prayer times with Adhan notifications |
| **Radio** | Islamic radio stations |
| **Hijri Calendar** | Islamic date display |
| **Notifications** | Adhan and Adhkar audio reminders |
| **Dark/Light Mode** | Switch between themes |

---

## Terminal Usage

After installation, you can launch Noor from anywhere:

```bash
noor              # Launch normally
noor --hidden     # Launch minimized to tray
```

---

## Desktop Integration

- **Linux**: Desktop entry created automatically. Find "Noor (نور)" in your app menu.
- **Windows**: Shortcut created on Desktop.
- **Tray Icon**: Minimize to system tray for quick access.

---

## Tech Stack

- **Electron** - Cross-platform desktop framework
- **Node.js** - Backend runtime
- **adhan-js** - Prayer time calculations
- **moment-hijri** - Hijri date support
- **HTML/CSS/JS** - Frontend

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file.

---

## Acknowledgments

- Quran data from [Quran-Json](https://github.com/rn0x/Quran-Json)
- Audio from [mp3quran.net](https://www.mp3quran.net)
- Adhkar from [islambook.com](https://www.islambook.com/azkar)
- Icons from [Flaticon](https://www.flaticon.com)

---

<p align="center">
  Made with love for the Muslim Ummah
</p>
