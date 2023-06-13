#Ignore this
#!/bin/bash

# Define the PHP version
PHP_VERSION="php-8.1.8"

# Define the directory for the PHP source
SOURCE_DIR="/usr/local/src"

# Define the directory for the RPM build
RPMBUILD_DIR="/usr/local/rpmbuild"

# Install the required development libraries and RPM building tools
dnf install -y curl-devel freetype-devel gd-devel libicu-devel libjpeg-devel libpng-devel libxml2-devel libxslt-devel postgresql-devel openssl-devel pcre-devel rpm-build rpmdevtools dnf-utils createrepo mock

# Check if the installation was successful
if [ $? -ne 0 ]; then
 echo "Failed to install required packages. Exiting."
 exit 1
fi

# Download the PHP source code
wget -O ${SOURCE_DIR}/${PHP_VERSION}.tar.gz https://www.php.net/distributions/${PHP_VERSION}.tar.gz

# Check if the download was successful
if [ $? -ne 0 ]; then
 echo "Failed to download PHP source code. Exiting."
 exit 1
fi

# Extract the source code
tar -zxvf ${SOURCE_DIR}/${PHP_VERSION}.tar.gz -C ${SOURCE_DIR}

# Check if the extraction was successful
if [ $? -ne 0 ]; then
 echo "Failed to extract PHP source code. Exiting."
 exit 1
fi

# Go to the PHP source directory
cd ${SOURCE_DIR}/${PHP_VERSION}

# Prepare the PHP configuration
./configure --prefix=/usr --with-config-file-path=/etc --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --disable-short-tags --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --with-openssl --with-pcre-regex --with-zlib --with-curl --enable-exif --enable-ftp --with-gd --enable-intl --with-mysqli --enable-opcache --with-pdo-mysql --with-pdo-sqlite --enable-soap --enable-wddx --with-xmlrpc --enable-zip --disable-mbstring

# Check if the configuration was successful
if [ $? -ne 0 ]; then
 echo "Failed to configure PHP. Exiting."
 exit 1
fi

# Compile PHP
make

# Check if the compilation was successful
if [ $? -ne 0 ]; then
 echo "Failed to compile PHP. Exiting."
 exit 1
fi

# Install PHP
make install

# Check if the installation was successful
if [ $? -ne 0 ]; then
 echo "Failed to install PHP. Exiting."
 exit 1
fi

# Create the RPM build environment
mkdir -p ${RPMBUILD_DIR}/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
echo "%_topdir ${RPMBUILD_DIR}" > ~/.rpmmacros

# Copy the PHP source code to the SOURCES directory
cp ${SOURCE_DIR}/${PHP_VERSION}.tar.gz ${RPMBUILD_DIR}/SOURCES/

# Create a basic spec file
cat > ${RPMBUILD_DIR}/SPECS/php.spec <<EOF
Summary: PHP is a popular general-purpose scripting language that is especially suited to web development.
Name: php
Version: 8.1.8
Release: 1%{?dist}
License: PHP
Group: Development/Languages
Source: ${PHP_VERSION}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
EOF
