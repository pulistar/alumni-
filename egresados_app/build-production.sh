#!/bin/bash
# Script para build de producción con variables de entorno
# Uso: ./build-production.sh

echo "🚀 Building Alumni UCC for Production..."
echo ""

# Variables de entorno (CAMBIAR ESTOS VALORES)
SUPABASE_URL="https://cqumdqgrcbrqlrmsfswg.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxdW1kcWdyY2JycWxybXNmc3dnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MzQ4MDksImV4cCI6MjA3OTUxMDgwOX0.x4Nl5UyU135Ez8o5JGOCHl_je0PApwcLC82apwJP40A"
API_BASE_URL="https://aditya-pedimented-adela.ngrok-free.dev/api"  # CAMBIAR A URL DE PRODUCCIÓN

echo "📋 Configuration:"
echo "  Supabase URL: $SUPABASE_URL"
echo "  API URL: $API_BASE_URL"
echo ""

# Limpiar build anterior
echo "🧹 Cleaning previous build..."
flutter clean
flutter pub get

# Ejecutar tests
echo ""
echo "🧪 Running tests..."
flutter test test/unit/utils/validators_test.dart test/widget/widgets/custom_button_test.dart

if [ $? -ne 0 ]; then
    echo "❌ Tests failed! Fix tests before building for production."
    exit 1
fi

echo "✅ Tests passed!"

# Build APK
echo ""
echo "📦 Building APK..."

flutter build apk --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=API_BASE_URL=$API_BASE_URL

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📱 APK location:"
    echo "  build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📊 APK size:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print "  " $5}'
    echo ""
    echo "🚀 Next steps:"
    echo "  1. Test APK on physical device"
    echo "  2. Upload to Firebase App Distribution"
    echo "  3. Invite testers"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi
