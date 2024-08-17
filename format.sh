#!/bin/bash
set -e

# Local variables
if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
  project_root="$(git rev-parse --show-toplevel)"
else
  project_root="$(pwd)"
fi

# Functions
ok() {
  printf "\e[32mok\e[0m\n"
}

header() {
  printf "\e[34mFormat \e[36m%s\e[34m files with '%s'...\e[0m" "$1" "$2"
}

line() {
  # print horizontal line
  printf "\e[34m%s\e[0m\n" "----------------------------------------"
}

skip() {
  printf "\e[33mskip\e[0m\n"
}

append_if_exists() {
  if [ -d "${project_root}/$1" ]; then
    printf "%s/%s" "$project_root" "$1"
  else
    printf "%s" "$project_root"
  fi
}

shell_root=$(append_if_exists "scripts")
cpp_root=$(append_if_exists "src")
python_root=$(append_if_exists "src")
latex_root="$project_root"

# Print project root
line
printf "Shell scripts root: %s\n" "$shell_root"
printf "C++ code root: %s\n" "$cpp_root"
printf "Python code root: %s\n" "$python_root"
printf "Latex code root: %s\n" "$latex_root"
line

# Count files
n_shell="$(find "$shell_root" -name "*.sh" | wc -l)"
n_cpp="$(find "$cpp_root" -name "*.cpp" -o -name "*.h" | wc -l)"
n_python="$(find "$python_root" -name "*.py" | wc -l)"
n_latex="$(find "$latex_root" -name "*.tex" | wc -l)"

# Format: shfmt
header "$n_shell" "shfmt"
if [ "$n_shell" -gt 0 ]; then
  find "$shell_root" -name "*.sh" -print0 | xargs -0 shfmt -w -l -s -d
  ok
else
  skip
fi

# Format: clang-format
header "$n_cpp" "clang-format"
if [ "$n_cpp" -gt 0 ]; then
  clang-format -q -i -style=Google "$cpp_root"
  ok
else
  skip
fi

# Format: black
header "$n_python" "black"
if [ "$n_python" -gt 0 ]; then
  black --quiet "$python_root"
else
  skip
fi

# Format: latex
header "$n_latex" "latex"
if [ "$n_latex" -gt 0 ]; then
  find "$latex_root" -name "*.tex" -print0 | xargs -0 \
    latexindent -s -w -m -l /etc/configs/latexindent.yaml
else
  skip
fi

# Change ownership
chown -R ${UID}:${UID} "$project_root"
