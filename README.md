# Drupal on Windows Subsystem Linux (Ubuntu)

Drupal on Windows Subsystem Linux (Ubuntu) is a project that facilitates quick configuration of Windows Subsystem for Linux (WSL) on Ubuntu-based distributions for people who want to work with Drupal 10/11.

## 🚀 Installation

To install, clone the repository and run the configuration script:

```bash
git clone https://github.com/tiagohenriqueferreira/wsl-drupal.git
cd wsl-drupal
sudo chmod +x install.sh
./install.sh
```

## 📦 Installed Software

The script automatically installs and configures:

- Apache2
- PHP 8.3 with various modules
- Composer
- PostgreSQL
- MariaDB
- FFmpeg

Optional installations based on user prompts:

- PostgreSQL
- MariaDB
- Node.js and npm (required for Sass)
- SASS

## 💡 Features

- Automated WSL environment configuration
- Installation of essential packages
- Development environment setup
- Performance optimizations

## 🔧 Usage

After installation, you can use the following aliases added to your `.bashrc`:

- `drush` - Shortcut for Drush (`./vendor/drush/drush/drush`)
- `sites` - Navigate to `/var/www/` directory
- `vhosts` - Navigate to `/etc/apache2/sites-available/` directory
- `update` - Update and list upgradable packages (`sudo apt update && sudo apt list --upgradable && sudo apt upgrade`)
- `rap` - Restart Apache2, MariaDB, and PostgreSQL services (`sudo service apache2 restart`)
- `rmdb` - Restart MariaDB service (if installed) (`sudo service mariadb restart`)
- `rpg` - Restart PostgreSQL service (if installed) (`sudo service postgresql restart`)

SASS related aliases (if SASS is installed):

- `ss1` - Compiles `scss/style.scss` to `css/style.css` using SASS in watch mode
- `ss2` - Compiles `scss/ck5style.scss` to `css/ck5style.css` using SASS in watch mode

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add: new feature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📬 Contact

Tiago Henrique Ferreira - [tiagohenriqueferreira@gmail.com](mailto:tiagohenriqueferreira@gmail.com)

Project Link: [https://github.com/tiagohenriqueferreira/wsl-drupal](https://github.com/tiagohenriqueferreira/wsl-drupal)

## 📝 License

This project is under the MIT License. See the `LICENSE` file for more information.
