---
type: guide
title: macOS
description: Toucan Installation Guide for macOS
category: installation
order: 1
---

# macOS
---

Toucan can be installed on macOS using the Brew or Mint package managers, or by compiling from source.

## Using Brew

It is possible to install Toucan using the Brew package manager.

### Prerequisites

Ensure the Brew package manager is installed and configured on your system. Brew is a popular package manager for macOS that simplifies the installation of software. For installation instructions, visit the [Brew homepage](https://brew.sh/).

### Installation Steps

Follow these steps to install Toucan using Brew.

#### Tap into the Binary Birds kegs

Open your terminal and run the command: 

```sh
brew tap binarybirds
```

This command adds the Binary Birds repository to your Brew configuration, allowing you to access their packages.

#### Install Toucan

After tapping into the Binary Birds kegs, install Toucan by running:

```sh

brew install binarybirds/toucan
```

This command fetches and installs the Toucan binary on your system. After installation, the Toucan executable will be available for use.

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
