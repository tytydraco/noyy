# noyy
Automatically commit and push git repos upon inode changes  
This is the more efficient successor to [slinky](https://github.com/tytydraco/slinky).

# Install
`curl -L https://raw.githubusercontent.com/tytydraco/noyy/main/noyy > /usr/bin/noyy && chmod +x /usr/bin/noyy`

# Paths
The `paths` template file can be copied to `~/.config/slinky/paths`. The directory can be made manually. Alternatively, a paths file can be manually specified. Keep in mind that the paths file is sourced as a shell script, not executed.

# Usage Examples
- `noyy -h` to list help
- `noyy -p paths` to use a custom paths file
