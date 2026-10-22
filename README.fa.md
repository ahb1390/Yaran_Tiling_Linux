# یاران لینوکس

**English** ([README.md](README.md)) | فارسی ([README.fa.md](README.fa.md))

[![Build](https://github.com/ahb1390/Yaran_linux/actions/workflows/build.yml/badge.svg)](https://github.com/ahb1390/Yaran_linux/actions/workflows/build.yml)
![Debian](https://img.shields.io/badge/base-Debian%2013-A81D33?logo=debian&logoColor=white)
![Architecture](https://img.shields.io/badge/architecture-amd64-4B6CB7)

یاران لینوکس یک سیستم‌عامل مبتنی بر Debian 13 است که به‌صورت تصاویر Live ISO
قابل بازتولید ساخته می‌شود. این توزیع یک دسکتاپ KDE Plasma حرفه‌ای را در دو
نسخهٔ AMD64 با نام‌های Minimal و Extended عرضه می‌کند. هر تصویر با یک مانیفست
JSON تعریف می‌شود و هر دو با یک سازندهٔ (builder) عمومی پایتونی ساخته می‌شوند.

## وضعیت پروژه

نسخهٔ ۲٫۰ یاران لینوکس بر Debian 13 (Trixie) قفل شده و مخازن‌های امنیتی،
به‌روزرسانی و backports متناظر را فعال دارد. در کل مستندات از این نمادها
استفاده می‌شود:

| نماد | معنا |
|---|---|
| ✅ | پیاده‌سازی‌شده و تأییدشده (ساخت موفق در CI یا تست موفق) |
| 🟡 | پیاده‌سازی‌شده اما هنوز به‌صورت سرتاسری آزمایش‌نشده |
| 📋 | در برنامهٔ آینده یا پیشنهاد؛ پیاده‌سازی نشده |

وضعیت فعلی نسخه‌ها:

| نسخه | مانیفست | وضعیت |
|---|---|---|
| دسکتاپ Minimal (AMD64) | `Yaran-2.0-amd64-minimal.json` | ✅ ساخت و تست‌شده در CI |
| دسکتاپ Extended (AMD64) | `Yaran-2.0-amd64-extended.json` | ✅ ساخت و تست‌شده در CI |

امضای Secure Boot و bootstrap بین معماری‌ها **پیاده‌سازی نشده‌اند** (📋).

## اهداف طراحی

- **پایدار:** یاران لینوکس ۲٫۰ از Debian 13 (Trixie) با مخازن‌های امنیتی و
  به‌روزرسانی stable متناظر پیروی می‌کند.
- **کاربرپسند:** نشست زندهٔ دسکتاپ شامل Plasma در هر دو حالت Wayland و X11،
  مرورگر وب مدرن، فرمت‌های رایج فایل، ابزار عکس‌برداری، شبکه، صدا، بلوتوث،
  مدیریت مصرف انرژی و firmware و پایش سلامت دیسک و یک نصب‌کنندهٔ گرافیکی
  برندشده است.
- **سبک:** بسته‌ها بدون توصیه‌های خودکار (recommendations) نصب می‌شوند. هر
  تصویر به‌جای چند برنامهٔ تکراری برای یک کار، یک مجموعهٔ کوچک و هدفمند
  از برنامه‌ها دارد.

افزودن بسته باید نیاز رایج دسکتاپ، نیاز سخت‌افزاری، مسئلهٔ امنیتی یا
مسئلهٔ دسترس‌پذیری را حل کند. برنامه‌های تخصصی اختیاری جای‌شان در مخازن
است، نه در تصویر پایه.

## نسخه‌ها و برنامه‌ها

هر دو نسخهٔ دسکتاپ AMD64 یک دسکتاپ Plasma، برندینگ و تجربهٔ زندهٔ یکسانی
دارند. همهٔ تصاویر دسکتاپ Fastfetch (که هنگام بازشدن یک ترمینال Bash
تعاملی نمایش داده می‌شود)، مخزن Flatpak فلاتهاب و نصب‌کنندهٔ گرافیکی
Calamares را شامل می‌شوند.

**مجموعهٔ برنامه‌های پایه (Minimal و Extended):** Firefox ESR، LibreOffice
(Writer، Calc، Impress، Draw، Base، Math)، VLC، Telegram Desktop، Google
Chrome (از مخزن APT رسمی و امضاشدهٔ گوگل)، Hiddify و v2rayN (نسخه‌های `.deb`
رسمی و قفل‌شده با تأیید SHA-256)، Dolphin، Kate، Konsole، Gwenview، Okular،
Ark، Spectacle، KCalc، Partition Manager، Plasma Discover با پشتیبانی
Flatpak، Print Manager، timeshift و نیز firmware، گرافیک Mesa/Vulkan، صدای
PipeWire، بلوتوث، AppArmor، nftables، پشتهٔ اشتراک‌گذاری صفحهٔ
xdg-desktop-portal، فونت‌های کامل فارسی/CJK/ایموجی و ابزار
`unattended-upgrades` (به‌صورت پیش‌فرض غیرفعال — به‌روزرسانی‌ها با
`yaran-update` و توسط خود کاربر انجام می‌شوند؛
[سیاست به‌روزرسانی](docs/updates-policy.fa.md) را ببینید).

**Extended علاوه بر پایه، این‌ها را اضافه می‌کند:** GIMP، VirtualBox نسخهٔ
۷٫۲ (از مخزن APT رسمی و امضاشدهٔ Oracle)، VSCodium و Obsidian (نسخه‌های `.deb`
رسمی و قفل‌شده با تأیید SHA-256) و یک مجموعهٔ ابزار توسعه‌دهنده
(`build-essential`، `git`، `dkms`، `linux-headers-amd64`، Node.js نسخهٔ ۲۶
همراه با `npm`/`npx` از تاربال رسمی قفل‌شده در `/usr/local` (زیرا Debian trixie
فقط Node.js نسخهٔ ۲۰ را بسته‌بندی می‌کند و افزودن مخزن APT خارجیخلاف سیاست
مخازن پروژه است)، `python3`، `python3-pip`، `python3-venv`، `lazygit`).


## ساخت یک ISO

سازندهٔ تصویر از تصاویر Live خانوادهٔ Debian با پیکربندی پذیرنده پشتیبانی
می‌کند. برای پیش‌نیازهای میزبان، نیازمندی‌های معماری و همهٔ گزینه‌های ساخت،
[راهنمای سازنده](docs/builder.fa.md) را ببینید. ساخت کامل به root نیاز
دارد؛ اعتبارسنجی پیکربندی ندارد.

```bash
python3 build.py Yaran-2.0-amd64-minimal.json --validate
sudo python3 build.py Yaran-2.0-amd64-minimal.json --workdir build --outdir output
```

برای نسخهٔ کامل از `Yaran-2.0-amd64-extended.json` استفاده کنید. فایل‌های خروجی در
`output/` نوشته می‌شوند؛ وضعیت موقت ساخت در شاخهٔ کاری (work) نگهداری می‌شود
و در Git نادیده گرفته می‌شود.

راهنماهای بیشتر:

- [معماری](docs/architecture.fa.md) — چگونگی کنار هم قرار گرفتن سازنده،
  مانیفست‌ها و hookها
- [مرجع مانیفست](docs/manifest.fa.md) — همهٔ فیلدهای مانیفست و روش ایمن
  افزودن بسته
- [عیب‌یابی](docs/troubleshooting.fa.md) — نشانه‌ها، لاگ‌ها و راه‌حل‌های
  تأییدشده برای خطاهای رایج ساخت و بوت
- [انتشار](docs/releases.fa.md) — چگونگی عملکرد artifactهای CI و انتشارهای
  GitHub
- [راهنمای تم](docs/theme.fa.md) — هویت بصری و محل قرارگیری آن
- [مشارکت](CONTRIBUTING.fa.md) — شاخه‌ها، تست‌ها و Pull Requestها

## آزمایش

تست‌های واحد را اجرا کنید (به root نیاز ندارد):

```bash
python3 -m unittest discover -s tests -v
```

علاوه بر این، CI یک تست دود (smoke) بوت BIOS **و** UEFI را روی AMD64 اجرا
می‌کند (`RUN_BOOT_SMOKE=1 REQUIRE_UEFI_SMOKE=1`): یک ISO آزمایشی GRUB ساخته
شده و در QEMU بوت می‌شود. این فیکسچر هیچ سیستم‌عاملی ندارد؛ پیش از توزیع هر
ISO همچنان بوت تصویر کامل در یک ماشین مجازی باید بررسی شود. جزئیات در
[راهنمای سازنده](docs/builder.fa.md#اعتبارسنجی) است.

### آزمایش در QEMU

برای یک ISO دسکتاپ AMD64، از پوشهٔ پروژه اجرا کنید:

```bash
qemu-system-x86_64 -m 4096 -smp 2 -boot d \
  -cdrom output/Yaran-2.0-amd64-minimal.iso
```

منوی GRUB ظاهر می‌شود و سپس نشست زنده به‌طور خودکار آغاز می‌شود. برای دیدن
پیام‌های بوت، ورودی `live, debug` و برای رفع مشکل نمایش گرافیکی سفید، ورودی
`live, nomodeset` را انتخاب کنید. از پنجرهٔ گرافیکی QEMU استفاده کنید؛ ورودی‌های
پیش‌فرض بوت کنسول سریال (serial) پیکربندی نمی‌کنند.

اگر یک تصویر قدیمی AMD64 پیش از نمایش GRUB روی `Booting from DVD/CD...`
متوقف می‌شود، آن را با سازندهٔ فعلی دوباره بسازید. ساختهای قدیمی‌تر loader
مربوط به CD در GRUB را به ۵۱۲ بایت بریده و ISOیی تولید می‌کردند که با موفقیت
ساخته می‌شد اما از طریق BIOS بوت نمی‌شد.

## دریافت تصاویر

- **Artifactهای CI:** هر اجرای موفق [Workflow ساخت](https://github.com/ahb1390/Yaran_linux/actions/workflows/build.yml)
  هر ISO را همراه با فایل checksum آن (`.iso.sha256`) و لاگ ساخت به‌صورت
  artifact قابل دانلود آپلود می‌کند. روش دانلود و تأیید آن‌ها در
  [انتشار](docs/releases.fa.md) توضیح داده شده است.
- **انتشارها:** انتشار یک Release در GitHub
  [Workflow انتشار](https://github.com/ahb1390/Yaran_linux/actions/workflows/release.yml)
  را فعال می‌کند که هر دو نسخهٔ دسکتاپ را دوباره ساخته و ISOها و checksumها را
  به Release پیوست می‌کند. تاکنون Release‌ای منتشر نشده است (🟡).

هر تصویر دریافتی را پیش از استفاده تأیید کنید:

```bash
sha256sum -c Yaran-2.0-amd64-minimal.iso.sha256
```

## آزمایش و نصب

**دسکتاپ:** ISO را بوت کنید؛ نشست زنده به‌طور خودکار با کاربر `admin`
(گذرواژهٔ زنده: `yaranlinux`) وارد می‌شود. نصب‌کننده به‌صورت
`Install Yaran Linux.desktop` روی دسکتاپ در دسترس است؛ آن را اجرا کنید تا
سیستم روی دیسک نصب شود.

هرگز گذرواژه‌های منتشرشدهٔ زنده را در یک سیستم نصب‌شدهٔ تولیدی استفاده نکنید.

## ساختار پروژه

- `build.py` — سازندهٔ قابل پیکربندی ISOهای Live خانوادهٔ Debian
- `Yaran-2.0-*.json` — مانیفست‌های تصویر دسکتاپ
- `hooks/` — اسکریپت‌های سفارشی‌سازی تصویر (`common/`، `desktop/`)
- `scripts/ci-build.sh` — اسکریپت ساخت مشترک Debian که در CI استفاده می‌شود
- `examples/` — مانیفست‌های اولیهٔ Minimal برای Debian و Ubuntu
- `assets/` — برندینگ Plasma، SDDM، Calamares، Fastfetch و پس‌زمینه‌ها
- `tests/` — تست‌های واحد و تست دود بوت QEMU
- `.github/workflows/` — ساخت برای Pull Request، شاخه و Release
- `docs/` — [فهرست مستندات](docs/)

## مشارکت

گزارش باگ، رفع باگ و بهبود مستندات پذیرفته می‌شود. برای چیدمان شاخه‌ها،
تست‌های لازم و فرآیند Pull Request، [CONTRIBUTING.fa.md](CONTRIBUTING.fa.md)
را بخوانید و پیش از گزارش خطاهای ساخت، [عیب‌یابی](docs/troubleshooting.fa.md)
را بررسی کنید. برای گزارش باگ و پیشنهاد قابلیت از
[ردیاب مشکلات](https://github.com/ahb1390/Yaran_linux/issues) استفاده کنید.

## مجوز

یاران لینوکس تحت شرایط مندرج در فایل [LICENSE](LICENSE) این مخزن توزیع
می‌شود.
