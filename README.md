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