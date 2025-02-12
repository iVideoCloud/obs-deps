autoload -Uz log_debug log_error log_info log_status log_output

## Dependency Information
local name='jansson'
local version='2.14'
local url='https://github.com/akheron/jansson/releases/download/v2.14/jansson-2.14.tar.gz'
local hash="${0:a:h}/checksums/jansson-2.14.tar.gz.sha256"

## Build Steps
setup() {
  log_info "Setup (%F{3}${target}%f)"
  setup_dep ${url} ${hash}
}

clean() {
  cd "${dir}"

  if [[ ${clean_build} -gt 0 && -d "build_${arch}" ]] {
    log_info "Clean build directory (%F{3}${target}%f)"

    rm -rf "build_${arch}"
  }
}

config() {
  autoload -Uz mkcd progress

  log_info "Config (%F{3}${target}%f)"

  local _onoff=(OFF ON)

  args=(
    ${cmake_flags}
    -DJANSSON_EXAMPLES=OFF
    -DJANSSON_BUILD_DOCS=OFF
    -DJANSSON_BUILD_SHARED_LIBS="${_onoff[(( shared_libs + 1 ))]}"
  )

  cd "${dir}"
  log_debug "CMake configure args: ${args}'"
  progress cmake -S . -B "build_${arch}" -G Ninja ${args}
}

build() {
  autoload -Uz mkcd

  log_info "Build (%F{3}${target}%f)"

  cd "${dir}"
  cmake --build "build_${arch}" --config "${config}"
}

install() {
  autoload -Uz progress

  log_info "Install (%F{3}${target}%f)"

  args=(
    --install "build_${arch}"
    --config "${config}"
  )

  if [[ "${config}" =~ "Release|MinSizeRel" ]] args+=(--strip)

  cd "${dir}"
  progress cmake ${args}
}

fixup() {
  cd "${dir}"

  case ${target} {
    macos*)
      if (( shared_libs )) {
        log_info "Fixup (%F{3}${target}%f)"
        pushd "${target_config[output_dir]}"/lib
        if [[ -h libjansson.dylib ]] {
          rm libjansson.dylib
          ln -s libjansson.*.dylib(.) libjansson.dylib
        }
        popd
      }
      ;;
  }
}
