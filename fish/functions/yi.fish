function yi -d "Install packages via yay with --needed & --noconfirm" -w "yay -S"
    if test (count $argv) -lt 1
        echo "Usage: yi <package-name> [more-packages...]"
        return 1
    end

    echo "[RUN] | yay -Sy $argv --needed --noconfirm"
    yay -S $argv --needed --noconfirm
end


