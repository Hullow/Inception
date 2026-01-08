2) Pin WordPress version instead of latest.tar.gz
Edit wordpress-entrypoint.sh and replace the latest.tar.gz download with a versioned URL. Example:

# near top of the script
WP_VERSION="${WP_VERSION:-6.4.3}"
WP_TARBALL="/tmp/wordpress-${WP_VERSION}.tar.gz"

# replace the current download block
curl -fsSL "https://wordpress.org/wordpress-${WP_VERSION}.tar.gz" -o "$WP_TARBALL"
tar -xzf "$WP_TARBALL" -C /tmp
cp -r /tmp/wordpress/* "$WP_PATH"
rm -rf "$WP_TARBALL" /tmp/wordpress
Then add to srcs/.env:

WP_VERSION=6.4.3
Optional (stronger reproducibility): add a checksum and verify before extracting:

WP_SHA256="${WP_SHA256:-<sha256_here>}"
echo "${WP_SHA256}  $WP_TARBALL" | sha256sum -c -
