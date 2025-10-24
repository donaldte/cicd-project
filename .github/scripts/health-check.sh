#!/bin/bash

set -e

echo "🏥 Starting health checks..."

MAX_RETRIES=30
RETRY_INTERVAL=10

for i in $(seq 1 $MAX_RETRIES); do
    echo "Health check attempt $i/$MAX_RETRIES..."
    
    if curl -f http://localhost/api/books/ > /dev/null 2>&1; then
        echo "✅ Health check passed!"
        exit 0
    fi
    
    sleep $RETRY_INTERVAL
done

echo "❌ Health check failed after $MAX_RETRIES attempts"
exit 1