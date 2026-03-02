#!/usr/bin/env bash
set -e
# Ensure stripe-cli is installed
if ! command -v stripe > /dev/null; then
  echo "stripe CLI not found. Please install it." >&2
  exit 1
fi

# Create product
PRODUCT_ID=$(stripe products create \
  --name "Digital Guide" \
  --description "30-page revenue guide" \
  --default_price 0 \
  --currency usd \
  --type one_time \
  --output json | jq -r '.id')

# Create price (e.g., $9.99)
PRICE_ID=$(stripe prices create \
  --product $PRODUCT_ID \
  --unit_amount 999 \
  --currency usd \
  --output json | jq -r '.id')

# Create checkout session
SESSION_URL=$(stripe checkout sessions create \
  --payment_method_types card \
  --mode payment \
  --line_items "price=$PRICE_ID,quantity=1" \
  --success_url "https://example.com/success" \
  --cancel_url "https://example.com/cancel" \
  --output json | jq -r '.url')

# Update landing page
sed -i "s/{CHECKOUT_URL}/$SESSION_URL/g" landing.html

echo "Checkout session created: $SESSION_URL"
