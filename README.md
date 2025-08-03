# ClientCli - Command-Line Client Management Tool

A Ruby command-line application for searching and managing client data from JSON datasets.

## Features

- Search any field in JSON data with partial matching, case-insensitive
- Find duplicates in any field
- Works with any JSON file structure
- Choose default or custom data files
- Handles invalid data and edge cases
- Use rspec for testing

## Setup and Installation

### Prerequisites

- Ruby 3.2.2 or higher
- No additional gems required (uses only Ruby standard library)
- RSpec gem for running tests (install with `gem install rspec`)

### Installation

1. Clone or download this repository
2. Make the executable script runnable:
   ```bash
   chmod +x bin/client_cli
   ```

### Usage

#### Interactive Mode

Simply run the command without arguments for an interactive menu:

```bash
./bin/client_cli

# This will show:
# ClientCli - Client Data Management Tool
# =========================================
# 
# Data file options:
# 1. Use default file (data/clients.json)
# 2. Specify custom file
#
# Enter your choice (1-2):
#
# What would you like to do?
# 1. Search records
# 2. Find duplicates  
# 3. Exit
#
# Enter your choice (1-3):
```

#### Command Line Mode

Or use direct commands:

#### Dynamic Field Search

```bash
# Search by full_name (default field)
./bin/client_cli search full_name john

# Search by email
./bin/client_cli search email gmail

# Using custom data file
./bin/client_cli search full_name "john" --file path/to/custom_data.json
```

#### Dynamic Duplicate Detection

```bash
# Find duplicate emails (default field)
./bin/client_cli duplicates email

# Find duplicate names
./bin/client_cli duplicates full_name

# Using custom data file
./bin/client_cli duplicates email --file path/to/custom_data.json
```

### Data Format

The application expects JSON data in the following format:

```json
[
  {
    "id": 1,
    "full_name": "John Doe",
    "email": "john.doe@example.com"
  },
  {
    "id": 2,
    "full_name": "Jane Smith",
    "email": "jane.smith@example.com"
  }
]
```

## Testing

Run the test suite using RSpec:

```bash
# Install RSpec if not already installed
gem install rspec

# Run all tests
rspec spec/client_cli_spec.rb
```

### Design Principles

1. **Separation of Concerns**: Each class has a single responsibility
   - `ClientManager`: Logic for the query and data operations
   - `CLI`: User interface and command parsing

2. **Error Handling**: Comprehensive error handling with meaningful messages
   - File not found errors
   - JSON parsing errors
   - Data validation errors

### Key Assumptions
- Assumed to have json array
- Only partial matching on full_name

### Known Limitations
- Only search by single field, cannot search by both field on the same request
