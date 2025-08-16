function activate_pyvenv
    set venv_path (dirname (which python))/activate.fish
    if test -f $venv_path
        source $venv_path
        echo "Activated Python virtual environment."
    else
        echo "Error: Virtual environment activation script not found."
    end
end
