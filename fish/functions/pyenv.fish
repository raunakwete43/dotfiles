function pyenv
    set env_name $argv[1]

    # Check if the environment name is provided
    if test -z "$env_name"
        echo "Usage: pyenv <env_name>"
        return
    end

    # Create the directory structure
    mkdir -p $env_name/src

    # Activate virtual environment and display a message
    echo "Creating virtual environment for $env_name..."
    uv venv $env_name/.venv
    echo "Virtual environment $env_name created successfully."

    # Provide instructions on activating the virtual environment
    echo "Activating the virtual environment..."
    source $env_name/.venv/bin/activate.fish
    cd $env_name/src
end
