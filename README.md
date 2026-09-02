# WebServerApp

Local web server for iOS. Serves HTML/CSS/JS files from the app's Documents folder.

## Features

- Runs a local HTTP server on port 8080
- Serves files from the Documents folder (accessible via iTunes/Finder)
- Built-in web view to preview your pages
- File sharing enabled - drag and drop files via Finder

## How to Use

1. Install the IPA via AltStore or SideStore
2. Connect your iPhone to your computer
3. Open Finder (macOS) or iTunes (Windows)
4. Select your iPhone > File Sharing > WebServerApp
5. Drop your HTML, CSS, and JS files into the Documents folder
6. Open WebServerApp on your iPhone
7. Access your pages at `http://127.0.0.1:8080/`

## Build from Source

Requires [Theos](https://theos.dev) on Linux/macOS.

```bash
export THEOS=~/theos
make
```

## License

MIT
