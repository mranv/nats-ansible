#!/bin/bash

# Configuration
CERT_DIR="./certs"
DAYS_VALID=365
RSA_KEY_SIZE=2048
COUNTRY="IN"
STATE="GUJARAT"
LOCALITY="AHMEDABAD"
ORGANIZATION="Green Team"
ORGANIZATIONAL_UNIT="DevSecOps"
COMMON_NAME="nats.local"
EMAIL="anubhavg@infopercept.com"

# Create certificates directory
mkdir -p "$CERT_DIR"

# Generate CA private key and certificate
echo "Generating CA key and certificate..."
openssl req -x509 -new -newkey rsa:$RSA_KEY_SIZE -nodes \
    -keyout "$CERT_DIR/ca-key.pem" \
    -out "$CERT_DIR/ca.pem" \
    -days $DAYS_VALID \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"

# Generate server private key
echo "Generating server private key..."
openssl genrsa -out "$CERT_DIR/server-key.pem" $RSA_KEY_SIZE

# Generate server CSR
echo "Generating server CSR..."
openssl req -new \
    -key "$CERT_DIR/server-key.pem" \
    -out "$CERT_DIR/server.csr" \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$COMMON_NAME/emailAddress=$EMAIL"

# Create server certificate extensions file
cat > "$CERT_DIR/server-ext.cnf" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = nats.local
DNS.3 = *.nats.local
IP.1 = 127.0.0.1
EOF

# Generate server certificate
echo "Generating server certificate..."
openssl x509 -req \
    -in "$CERT_DIR/server.csr" \
    -CA "$CERT_DIR/ca.pem" \
    -CAkey "$CERT_DIR/ca-key.pem" \
    -CAcreateserial \
    -out "$CERT_DIR/server-cert.pem" \
    -days $DAYS_VALID \
    -extfile "$CERT_DIR/server-ext.cnf"

# Clean up temporary files
rm "$CERT_DIR/server.csr" "$CERT_DIR/server-ext.cnf" "$CERT_DIR/ca.srl"

# Set appropriate permissions
chmod 600 "$CERT_DIR/server-key.pem" "$CERT_DIR/ca-key.pem"
chmod 644 "$CERT_DIR/server-cert.pem" "$CERT_DIR/ca.pem"

echo "Certificate generation complete!"
echo "Generated files:"
echo "  - $CERT_DIR/ca.pem (CA certificate)"
echo "  - $CERT_DIR/server-cert.pem (Server certificate)"
echo "  - $CERT_DIR/server-key.pem (Server private key)"

# Verify certificates
echo -e "\nVerifying certificates..."
echo "CA certificate info:"
openssl x509 -in "$CERT_DIR/ca.pem" -noout -text | grep "Subject:"
echo -e "\nServer certificate info:"
openssl x509 -in "$CERT_DIR/server-cert.pem" -noout -text | grep "Subject:"