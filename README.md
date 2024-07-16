# Universal Package Manager (UPM)

UPM is a bash script that simplifies package management across multiple package managers.

## Features

- Supports apt, brew, pip, npm, and cargo
- Installs, removes, updates, and searches for packages
- Automatically elevates privileges when necessary
- Logs operations for troubleshooting

## Installation

1. Download the `upm.bash` script
2. Make it executable: `chmod +x upm.bash`
3. Move it to a directory in your PATH: `sudo mv upm.bash /usr/local/bin/upm`

## Usage

`upm <command> <package>`


Commands:
- `install`: Install a package
- `remove`: Remove a package
- `update`: Update a package
- `search`: Search for a package
- `version`: Display UPM version

## Examples

`bash
upm install nodejs
upm remove python3
upm update git
upm search docker`

## Logging

Operations are logged to `/var/log/upm.log`

## Version

Current version: 1.0.0

## License

This project is licensed under the MIT License - see the LICENSE file for details