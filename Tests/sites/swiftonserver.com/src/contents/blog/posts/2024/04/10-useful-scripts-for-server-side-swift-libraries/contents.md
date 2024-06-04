---
slug: useful-scripts-for-server-side-swift-libraries
title: Useful scripts for server-side Swift libraries
description: Learn about shell scripts to enforce coding standards and conduct checks for backend Swift projects.
publication: 2024-04-10 18:30:00
tags: Swift, Shell, Scripts
author: Tibor Bödecs
authorLink: https://x.com/tiborbodecs
authorGithub: tib
authorAbout: Tibor, also known as <a href="https://theswiftdev.com">"The Swift Dev"</a>, is the co-founder of <a href="https://binarybirds.com/">Binary Birds Kft.</a> Tibor provides Server-Side Swift development and consulting.
cta: Contact us
ctaLink: mailto:info@binarybirds.com
company: Binary Birds Kft.
companyLink: https://binarybirds.com/
duration: 10 minutes
---

Several open-source server-side Swift projects include a scripts directory. These scripts are employed to conduct checks on the source code, utilizing a Swift code formatter / linter or similar tools. Even among the most popular repositories, the scripts unfortunately exhibit a noticeable level of inconsistency:

- [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator/tree/main/scripts)
- [SwiftNIO](https://github.com/apple/swift-nio/tree/main/scripts)
- [SwiftLog](https://github.com/apple/swift-log/tree/main/scripts)
- [Hummingbird](https://github.com/hummingbird-project/hummingbird/tree/main/scripts)
- [FeatherOpenAPIKit](https://github.com/feather-framework/feather-openapi-kit/tree/main/scripts)

Upon examining these repositories, it becomes evident that while some utilize the "soundness.sh" script to perform checks, others refer to the very same script as "validation.sh". Besides the differences in naming conventions, these bash scripts also contain slight variations. 

The aim of this article is to provide insight into common scripts that are implemented across a wide range of open-source server-side Swift repositories.

To begin, let's categorize the scripts based on their functionalities and purposes. This initial step will help us gain a clearer understanding of their roles within the repositories.

A potential naming convention could utilize the following prefixes:

- `check-xyz.sh` for conducting checks
- `generate-xyz.sh` for generating source code or resources
- `install-xyz.sh` for tool installation
- `run-xyz.sh` for executing tasks
- `test-xyz.sh` for testing functionalities

Now that we've categorized the scripts, let's go through each one, providing a detailed explanation of its functionality line by line. This will help to elucidate the purpose and operation of each script within its respective category.

## Check for broken symlinks

This script (`check-broken-symlinks.sh`) checks for broken symlinks within a Git repository.  If any broken symlinks are found, it prints an error message and exits with a non-zero status; otherwise, it prints a success message and exits normally.

```sh
#!/usr/bin/env bash
# 1.
set -euo pipefail

# 2.
log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

# 3.
CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

log "Checking for broken symlinks..."
NUM_BROKEN_SYMLINKS=0
# 4.
while read -r -d '' file; do
    # 5.
    if ! test -e "${REPO_ROOT}/${file}"; then
        error "Broken symlink: ${file}"
        ((NUM_BROKEN_SYMLINKS++))
    fi
done < <(git -C "${REPO_ROOT}" ls-files -z)

# 6.
if [ "${NUM_BROKEN_SYMLINKS}" -gt 0 ]; then
    fatal "❌ Found ${NUM_BROKEN_SYMLINKS} symlinks."
fi

log "✅ Found 0 symlinks."
```

1. Enhance script reliability by enforcing strict variables, error handling and pipeline behavior.
2. Definition of custom functions for managing logging and error handling.
3. Determine the directory where the script is located and the root directory of the repository.
4. Iterate over each file in the repository using the `git ls-files -z` command.
5. Check if the corresponding file exists in the repository, if not increment the counter.
6. If any broken symlinks were found, exit using fatal, otherwise print a success message.

This bash script can be used to automate the process of checking for broken symbolic links within a Git repository. 


## Check unacceptable language 

This Bash script (`check-unacceptable-language.sh`) uses unacceptable language patterns and proceeds to check for their presence within the repository using Git commands. If any files containing unacceptable language are found, it exits with an error message; otherwise, it logs a success message indicating no unacceptable language was found.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
UNACCEPTABLE_LANGUAGE_PATTERNS_PATH="${CURRENT_SCRIPT_DIR}/unacceptable-language.txt"

log "Checking for unacceptable language..."
# 2.
PATHS_WITH_UNACCEPTABLE_LANGUAGE=$(git -C "${REPO_ROOT}" grep \
  -l -F -w \
  -f "${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" \
  -- \
  ":(exclude)${UNACCEPTABLE_LANGUAGE_PATTERNS_PATH}" \
) || true | /usr/bin/paste -s -d " " -

# 3.
if [ -n "${PATHS_WITH_UNACCEPTABLE_LANGUAGE}" ]; then
  fatal "❌ Found unacceptable language in files: ${PATHS_WITH_UNACCEPTABLE_LANGUAGE}."
fi

log "✅ Found no unacceptable language."
```

1. Defines the path to the `unacceptable-language.txt` file, which contains all the words separated by a newline.
2. Check all the files within the repository, if it contains unacceptable words add it to the paths array.
3. If there's a file that contains unacceptable language, exit with a fatal error, otherwise print a success message.

A good starting point for the unacceptable language text file:

```
blacklist
whitelist
slave
master
sane
sanity
insane
insanity
kill
killed
killing
hang
hung
hanged
hanging
```

By searching through the repository's files, this script can automate the process of enforcing compliance with coding standards within the repository.


## Check local swift dependencies 

This script (`check-local-swift-dependencies.sh`) checks the `Package.swift` file in a Git repository to see if it contains references to local Swift packages.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
read -ra PATHS_TO_CHECK <<< "$( \
  git -C "${REPO_ROOT}" ls-files -z \
  "Package.swift" \
  | xargs -0 \
)"

# 2.
for FILE_PATH in "${PATHS_TO_CHECK[@]}"; do
echo $FILE_PATH
    if [[ $(grep ".package(path:" "${FILE_PATH}"|wc -l) -ne 0 ]] ; then
        fatal "❌ The '${FILE_PATH}' file contains local Swift package reference(s)."
    fi
done 

log "✅ Found 0 local Swift package dependency references."
```

1. Read the repository and detect `Package.swift` files.
2. Check if a Package.swift file contains local dependencies.

This becomes handy during the development of packages using local dependencies, as it guarantees that once changes are pushed to the repository, any remaining local development dependencies are removed.


## Install swift format 

The script (`install-swift-format.sh`) provided below installs [swift-format](https://github.com/apple/swift-format) with a predetermined version.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

# https://github.com/apple/swift-format
# 1. 
VERSION="509.0.0"

# 2.
curl -L -o "${VERSION}.tar.gz" "https://github.com/apple/swift-format/archive/refs/tags/${VERSION}.tar.gz"
tar -xf "${VERSION}.tar.gz"
# 3.
cd "swift-format-${VERSION}"
swift build -c release
# 4.
install .build/release/swift-format /usr/local/bin/swift-format
# 5.
cd ..
rm -f "${VERSION}.tar.gz"
rm -rf "swift-format-${VERSION}"
```

1. Define the desired swift-format version.
2. Download and extract the swift-format repository.
3. Build the swift-format executable 
4. Install the swift-format binary 
5. Cleanup unnecessary files and directories.


## Run swift-format 

The following script (`run-swift-format.sh`) executes `swift-format` to perform linting and fix potential code issues, enhancing code readability and adherence to established formatting standards.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
FORMAT_COMMAND=(lint --strict)
for arg in "$@"; do
  if [ "$arg" == "--fix" ]; then
    FORMAT_COMMAND=(format --in-place)
  fi
done

# 2. 
SWIFTFORMAT_BIN=${SWIFTFORMAT_BIN:-$(command -v swift-format)} || fatal "❌ SWIFTFORMAT_BIN unset and no swift-format on PATH"

# 3.
git -C "${REPO_ROOT}" ls-files -z '*.swift' \
    | grep -z -v \
    -e 'Sources/CoreOpenAPIRuntimeKit/Types.swift' \
    -e 'Package.swift' \
  | xargs -0 "${SWIFTFORMAT_BIN}" "${FORMAT_COMMAND[@]}" --parallel \
  && SWIFT_FORMAT_RC=$? || SWIFT_FORMAT_RC=$?

# 4.
if [ "${SWIFT_FORMAT_RC}" -ne 0 ]; then
  fatal "❌ Running swift-format produced errors.

  To fix, run the following command:

    % ./scripts/run-swift-format.sh --fix
  "
  exit "${SWIFT_FORMAT_RC}"
fi

log "✅ Ran swift-format with no errors."

```

1. If the --fix argument is provided, the formatting command is adjusted to perform in-place formatting.
2. Sets the variable `SWIFTFORMAT_BIN` to the path of the swift-format binary, if not found, the script will fail.
3. Run swift-format using all the files in the repository, excluding the listed ones. The result code of swift-format execution is stored in SWIFT_FORMAT_RC.
4. If swift-format encounters errors during execution, the script exits with a fatal error message.



## Run checks 

This script (`run-checks.sh`) executes all checks found in the scripts directory, and additionally runs the `run-swift-format.sh` script for supplementary checks.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 1.
NUM_CHECKS_FAILED=0

# 2.
SCRIPT_PATHS=(
  "${CURRENT_SCRIPT_DIR}/check-broken-symlinks.sh"
  "${CURRENT_SCRIPT_DIR}/check-unacceptable-language.sh"
  "${CURRENT_SCRIPT_DIR}/check-local-swift-dependencies.sh"
)

# 3.
for SCRIPT_PATH in "${SCRIPT_PATHS[@]}"; do
  log "Running ${SCRIPT_PATH}..."
  if ! bash "${SCRIPT_PATH}"; then
    ((NUM_CHECKS_FAILED+=1))
  fi
done

# 4. 
FIX_FORMAT=""
for arg in "$@"; do
  if [ "$arg" == "--fix" ]; then
    FIX_FORMAT="--fix"
  fi
done

# 5.
log "Running swift-format..."
bash "${CURRENT_SCRIPT_DIR}"/run-swift-format.sh $FIX_FORMAT > /dev/null
FORMAT_EXIT_CODE=$?
if [ $FORMAT_EXIT_CODE -ne 0 ]; then
  ((NUM_CHECKS_FAILED+=1))
fi

#6. 
if [ "${NUM_CHECKS_FAILED}" -gt 0 ]; then
  fatal "❌ ${NUM_CHECKS_FAILED} check(s) failed."
fi

log "✅ All check(s) passed."
```

1. Initializes a counter variable NUM_CHECKS_FAILED to track the number of failed checks.
2. Defines an array SCRIPT_PATHS containing paths to several scripts for performing different checks.
3. Executes each script in SCRIPT_PATHS, logging its execution and incrementing NUM_CHECKS_FAILED if it fails.
4. Parses command-line arguments to determine if the --fix flag is present for fixing formatting issues.
5. Runs a script for Swift code formatting, suppressing output (/dev/null), and updates NUM_CHECKS_FAILED if it fails.
6. Checks if any checks have failed and exits with an error message if so; otherwise, logs success.


## Generate contributors list 

This script (`generate-contributors-list.sh`) is designed to gather all contributors for a Git repository, producing a `CONTRIBUTORS.txt` file within the repository's root directory.

```sh
#!/usr/bin/env bash
set -euo pipefail

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
CONTRIBUTORS=$( cd "$CURRENT_SCRIPT_DIR"/.. && git shortlog -es | cut -f2 | sed 's/^/- /' )

# 2.
cat > "$REPO_ROOT/CONTRIBUTORS.txt" <<- EOF
	### Contributors

	$CONTRIBUTORS

	**Updating this list**

	Please do not edit this file manually. It is generated using \`bash ./scripts/generate-contributors-list.sh\`. 
	If a name is misspelled or appearing multiple times: add an entry in \`./.mailmap\`.
EOF
```

1. Gather the name and email address of all the contributors using `git shortlog -es`
2. Output the list of the contributors to the `CONTRIBUTORS.txt` file to the repo root.

If repeated names are found in the contributors file, they can be eliminated by utilizing a custom .mailmap file.

```
Tibor Bödecs <mail.tib@gmail.com> Tibor Bodecs <mail.tib@gmail.com>
```

The mailmap file follows the format: `name1 <email1> name2 <email2>`. This allows for overriding `name2` with `name1`.


## Check API breakage 

This script (`check-api-breakage.sh`) aims to identify API-breaking changes within a Swift package.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
git fetch -t 
LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))

# 2.
swift package diagnose-api-breaking-changes "$LATEST_TAG" 2>&1 > api-breakage-output.log || { 
    NUM=$(cat api-breakage-output.log|grep "💔"|wc -l)
    log "❌ Found ${NUM} API breakages."
    cat api-breakages.log
    exit 0;
}

log "✅ Found no API breakages."
```

1. Fetches all tags from the remote repository and determine the latest one.
2. Check for API-breaking changes since the latest tag. 

Despite any breaking changes detected by the `swift package diagnose-api-breaking-changes` command, this script will exit gracefully, and its output will be logged in the `api-breakage-output.log` file. The log file is a means to inform developers about any API-breaking changes.



## Run chmod 

This script (`run-chmod.sh`) ensures that the appropriate permissions are set on the scripts directory.


```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

chmod -R oug+x "${REPO_ROOT}/scripts/"
```

This Bash script ensures that all scripts within a Git repository are executable by adding execute permissions recursively.


## Install Swift OpenAPI generator (`install-swift-openapi-generator.sh`)

This script is designed to install the Swift OpenAPI generator tool onto your system.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

# https://github.com/apple/swift-openapi-generator
VERSION="1.2.1"

curl -L -o "${VERSION}.tar.gz" "https://github.com/apple/swift-openapi-generator/archive/refs/tags/${VERSION}.tar.gz"
tar -xf "${VERSION}.tar.gz"
cd "swift-openapi-generator-${VERSION}"
swift build -c release
install .build/release/swift-openapi-generator /usr/local/bin/swift-openapi-generator
cd ..
rm -f "${VERSION}.tar.gz"
rm -rf "swift-openapi-generator-${VERSION}"
```

After running this script, the `swift-openapi-generator` command will be available for use.


## Check OpenAPI security 

This script (`check-openapi-security.sh`) employs the [OWASP ZAP security tool](https://hub.docker.com/r/owasp/zap2docker-weekly/) to scan the OpenAPI YAML file for possible vulnerabilities.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
OPENAPI_YAML_LOCATION="${REPO_ROOT}/openapi";

# 2.
docker run --rm --name "openapi-security-check" \
    -v "${OPENAPI_YAML_LOCATION}:/app" \
    -t owasp/zap2docker-weekly zap-api-scan.py \
    -t /app/openapi.yaml -f openapi
```

1. Define the location of the OpenAPI YAML file within the repository.
2. Use a Docker container to scan the OpenAPI YAML file for potential vulnerabilities.



## Check OpenAPI validation 

This script (`check-openapi-validation.sh`) utilizes the [OpenAPI spec validator](https://pypi.org/project/openapi-spec-validator/) to validate the OpenAPI YAML file.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
OPENAPI_YAML_LOCATION="${REPO_ROOT}/openapi";

# 2.
docker run --rm --name "openapi-validate" \
    -v "${OPENAPI_YAML_LOCATION}/openapi.yaml:/openapi.yaml" \
    pythonopenapi/openapi-spec-validator /openapi.yaml
```

1. Define the location of the OpenAPI YAML file within the repository.
2. Use a Docker container to validate the OpenAPI YAML file.


## Run OpenAPI server

This script (`run-openapi-server.sh`) can be used to quickly host a web service to preview an OpenAPI YAML file using the [SwaggerUI](https://github.com/swagger-api/swagger-ui) library.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
OPENAPI_YAML_LOCATION="${REPO_ROOT}/openapi/";

# 2.
docker run --rm --name "openapi-server" \
    -v "${OPENAPI_YAML_LOCATION}:/usr/share/nginx/html" \
    -p 8888:80 nginx
```

1. Define the location of the OpenAPI YAML file within the repository.
2. Use a Docker container to start nginx using the 8888 port.

The `openapi` directory should contain both the `openapi.yaml` file and the `index.html` file with the following contents:

```html
<!DOCTYPE html>
<html>
<head>
    <title>OpenAPI</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.12.0/swagger-ui.min.css" rel="stylesheet">
</head>

<body onload="render()">
    <div id="swagger-ui"></div>
    <script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.12.0/swagger-ui-bundle.min.js"></script>
    <script>
        function render() {
            var ui = SwaggerUIBundle({
                url:  `/openapi.yaml`,
                dom_id: '#swagger-ui',
                docExpansion: 'none',
                presets: [
                    SwaggerUIBundle.presets.apis,
                    SwaggerUIBundle.SwaggerUIStandalonePreset
                ]
            });
        }
    </script>
</body>
</html>
```

Once the script has been executed, the Swagger UI services should be accessible via the [http://localhost:8888/](http://localhost:8888/) address.


## Check DocC warnings 

This script (`check-docc-warnings.sh`) builds the DocC documentation and checks for potential issues within it:

```sh
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
log "Checking required environment variables..."
test -n "${DOCC_TARGET:-}" || fatal "DOCC_TARGET unset"

# 2.
swift package --package-path "${REPO_ROOT}" plugin generate-documentation \
  --product "${DOCC_TARGET}" \
  --analyze \
  --level detailed \
  --warnings-as-errors \
  && DOCC_PLUGIN_RC=$? || DOCC_PLUGIN_RC=$?

# 3.
if [ "${DOCC_PLUGIN_RC}" -ne 0 ]; then
  fatal "❌ Generating documentation produced warnings and/or errors."
  exit "${DOCC_PLUGIN_RC}"
fi

log "✅ Generated documentation with no warnings."
```

1. The DocC target should be provided as an environment variable (`DOCC_TARGET`).
2. The Swift package manager analyzes the documentation and saves the error output.
3. If there were any issues with the documentation, display the errors.


## Check license headers 

This script (`check-license-headers.sh`) enables developers to verify license headers across project files. Additionally, it offers the capability to generate a diff file for patching all files, thereby ensuring uniform license headers throughout the project.

```sh
#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

CURRENT_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git -C "${CURRENT_SCRIPT_DIR}" rev-parse --show-toplevel)"

# 1.
HEADER_TEMPLATE=$(cat $CURRENT_SCRIPT_DIR/license-header.txt)
AUTHOR="Binary Birds Kft"
YEAR=$(date +%Y)

PATHS_WITH_INVALID_HEADER=( )

# 2.
read -ra PATHS_TO_CHECK_FOR_LICENSE <<< "$( \
    git -C "${REPO_ROOT}" ls-files -z \
        ":(exclude).*" \
        ":(exclude)*.txt" \
        ":(exclude)*.sh" \
        ":(exclude)*.html" \
        ":(exclude)*.yaml" \
        ":(exclude)Package.swift" \
  | xargs -0 \
)"

for FILE_PATH in "${PATHS_TO_CHECK_FOR_LICENSE[@]}"; do
    # 3.
    FILE_BASENAME=$(basename -- "${FILE_PATH}")
    FILE_EXTENSION="${FILE_BASENAME##*.}"

    # 4.
    case "${FILE_EXTENSION}" in
        swift) EXPECTED_HEADER=$(sed -e 's|@@|//|g' <<<"${HEADER_TEMPLATE}") ;;
        yml) EXPECTED_HEADER=$(sed -e 's|@@|##|g' <<<"${HEADER_TEMPLATE}") ;;
        sh) EXPECTED_HEADER=$(cat <(echo '#!/usr/bin/env bash') <(sed -e 's|@@|##|g' <<<"${HEADER_TEMPLATE}")) ;;
        *) fatal "Unsupported file extension for file (exclude or update this script): ${FILE_PATH}" ;;
    esac

    # 5.
    EXPECTED_HEADER=$(sed "s/{FILE}/${FILE_BASENAME}/" <<< "${EXPECTED_HEADER}")
    EXPECTED_HEADER=$(sed "s/{AUTHOR}/$AUTHOR/" <<< "${EXPECTED_HEADER}")
    EXPECTED_HEADER=$(sed "s/{YEAR}/$YEAR/" <<< "${EXPECTED_HEADER}")
    
    # 6.
    EXPECTED_HEADER_LINECOUNT=$(wc -l <<<"${EXPECTED_HEADER}")
    FILE_HEADER=$(head -n "${EXPECTED_HEADER_LINECOUNT}" "${FILE_PATH}")

    # 7.
    if ! diff -u \
        --label "Expected header" <(echo "${FILE_HEADER}") \
        --label "${FILE_PATH}" <(echo "${EXPECTED_HEADER}")
    then
        PATHS_WITH_INVALID_HEADER+=("${FILE_PATH} ")
    fi
