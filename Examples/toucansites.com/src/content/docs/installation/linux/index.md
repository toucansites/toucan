---
type: guide
title: Linux
description: Linux
category: installation
order: 2
---

# Linux
---

Toucan can be installed on Linux using the Mint package manager, or by compiling from source.

## Using Mint

It is possible to install Toucan using the Mint package manager.

### Prerequisites

Ensure the Mint package manager is installed and configured on your system. Mint is a Swift-based package manager that makes it easy to install and manage Swift command-line tools. For installation instructions, visit the [Mint GitHub page](https://github.com/yonaskolb/Mint).

### Installation Steps

Follow these steps to install Toucan using Mint.

#### Install Toucan

Open your terminal and run the command:

```sh
mint install binarybirds/toucan
```

This command installs the Toucan binary using Mint. Once the installation is complete, the Toucan executable will be ready to use.

## Compile from source

It is possible to install Toucan by compiling it from source.

### Prerequisites

Before installing Toucan, ensure Swift 5.10 or a later version is installed on your Linux distribution. Refer to the Swift [installation guide](https://swift.org/install/linux/#platforms) on [swift.org](https://swift.org) for detailed instructions on installing Swift.

### Installation Steps

Follow these steps to install Toucan by compiling it from source.

#### Clone the Toucan Repository

Open your terminal and run the following command to clone the Toucan repository from [GitHub](https://github.com/binarybirds/toucan):

```sh
git clone https://github.com/BinaryBirds/Toucan.git
```

This command will download the Toucan repository from GitHub to your local machine.

#### Navigate to the Toucan Directory

Change to the Toucan directory by running:

```sh
cd Toucan
```

This will set your current directory to the Toucan project directory.

#### Build Toucan

Compile Toucan in release mode by executing:

```sh
swift build -c release
```

This command will build the Toucan project, creating the necessary executable files.

#### Install Toucan

Install the compiled Toucan binary to /usr/local/bin:

```sh
install ./.build/release/toucan /usr/local/bin/toucan
```

This step places the Toucan executable in a directory included in your system’s PATH, making it easy to run.

## Verification

To verify that Toucan is installed correctly, run the following command:

```sh
which toucan
```

This should output the path to the toucan executable, confirming that the installation was successful.
