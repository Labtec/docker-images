#!/usr/local/bin/bash

set -ex

RUBY_VERSION=${RUBY_VERSION-2.6.0}
RUBY_MAJOR=$(echo $RUBY_VERSION | sed -E 's/\.[0-9]+(-.*)?$//g')
RUBYGEMS_VERSION=${RUBYGEMS_VERSION-3.2.3}
PREFIX=${PREFIX-/usr/local}

function get_released_ruby() {
  git clone --depth 1 https://github.com/ruby/www.ruby-lang.org.git /tmp/www

  cat << RUBY | ruby - $1 /tmp/www/_data/releases.yml
require "psych"
version = ARGV[0]
if Psych.respond_to?(:safe_load_file)
  require "date"
  releases = Psych.safe_load_file(ARGV[1], permitted_classes: [Symbol, Date])
else
  releases = Psych.load_file(ARGV[1])
end
release = releases.find {|x| x["version"] == version }
puts "#{release["url"]["xz"]} #{release["sha256"]["xz"]}"
RUBY
  rm -rf /tmp/www
}

case $RUBY_VERSION in
  master)
    RUBY_MASTER_COMMIT=
    ;;
  master:*)
    RUBY_MASTER_COMMIT=$(echo $RUBY_VERSION | awk -F: '{print $2}' )
    RUBY_VERSION=master
    ;;
  *)
    read RUBY_DOWNLOAD_URI RUBY_DOWNLOAD_SHA256 < <(get_released_ruby $RUBY_VERSION)
    if test -z "$RUBY_DOWNLOAD_URI"; then
      echo "Unsupported RUBY_VERSION ($RUBY_VERSION)" >2
      exit 1
    fi
    echo $RUBY_DOWNLOAD_URI
    echo $RUBY_DOWNLOAD_SHA256
    ;;
esac

case $RUBY_VERSION in
  2.3.*)
    # Need to down grade openssl to 1.1.x for Ruby 2.3.x
    pkg install -y openssl111
    ;;
esac

if test -n "$RUBY_MASTER_COMMIT"; then
  if test -f /usr/local/src/ruby/configure.ac; then
    cd /usr/local/src/ruby
    git pull --rebase origin
  else
    rm -r /usr/local/src/ruby
    git clone https://github.com/ruby/ruby.git /usr/local/src/ruby
    cd /usr/local/src/ruby
  fi
  git checkout $RUBY_MASTER_COMMIT
else
  if test -z "$RUBY_DOWNLOAD_URI"; then
    RUBY_DOWNLOAD_URI="https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.xz"
  fi
  wget -O ruby.tar.xz $RUBY_DOWNLOAD_URI
  echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c -
  mkdir -p /usr/local/src/ruby
  tar -xJf ruby.tar.xz -C /usr/local/src/ruby --strip-components=1
  rm ruby.tar.xz
fi

(
  cd /usr/local/src/ruby

  if test ! -x ./configure; then
    if test -x ./autogen.sh; then
      ./autogen.sh
    else
      autoconf
    fi
  fi

  mkdir -p /tmp/ruby-build
  pushd /tmp/ruby-build

  configure_args=( \
    --prefix="$PREFIX" \
    --disable-install-doc \
    --enable-shared \
    --enable-yjit
  )

  if [ -n "$cppflags" ]; then
    export cppflags=$cppflags
  else
    unset cppflags
  fi

  if [ -n "$optflags" ]; then
    export optflags=$optflags
  else
    unset optflags
  fi

  if [ -n "$debugflags" ]; then
    export debugflags=$debugflags
  else
    unset debugflags
  fi

  /usr/local/src/ruby/configure "${configure_args[@]}" || {
    cat config.log | grep flags=
    exit 1
  }

  make -j "$(nproc)"
  make install

  popd
  rm -rf /tmp/ruby-build
)

rm -fr /usr/local/src/ruby /root/.gem/

# rough smoke test
export PATH=$PREFIX/bin:$PATH
(cd && ruby --version && gem --version && bundle --version)
