# Service bus Trigger Demo

## Pre-requisites

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [DotNet 6](https://dotnet.microsoft.com/en-us/download/dotnet/6.0)
- [Azure Function Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local)
- [VS Code](https://code.visualstudio.com/)

## Run Function Locally

### Using Command-line

```bash
func start --csharp
```

## Deploy infrastructure

### 

### Plan (Verify) deployment

```bash
az deployment sub create --location <your-preferred-location> --template-file main.bicep --what-if
```

### Deploy infrasturcture to Azure

```bash
az deployment sub create --location <your-preferred-location> --template-file main.bicep
```

## Deploy Function to Azure

```bash
func azure functionapp publish <your-function-app-name>
```