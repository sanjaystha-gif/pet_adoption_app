#!/bin/bash
# Test script to verify backend API is working
# Run this in terminal: bash test_api.sh

BASE_URL="http://localhost:5000/api/v1"

echo "🔍 Testing Pet Adoption App API"
echo "================================"
echo ""

# Test 1: Check if backend is accessible
echo "1️⃣  Testing base server connectivity..."
if curl -s -o /dev/null -w "%{http_code}" "$BASE_URL" 2>&1 | grep -q "000"; then
    echo "❌ Cannot reach backend at $BASE_URL"
    echo "   Make sure backend is running on port 5000"
    exit 1
else
    echo "✅ Backend server is accessible"
fi

echo ""

# Test 2: Test login endpoint
echo "2️⃣  Testing /auth/login endpoint..."
RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}')

echo "Response: $RESPONSE"
echo ""

# Test 3: Test register endpoint
echo "3️⃣  Testing /auth/register endpoint..."
RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName":"John",
    "lastName":"Doe",
    "email":"john@test.com",
    "password":"password123",
    "phoneNumber":"1234567890",
    "address":"123 Main St"
  }')

echo "Response: $RESPONSE"
echo ""

echo "================================"
echo "API Test Complete!"
