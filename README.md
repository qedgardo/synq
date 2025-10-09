# Synq - Repository Synchronization Tool

A bash script for managing GitHub repositories with two main operations: discovering existing repositories and cloning them in bulk.

## Features

- **Push Mode**: Scan directories and catalog repositories into a YAML file
- **Pull Mode**: Clone all repositories from the YAML file with proper directory structure
- **Custom Locations**: Specify custom directories for scanning and cloning
- **Smart Cloning**: Skip repositories that already exist
- **Progress Feedback**: Detailed output with status indicators

## Installation

1. Clone or download the script:
```bash
git clone <repository-url>
cd synq
```

2. Make the script executable:
```bash
chmod +x synq.sh
```

## Usage

### Basic Syntax
```bash
./synq.sh <mode> [location]
```

### Modes

#### Push Mode
Scans a directory structure and creates a `repositories.yaml` file with all discovered repositories.

```bash
# Scan default location (~/Documents/code/github.com)
./synq.sh push

# Scan custom location
./synq.sh push /path/to/repositories
```

**What it does:**
- Scans the specified directory for organization folders
- Looks inside each organization for repository folders
- Creates `repositories.yaml` with the format:
  ```yaml
  repositories:
    - org1/repo1
    - org1/repo2
    - org2/repo3
  ```

#### Pull Mode
Clones all repositories listed in `repositories.yaml` to the specified location.

```bash
# Clone to default location (~/Documents/code/github.com)
./synq.sh pull

# Clone to custom location
./synq.sh pull /path/to/clone/repositories
```

**What it does:**
- Reads repositories from `repositories.yaml`
- Creates the directory structure: `location/org_name/repo_name`
- Clones repositories using HTTPS URLs
- Skips repositories that already exist
- Provides progress feedback and summary statistics

### Help
```bash
./synq.sh help
# or
./synq.sh
```

## Examples

### Complete Workflow

1. **Discover repositories** in your existing code directory:
```bash
./synq.sh push ~/Documents/code/github.com
```

2. **Clone all repositories** to a new location:
```bash
./synq.sh pull ~/Projects/backup
```

### Custom Scenarios

**Backup repositories to external drive:**
```bash
./synq.sh pull /Volumes/ExternalDrive/repos
```

**Sync repositories to a different machine:**
```bash
# On source machine
./synq.sh push

# Copy repositories.yaml to target machine
scp repositories.yaml user@target:/path/to/synq/

# On target machine
./synq.sh pull
```

## File Structure

```
synq/
├── synq.sh           # Main script
├── repositories.yaml # Generated repository list
└── README.md         # This file
```

## Output Examples

### Push Mode Output
```
Scanning directory: /Users/username/Documents/code/github.com
Scanning organization: featureinc
Scanning organization: qedgardo
Scanning organization: xlabs
Successfully updated repositories.yaml with repositories from /Users/username/Documents/code/github.com
Added 52 repositories
```

### Pull Mode Output
```
Cloning repositories to: /Users/username/Projects
Processing: featureinc/feature-platform-api
  📥 Cloning: https://github.com/featureinc/feature-platform-api.git
  ✓ Successfully cloned: featureinc/feature-platform-api
Processing: qedgardo/aptos-metrics-exporter
  ✓ Repository already exists, skipping: qedgardo/aptos-metrics-exporter

Clone operation completed!
Cloned: 45 repositories
Skipped: 7 repositories (already exist)
```

## Requirements

- Bash shell
- Git (for pull mode)
- Standard Unix utilities (find, grep, sed, cut)

## Configuration

### Default Locations
- **Default scan location**: `~/Documents/code/github.com`
- **Default clone location**: `~/Documents/code/github.com`
- **Repositories file**: `repositories.yaml` (in script directory)

### Customization
You can modify the default locations by editing the script variables:
```bash
DEFAULT_LOCATION="$HOME/Documents/code/github.com"
REPOSITORIES_FILE="repositories.yaml"
```

## Error Handling

The script includes error handling for:
- Missing directories
- Missing `repositories.yaml` file (for pull mode)
- Git clone failures
- Invalid modes