done

# 8.
if [ "${#PATHS_WITH_INVALID_HEADER[@]}" -gt 0 ]; then
    fatal "❌ Found invalid license header in files: ${PATHS_WITH_INVALID_HEADER[*]}."
fi

log "✅ Found no files with invalid license header."
```

1. Define the location of the external header template file, an author, and the current year as variables.
2. Obtain all files for license header checks, excluding some using specified patterns.
3. Store the basename and extension of the file as variables for later use.
4. Replace `@@` characters according to the file type to ensure proper documentation comments for the license.
5. Replace the `{FILE}`, `{AUTHOR}`, and `{YEAR}` variables in the header template.
6. Retrieve the original license file header based on the line count of the expected header.
7. Check if the expected license header matches the file header and collect any differences.
8. If there are invalid or missing license headers, return with an error.


The diff command, within the _check-license-headers_ script can create a patch file, and it can be applied using the following command:

```sh
./scripts/check-license-headers.sh > license.patch
patch -s -p0 < license.patch 
```

This script ensures that all project files maintain a uniform license header, and it simplifies the process of identifying and resolving any issues using the patch command.

## Conclusion

Shell scripts are helpful tools in a developer's job of maintaining a codebase. Through automated checks, you can ensure that standards are adhered to. Scripts can hook into any tool, and are used for running tests and gathering code coverage. In an upcoming article, we'll explore how to set up GitHub Actions to execute these scripts.
