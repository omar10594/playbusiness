# README

## Play Business

## Visual Studio Code

### Recommended configuration.

#### launch.json
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Start Rails server",
            "type": "Ruby",
            "request": "launch",
            "cwd": "${workspaceRoot}",
            "program": "${workspaceRoot}/bin/rails",
            "args": [
                "server",
                "-p",
                "3000"
            ]
        },
        {
            "name": "Debug Rails server",
            "type": "Ruby",
            "request": "launch",
            "cwd": "${workspaceRoot}",
            "useBundler": true,
            "pathToBundler": "/path/to/bundle",
            "pathToRDebugIDE": "/path/to/ruby-debug-ide-x.x.x",
            "program": "${workspaceRoot}/bin/rails",
            "args": [
                "server",
                "-p",
                "3000"
            ]
        },
    ]
}
```