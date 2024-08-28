# dotfiles

## Notes

* `scope.sh` can and will change, as it's content depends on `ranger` package version. Due to this we have to regenerate it once in a while using:
    ```
    rm ~/.config/ranger/scope.sh
    ranger --copy-config=scope
    ```
    After that, uncomment section about `application/pdf` that uses `pdftoppm` and add it to chezmoi using
    ```
    chezmoi add ~/.config/ranger/scope.sh
    ```
* After modifying keybinding in cinnamon, those can be save by executing:
    ```
    dconf dump /org/cinnamon/desktop/keybindings/ > keybindings-cinnamon.dconf
    ```
* After creating custom keybinding in gnome, those can be save by executing:
    ```
    dconf dump /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ > custom-keybindings-gnome.dconf
    ```
